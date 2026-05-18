import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:trippo_shared/trippo_shared.dart';
import '../../../../core/app_providers.dart';
import '../../../dispatch/presentation/notifiers/dispatch_notifier.dart';

/// Nearby area statistics (visible to driver when online)
class NearbyStats {
  final int nearbyDrivers;
  final int activeRequests;
  final double surgeMultiplier;
  final bool isHighDemandArea;

  const NearbyStats({
    this.nearbyDrivers = 0,
    this.activeRequests = 0,
    this.surgeMultiplier = 1.0,
    this.isHighDemandArea = false,
  });

  NearbyStats copyWith({
    int? nearbyDrivers,
    int? activeRequests,
    double? surgeMultiplier,
    bool? isHighDemandArea,
  }) =>
      NearbyStats(
        nearbyDrivers: nearbyDrivers ?? this.nearbyDrivers,
        activeRequests: activeRequests ?? this.activeRequests,
        surgeMultiplier: surgeMultiplier ?? this.surgeMultiplier,
        isHighDemandArea: isHighDemandArea ?? this.isHighDemandArea,
      );
}

/// Driver Home State
class DriverHomeState {
  /// Whether the driver is currently online (accepting rides)
  final bool isOnline;

  /// Current GPS location of the driver
  final LocationPoint? currentLocation;

  /// Current heading/bearing in degrees (0 = north, clockwise)
  final double heading;

  /// Nearby area statistics
  final NearbyStats nearbyStats;

  /// Whether location tracking is active
  final bool isTrackingLocation;

  /// Loading state for online/offline transitions
  final bool isLoading;

  /// Error message if any
  final String? error;

  /// Duration driver has been online in current session
  final Duration? onlineDuration;

  /// Timestamp when driver went online
  final DateTime? wentOnlineAt;

  /// Default fallback location (Sana'a, Yemen)
  static const LatLng defaultLocation = LatLng(15.3694, 44.1910);

  const DriverHomeState({
    this.isOnline = false,
    this.currentLocation,
    this.heading = 0,
    this.nearbyStats = const NearbyStats(),
    this.isTrackingLocation = false,
    this.isLoading = false,
    this.error,
    this.onlineDuration,
    this.wentOnlineAt,
  });

  DriverHomeState copyWith({
    bool? isOnline,
    LocationPoint? currentLocation,
    double? heading,
    NearbyStats? nearbyStats,
    bool? isTrackingLocation,
    bool? isLoading,
    String? error,
    Duration? onlineDuration,
    DateTime? wentOnlineAt,
  }) =>
      DriverHomeState(
        isOnline: isOnline ?? this.isOnline,
        currentLocation: currentLocation ?? this.currentLocation,
        heading: heading ?? this.heading,
        nearbyStats: nearbyStats ?? this.nearbyStats,
        isTrackingLocation: isTrackingLocation ?? this.isTrackingLocation,
        isLoading: isLoading ?? this.isLoading,
        error: error,
        onlineDuration: onlineDuration ?? this.onlineDuration,
        wentOnlineAt: wentOnlineAt ?? this.wentOnlineAt,
      );
}

/// Driver Home Notifier
/// Manages driver online/offline status and location tracking
/// When going online: starts GPS tracking, joins dispatch room
/// When going offline: stops GPS tracking, leaves dispatch room
/// Sends location updates every 5 seconds via Socket.IO when online
class DriverHomeNotifier extends StateNotifier<DriverHomeState> {
  final Ref _ref;
  Timer? _locationUpdateTimer;
  Timer? _onlineDurationTimer;
  StreamSubscription<Position>? _positionStreamSubscription;

  /// Location update interval when online (5 seconds)
  static const Duration _locationUpdateInterval = Duration(seconds: 5);

  /// Online duration update interval (1 second)
  static const Duration _durationUpdateInterval = Duration(seconds: 1);

  DriverHomeNotifier(this._ref) : super(const DriverHomeState());

