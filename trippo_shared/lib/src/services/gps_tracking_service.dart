import 'dart:async';
import 'package:geolocator/geolocator.dart';
import '../utils/kalman_filter.dart';
import '../utils/geo_utils.dart';
import '../constants/app_constants.dart';

/// GPS Tracking Service - Professional location tracking with Kalman filtering
/// Handles location streaming, smoothing, anti-spoofing, and battery optimization
class GpsTrackingService {
  StreamSubscription<Position>? _positionSubscription;
  final KalmanFilter _kalmanFilter = KalmanFilter();
  final List<LocationPoint> _recentPoints = [];
  
  // Configuration
  int _updateIntervalMs = AppConstants.gpsUpdateIntervalMs;
  double _minAccuracy = AppConstants.gpsMinAccuracyMeters;
  bool _isActive = false;
  
  // Callbacks
  Function(LocationPoint)? onLocationUpdate;
  Function(GpsAnomaly)? onAnomalyDetected;
  Function(LocationPoint)? onFilteredLocationUpdate;
  
  // Stream controllers
  final _locationStreamController = StreamController<LocationPoint>.broadcast();
  Stream<LocationPoint> get locationStream => _locationStreamController.stream;
  
  final _filteredStreamController = StreamController<LocationPoint>.broadcast();
  Stream<LocationPoint> get filteredLocationStream => _filteredStreamController.stream;
  
  /// Start tracking GPS location
  Future<bool> startTracking({
    int? updateIntervalMs,
    double? minAccuracy,
    bool highAccuracy = true,
  }) async {
    if (_isActive) return true;
    
    _updateIntervalMs = updateIntervalMs ?? AppConstants.gpsUpdateIntervalMs;
    _minAccuracy = minAccuracy ?? AppConstants.gpsMinAccuracyMeters;
    
    // Check and request permissions
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      return false;
    }
    
