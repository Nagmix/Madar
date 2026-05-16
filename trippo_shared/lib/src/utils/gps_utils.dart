import 'dart:math';

/// GPS Utilities - Helper functions for GPS calculations
class GpsUtils {
  GpsUtils._();

  /// Calculate distance between two GPS points using Haversine formula
  /// Returns distance in meters
  static double distanceBetween(
    double lat1,
    double lng1,
    double lat2,
    double lng2,
  ) {
    const earthRadius = 6371000.0; // Earth's radius in meters
    
    final dLat = _toRadians(lat2 - lat1);
    final dLng = _toRadians(lng2 - lng1);
    
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) * cos(_toRadians(lat2)) *
        sin(dLng / 2) * sin(dLng / 2);
    
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    
    return earthRadius * c;
  }

  /// Calculate bearing between two GPS points
  /// Returns bearing in degrees (0-360)
  static double bearingBetween(
    double lat1,
    double lng1,
    double lat2,
    double lng2,
  ) {
    final dLng = _toRadians(lng2 - lng1);
    
    final y = sin(dLng) * cos(_toRadians(lat2));
    final x = cos(_toRadians(lat1)) * sin(_toRadians(lat2)) -
        sin(_toRadians(lat1)) * cos(_toRadians(lat2)) * cos(dLng);
    
    final bearing = atan2(y, x);
    return (_toDegrees(bearing) + 360) % 360;
  }

  /// Interpolate between two GPS points
  /// Returns a point at the given fraction (0.0 to 1.0) between the two points
  static ({double latitude, double longitude}) interpolate({
    required double lat1,
    required double lng1,
    required double lat2,
    required double lng2,
    required double fraction,
  }) {
    // Simple linear interpolation for short distances
    // For longer distances, great circle interpolation would be more accurate
    return (
      latitude: lat1 + (lat2 - lat1) * fraction,
      longitude: lng1 + (lng2 - lng1) * fraction,
    );
  }

  /// Check if a point is inside a polygon (for geo-fencing)
  /// Uses the ray casting algorithm
  static bool isPointInPolygon({
    required double latitude,
    required double longitude,
    required List<({double latitude, double longitude})> polygon,
  }) {
    int intersections = 0;
    final n = polygon.length;
    
    for (int i = 0; i < n; i++) {
      final j = (i + 1) % n;
      
      final v1 = polygon[i];
      final v2 = polygon[j];
      
      if (_rayIntersects(
        latitude, longitude,
        v1.latitude, v1.longitude,
        v2.latitude, v2.longitude,
      )) {
        intersections++;
      }
    }
    
    return intersections % 2 == 1;
  }

  static bool _rayIntersects(
    double px, double py,
    double x1, double y1,
    double x2, double y2,
  ) {
    if ((y1 > py) == (y2 > py)) return false;
    
    final xIntersect = x1 + (py - y1) / (y2 - y1) * (x2 - x1);
    return px < xIntersect;
  }

  /// Calculate the centroid of a polygon
  static ({double latitude, double longitude}) polygonCentroid(
    List<({double latitude, double longitude})> polygon,
  ) {
    double sumLat = 0;
    double sumLng = 0;
    
    for (final point in polygon) {
      sumLat += point.latitude;
      sumLng += point.longitude;
    }
    
    return (
      latitude: sumLat / polygon.length,
      longitude: sumLng / polygon.length,
    );
  }

  /// Calculate speed between two GPS points
  /// Returns speed in km/h
  static double calculateSpeed({
    required double lat1,
    required double lng1,
    required double lat2,
    required double lng2,
    required int timeDifferenceSeconds,
  }) {
    if (timeDifferenceSeconds <= 0) return 0.0;
    
    final distanceMeters = distanceBetween(lat1, lng1, lat2, lng2);
    final speedMs = distanceMeters / timeDifferenceSeconds;
    return speedMs * 3.6; // Convert m/s to km/h
  }

  /// Calculate ETA (Estimated Time of Arrival) in minutes
  static int calculateETA({
    required double distanceMeters,
    double averageSpeedKmh = 30.0,
  }) {
    if (averageSpeedKmh <= 0) return 0;
    
    final distanceKm = distanceMeters / 1000.0;
    final timeHours = distanceKm / averageSpeedKmh;
    return (timeHours * 60).ceil();
  }

  static double _toRadians(double degrees) => degrees * pi / 180;
  static double _toDegrees(double radians) => radians * 180 / pi;
}
