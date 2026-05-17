import 'package:latlong2/latlong.dart';

/// RouteParser - Converts GeoJSON polyline data to drawable points
///
/// OSRM returns route geometry in GeoJSON format:
/// { "type": "LineString", "coordinates": [[lng, lat], [lng, lat], ...] }
///
/// This parser handles the conversion and provides utilities
/// for working with route polylines in flutter_map.

class RouteParser {
  RouteParser._();

  // ==================== GeoJSON Parsing ====================

  /// Parse GeoJSON coordinates array to List<LatLng>
  ///
  /// GeoJSON format: [longitude, latitude] (x, y order)
  /// LatLng format: (latitude, longitude) (y, x order)
  ///
  /// Input: [[46.6753, 24.7136], [46.6760, 24.7140], ...]
  /// Output: [LatLng(24.7136, 46.6753), LatLng(24.7140, 46.6760), ...]
  static List<LatLng> parseGeoJsonCoordinates(List<dynamic> coordinates) {
    final points = <LatLng>[];

    for (final coord in coordinates) {
      if (coord is List<dynamic> && coord.length >= 2) {
        final lng = (coord[0] as num).toDouble();
        final lat = (coord[1] as num).toDouble();
        points.add(LatLng(lat, lng));
      }
    }

    return points;
  }

  /// Parse a full GeoJSON FeatureCollection with LineString features
  static List<List<LatLng>> parseGeoJsonFeatureCollection(Map<String, dynamic> geojson) {
    final routes = <List<LatLng>>[];

    final features = geojson['features'] as List<dynamic>?;
    if (features == null) return routes;

    for (final feature in features) {
      final geometry = feature['geometry'] as Map<String, dynamic>?;
      if (geometry?['type'] == 'LineString') {
        final coords = geometry!['coordinates'] as List<dynamic>;
        routes.add(parseGeoJsonCoordinates(coords));
      }
    }

    return routes;
  }

  /// Parse GeoJSON LineString geometry
  static List<LatLng> parseGeoJsonLineString(Map<String, dynamic> geometry) {
    if (geometry['type'] != 'LineString') return [];
    final coords = geometry['coordinates'] as List<dynamic>;
    return parseGeoJsonCoordinates(coords);
  }

  // ==================== Polyline Simplification ====================

  /// Simplify a polyline using Douglas-Peucker algorithm
  /// Reduces the number of points while maintaining shape accuracy
  static List<LatLng> simplifyPolyline(List<LatLng> points, {double epsilon = 0.0001}) {
    if (points.length <= 2) return List.from(points);

    // Find the point with maximum distance from the line
    double maxDist = 0;
    int maxIndex = 0;

    final first = points.first;
    final last = points.last;

    for (var i = 1; i < points.length - 1; i++) {
      final dist = _perpendicularDistance(points[i], first, last);
      if (dist > maxDist) {
        maxDist = dist;
        maxIndex = i;
      }
    }

    // If max distance is greater than epsilon, recursively simplify
    if (maxDist > epsilon) {
      final left = simplifyPolyline(points.sublist(0, maxIndex + 1), epsilon: epsilon);
      final right = simplifyPolyline(points.sublist(maxIndex), epsilon: epsilon);

      return [...left.sublist(0, left.length - 1), ...right];
    } else {
      return [first, last];
    }
  }

  /// Calculate perpendicular distance from point to line segment
  static double _perpendicularDistance(LatLng point, LatLng lineStart, LatLng lineEnd) {
    final dx = lineEnd.longitude - lineStart.longitude;
    final dy = lineEnd.latitude - lineStart.latitude;

    // Normalize
    final mag = (dx * dx + dy * dy);
    if (mag == 0) {
      return _distanceBetween(point, lineStart);
    }

    final u = ((point.longitude - lineStart.longitude) * dx +
            (point.latitude - lineStart.latitude) * dy) /
        mag;

    LatLng closest;
    if (u < 0) {
      closest = lineStart;
    } else if (u > 1) {
      closest = lineEnd;
    } else {
      closest = LatLng(
        lineStart.latitude + u * dy,
        lineStart.longitude + u * dx,
      );
    }

    return _distanceBetween(point, closest);
  }

  /// Simple distance between two points (approximate)
  static double _distanceBetween(LatLng p1, LatLng p2) {
    final dLat = p2.latitude - p1.latitude;
    final dLng = p2.longitude - p1.longitude;
    return (dLat * dLat + dLng * dLng);
  }

  // ==================== Bounds Calculation ====================

  /// Calculate bounding box for a set of points
  /// Returns (southWest, northEast) or null if empty
  static ({LatLng southWest, LatLng northEast})? calculateBounds(List<LatLng> points) {
    if (points.isEmpty) return null;

    double minLat = points.first.latitude;
    double maxLat = points.first.latitude;
    double minLng = points.first.longitude;
    double maxLng = points.first.longitude;

    for (final p in points) {
      if (p.latitude < minLat) minLat = p.latitude;
      if (p.latitude > maxLat) maxLat = p.latitude;
      if (p.longitude < minLng) minLng = p.longitude;
      if (p.longitude > maxLng) maxLng = p.longitude;
    }

    return (
      southWest: LatLng(minLat, minLng),
      northEast: LatLng(maxLat, maxLng),
    );
  }

  /// Add padding to bounds (in approximate degrees)
  static ({LatLng southWest, LatLng northEast}) padBounds(
    ({LatLng southWest, LatLng northEast}) bounds,
    double paddingDegrees,
  ) {
    return (
      southWest: LatLng(
        bounds.southWest.latitude - paddingDegrees,
        bounds.southWest.longitude - paddingDegrees,
      ),
      northEast: LatLng(
        bounds.northEast.latitude + paddingDegrees,
        bounds.northEast.longitude + paddingDegrees,
      ),
    );
  }

  // ==================== Interpolation ====================

  /// Interpolate points along a route at regular intervals
  /// Useful for animating a marker along the route
  static List<LatLng> interpolateAlongRoute(List<LatLng> route, {int pointsPerSegment = 5}) {
    if (route.length < 2) return List.from(route);

    final result = <LatLng>[];

    for (var i = 0; i < route.length - 1; i++) {
      final start = route[i];
      final end = route[i + 1];

      for (var j = 0; j < pointsPerSegment; j++) {
        final t = j / pointsPerSegment;
        result.add(LatLng(
          start.latitude + (end.latitude - start.latitude) * t,
          start.longitude + (end.longitude - start.longitude) * t,
        ));
      }
    }

    // Add the last point
    result.add(route.last);
    return result;
  }

  /// Find the closest point on a route to a given position
  static int findClosestSegmentIndex(List<LatLng> route, LatLng position) {
    double minDist = double.infinity;
    int closestIndex = 0;

    for (var i = 0; i < route.length; i++) {
      final dist = _distanceBetween(route[i], position);
      if (dist < minDist) {
        minDist = dist;
        closestIndex = i;
      }
    }

    return closestIndex;
  }
}
