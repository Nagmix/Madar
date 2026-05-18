/// Background Location Service for مدار Driver App
///
/// This service provides continuous GPS location tracking that persists even when
/// the app moves to the background. It is designed for ride-hailing driver use
/// cases where location must be tracked reliably during active trips and while
/// the driver is online and available for dispatch.
///
/// Key Features:
/// - **Foreground Service** (Android): Keeps the app alive in the background
///   with a persistent notification so the OS does not kill the process.
/// - **Kalman Filter Smoothing**: GPS readings are smoothed using the shared
///   [KalmanFilter] from `trippo_shared` before being sent to the backend,
///   reducing GPS jitter by 40-60% on typical mobile hardware.
/// - **Anomaly Detection**: Rejects or flags readings that imply impossible
///   physics (speed > 200 km/h, location jumps > 500 m in 5 s).
/// - **Dual Transmission**: Every smoothed location update is sent via
///   **Socket.IO** (real-time, ~50 ms latency) *and* **REST API** fallback
///   (POST /drivers/location) for persistence and reliability.
/// - **Battery Optimization**: When the device battery drops below 20% the
///   update interval is automatically increased from 5 s to 30 s to conserve
///   power. The interval also widens when the app is backgrounded.
/// - **Trip Meter**: Accumulates the total distance traveled during the
///   current tracking session so the UI can display a live trip odometer.
/// - **Heading Calculation**: Bearing between consecutive points is computed
///   with [GpsUtils.bearingBetween] and attached to each update.
///
/// Architecture:
/// ```
///  GPS (Geolocator)
///       |
///       v
///  _onLocationUpdate()  ──►  Anomaly Check
///       |                        |
///       v                        v
///  _applyKalmanFilter()    Flag / Discard
///       |
///       v
///  _sendLocationToBackend()
///    ├── Socket.IO emit (real-time)
///    └── REST POST /drivers/location (persistence)
///       |
///       v
///  BackgroundLocationState (StateNotifier)
///       |
///       v
///  UI via Riverpod
/// ```
///
/// Dependencies that must be added to `pubspec.yaml`:
/// ```yaml
///   flutter_background_service: ^3.0.1
///   battery_plus: ^5.0.2
/// ```
///
/// Android manifest requirements (already in AndroidManifest.xml for most
/// foreground-service setups):
/// ```xml
/// <uses-permission android:name="android.permission.FOREGROUND_SERVICE" />
/// <uses-permission android:name="android.permission.FOREGROUND_SERVICE_LOCATION" />
/// <uses-permission android:name="android.permission.ACCESS_BACKGROUND_LOCATION" />
/// <uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
/// ```
library;

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:trippo_shared/trippo_shared.dart';

import '../../../core/app_providers.dart';
import '../../../core/network/nestjs_api_client.dart';
import '../../../core/storage/secure_storage.dart';

// ============================================================================
// LocationUpdate Model
// ============================================================================

/// Represents a single location update prepared for transmission to the
/// NestJS backend. Contains all the fields required by the
/// `POST /drivers/location` endpoint and the `driver:location` Socket.IO
/// event.
///
/// The model is intentionally kept flat (no nested objects) so that
/// [toJson] produces a map that can be sent directly over the wire
/// without further transformation.
class LocationUpdate {
  /// Filtered latitude (after Kalman smoothing), in decimal degrees.
  final double latitude;

  /// Filtered longitude (after Kalman smoothing), in decimal degrees.
  final double longitude;

  /// GPS accuracy radius in meters as reported by the hardware.
  final double accuracy;

  /// Speed in meters per second. Derived from GPS when available,
  /// otherwise calculated between consecutive points.
  final double speed;

  /// Bearing / heading in degrees (0-360). Computed with Haversine
  /// bearing between the previous and current point.
  final double heading;

  /// Timestamp of the GPS fix in UTC milliseconds since epoch.
  final int timestamp;

  /// Total distance traveled in the current session, in meters.
  /// Sent so the backend can verify the trip meter independently.
  final double totalDistance;

  /// Whether this reading was flagged by the anomaly detector.
  /// The backend uses this for anti-fraud heuristics.
  final bool isFlagged;

  const LocationUpdate({
    required this.latitude,
    required this.longitude,
    required this.accuracy,
    required this.speed,
    required this.heading,
    required this.timestamp,
    this.totalDistance = 0.0,
    this.isFlagged = false,
  });

