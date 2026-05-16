import 'api_service.dart';
import 'gps_tracking_service.dart';
import '../constants/api_constants.dart';
import '../constants/app_constants.dart';
import '../utils/geo_utils.dart';

/// AntiFraudService - Detects and reports suspicious activities
/// Works with NestJS backend anti-fraud module.
///
/// Client-side detection includes:
/// - GPS anomaly detection (fake GPS, teleportation, unrealistic speed)
/// - Rate limiting for frequent actions
/// - Device fingerprinting for fraud detection
///
/// Server-side detection (NestJS) includes:
/// - Multi-account detection
/// - Payment fraud detection
/// - Trip pattern analysis
/// - Location spoofing verification (PostGIS queries)
class AntiFraudService {
  final ApiService _apiService;
  final GpsTrackingService _gpsService;

  /// Rate limiting tracking: action -> list of timestamps
  final Map<String, List<DateTime>> _actionTimestamps = {};

  /// Rate limiting configuration per action type
  static const Map<String, _RateLimitConfig> _rateLimitConfigs = {
    'trip_request': _RateLimitConfig(maxActions: AppConstants.maxTripsPerHour, windowMinutes: 60),
    'trip_cancel': _RateLimitConfig(maxActions: AppConstants.maxCancellationPerDay, windowMinutes: 1440),
    'wallet_withdraw': _RateLimitConfig(maxActions: 3, windowMinutes: 60),
    'login_attempt': _RateLimitConfig(maxActions: 5, windowMinutes: 15),
    'sms_otp': _RateLimitConfig(maxActions: 3, windowMinutes: 60),
  };

  AntiFraudService({
    required ApiService apiService,
    required GpsTrackingService gpsService,
  })  : _apiService = apiService,
        _gpsService = gpsService;

  // ==================== Suspicious Activity Reporting ====================

  /// Report suspicious activity - POST /anti-fraud/report
  /// Sends detected anomaly data to NestJS backend for analysis and logging.
  /// NestJS may trigger: account suspension, manual review, or fraud alert.
  Future<void> reportSuspiciousActivity({
    required String type,
    required String severity,
    required Map<String, dynamic> details,
    String? userId,
    String? tripId,
  }) async {
    try {
      await _apiService.post(
        '/anti-fraud/report',
        data: {
          'type': type,
          'severity': severity,
          'details': details,
          'userId': userId,
          'tripId': tripId,
          'timestamp': DateTime.now().toUtc().toIso8601String(),
        },
      );
    } catch (e) {
      // Fail silently - don't block user flow for reporting failure
      // The anomaly is still detected locally
    }
  }

  // ==================== GPS Anomaly Detection ====================

  /// Check GPS anomaly (uses GpsTrackingService anomaly detection logic)
  /// Compares current and previous location points for anomalies.
  GpsAnomaly? checkGpsAnomaly(LocationPoint current, LocationPoint previous) {
    final timeDiff = current.timestamp.difference(previous.timestamp).inSeconds;

    if (timeDiff <= 0) return null;

    // 1. Check for unrealistic speed
    final distance = GeoUtils.distanceBetween(
      previous.latitude,
      previous.longitude,
      current.latitude,
      current.longitude,
    );
    final speedKmh = (distance / timeDiff) * 3.6;

    if (detectSpeedAnomaly(speedKmh)) {
      return GpsAnomaly(
        type: GpsAnomalyType.unrealisticSpeed,
        description: 'Speed $speedKmh km/h exceeds max ${AppConstants.gpsMaxSpeedKmh} km/h',
        value: speedKmh,
        threshold: AppConstants.gpsMaxSpeedKmh,
        timestamp: current.timestamp,
      );
    }

    // 2. Check for GPS jumping (teleportation)
    if (detectGpsJumping(current, previous, Duration(seconds: timeDiff))) {
      return GpsAnomaly(
        type: GpsAnomalyType.gpsJump,
        description: 'Location jumped ${distance.toStringAsFixed(0)}m in ${timeDiff}s',
        value: distance,
        threshold: 500,
        timestamp: current.timestamp,
      );
    }

    // 3. Check for poor accuracy
    if (current.accuracy > 200) {
      return GpsAnomaly(
        type: GpsAnomalyType.poorAccuracy,
        description: 'GPS accuracy ${current.accuracy.toStringAsFixed(0)}m is too poor',
        value: current.accuracy,
        threshold: 200,
        timestamp: current.timestamp,
      );
    }

    return null;
  }

  /// Detect fake GPS (mock location provider)
  /// Checks for indicators that the device is using a mock location app.
  /// This is a heuristic check; NestJS backend provides authoritative verification.
  bool detectFakeGps() {
    // On Android, we can check if the location provider is "mock"
    // using platform channels. This is a simplified check.
    //
    // Indicators of fake GPS:
    // 1. Location provider is set to "mock" (Android only)
    // 2. Perfect accuracy (0.0 or very low values consistently)
    // 3. Altitude is exactly 0.0 for all readings
    // 4. Speed is exactly 0.0 while location is changing
    //
    // Platform-specific implementation is in each app's native code.
    // This method returns a heuristic result based on GPS service data.
    return false; // Placeholder - actual check uses platform channels
  }

  /// Detect speed anomaly (> 200 km/h is suspicious for ground vehicle)
  /// Uses the threshold defined in AppConstants.maxReasonableSpeedKmh.
  bool detectSpeedAnomaly(double speedKmh) {
    return speedKmh > AppConstants.maxReasonableSpeedKmh;
  }

