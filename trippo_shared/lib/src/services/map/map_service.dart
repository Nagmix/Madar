import 'package:latlong2/latlong.dart';
import 'dart:math' as math;
import 'osrm_routing_service.dart';
import 'nominatim_service.dart';
import 'tile_provider.dart';
import 'route_parser.dart';

/// MapService - Unified abstraction for all map operations
///
/// This service provides a single entry point for all map-related operations:
/// - Routing (OSRM)
/// - Geocoding/Reverse geocoding (Nominatim)
/// - Place search (Nominatim)
/// - Tile provider configuration
/// - Camera animations
/// - Driver marker updates
///
/// The abstraction allows swapping underlying implementations
/// without changing consuming code.

class MapService {
  final OsrmRoutingService _routingService;
  final NominatimService _geocodingService;

  /// Create MapService with default (public) servers for testing
  MapService({
    OsrmRoutingService? routingService,
    NominatimService? geocodingService,
  })  : _routingService = routingService ?? OsrmRoutingService(),
        _geocodingService = geocodingService ?? NominatimService();

  /// Create MapService with self-hosted servers for production
  factory MapService.selfHosted({
    required String osrmUrl,
    required String nominatimUrl,
    String language = 'ar',
  }) {
    return MapService(
      routingService: OsrmRoutingService.selfHosted(osrmUrl),
      geocodingService: NominatimService.selfHosted(nominatimUrl, language: language),
    );
  }

  // ==================== Routing ====================

  /// Get route between two points
  Future<RouteResult> getRoute({
    required LatLng origin,
    required LatLng destination,
    List<LatLng>? waypoints,
  }) async {
    final result = await _routingService.getRoute(
      origin: origin,
      destination: destination,
      waypoints: waypoints,
    );

    return RouteResult(
      polylinePoints: result.polylinePoints,
      distanceMeters: result.distanceMeters,
      durationSeconds: result.durationSeconds,
      steps: result.steps.map((s) => RouteStepResult(
        instruction: _buildInstruction(s),
        distanceMeters: s.distanceMeters,
        durationSeconds: s.durationSeconds,
        startLocation: s.startLocation,
        endLocation: s.endLocation,
      )).toList(),
    );
  }

  /// Get distance and duration only (no geometry)
  Future<({double distanceKm, int durationSeconds})> getDistanceAndDuration({
    required LatLng origin,
    required LatLng destination,
  }) async {
    return _routingService.getDistanceAndDuration(
      origin: origin,
      destination: destination,
    );
  }

  // ==================== Geocoding ====================

  /// Reverse geocode: coordinates → address
  Future<GeocodeResult> reverseGeocode({
    required double latitude,
    required double longitude,
  }) async {
    final result = await _geocodingService.reverseGeocode(
      latitude: latitude,
      longitude: longitude,
    );

    return GeocodeResult(
      latitude: result.lat,
      longitude: result.lon,
      fullAddress: result.displayName,
      shortAddress: result.address?.shortAddress ?? result.displayName,
      name: result.name,
      city: result.address?.city,
      road: result.address?.road,
      countryCode: result.address?.countryCode,
    );
  }

  /// Forward geocode: address → coordinates
  Future<List<GeocodeResult>> geocode(String address, {int limit = 5}) async {
    final results = await _geocodingService.search(address, limit: limit);
    return results.map((r) => GeocodeResult(
      latitude: r.lat,
      longitude: r.lon,
      fullAddress: r.displayName,
      shortAddress: r.address?.shortAddress ?? r.displayName,
      name: r.name ?? r.address?.road,
      city: r.address?.city,
      road: r.address?.road,
      countryCode: r.address?.countryCode,
    )).toList();
  }

  // ==================== Place Search ====================

  /// Search for places (autocomplete)
  Future<List<PlaceResult>> searchPlace(
    String query, {
    int limit = 5,
    LatLng? nearPosition,
  }) async {
    final results = await _geocodingService.autocomplete(
      query,
      limit: limit,
      nearPosition: nearPosition,
    );

    return results.map((r) => PlaceResult(
      placeId: r.placeId?.toString() ?? '',
      name: r.name ?? r.address?.road ?? r.displayName.split(',').first.trim(),
      fullAddress: r.displayName,
      shortAddress: r.address?.shortAddress ?? r.displayName,
      latitude: r.lat,
      longitude: r.lon,
      type: r.type,
      importance: r.importance,
    )).toList();
  }