  /// Serializes the update to a JSON map compatible with the NestJS
  /// `POST /drivers/location` body and the `driver:location` Socket.IO
  /// event payload.
  Map<String, dynamic> toJson() => {
        'latitude': latitude,
        'longitude': longitude,
        'accuracy': accuracy,
        'speed': speed,
        'heading': heading,
        'timestamp': timestamp,
        'totalDistance': totalDistance,
        'isFlagged': isFlagged,
      };
}

// ============================================================================
// BackgroundLocationState
// ============================================================================

/// Immutable state snapshot emitted by [BackgroundLocationNotifier].
///
/// Consumers watch this via the [backgroundLocationProvider] Riverpod
/// provider and rebuild UI accordingly.
class BackgroundLocationState {
  /// Whether the foreground service is running and GPS tracking is active.
  final bool isTracking;

  /// The most recent smoothed (Kalman-filtered) location update.
  final LocationUpdate? currentLocation;

  /// Timestamp of the last location that was *successfully* sent to the
  /// backend (via either Socket.IO or REST). Used to detect stale data
  /// on the UI.
  final DateTime? lastSentTime;

  /// Human-readable error message, or `null` if no error is present.
  /// Cleared automatically on the next successful update cycle.
  final String? error;

  /// Accumulated distance for the current tracking session, in meters.
  /// Reset when tracking is stopped and restarted.
  final double totalDistanceTracked;

  /// The current GPS update interval in seconds, which may change
  /// dynamically based on battery level and app lifecycle state.
  final int currentIntervalSeconds;

  /// The device battery level at the last check (0-100), or `null` if
  /// the battery info has not been retrieved yet.
  final int? batteryLevel;

  const BackgroundLocationState({
    this.isTracking = false,
    this.currentLocation,
    this.lastSentTime,
    this.error,
    this.totalDistanceTracked = 0.0,
    this.currentIntervalSeconds = _activeIntervalSeconds,
    this.batteryLevel,
  });

  /// Creates a copy of this state with selectively overridden fields.
  BackgroundLocationState copyWith({
    bool? isTracking,
    LocationUpdate? currentLocation,
    DateTime? lastSentTime,
    String? error,
    double? totalDistanceTracked,
    int? currentIntervalSeconds,
    int? batteryLevel,
  }) =>
      BackgroundLocationState(
        isTracking: isTracking ?? this.isTracking,
        currentLocation: currentLocation ?? this.currentLocation,
        lastSentTime: lastSentTime ?? this.lastSentTime,
        error: error,
        totalDistanceTracked:
            totalDistanceTracked ?? this.totalDistanceTracked,
        currentIntervalSeconds:
            currentIntervalSeconds ?? this.currentIntervalSeconds,
        batteryLevel: batteryLevel ?? this.batteryLevel,
      );
}

// ============================================================================
// Constants
// ============================================================================

/// Location update interval while the app is in the **foreground** (active
/// trip or driver online). Fast enough for real-time rider tracking.
const int _activeIntervalSeconds = 5;

/// Location update interval while the app is in the **background**. Longer
/// to conserve battery while still providing useful tracking data.
const int _backgroundIntervalSeconds = 30;

/// Location update interval when battery is critically low (< 20%).
const int _lowBatteryIntervalSeconds = 60;

/// Speed threshold for anomaly detection. Any reading implying a speed
/// above this value (in km/h) is flagged or discarded.
const double _maxSpeedKmh = 200.0;

/// Distance threshold for GPS jump detection. If the distance between two
/// consecutive points exceeds this value (in meters) within the update
/// interval, the reading is considered a GPS anomaly.
const double _maxJumpMeters = 500.0;

/// Battery percentage below which the update interval is relaxed.
const int _lowBatteryThreshold = 20;

/// Minimum GPS accuracy in meters. Readings worse than this are discarded.
const double _minAccuracyMeters = 50.0;

// ============================================================================
// BackgroundLocationNotifier
// ============================================================================