  /// Check and request location permission
  /// Returns true if permission is granted
  Future<bool> _checkLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      // Could open app settings here, but we return false
      // and let the UI handle it
      return false;
    }
    return true;
  }

  /// Get current GPS position
  Future<Position?> _getCurrentPosition() async {
    final hasPermission = await _checkLocationPermission();
    if (!hasPermission) return null;

    try {
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );
    } catch (e) {
      return null;
    }
  }

  /// Go online - POST /drivers/online with current GPS
  /// Starts GPS tracking service and joins dispatch room
  Future<void> goOnline() async {
    if (state.isOnline) return;

    state = state.copyWith(isLoading: true, error: null);

    try {
      // Get current GPS position first
      final position = await _getCurrentPosition();
      if (position == null) {
        state = state.copyWith(
          isLoading: false,
          error: 'Unable to get current location. Please enable GPS and grant location permission.',
        );
        return;
      }

      final currentLocation = LocationPoint(
        latitude: position.latitude,
        longitude: position.longitude,
        accuracy: position.accuracy,
        heading: position.heading,
        speed: position.speed,
        timestamp: DateTime.now(),
      );

      // Tell server the driver is online with current GPS
      final apiClient = _ref.read(nestjsApiClientProvider);
      await apiClient.setDriverOnline(
        latitude: currentLocation.latitude,
        longitude: currentLocation.longitude,
        heading: currentLocation.heading,
        accuracy: currentLocation.accuracy,
      );

      // Start real-time position stream
      _startPositionStream();

      // Start dispatch listening
      final dispatchNotifier = _ref.read(dispatchProvider.notifier);
      dispatchNotifier.startListening();

      // Start periodic location updates via Socket.IO (every 5 seconds)
      _startLocationUpdateTimer();

      // Start online duration timer
      _startOnlineDurationTimer();

      state = state.copyWith(
        isOnline: true,
        currentLocation: currentLocation,
        heading: currentLocation.heading,
        isTrackingLocation: true,
        isLoading: false,
        wentOnlineAt: DateTime.now(),
        onlineDuration: Duration.zero,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Start listening to GPS position stream for real-time tracking
  void _startPositionStream() {
    _stopPositionStream();

    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 5, // Minimum 5 meters between updates
    );

    _positionStreamSubscription = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen(_handlePositionUpdate);
  }

  /// Stop the position stream
  void _stopPositionStream() {
    _positionStreamSubscription?.cancel();
    _positionStreamSubscription = null;
  }

  /// Handle position update from GPS stream
  void _handlePositionUpdate(Position position) {
    final locationPoint = LocationPoint(
      latitude: position.latitude,
      longitude: position.longitude,
      accuracy: position.accuracy,
      heading: position.heading,
      speed: position.speed,
      timestamp: DateTime.now(),
    );

    // Update state with new location and heading
    state = state.copyWith(
      currentLocation: locationPoint,
      heading: position.heading,
    );

    // Send location update via Socket.IO immediately for real-time tracking
    if (state.isOnline) {
      final socketService = _ref.read(driverSocketServiceProvider);
      socketService.emitDriverLocation(
        tripId: '',
        latitude: locationPoint.latitude,
        longitude: locationPoint.longitude,
        heading: locationPoint.heading,
        speed: locationPoint.speed,
        accuracy: locationPoint.accuracy,
      );
    }
  }

  /// Go offline - POST /drivers/offline
  /// Stops GPS tracking service and leaves dispatch room
  Future<void> goOffline() async {
    if (!state.isOnline) return;

    state = state.copyWith(isLoading: true, error: null);

    try {
      final apiClient = _ref.read(nestjsApiClientProvider);
      await apiClient.setDriverOffline();

      // Stop position stream
      _stopPositionStream();

      // Stop dispatch listening
      final dispatchNotifier = _ref.read(dispatchProvider.notifier);
      dispatchNotifier.stopListening();

      // Stop timers
      _stopLocationUpdateTimer();
      _stopOnlineDurationTimer();

      state = state.copyWith(
        isOnline: false,
        isTrackingLocation: false,
        isLoading: false,
        currentLocation: null,
        heading: 0,
        wentOnlineAt: null,
        onlineDuration: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Update driver location - POST /drivers/location
  /// Called periodically when online AND on significant location changes
  Future<void> updateLocation({
    required double latitude,
    required double longitude,
    double? heading,
    double? speed,
    double? accuracy,
  }) async {
    if (!state.isOnline) return;

    try {
      final apiClient = _ref.read(nestjsApiClientProvider);

      // Send to REST API for persistence
      await apiClient.updateDriverLocation(
        latitude: latitude,
        longitude: longitude,
        heading: heading,
        speed: speed,
        accuracy: accuracy,
      );

      // Also send via Socket.IO for real-time tracking
      final socketService = _ref.read(driverSocketServiceProvider);
      socketService.emitDriverLocation(
        tripId: '', // Empty when not on a trip
        latitude: latitude,
        longitude: longitude,
        heading: heading,
        speed: speed,
        accuracy: accuracy,
      );

      // Update local state with new location
      state = state.copyWith(
        currentLocation: LocationPoint(
          latitude: latitude,
          longitude: longitude,
          accuracy: accuracy ?? 0,
          heading: heading ?? 0,
          speed: speed ?? 0,
          timestamp: DateTime.now(),
        ),
        heading: heading ?? state.heading,
      );
    } catch (e) {
      // Don't update error state for location failures to avoid UI flicker
      // Location updates are best-effort
    }
  }

  /// Start periodic location update timer
  /// Sends location to REST API every 5 seconds for server-side persistence
  void _startLocationUpdateTimer() {
    _stopLocationUpdateTimer();

    _locationUpdateTimer = Timer.periodic(_locationUpdateInterval, (_) {
      if (state.isOnline && state.currentLocation != null) {
        updateLocation(
          latitude: state.currentLocation!.latitude,
          longitude: state.currentLocation!.longitude,
          heading: state.currentLocation!.heading,
          speed: state.currentLocation!.speed,
          accuracy: state.currentLocation!.accuracy,
        );
      }
    });
  }

  /// Stop periodic location update timer
  void _stopLocationUpdateTimer() {
    _locationUpdateTimer?.cancel();
    _locationUpdateTimer = null;
  }

  /// Start online duration timer
  void _startOnlineDurationTimer() {
    _stopOnlineDurationTimer();

    _onlineDurationTimer = Timer.periodic(_durationUpdateInterval, (_) {
      if (state.wentOnlineAt != null) {
        final duration = DateTime.now().difference(state.wentOnlineAt!);
        state = state.copyWith(onlineDuration: duration);
      }
    });
  }

  /// Stop online duration timer
  void _stopOnlineDurationTimer() {
    _onlineDurationTimer?.cancel();
    _onlineDurationTimer = null;
  }

  /// Toggle online/offline status
  Future<void> toggleOnlineStatus() async {
    if (state.isOnline) {
      await goOffline();
    } else {
      await goOnline();
    }
  }

  /// Update nearby stats (received from server via Socket.IO)
  void updateNearbyStats(NearbyStats stats) {
    state = state.copyWith(nearbyStats: stats);
  }

  /// Get current LatLng for the map
  LatLng get currentLatLng {
    if (state.currentLocation != null) {
      return LatLng(state.currentLocation!.latitude, state.currentLocation!.longitude);
    }
    return DriverHomeState.defaultLocation;
  }

  @override
  void dispose() {
    _stopLocationUpdateTimer();
    _stopOnlineDurationTimer();
    _stopPositionStream();
    super.dispose();
  }
}

/// Driver Home Provider
final driverHomeProvider =
    StateNotifierProvider<DriverHomeNotifier, DriverHomeState>((ref) {
  return DriverHomeNotifier(ref);
});

/// Is driver online provider
final isDriverOnlineProvider = Provider<bool>((ref) {
  final homeState = ref.watch(driverHomeProvider);
  return homeState.isOnline;
});

/// Driver current location provider
final driverCurrentLocationProvider = Provider<LocationPoint?>((ref) {
  final homeState = ref.watch(driverHomeProvider);
  return homeState.currentLocation;
});

/// Driver current heading provider
final driverHeadingProvider = Provider<double>((ref) {
  final homeState = ref.watch(driverHomeProvider);
  return homeState.heading;
});

/// Driver online duration provider
final driverOnlineDurationProvider = Provider<Duration?>((ref) {
  final homeState = ref.watch(driverHomeProvider);
  return homeState.onlineDuration;
});

/// Nearby stats provider
final nearbyStatsProvider = Provider<NearbyStats>((ref) {
  final homeState = ref.watch(driverHomeProvider);
  return homeState.nearbyStats;
});