  // ==================== Camera ====================

  /// Calculate camera position to show route with padding
  CameraFitResult calculateCameraFit(List<LatLng> points, {double padding = 0.02}) {
    if (points.isEmpty) {
      return const CameraFitResult(
        center: LatLng(15.3694, 44.1910), // Sana'a, Yemen default
        zoom: 12.0,
      );
    }

    final bounds = RouteParser.calculateBounds(points);
    if (bounds == null) {
      return const CameraFitResult(
        center: LatLng(15.3694, 44.1910),
        zoom: 12.0,
      );
    }

    final paddedBounds = RouteParser.padBounds(bounds, padding);

    final centerLat = (paddedBounds.southWest.latitude + paddedBounds.northEast.latitude) / 2;
    final centerLng = (paddedBounds.southWest.longitude + paddedBounds.northEast.longitude) / 2;

    // Calculate appropriate zoom level based on bounds size
    final latDiff = paddedBounds.northEast.latitude - paddedBounds.southWest.latitude;
    final lngDiff = paddedBounds.northEast.longitude - paddedBounds.southWest.longitude;
    final maxDiff = latDiff > lngDiff ? latDiff : lngDiff;

    double zoom;
    if (maxDiff > 1.0) {
      zoom = 6.0;
    } else if (maxDiff > 0.5) {
      zoom = 8.0;
    } else if (maxDiff > 0.1) {
      zoom = 10.0;
    } else if (maxDiff > 0.05) {
      zoom = 12.0;
    } else if (maxDiff > 0.01) {
      zoom = 14.0;
    } else {
      zoom = 16.0;
    }

    return CameraFitResult(
      center: LatLng(centerLat, centerLng),
      zoom: zoom,
      bounds: paddedBounds,
    );
  }

  // ==================== Driver Tracking ====================

  /// Update driver marker position with animation data
  /// Returns interpolated position for smooth movement
  DriverMarkerUpdate updateDriverMarker({
    required LatLng previousPosition,
    required LatLng newPosition,
    required DateTime previousTime,
    required DateTime currentTime,
  }) {
    // Calculate bearing/heading
    final bearing = _calculateBearing(previousPosition, newPosition);

    // Calculate speed in m/s
    final timeDiff = currentTime.difference(previousTime).inMilliseconds;
    final distance = _haversineDistance(previousPosition, newPosition);
    final speedMs = timeDiff > 0 ? (distance / timeDiff) * 1000 : 0.0;

    return DriverMarkerUpdate(
      position: newPosition,
      bearing: bearing,
      speedMs: speedMs,
      timestamp: currentTime,
    );
  }

  // ==================== Tile Provider ====================

  /// Get tile URL template for current configuration
  String getTileUrl({bool isDarkTheme = true}) {
    if (isDarkTheme) {
      return TileProviderLayer.darkThemeTileUrl;
    }
    return TileProviderLayer.lightThemeTileUrl;
  }

  // ==================== Helpers ====================

  /// Build instruction string from OSRM step
  String _buildInstruction(OsrmStep step) {
    final buffer = StringBuffer();
    if (step.maneuverType != null) {
      buffer.write(_translateManeuver(step.maneuverType!, step.maneuverModifier));
    }
    if (step.name != null && step.name!.isNotEmpty) {
      if (buffer.isNotEmpty) buffer.write(' onto ');
      buffer.write(step.name!);
    }
    return buffer.isEmpty ? 'Continue' : buffer.toString();
  }

  /// Translate OSRM maneuver type to human-readable instruction
  String _translateManeuver(String type, String? modifier) {
    const maneuverMap = {
      'turn': 'Turn',
      'new name': 'Continue',
      'depart': 'Head',
      'arrive': 'Arrive',
      'merge': 'Merge',
      'on ramp': 'Take the ramp',
      'off ramp': 'Take the exit',
      'fork': 'Take the fork',
      'end of road': 'Turn',
      'roundabout': 'Enter the roundabout',
      'rotary': 'Enter the rotary',
    };

    final directionMap = {
      'left': 'left',
      'right': 'right',
      'slight left': 'slight left',
      'slight right': 'slight right',
      'sharp left': 'sharp left',
      'sharp right': 'sharp right',
      'straight': 'straight',
      'uturn': 'make a U-turn',
    };

    final base = maneuverMap[type] ?? type;
    final dir = modifier != null ? directionMap[modifier] ?? modifier : null;

    if (dir != null && type != 'arrive' && type != 'depart') {
      return '$base $dir';
    }
    return base;
  }

