/// Kalman Filter for GPS smoothing
/// Reduces GPS noise and jitter by combining predictions with measurements
/// Based on the 2D Kalman filter with speed/heading consideration
class KalmanFilter {
  double _latitude = 0.0;
  double _longitude = 0.0;
  
  // Covariance matrix elements (simplified 2D)
  double _pLatitude = 0.0;
  double _pLongitude = 0.0;
  
  // Process noise (how much we expect the position to change)
  double _qLatitude = 0.000001; // ~0.1m variance
  double _qLongitude = 0.000001;
  
  // Measurement noise (GPS accuracy)
  double _rLatitude = 0.0;
  double _rLongitude = 0.0;
  
  double _velocityLatitude = 0.0;
  double _velocityLongitude = 0.0;
  
  int _lastTimestamp = 0;
  bool _isInitialized = false;
  
  double get latitude => _latitude;
  double get longitude => _longitude;
  
  /// Process a new GPS measurement
  void process({
    required double latitude,
    required double longitude,
    required double accuracy,
    required int timestamp,
  }) {
    // Set measurement noise based on GPS accuracy
    // Convert accuracy in meters to approximate lat/lng variance
    final accuracyVariance = _metersToLatLng(accuracy);
    _rLatitude = accuracyVariance;
    _rLongitude = accuracyVariance;
    
    if (!_isInitialized) {
      _initialize(latitude, longitude, timestamp);
      return;
    }
    
    // Time delta in seconds
    final dt = (timestamp - _lastTimestamp) / 1000.0;
    if (dt <= 0) return;
    
    // ==================== PREDICT ====================
    // Predict next position based on velocity
    _latitude += _velocityLatitude * dt;
    _longitude += _velocityLongitude * dt;
    
    // Update covariance (add process noise)
    _pLatitude += _qLatitude * dt;
    _pLongitude += _qLongitude * dt;
    
    // ==================== UPDATE ====================
    // Kalman gain
    final kLatitude = _pLatitude / (_pLatitude + _rLatitude);
    final kLongitude = _pLongitude / (_pLongitude + _rLongitude);
    
    // Update position with measurement
    _latitude += kLatitude * (latitude - _latitude);
    _longitude += kLongitude * (longitude - _longitude);
    
    // Update covariance
    _pLatitude *= (1 - kLatitude);
    _pLongitude *= (1 - kLongitude);
    
    // Update velocity estimate
    _velocityLatitude = (_latitude - (_latitude - kLatitude * (latitude - _latitude))) / dt;
    _velocityLongitude = (_longitude - (_longitude - kLongitude * (longitude - _longitude))) / dt;
    
    _lastTimestamp = timestamp;
  }
  
  void _initialize(double latitude, double longitude, int timestamp) {
    _latitude = latitude;
    _longitude = longitude;
    _lastTimestamp = timestamp;
    _pLatitude = _rLatitude;
    _pLongitude = _rLongitude;
    _isInitialized = true;
  }
  
  /// Convert meters to approximate lat/lng variance
  /// At the equator: 1 degree ≈ 111,320 meters
  double _metersToLatLng(double meters) {
    return (meters * meters) / (111320.0 * 111320.0);
  }
  
  /// Reset the filter state
  void reset() {
    _latitude = 0.0;
    _longitude = 0.0;
    _pLatitude = 0.0;
    _pLongitude = 0.0;
    _velocityLatitude = 0.0;
    _velocityLongitude = 0.0;
    _lastTimestamp = 0;
    _isInitialized = false;
  }
}
