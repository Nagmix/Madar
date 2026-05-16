import 'api_service.dart';
import '../constants/api_constants.dart';
import '../constants/app_constants.dart';
import '../models/location_model.dart';
import '../utils/geo_utils.dart';

/// GeoSpatialService - Geo queries via NestJS Geo Module (PostGIS)
///
/// All heavy geospatial queries are handled by the NestJS backend using PostGIS:
/// - ST_Distance, ST_Within, ST_Contains for spatial operations
/// - PostGIS geography type for accurate distance calculations
/// - Geofence intersection checks
/// - Reverse/forward geocoding via external APIs (proxied through NestJS)
///
/// Flutter is the client; NestJS handles all PostGIS queries.
/// Client-side point-in-polygon is provided as a fallback only.
class GeoSpatialService {
  final ApiService _apiService;

  /// Cached service areas for client-side checks
  List<GeoFence>? _cachedServiceAreas;

  GeoSpatialService({
    required ApiService apiService,
  }) : _apiService = apiService;

  // ==================== Geocoding ====================

  /// Reverse geocode - GET /geo/reverse-geocode
  /// Converts coordinates to an address using NestJS Geo Module.
  /// NestJS proxies to Google Maps Geocoding API or similar.
  Future<LocationModel> reverseGeocode(double lat, double lng) async {
    try {
      final response = await _apiService.get(
        ApiConstants.reverseGeocode,
        queryParameters: {
          'latitude': lat,
          'longitude': lng,
        },
      );

      return LocationModel.fromJson(
        response.data is Map<String, dynamic>
            ? response.data
            : Map<String, dynamic>.from(response.data as Map),
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Forward geocode - GET /geo/geocode
  /// Converts an address to coordinates using NestJS Geo Module.
  Future<LocationModel> geocode(String address) async {
    try {
      final response = await _apiService.get(
        ApiConstants.geocode,
        queryParameters: {
          'address': address,
        },
      );

      return LocationModel.fromJson(
        response.data is Map<String, dynamic>
            ? response.data
            : Map<String, dynamic>.from(response.data as Map),
      );
    } catch (e) {
      rethrow;
    }
  }

  // ==================== Places ====================

  /// Search places - GET /geo/places
  /// Proxied through NestJS to Google Places Autocomplete API.
  /// Returns a list of predicted places matching the query.
  Future<List<PredictedPlace>> searchPlaces(
    String query, {
    double? lat,
    double? lng,
    String? country,
    String? language,
  }) async {
    try {
      final response = await _apiService.get(
        ApiConstants.searchPlaces,
        queryParameters: {
          'query': query,
          if (lat != null) 'latitude': lat,
          if (lng != null) 'longitude': lng,
          if (country != null) 'country': country,
          if (language != null) 'language': language,
        },
      );

      final data = response.data;
      if (data is List) {
        return data
            .map((e) => PredictedPlace.fromJson(e as Map<String, dynamic>))
            .toList();
      } else if (data is Map<String, dynamic> && data.containsKey('items')) {
        final items = data['items'] as List<dynamic>;
        return items
            .map((e) => PredictedPlace.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }

  // ==================== Service Areas & Zones ====================

  /// Get service areas - GET /geo/service-areas
  /// Returns all active service areas from PostGIS.
  /// Service areas define where Trippo operates.
  Future<List<GeoFence>> getServiceAreas() async {
    try {
      final response = await _apiService.get(
        ApiConstants.serviceAreas,
      );

      final data = response.data;
      final areas = _parseGeoFenceList(data);
      _cachedServiceAreas = areas;
      return areas;
    } catch (e) {
      rethrow;
    }
  }

  /// Get zones - GET /geo/zones
  /// Returns all zones including surge zones, restricted areas, airport zones.
  /// Used for pricing, dispatch restrictions, and special area rules.
  Future<List<GeoFence>> getZones() async {
    try {
      final response = await _apiService.get(
        ApiConstants.zones,
      );

      return _parseGeoFenceList(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Check if point is in service area (client-side fallback)
  /// Uses ray-casting algorithm for point-in-polygon check.
  /// This is a fallback when server check is not available.
  /// For authoritative checks, use NestJS Geo Module endpoint.
  bool isInServiceArea(double lat, double lng, GeoFence area) {
    final polygon = area.polygon;
    if (polygon.isEmpty) return false;

    return _isPointInPolygon(lat, lng, polygon);
  }

  /// Check if a point is inside any service area
  /// Uses cached service areas; fetches them if not cached.
  Future<bool> isPointInAnyServiceArea(double lat, double lng) async {
    try {
      final areas = _cachedServiceAreas ?? await getServiceAreas();
      return areas.any((area) => isInServiceArea(lat, lng, area));
    } catch (e) {
      return false; // Fail open - allow operation if check fails
    }
  }

  // ==================== Directions ====================

  /// Get directions - GET /geo/directions (proxied through NestJS)
  /// Returns route information between two points.
  /// NestJS proxies to Google Directions API or OSRM.
  Future<RouteInfo> getDirections(
    double fromLat,
    double fromLng,
    double toLat,
    double toLng,
  ) async {
    try {
      final response = await _apiService.get(
        '/geo/directions',
        queryParameters: {
          'fromLatitude': fromLat,
          'fromLongitude': fromLng,
          'toLatitude': toLat,
          'toLongitude': toLng,
        },
      );

      return RouteInfo.fromJson(
        response.data is Map<String, dynamic>
            ? response.data
            : Map<String, dynamic>.from(response.data as Map),
      );
    } catch (e) {
      rethrow;
    }
  }

  // ==================== Utility Methods ====================

  /// Calculate distance between two points (client-side, Haversine)
  /// Uses GeoUtils.distanceBetween for approximate distance.
  /// For accurate PostGIS calculations, use the NestJS endpoint.
  double calculateDistance(
    double fromLat,
    double fromLng,
    double toLat,
    double toLng,
  ) {
    return GeoUtils.distanceBetween(fromLat, fromLng, toLat, toLng);
  }

  /// Create a bounding box around a point (client-side utility)
  /// Useful for map camera bounds and search area visualization.
  GeoBounds createBoundingBox({
    required double latitude,
    required double longitude,
    required double radiusMeters,
  }) {
    final box = GeoUtils.boundingBox(
      latitude: latitude,
      longitude: longitude,
      radiusMeters: radiusMeters,
    );
    return GeoBounds(
      northeastLat: box.maxLat,
      northeastLng: box.maxLng,
      southwestLat: box.minLat,
      southwestLng: box.minLng,
    );
  }

  // ==================== Private Helpers ====================

  /// Parse a list of GeoFence from API response data
  List<GeoFence> _parseGeoFenceList(dynamic data) {
    if (data is List) {
      return data
          .map((e) => GeoFence.fromJson(e as Map<String, dynamic>))
          .toList();
    } else if (data is Map<String, dynamic> && data.containsKey('items')) {
      final items = data['items'] as List<dynamic>;
      return items
          .map((e) => GeoFence.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  /// Ray-casting algorithm for point-in-polygon check
  /// Determines if a point (lat, lng) is inside a polygon.
  bool _isPointInPolygon(
    double lat,
    double lng,
    List<LocationModel> polygon,
  ) {
    int crossings = 0;
    final n = polygon.length;

    for (int i = 0; i < n; i++) {
      final j = (i + 1) % n;
      final yi = polygon[i].latitude;
      final xi = polygon[i].longitude;
      final yj = polygon[j].latitude;
      final xj = polygon[j].longitude;

      // Check if the ray from point to the right crosses this edge
      if (((yi <= lat && yj > lat) || (yj <= lat && yi > lat)) &&
          (lng < (xj - xi) * (lat - yi) / (yj - yi) + xi)) {
        crossings++;
      }
    }

    return crossings % 2 == 1;
  }

  /// Dispose resources
  void dispose() {
    _cachedServiceAreas = null;
  }
}

/// Predicted place result from place search
/// Matches the NestJS Geo Module response format
class PredictedPlace {
  /// Google Places place_id or internal ID
  final String placeId;

  /// Main text (e.g., "Riyadh International Airport")
  final String mainText;

  /// Secondary text (e.g., "King Fahd Road, Riyadh, Saudi Arabia")
  final String secondaryText;

  /// Full description
  final String description;

  PredictedPlace({
    required this.placeId,
    required this.mainText,
    required this.secondaryText,
    this.description = '',
  });

  factory PredictedPlace.fromJson(Map<String, dynamic> json) {
    return PredictedPlace(
      placeId: json['place_id'] as String? ?? json['placeId'] as String? ?? '',
      mainText: json['main_text'] as String? ??
          json['mainText'] as String? ??
          json['structured_formatting']?['main_text'] as String? ??
          '',
      secondaryText: json['secondary_text'] as String? ??
          json['secondaryText'] as String? ??
          json['structured_formatting']?['secondary_text'] as String? ??
          '',
      description: json['description'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'placeId': placeId,
        'mainText': mainText,
        'secondaryText': secondaryText,
        'description': description,
      };
}