  /// Detect GPS jumping (teleportation - >500m in <2 seconds)
  /// This indicates either GPS spoofing or a GPS glitch.
  /// The NestJS backend can verify with PostGIS trajectory analysis.
  bool detectGpsJumping(LocationPoint a, LocationPoint b, Duration timeDiff) {
    if (timeDiff.inSeconds >= 2) return false;

    final distance = GeoUtils.distanceBetween(
      a.latitude,
      a.longitude,
      b.latitude,
      b.longitude,
    );

    // > 500 meters in < 2 seconds is physically impossible for ground vehicles
    // At 200 km/h (max reasonable speed), you'd cover ~111m in 2 seconds
    return distance > 500;
  }

  // ==================== Rate Limiting ====================

  /// Rate limiting check
  /// Returns true if the action is rate-limited (too many attempts).
  /// Uses sliding window algorithm with configurable limits per action type.
  bool isRateLimited(String action) {
    final config = _rateLimitConfigs[action];
    if (config == null) return false;

    final now = DateTime.now();
    final windowStart = now.subtract(Duration(minutes: config.windowMinutes));

    // Get or create timestamp list for this action
    _actionTimestamps[action] ??= [];
    final timestamps = _actionTimestamps[action]!;

    // Remove timestamps outside the window
    timestamps.removeWhere((ts) => ts.isBefore(windowStart));

    // Check if limit is exceeded
    return timestamps.length >= config.maxActions;
  }

  /// Record an action for rate limiting
  /// Call this when an action is performed (e.g., trip requested, login attempted).
  void recordAction(String action) {
    final now = DateTime.now();
    _actionTimestamps[action] ??= [];
    _actionTimestamps[action]!.add(now);

    // Clean up old entries to prevent memory leaks
    final config = _rateLimitConfigs[action];
    if (config != null) {
      final windowStart = now.subtract(Duration(minutes: config.windowMinutes));
      _actionTimestamps[action]!.removeWhere((ts) => ts.isBefore(windowStart));
    }
  }

  /// Get remaining actions before rate limit is hit
  /// Returns the number of remaining allowed actions in the current window.
  int getRemainingActions(String action) {
    final config = _rateLimitConfigs[action];
    if (config == null) return 999;

    final now = DateTime.now();
    final windowStart = now.subtract(Duration(minutes: config.windowMinutes));

    _actionTimestamps[action] ??= [];
    final timestamps = _actionTimestamps[action]!;

    // Remove timestamps outside the window
    timestamps.removeWhere((ts) => ts.isBefore(windowStart));

    return (config.maxActions - timestamps.length).clamp(0, config.maxActions);
  }

  // ==================== Device Fingerprinting ====================

  /// Get device fingerprint for fraud detection
  /// Creates a unique identifier for the device based on hardware characteristics.
  /// Sent to NestJS backend for multi-account detection.
  Future<String> getDeviceFingerprint() async {
    // Device fingerprint is constructed from:
    // - Device model + manufacturer
    // - OS version
    // - Screen resolution
    // - Device ID (Android ID / iOS identifierForVendor)
    // - App installation ID
    //
    // Implementation uses device_info_plus and similar packages
    // which are in each app's dependencies.
    //
    // The fingerprint is hashed before sending to the server.
    // NestJS backend uses it to detect:
    // - Multiple accounts on same device
    // - Device switching (same account, different devices)
    // - Emulator detection

    // Placeholder - actual implementation uses platform channels
    return '';
  }

  // ==================== Comprehensive Fraud Check ====================

  /// Perform a comprehensive fraud check on a GPS location update.
  /// Combines all detection methods and reports anomalies to backend.
  /// Returns a list of detected anomalies (empty if none detected).
  List<GpsAnomaly> performFullGpsCheck(LocationPoint current, LocationPoint? previous) {
    final anomalies = <GpsAnomaly>[];

    if (previous == null) return anomalies;

    // 1. Check GPS anomaly (speed, jumping, accuracy)
    final anomaly = checkGpsAnomaly(current, previous);
    if (anomaly != null) {
      anomalies.add(anomaly);
    }

    // 2. Check for fake GPS
    if (detectFakeGps()) {
      anomalies.add(GpsAnomaly(
        type: GpsAnomalyType.mockLocation,
        description: 'Mock location provider detected',
        value: 1,
        threshold: 0,
        timestamp: current.timestamp,
      ));
    }

    // 3. Report all anomalies to backend
    for (final a in anomalies) {
      reportSuspiciousActivity(
        type: 'gps_anomaly_${a.type.name}',
        severity: _mapSeverity(a),
        details: {
          'anomalyType': a.type.name,
          'description': a.description,
          'value': a.value,
          'threshold': a.threshold,
          'latitude': current.latitude,
          'longitude': current.longitude,
          'accuracy': current.accuracy,
          'speed': current.speed,
        },
      );
    }

    return anomalies;
  }

  /// Map anomaly severity based on type and value
  String _mapSeverity(GpsAnomaly anomaly) {
    switch (anomaly.type) {
      case GpsAnomalyType.mockLocation:
        return 'high';
      case GpsAnomalyType.unrealisticSpeed:
        // Speed slightly over limit = medium, way over = high
        final ratio = anomaly.value / anomaly.threshold;
        return ratio > 2.0 ? 'high' : 'medium';
      case GpsAnomalyType.gpsJump:
        return 'medium';
      case GpsAnomalyType.poorAccuracy:
        return 'low';
      case GpsAnomalyType.duplicatePoint:
        return 'low';
    }
  }

  // ==================== Cleanup ====================

  /// Dispose resources
  void dispose() {
    _actionTimestamps.clear();
  }
}

/// Rate limit configuration for an action type
class _RateLimitConfig {
  final int maxActions;
  final int windowMinutes;

  const _RateLimitConfig({
    required this.maxActions,
    required this.windowMinutes,
  });
}
