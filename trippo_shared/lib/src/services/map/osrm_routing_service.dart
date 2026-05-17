import 'package:dio/dio.dart';
import 'package:latlong2/latlong.dart';
import 'route_parser.dart';

/// OSRM Routing Service - Open Source Routing Machine
///
/// Uses the public OSRM demo server for development/testing.
/// In production, deploy your own OSRM instance with regional data.
///
/// Public server: https://router.project-osrm.org
/// Self-hosted: http://your-server:5000
///
/// Rate limits on public server: ~1 request/second
/// For production, self-host OSRM with Docker:
///   docker run -t -v $(pwd):/data -p 5000:5000 osrm/osrm-backend osrm-routed --algorithm mld /data/your-region.osrm

class OsrmRoutingService {
  final Dio _dio;

  /// Base URL for OSRM server
  final String baseUrl;

  /// Default constructor with public OSRM server
  OsrmRoutingService({
    Dio? dio,
    this.baseUrl = 'https://router.project-osrm.org',
  }) : _dio = dio ?? Dio(BaseOptions(
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 15),
          headers: {
            'User-Agent': 'Madar-RideHailing/2.0',
          },
        ));

  /// Create with custom (self-hosted) OSRM server
  factory OsrmRoutingService.selfHosted(String serverUrl, {Dio? dio}) {
    return OsrmRoutingService(dio: dio, baseUrl: serverUrl);
  }

  // ==================== Routing ====================

  /// Get route between two points
  ///
  /// Returns a list of [LatLng] points forming the route polyline.
  /// Uses OSRM route service with GeoJSON geometry.
  Future<OsrmRouteResult> getRoute({
    required LatLng origin,
    required LatLng destination,
    List<LatLng>? waypoints,
    bool alternatives = false,
    OsrmProfile profile = OsrmProfile.driving,
  }) async {
    try {
      // Build coordinate string: lng,lat;lng,lat;...
      final coords = <String>[
        '${origin.longitude},${origin.latitude}',
      ];

      for (final wp in (waypoints ?? <LatLng>[])) {
        coords.add('${wp.longitude},${wp.latitude}');
      }

      coords.add('${destination.longitude},${destination.latitude}');

      final coordString = coords.join(';');

      final url = '$baseUrl/route/v1/${profile.name}/$coordString'
          '?overview=full'
          '&geometries=geojson'
          '&steps=true'
          '&alternatives=$alternatives';

      final response = await _dio.get(url);

      if (response.statusCode == 200 && response.data != null) {
        return OsrmRouteResult.fromOsrmResponse(response.data);
      }

      throw OsrmException('OSRM returned status ${response.statusCode}');
    } on DioException catch (e) {
      throw OsrmException('Network error: ${e.message}');
    } catch (e) {
      if (e is OsrmException) rethrow;
      throw OsrmException('Routing failed: $e');
    }
  }

  /// Get distance and duration between two points (no geometry)
  Future<({double distanceKm, int durationSeconds})> getDistanceAndDuration({
    required LatLng origin,
    required LatLng destination,
    OsrmProfile profile = OsrmProfile.driving,
  }) async {
    try {
      final coordString =
          '${origin.longitude},${origin.latitude};${destination.longitude},${destination.latitude}';

      final url = '$baseUrl/route/v1/${profile.name}/$coordString'
          '?overview=false';

      final response = await _dio.get(url);

      if (response.statusCode == 200 && response.data != null) {
        final routes = response.data['routes'] as List<dynamic>;
        if (routes.isNotEmpty) {
          final route = routes[0];
          return (
            distanceKm: (route['distance'] as num).toDouble() / 1000.0,
            durationSeconds: (route['duration'] as num).toInt(),
          );
        }
      }

      throw OsrmException('No route found');
    } on DioException catch (e) {
      throw OsrmException('Network error: ${e.message}');
    } catch (e) {
      if (e is OsrmException) rethrow;
      throw OsrmException('Distance calculation failed: $e');
    }
  }

  /// Get nearest road point for a given coordinate (snap to road)
  Future<LatLng?> snapToRoad(LatLng point) async {
    try {
      final url = '$baseUrl/nearest/v1/driving/${point.longitude},${point.latitude}';

      final response = await _dio.get(url);

      if (response.statusCode == 200 && response.data != null) {
        final waypoints = response.data['waypoints'] as List<dynamic>;
        if (waypoints.isNotEmpty) {
          final location = waypoints[0]['location'] as List<dynamic>;
          return LatLng(
            (location[1] as num).toDouble(),
            (location[0] as num).toDouble(),
          );
        }
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Get a table of distances/durations between multiple points
  /// Useful for driver matching (distance from driver to multiple riders)
  Future<OsrmTableResult> getDistanceTable({
    required List<LatLng> origins,
    required List<LatLng> destinations,
    OsrmProfile profile = OsrmProfile.driving,
  }) async {
    try {
      final originCoords = origins
          .map((p) => '${p.longitude},${p.latitude}')
          .join(';');
      final destCoords = destinations
          .map((p) => '${p.longitude},${p.latitude}')
          .join(';');

      // If same points, use single source
      final allCoords = originCoords == destCoords
          ? originCoords
          : '$originCoords;$destCoords';

      final url = '$baseUrl/table/v1/${profile.name}/$allCoords'
          '?annotations=distance,duration';

      final response = await _dio.get(url);

      if (response.statusCode == 200 && response.data != null) {
        return OsrmTableResult.fromOsrmResponse(response.data);
      }

      throw OsrmException('Table request failed');
    } catch (e) {
      if (e is OsrmException) rethrow;
      throw OsrmException('Table request failed: $e');
    }
  }
}

// ==================== Data Classes ====================

/// Result from OSRM route request
class OsrmRouteResult {
  final List<LatLng> polylinePoints;
  final double distanceMeters;
  final int durationSeconds;
  final List<OsrmStep> steps;
  final List<OsrmRouteResult>? alternatives;

  const OsrmRouteResult({
    required this.polylinePoints,
    required this.distanceMeters,
    required this.durationSeconds,
    this.steps = const [],
    this.alternatives,
  });

  /// Parse from OSRM JSON response
  factory OsrmRouteResult.fromOsrmResponse(Map<String, dynamic> json) {
    final routes = json['routes'] as List<dynamic>;
    if (routes.isEmpty) {
      throw OsrmException('No routes found in OSRM response');
    }

    final mainRoute = routes[0] as Map<String, dynamic>;
    final geometry = mainRoute['geometry'] as Map<String, dynamic>;
    final coords = geometry['coordinates'] as List<dynamic>;

    final points = RouteParser.parseGeoJsonCoordinates(coords);

    final stepsList = <OsrmStep>[];
    final legs = mainRoute['legs'] as List<dynamic>?;
    if (legs != null && legs.isNotEmpty) {
      final steps = legs[0]['steps'] as List<dynamic>?;
      if (steps != null) {
        for (final step in steps) {
          stepsList.add(OsrmStep.fromJson(step as Map<String, dynamic>));
        }
      }
    }

    // Parse alternative routes if present
    List<OsrmRouteResult>? altRoutes;
    if (routes.length > 1) {
      altRoutes = [];
      for (var i = 1; i < routes.length; i++) {
        final altRoute = routes[i] as Map<String, dynamic>;
        final altGeom = altRoute['geometry'] as Map<String, dynamic>;
        final altCoords = altGeom['coordinates'] as List<dynamic>;
        altRoutes.add(OsrmRouteResult(
          polylinePoints: RouteParser.parseGeoJsonCoordinates(altCoords),
          distanceMeters: (altRoute['distance'] as num).toDouble(),
          durationSeconds: (altRoute['duration'] as num).toInt(),
        ));
      }
    }

    return OsrmRouteResult(
      polylinePoints: points,
      distanceMeters: (mainRoute['distance'] as num).toDouble(),
      durationSeconds: (mainRoute['duration'] as num).toInt(),
      steps: stepsList,
      alternatives: altRoutes,
    );
  }

  /// Distance in kilometers
  double get distanceKm => distanceMeters / 1000.0;

  /// Duration in minutes
  double get durationMinutes => durationSeconds / 60.0;

  /// Estimated fare helper (base + per_km + per_min)
  double estimateFare({
    required double baseFare,
    required double perKmRate,
    required double perMinRate,
    double? surgeMultiplier,
  }) {
    final multiplier = surgeMultiplier ?? 1.0;
    return (baseFare + (distanceKm * perKmRate) + (durationMinutes * perMinRate)) * multiplier;
  }
}

/// A single step in the route
class OsrmStep {
  final String? name;
  final double distanceMeters;
  final int durationSeconds;
  final String? maneuverType;
  final String? maneuverModifier;
  final LatLng? startLocation;
  final LatLng? endLocation;

  const OsrmStep({
    this.name,
    required this.distanceMeters,
    required this.durationSeconds,
    this.maneuverType,
    this.maneuverModifier,
    this.startLocation,
    this.endLocation,
  });

  factory OsrmStep.fromJson(Map<String, dynamic> json) {
    final maneuver = json['maneuver'] as Map<String, dynamic>?;
    LatLng? start;
    LatLng? end;

    if (maneuver?['location'] != null) {
      final loc = maneuver!['location'] as List<dynamic>;
      start = LatLng((loc[1] as num).toDouble(), (loc[0] as num).toDouble());
    }

    return OsrmStep(
      name: json['name'] as String?,
      distanceMeters: (json['distance'] as num?)?.toDouble() ?? 0,
      durationSeconds: (json['duration'] as num?)?.toInt() ?? 0,
      maneuverType: maneuver?['type'] as String?,
      maneuverModifier: maneuver?['modifier'] as String?,
      startLocation: start,
      endLocation: end,
    );
  }
}

/// Result from OSRM table request
class OsrmTableResult {
  final List<List<double>> distances; // in meters
  final List<List<double>> durations; // in seconds

  const OsrmTableResult({
    required this.distances,
    required this.durations,
  });

  factory OsrmTableResult.fromOsrmResponse(Map<String, dynamic> json) {
    final distArrays = (json['distances'] as List<dynamic>)
        .map((row) => (row as List<dynamic>).map((v) => (v as num).toDouble()).toList())
        .toList();
    final durArrays = (json['durations'] as List<dynamic>)
        .map((row) => (row as List<dynamic>).map((v) => (v as num).toDouble()).toList())
        .toList();

    return OsrmTableResult(distances: distArrays, durations: durArrays);
  }
}

/// OSRM routing profile
enum OsrmProfile {
  /// Car driving (default)
  driving,

  /// Bicycle
  cycling,

  /// Walking/foot
  walking,
}

/// OSRM exception
class OsrmException implements Exception {
  final String message;
  const OsrmException(this.message);

  @override
  String toString() => 'OsrmException: $message';
}