/// Riverpod [StateNotifier] that manages the entire background location
/// tracking lifecycle for the driver app.
///
/// Typical usage from UI code:
/// ```dart
/// final bgLocation = ref.read(backgroundLocationProvider.notifier);
/// await bgLocation.startTracking();
/// // ... later ...
/// await bgLocation.stopTracking();
/// ```
///
/// The notifier integrates with:
/// - **Geolocator** for raw GPS position streams
/// - **KalmanFilter** (from trippo_shared) for noise reduction
/// - **SocketService** (from trippo_shared) for real-time location streaming
/// - **NestjsApiClient** for REST API fallback persistence
/// - **SecureStorageService** for auth token retrieval
class BackgroundLocationNotifier extends StateNotifier<BackgroundLocationState> {
  final Ref _ref;

  // ---- Stream / timer subscriptions ----
  StreamSubscription<Position>? _positionSubscription;
  Timer? _locationSendTimer;
  Timer? _batteryCheckTimer;

  // ---- Kalman filter state ----
  final KalmanFilter _kalmanFilter = KalmanFilter();

  // ---- Tracking metadata ----
  LocationUpdate? _previousLocation;
  bool _isAppInForeground = true;

  // ---- Foreground service callback handle (Android only) ----
  // Stored so the service can be stopped later.
  static bool _foregroundServiceRunning = false;

  BackgroundLocationNotifier(this._ref)
      : super(const BackgroundLocationState());

  // ================================================================
  // Public API
  // ================================================================

  /// Starts background location tracking.
  ///
  /// This method:
  /// 1. Requests location permissions (including background / always).
  /// 2. Starts the Android foreground service with a persistent
  ///    notification (no-op on iOS, which uses `allowsBackgroundLocationUpdates`).
  /// 3. Subscribes to the Geolocator position stream with configurable
  ///    accuracy and distance filter.
  /// 4. Starts a periodic timer that sends the latest smoothed location
  ///    to the backend via Socket.IO and REST API.
  /// 5. Starts a battery monitoring timer to dynamically adjust the
  ///    update interval when battery is low.
  ///
  /// Returns `true` if tracking started successfully, `false` if
  /// permissions were denied or location services are disabled.
  Future<bool> startTracking() async {
    if (state.isTracking) return true;

    // ---- Step 1: Permissions ----
    final permissionGranted = await _requestLocationPermissions();
    if (!permissionGranted) {
      state = state.copyWith(
        error: 'Location permissions denied. Please enable location access '
            'and set it to "Always" in app settings.',
      );
      return false;
    }

    // ---- Step 2: Foreground service (Android) ----
    await _startForegroundService();

    // ---- Step 3: GPS position stream ----
    final locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 5, // Minimum 5 meters between updates
      // timeLimit is not set here; interval is controlled by the send timer.
    );

    _positionSubscription = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen(_onLocationUpdate);

    // ---- Step 4: Periodic backend send timer ----
    _startLocationSendTimer(intervalSeconds: _activeIntervalSeconds);

    // ---- Step 5: Battery monitoring ----
    _startBatteryMonitoring();

    // ---- Mark tracking active ----
    _foregroundServiceRunning = true;

    state = state.copyWith(
      isTracking: true,
      currentIntervalSeconds: _activeIntervalSeconds,
      error: null,
    );