    // Check if location services are enabled
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }
    
    // Start listening to position updates
    final locationSettings = LocationSettings(
      accuracy: highAccuracy ? LocationAccuracy.high : LocationAccuracy.medium,
      distanceFilter: 5, // Minimum 5 meters between updates
    );
    
    _positionSubscription = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen(_handlePositionUpdate);
    
    _isActive = true;
    return true;
  }
  
  /// Handle raw position update from GPS
  void _handlePositionUpdate(Position position) {
    final now = DateTime.now();
    final point = LocationPoint(
      latitude: position.latitude,
      longitude: position.longitude,
      accuracy: position.accuracy,
      heading: position.heading,
      speed: position.speed,
      timestamp: now,
    );
    
    // 1. Check for anomalies (GPS spoofing, unrealistic values)
    final anomaly = _checkForAnomalies(point);
    if (anomaly != null) {
      onAnomalyDetected?.call(anomaly);
      // Don't discard entirely, but flag it
      point.isFlagged = true;
    }
    
    // 2. Filter out low-accuracy readings
    if (position.accuracy > _minAccuracy) {
      return; // Skip this reading
    }
    
    // 3. Apply Kalman filter for smoothing
    final filteredPoint = _applyKalmanFilter(point);
    
    // 4. Store recent points for interpolation
    _recentPoints.add(point);
    if (_recentPoints.length > 100) {
      _recentPoints.removeAt(0);
    }
    
    // 5. Emit updates
    onLocationUpdate?.call(point);
    _locationStreamController.add(point);
    
    onFilteredLocationUpdate?.call(filteredPoint);
    _filteredStreamController.add(filteredPoint);
  }
  
  /// Apply Kalman filter to smooth GPS readings
  LocationPoint _applyKalmanFilter(LocationPoint raw) {
    _kalmanFilter.process(
      latitude: raw.latitude,
      longitude: raw.longitude,
      accuracy: raw.accuracy,
      timestamp: raw.timestamp.millisecondsSinceEpoch,
    );
    
    return LocationPoint(
      latitude: _kalmanFilter.latitude,
      longitude: _kalmanFilter.longitude,
      accuracy: raw.accuracy, // Keep original accuracy for reference
      heading: raw.heading,
      speed: raw.speed,
      timestamp: raw.timestamp,
      isFiltered: true,
      originalLatitude: raw.latitude,
      originalLongitude: raw.longitude,
    );
  }
  
  /// Check for GPS anomalies (spoofing detection)
  GpsAnomaly? _checkForAnomalies(LocationPoint point) {
    if (_recentPoints.isEmpty) return null;
    
    final lastPoint = _recentPoints.last;
    final timeDiff = point.timestamp.difference(lastPoint.timestamp).inSeconds;
    
    if (timeDiff <= 0) return null;
    
    // Check for unrealistic speed
    final distance = GeoUtils.distanceBetween(
      lastPoint.latitude,
      lastPoint.longitude,
      point.latitude,
      point.longitude,
    );
    final speedKmh = (distance / timeDiff) * 3.6;
    
    if (speedKmh > AppConstants.gpsMaxSpeedKmh) {
      return GpsAnomaly(
        type: GpsAnomalyType.unrealisticSpeed,
        description: 'Speed $speedKmh km/h exceeds max ${AppConstants.gpsMaxSpeedKmh} km/h',
        value: speedKmh,
        threshold: AppConstants.gpsMaxSpeedKmh,
        timestamp: point.timestamp,
      );
    }
    
    // Check for GPS jumping (teleportation)
    if (distance > 500 && timeDiff < 5) {
      return GpsAnomaly(
        type: GpsAnomalyType.gpsJump,
        description: 'Location jumped ${distance.toStringAsFixed(0)}m in ${timeDiff}s',
        value: distance,
        threshold: 500,
        timestamp: point.timestamp,
      );
    }
    
    // Check for accuracy degradation
    if (point.accuracy > 200) {
      return GpsAnomaly(
        type: GpsAnomalyType.poorAccuracy,
        description: 'GPS accuracy ${point.accuracy.toStringAsFixed(0)}m is too poor',
        value: point.accuracy,
        threshold: 200,
        timestamp: point.timestamp,
      );
    }
    
    return null;
  }
  
  /// Switch to active tracking mode (during trip - more frequent updates)
  void switchToActiveMode() {
    _updateIntervalMs = AppConstants.gpsUpdateIntervalActiveMs;
    // Could restart the stream with new settings here
  }
  
  /// Switch to passive tracking mode (idle - less frequent updates)
  void switchToPassiveMode() {
    _updateIntervalMs = AppConstants.gpsUpdateIntervalMs;
  }
  
  /// Stop tracking GPS location
  void stopTracking() {
    _positionSubscription?.cancel();
    _positionSubscription = null;
    _isActive = false;
    _recentPoints.clear();
    _kalmanFilter.reset();
  }
  
  /// Get current location once
  Future<LocationPoint?> getCurrentLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 10),
      );
      return LocationPoint(
        latitude: position.latitude,
        longitude: position.longitude,
        accuracy: position.accuracy,
        heading: position.heading,
        speed: position.speed,
        timestamp: DateTime.now(),
      );
    } catch (e) {
      return null;
    }
  }
  
  /// Dispose resources
  void dispose() {
    stopTracking();
    _locationStreamController.close();
    _filteredStreamController.close();
  }
}

/// Location point with additional metadata
class LocationPoint {
  final double latitude;
  final double longitude;
  final double accuracy;
  final double heading;
  final double speed;
  final DateTime timestamp;
  final bool isFiltered;
  final double? originalLatitude;
  final double? originalLongitude;
  bool isFlagged;

  LocationPoint({
    required this.latitude,
    required this.longitude,
    required this.accuracy,
    required this.heading,
    required this.speed,
    required this.timestamp,
    this.isFiltered = false,
    this.originalLatitude,
    this.originalLongitude,
    this.isFlagged = false,
  });
}

/// GPS anomaly types
enum GpsAnomalyType {
  unrealisticSpeed,
  gpsJump,
  poorAccuracy,
  mockLocation,
  duplicatePoint,
}

/// GPS anomaly detection result
class GpsAnomaly {
  final GpsAnomalyType type;
  final String description;
  final double value;
  final double threshold;
  final DateTime timestamp;

  GpsAnomaly({
    required this.type,
    required this.description,
    required this.value,
    required this.threshold,
    required this.timestamp,
  });
}