  /// Calculate bearing between two points in degrees
  double _calculateBearing(LatLng start, LatLng end) {
    final lat1 = _toRadians(start.latitude);
    final lat2 = _toRadians(end.latitude);
    final dLng = _toRadians(end.longitude - start.longitude);

    // Bearing calculation using dart:math
    final bearing = math.atan2(math.sin(dLng) * math.cos(lat2),
        math.cos(lat1) * math.sin(lat2) - math.sin(lat1) * math.cos(lat2) * math.cos(dLng));

    return (bearing * 180 / math.pi + 360) % 360;
  }

  // Math functions provided by dart:math (accessed as math.sin, math.cos, etc.)

  double _toRadians(double degrees) => degrees * math.pi / 180;

  /// Haversine distance between two points in meters
  double _haversineDistance(LatLng p1, LatLng p2) {
    const earthRadius = 6371000.0;
    final dLat = _toRadians(p2.latitude - p1.latitude);
    final dLng = _toRadians(p2.longitude - p1.longitude);
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRadians(p1.latitude)) *
            math.cos(_toRadians(p2.latitude)) *
            math.sin(dLng / 2) * math.sin(dLng / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadius * c;
  }
}

// Math functions provided by dart:math via 'math' prefix

// ==================== Result Data Classes ====================

/// Route result from MapService
class RouteResult {
  final List<LatLng> polylinePoints;
  final double distanceMeters;
  final int durationSeconds;
  final List<RouteStepResult> steps;

  const RouteResult({
    required this.polylinePoints,
    required this.distanceMeters,
    required this.durationSeconds,
    this.steps = const [],
  });

  double get distanceKm => distanceMeters / 1000;
  double get durationMinutes => durationSeconds / 60;
}

/// A single step in the route
class RouteStepResult {
  final String instruction;
  final double distanceMeters;
  final int durationSeconds;
  final LatLng? startLocation;
  final LatLng? endLocation;

  const RouteStepResult({
    required this.instruction,
    required this.distanceMeters,
    required this.durationSeconds,
    this.startLocation,
    this.endLocation,
  });
}

/// Geocode result
class GeocodeResult {
  final double latitude;
  final double longitude;
  final String fullAddress;
  final String shortAddress;
  final String? name;
  final String? city;
  final String? road;
  final String? countryCode;

  const GeocodeResult({
    required this.latitude,
    required this.longitude,
    required this.fullAddress,
    required this.shortAddress,
    this.name,
    this.city,
    this.road,
    this.countryCode,
  });

  LatLng get location => LatLng(latitude, longitude);
}

/// Place search result
class PlaceResult {
  final String placeId;
  final String name;
  final String fullAddress;
  final String shortAddress;
  final double latitude;
  final double longitude;
  final String? type;
  final double? importance;

  const PlaceResult({
    required this.placeId,
    required this.name,
    required this.fullAddress,
    required this.shortAddress,
    required this.latitude,
    required this.longitude,
    this.type,
    this.importance,
  });

  LatLng get location => LatLng(latitude, longitude);
}

/// Camera fit result
class CameraFitResult {
  final LatLng center;
  final double zoom;
  final ({LatLng southWest, LatLng northEast})? bounds;

  const CameraFitResult({
    required this.center,
    required this.zoom,
    this.bounds,
  });
}

/// Driver marker update data
class DriverMarkerUpdate {
  final LatLng position;
  final double bearing;
  final double speedMs;
  final DateTime timestamp;

  const DriverMarkerUpdate({
    required this.position,
    required this.bearing,
    required this.speedMs,
    required this.timestamp,
  });

  /// Speed in km/h
  double get speedKmh => speedMs * 3.6;
}