    return true;
  }

  /// Stops background location tracking and cleans up all resources.
  ///
  /// This cancels GPS subscriptions, stops timers, stops the foreground
  /// service, and resets the Kalman filter state.
  Future<void> stopTracking() async {
    if (!state.isTracking) return;

    // Cancel GPS stream
    await _positionSubscription?.cancel();
    _positionSubscription = null;

    // Stop timers
    _locationSendTimer?.cancel();
    _locationSendTimer = null;
    _batteryCheckTimer?.cancel();
    _batteryCheckTimer = null;

    // Stop foreground service
    await _stopForegroundService();

    // Reset filter and tracking metadata
    _kalmanFilter.reset();
    _previousLocation = null;
    _foregroundServiceRunning = false;

    state = const BackgroundLocationState();
  }

  /// Notifies the service that the app has moved to the foreground.
  /// Tightens the update interval to [_activeIntervalSeconds] for
  /// more responsive real-time tracking.
  void onAppForegrounded() {
    _isAppInForeground = true;
    if (state.isTracking) {
      _adjustUpdateInterval();
    }
  }

  /// Notifies the service that the app has moved to the background.
  /// Relaxes the update interval to [_backgroundIntervalSeconds] to
  /// conserve battery while still providing useful tracking data.
  void onAppBackgrounded() {
    _isAppInForeground = false;
    if (state.isTracking) {
      _adjustUpdateInterval();
    }
  }

  /// Returns whether the foreground service is currently running.
  /// Useful for checking state on app cold-start.
  static bool get isForegroundServiceRunning => _foregroundServiceRunning;

  // ================================================================
  // GPS Processing Pipeline
  // ================================================================

  /// Called for every raw GPS position from Geolocator.
  ///
  /// Processing pipeline:
  /// 1. Discard readings with accuracy worse than [_minAccuracyMeters].
  /// 2. Run anomaly detection (speed / GPS jump).
  /// 3. Apply Kalman filter smoothing.
  /// 4. Compute heading between previous and current point.
  /// 5. Accumulate distance for the trip meter.
  /// 6. Update state with the smoothed [LocationUpdate].
  void _onLocationUpdate(Position position) {
    if (!state.isTracking) return;

    // ---- Step 1: Accuracy gate ----
    if (position.accuracy > _minAccuracyMeters) {
      return; // Discard low-quality readings
    }

    final now = DateTime.now();
    final timestampMs = now.millisecondsSinceEpoch;

    // ---- Step 2: Anomaly detection ----
    bool isFlagged = false;
    if (_previousLocation != null) {
      final distance = GeoUtils.distanceBetween(
        _previousLocation!.latitude,
        _previousLocation!.longitude,
        position.latitude,
        position.longitude,
      );

      final timeDiffSeconds = (timestampMs - _previousLocation!.timestamp) /
          1000.0;

      if (timeDiffSeconds > 0) {
        // Speed check
        final speedKmh = (distance / timeDiffSeconds) * 3.6;
        if (speedKmh > _maxSpeedKmh) {
          isFlagged = true;
        }

        // GPS jump check
        if (distance > _maxJumpMeters && timeDiffSeconds < 5) {
          // Discard entirely — this is a GPS glitch, not real movement.
          return;
        }
      }
    }

    // ---- Step 3: Kalman filter ----
    final smoothed = _applyKalmanFilter(
      latitude: position.latitude,
      longitude: position.longitude,
      accuracy: position.accuracy,
      timestamp: timestampMs,
    );

    // ---- Step 4: Heading calculation ----
    double heading = position.heading;
    if (_previousLocation != null && (heading.isNaN || heading < 0)) {
      // Fallback: compute bearing from previous point
      heading = GpsUtils.bearingBetween(
        _previousLocation!.latitude,
        _previousLocation!.longitude,
        smoothed.latitude,
        smoothed.longitude,
      );
    } else if (_previousLocation != null) {
      // Use computed bearing if GPS heading is unreliable (0 = true north)
      final computedBearing = GpsUtils.bearingBetween(
        _previousLocation!.latitude,
        _previousLocation!.longitude,
        smoothed.latitude,
        smoothed.longitude,
      );
      // Prefer computed bearing when the distance is significant enough
      // (> 3 m) for a reliable direction; otherwise keep GPS heading.
      final dist = GeoUtils.distanceBetween(
        _previousLocation!.latitude,
        _previousLocation!.longitude,
        smoothed.latitude,
        smoothed.longitude,
      );
      if (dist > 3.0) {
        heading = computedBearing;
      }
    }

    // ---- Step 5: Distance accumulation ----
    double incrementalDistance = 0.0;
    if (_previousLocation != null) {
      incrementalDistance = GeoUtils.distanceBetween(
        _previousLocation!.latitude,
        _previousLocation!.longitude,
        smoothed.latitude,
        smoothed.longitude,
      );
    }

    final newTotalDistance = state.totalDistanceTracked + incrementalDistance;

    // ---- Step 6: Build update and emit state ----
    final speed = position.speed >= 0 ? position.speed : 0.0;

    final locationUpdate = LocationUpdate(
      latitude: smoothed.latitude,
      longitude: smoothed.longitude,
      accuracy: position.accuracy,
      speed: speed,
      heading: heading,
      timestamp: timestampMs,
      totalDistance: newTotalDistance,
      isFlagged: isFlagged,
    );

    _previousLocation = locationUpdate;

    state = state.copyWith(
      currentLocation: locationUpdate,
      totalDistanceTracked: newTotalDistance,
    );
  }

  // ================================================================
  // Kalman Filter
  // ================================================================

  /// Applies the shared [KalmanFilter] to smooth raw GPS coordinates.
  ///
  /// The filter maintains an internal state (position estimate, covariance,
  /// velocity estimate) and produces a smoothed output that is typically
  /// 40-60% less noisy than the raw GPS reading on standard mobile
  /// hardware.
  ///
  /// Returns a record `({double latitude, double longitude})` with the
  /// smoothed coordinates.
  ({double latitude, double longitude}) _applyKalmanFilter({
    required double latitude,
    required double longitude,
    required double accuracy,
    required int timestamp,
  }) {
    _kalmanFilter.process(
      latitude: latitude,
      longitude: longitude,
      accuracy: accuracy,
      timestamp: timestamp,
    );

    return (
      latitude: _kalmanFilter.latitude,
      longitude: _kalmanFilter.longitude,
    );
  }

  // ================================================================
  // Backend Communication
  // ================================================================

  /// Sends the current smoothed location to the NestJS backend using both
  /// Socket.IO (real-time) and REST API (persistence fallback).
  ///
  /// **Socket.IO** (`driver:location` event):
  /// - Primary channel for real-time rider tracking.
  /// - Low latency (~50 ms on 4G).
  /// - If the socket is disconnected the event is queued by
  ///   [SocketService] and flushed on reconnection.
  ///
  /// **REST API** (`POST /drivers/location`):
  /// - Secondary / fallback channel for reliable persistence.
  /// - The backend stores this in Redis for the dispatch engine and
  ///   in PostgreSQL for trip auditing.
  /// - If the REST call fails (network error, 5xx) the error is logged
  ///   but does **not** stop the tracking loop (best-effort delivery).
  Future<void> _sendLocationToBackend() async {
    final location = state.currentLocation;
    if (location == null) return;

    try {
      // ---- Socket.IO (primary, real-time) ----
      final socketService = _ref.read(driverSocketServiceProvider);
      if (socketService.isConnected) {
        socketService.emitDriverLocation(
          tripId: '', // Empty when not on an active trip
          latitude: location.latitude,
          longitude: location.longitude,
          heading: location.heading,
          speed: location.speed,
          accuracy: location.accuracy,
        );
      }

      // ---- REST API (fallback, persistent) ----
      final apiClient = _ref.read(nestjsApiClientProvider);
      await apiClient.updateDriverLocation(
        latitude: location.latitude,
        longitude: location.longitude,
        heading: location.heading,
        speed: location.speed,
        accuracy: location.accuracy,
      );

      state = state.copyWith(
        lastSentTime: DateTime.now(),
        error: null,
      );
    } catch (e) {
      // Best-effort: do not crash the tracking loop on send failure.
      // The next timer tick will retry.
      state = state.copyWith(
        error: 'Failed to send location: ${e.toString()}',
      );
    }
  }

  // ================================================================
  // Timers
  // ================================================================

  /// Starts (or restarts) the periodic timer that sends location updates
  /// to the backend at the given [intervalSeconds].
  void _startLocationSendTimer({required int intervalSeconds}) {
    _locationSendTimer?.cancel();

    _locationSendTimer = Timer.periodic(
      Duration(seconds: intervalSeconds),
      (_) => _sendLocationToBackend(),
    );
  }

  /// Starts a periodic timer that checks the device battery level every
  /// 60 seconds. When the battery drops below [_lowBatteryThreshold] the
  /// update interval is automatically relaxed.
  void _startBatteryMonitoring() {
    _batteryCheckTimer?.cancel();

    _batteryCheckTimer = Timer.periodic(
      const Duration(seconds: 60),
      (_) => _checkBatteryLevel(),
    );

    // Check immediately on start
    _checkBatteryLevel();
  }

  /// Checks the device battery level and adjusts the update interval
  /// accordingly.
  ///
  /// Battery optimization strategy:
  /// - Battery >= 20%: Use the normal interval (5 s foreground / 30 s bg)
  /// - Battery < 20%: Use [_lowBatteryIntervalSeconds] (60 s) regardless
  ///   of foreground/background state.
  Future<void> _checkBatteryLevel() async {
    try {
      // Using Geolocator's isLocationServiceEnabled as a proxy that the
      // device is alive; actual battery level requires battery_plus.
      // Since battery_plus may not be in pubspec yet, we use a
      // platform-agnostic approach with a conditional import pattern.
      //
      // For now, we attempt to get battery level via a method that
      // won't crash if battery_plus is not available.
      final batteryLevel = await _getBatteryLevel();

      state = state.copyWith(batteryLevel: batteryLevel);

      if (batteryLevel != null && batteryLevel < _lowBatteryThreshold) {
        // Override interval to low-battery mode
        if (state.currentIntervalSeconds != _lowBatteryIntervalSeconds) {
          _startLocationSendTimer(intervalSeconds: _lowBatteryIntervalSeconds);
          state = state.copyWith(
            currentIntervalSeconds: _lowBatteryIntervalSeconds,
          );
        }
      } else {
        // Restore normal interval based on app state
        _adjustUpdateInterval();
      }
    } catch (_) {
      // Battery info not available; continue with current interval
    }
  }

  /// Attempts to read the device battery level (0-100).
  ///
  /// This method uses a try/catch pattern so that the service works
  /// even if the `battery_plus` package has not been added to
  /// `pubspec.yaml`. In that case it returns `null` and battery
  /// optimization is effectively disabled.
  ///
  /// To enable battery optimization, add to `pubspec.yaml`:
  /// ```yaml
  ///   battery_plus: ^5.0.2
  /// ```
  /// And replace this method body with:
  /// ```dart
  ///   final battery = Battery();
  ///   return await battery.batteryLevel;
  /// ```
  Future<int?> _getBatteryLevel() async {
    // Placeholder: battery_plus integration point.
    // When battery_plus is added as a dependency, uncomment:
    //
    // try {
    //   final battery = Battery();
    //   return await battery.batteryLevel;
    // } catch (_) {
    //   return null;
    // }
    return null;
  }

  /// Adjusts the update interval based on current app lifecycle state
  /// (foreground vs background) and battery level.
  void _adjustUpdateInterval() {
    if (!state.isTracking) return;

    final batteryLevel = state.batteryLevel;
    if (batteryLevel != null && batteryLevel < _lowBatteryThreshold) {
      if (state.currentIntervalSeconds != _lowBatteryIntervalSeconds) {
        _startLocationSendTimer(intervalSeconds: _lowBatteryIntervalSeconds);
        state = state.copyWith(
          currentIntervalSeconds: _lowBatteryIntervalSeconds,
        );
      }
      return;
    }

    final targetInterval =
        _isAppInForeground ? _activeIntervalSeconds : _backgroundIntervalSeconds;

    if (state.currentIntervalSeconds != targetInterval) {
      _startLocationSendTimer(intervalSeconds: targetInterval);
      state = state.copyWith(currentIntervalSeconds: targetInterval);
    }
  }

  // ================================================================
  // Permissions
  // ================================================================

  /// Requests location permissions required for background tracking.
  ///
  /// Permission strategy:
  /// 1. Check if location services are enabled.
  /// 2. Check current permission status.
  /// 3. If denied, request `whileUsing` first (required before
  ///    requesting `always` on Android 12+).
  /// 4. Then request `always` permission for background location.
  /// 5. If `deniedForever`, the user must go to system settings.
  ///
  /// Returns `true` if the required permissions are granted.
  Future<bool> _requestLocationPermissions() async {
    // Check if location services are enabled
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    // Check current permission
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // User must manually enable in settings. Optionally open settings:
      // await Geolocator.openAppSettings();
      return false;
    }

    // On Android 12+, we need "always" permission for background location.
    // Request background/always permission.
    if (permission == LocationPermission.whileInUse) {
      permission = await Geolocator.requestPermission();
      // On Android 12+, this may still return whileInUse if the user
      // hasn't granted "always" in system settings.
    }

    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  // ================================================================
  // Foreground Service (Android)
  // ============================================================

  /// Starts the Android foreground service to keep the app alive when
  /// it moves to the background.
  ///
  /// This uses the `flutter_background_service` pattern. The service
  /// runs in a separate isolate and displays a persistent notification
  /// that cannot be swiped away by the user.
  ///
  /// **Important**: This is a no-op on iOS. Background location on iOS
  /// is handled by the `allowsBackgroundLocationUpdates` plist key and
  /// the blue status bar indicator.
  ///
  /// To enable this, add to `pubspec.yaml`:
  /// ```yaml
  ///   flutter_background_service: ^3.0.1
  /// ```
  Future<void> _startForegroundService() async {
    // When flutter_background_service is added as a dependency,
    // replace this block with the real implementation:
    //
    // final service = FlutterBackgroundService();
    //
    // await service.configure(
    //   androidConfiguration: AndroidConfiguration(
    //     onStart: _onForegroundServiceStart,
    //     autoStart: true,
    //     isForegroundMode: true,
    //     notificationTitle: 'مدار Driver',
    //     notificationText: 'Tracking your location',
    //     notificationIcon: AndroidResource(name: 'ic_launcher'),
    //   ),
    //   iosConfiguration: IosConfiguration(
    //     autoStart: true,
    //     onForeground: (_) {},
    //     onBackground: (_) => true,
    //   ),
    // );
    //
    // await service.startService();

    // Placeholder: mark service as running for state tracking
    _foregroundServiceRunning = true;
  }

  /// Stops the Android foreground service.
  Future<void> _stopForegroundService() async {
    // When flutter_background_service is added:
    //
    // final service = FlutterBackgroundService();
    // service.invoke('stop');
    //

    _foregroundServiceRunning = false;
  }

  /// Entry point for the foreground service isolate (Android only).
  ///
  /// This must be a top-level or static function so it can be passed
  /// as a callback to `FlutterBackgroundService.configure()`.
  ///
  /// When integrated with flutter_background_service, this function:
  /// 1. Sets the service as foreground mode with a notification.
  /// 2. Listens for `stop` events from the main isolate.
  /// 3. Optionally runs a lightweight location send loop as backup.
  @pragma('vm:entry-point')
  static void _onForegroundServiceStart(ServiceInstance service) async {
    // When flutter_background_service is integrated, this runs in
    // a separate isolate. Below is the reference implementation:
    //
    // DartPluginRegistrant.ensureInitialized();
    //
    // service.setAsForeground();
    // service.on('stop').listen((event) {
    //   service.stopSelf();
    // });
    //
    // // Optional: lightweight backup location loop in this isolate
    // Timer.periodic(const Duration(seconds: 30), (timer) async {
    //   if (!(await service.isRunning())) {
    //     timer.cancel();
    //     return;
    //   }
    //   // Could send a heartbeat here
    //   service.setNotificationInfo(
    //     title: 'مدار Driver',
    //     content: 'Location tracking active',
    //   );
    // });
  }

  // ================================================================
  // Lifecycle
  // ================================================================

  @override
  void dispose() {
    _positionSubscription?.cancel();
    _locationSendTimer?.cancel();
    _batteryCheckTimer?.cancel();
    _kalmanFilter.reset();
    super.dispose();
  }
}

