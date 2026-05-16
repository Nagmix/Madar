import 'dart:math';

/// Geo utility functions for coordinate conversions and checks
class GeoUtils {
  GeoUtils._();

  /// Earth's radius in meters
  static const double earthRadius = 6371000.0;

  /// Calculate distance between two coordinates using Haversine formula
  /// Returns distance in meters
  static double distanceBetween(
    double startLat,
    double startLng,
    double endLat,
    double endLng,
  ) {
    final dLat = _degreesToRadians(endLat - startLat);
    final dLng = _degreesToRadians(endLng - startLng);
    
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degreesToRadians(startLat)) *
            cos(_degreesToRadians(endLat)) *
            sin(dLng / 2) * sin(dLng / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    
    return earthRadius * c;
  }

  /// Convert meters to approximate latitude degrees
  static double metersToLatitude(double meters) {
    return meters / 111320.0;
  }

  /// Convert meters to approximate longitude degrees at given latitude
  static double metersToLongitude(double meters, double latitude) {
    return meters / (111320.0 * cos(_degreesToRadians(latitude)));
  }

  /// Create a bounding box around a point with given radius in meters
  static ({
    double minLat,
    double maxLat,
    double minLng,
    double maxLng,
  }) boundingBox({
    required double latitude,
    required double longitude,
    required double radiusMeters,
  }) {
    final latDelta = metersToLatitude(radiusMeters);
    final lngDelta = metersToLongitude(radiusMeters, latitude);
    
    return (
      minLat: latitude - latDelta,
      maxLat: latitude + latDelta,
      minLng: longitude - lngDelta,
      maxLng: longitude + lngDelta,
    );
  }

  static double _degreesToRadians(double degrees) => degrees * pi / 180;
}
