import 'package:latlong2/latlong.dart';
import 'osrm_routing_service.dart';
import 'maptiler_geocoding_service.dart';

/// MapService - Unified abstraction for all map operations
class MapService {
  final OsrmRoutingService _routingService;
  final MapTilerGeocodingService _geocodingService;

  MapService({
    OsrmRoutingService? routingService,
    MapTilerGeocodingService? geocodingService,
  })  : _routingService = routingService ?? OsrmRoutingService(),
        _geocodingService = geocodingService ?? MapTilerGeocodingService();

  /// Get route between two points
  Future<OsrmRouteResult> getRoute({
    required LatLng origin,
    required LatLng destination,
    List<LatLng>? waypoints,
  }) async {
    return _routingService.getRoute(
      origin: origin,
      destination: destination,
      waypoints: waypoints,
    );
  }

  /// Get distance and duration only
  Future<({double distanceKm, int durationSeconds})> getDistanceAndDuration({
    required LatLng origin,
    required LatLng destination,
  }) async {
    return _routingService.getDistanceAndDuration(origin: origin, destination: destination);
  }

  /// Reverse geocode: coordinates -> address
  Future<GeocodeResult> reverseGeocode({
    required double latitude,
    required double longitude,
  }) async {
    final result = await _geocodingService.reverseGeocode(latitude: latitude, longitude: longitude);
    return GeocodeResult(
      latitude: result.lat,
      longitude: result.lon,
      fullAddress: result.displayName,
      shortAddress: result.shortAddress.isNotEmpty ? result.shortAddress : result.displayName,
    );
  }

  /// Search places: text -> list of places
  Future<List<PlaceSearchResult>> searchPlaces(String query, {LatLng? nearPosition, int limit = 5}) async {
    try {
      final results = await _geocodingService.search(query, limit: limit, nearPosition: nearPosition);
      return results.map((r) => PlaceSearchResult(
        shortAddress: r.shortAddress,
        fullAddress: r.displayName,
        location: LatLng(r.lat, r.lon),
      )).toList();
    } catch (e) {
      return [];
    }
  }
}

class GeocodeResult {
  final double latitude;
  final double longitude;
  final String fullAddress;
  final String shortAddress;
  const GeocodeResult({required this.latitude, required this.longitude, required this.fullAddress, required this.shortAddress});
}

class PlaceSearchResult {
  final String shortAddress;
  final String fullAddress;
  final LatLng location;
  const PlaceSearchResult({required this.shortAddress, required this.fullAddress, required this.location});
}