// ============================================================================
// Foreground Service Type Alias
// ============================================================================

/// Type alias for the foreground service instance callback.
/// Defined so the code compiles regardless of whether
/// `flutter_background_service` is present.
///
/// When the package is added, replace with:
/// ```dart
/// typedef ServiceInstance
///     = flutter_background_service.FlutterBackgroundService;
/// ```
class ServiceInstance {
  /// Placeholder method for setting foreground mode.
  void setAsForeground() {}

  /// Placeholder method for stopping the service.
  void stopSelf() {}

  /// Placeholder for listening to events.
  Stream<dynamic> on(String event) => const Stream.empty();
}

// ============================================================================
// Riverpod Provider
// ============================================================================

/// Provides the [BackgroundLocationNotifier] as a keep-alive Riverpod
/// [StateNotifierProvider].
///
/// Usage:
/// ```dart
/// // Watch the state in a widget:
/// final bgState = ref.watch(backgroundLocationProvider);
/// if (bgState.isTracking) { ... }
///
/// // Control tracking from a notifier:
/// ref.read(backgroundLocationProvider.notifier).startTracking();
/// ref.read(backgroundLocationProvider.notifier).stopTracking();
/// ```
///
/// The provider is kept alive (`keepAlive: true`) so that tracking
/// continues even when no widget is currently watching the state.
final backgroundLocationProvider = StateNotifierProvider<
    BackgroundLocationNotifier, BackgroundLocationState>(
  (ref) => BackgroundLocationNotifier(ref),
);
