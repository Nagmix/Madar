import 'package:dio/dio.dart';
import 'package:latlong2/latlong.dart';

/// Nominatim Geocoding Service - OpenStreetMap geocoding
///
/// Uses Nominatim for geocoding (address → coordinates)
/// and reverse geocoding (coordinates → address).
///
/// Public server: https://nominatim.openstreetmap.org
/// Self-hosted: http://your-server:8080
///
/// Rate limits on public server: max 1 request/second
/// Required: Set a valid User-Agent header
/// For production, deploy your own Nominatim instance:
///   https://nominatim.org/release-docs/latest/admin/Installation/

class NominatimService {
  final Dio _dio;

  /// Base URL for Nominatim server
  final String baseUrl;

  /// Language preference for results (e.g., 'ar' for Arabic, 'en' for English)
  final String language;

  /// Default constructor with public Nominatim server
  NominatimService({
    Dio? dio,
    this.baseUrl = 'https://nominatim.openstreetmap.org',
    this.language = 'ar',
  }) : _dio = dio ?? Dio(BaseOptions(
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
          headers: {
            'User-Agent': 'Madar-RideHailing/2.0',
            'Accept-Language': language,
          },
        ));

  /// Create with custom (self-hosted) Nominatim server
  factory NominatimService.selfHosted(String serverUrl, {String language = 'ar', Dio? dio}) {
    return NominatimService(dio: dio, baseUrl: serverUrl, language: language);
  }

  // ==================== Search (Forward Geocoding) ====================

  /// Search for places by text query
  ///
  /// Returns a list of matching places with coordinates and addresses.
  /// Uses Nominatim search API.
  /// Defaults to Yemen (country code 'ye') and Yemen's bounded viewbox.
  Future<List<NominatimResult>> search(
    String query, {
    int limit = 5,
    LatLng? nearPosition,
    double? viewboxMinLat = 12.1,
    double? viewboxMinLng = 42.5,
    double? viewboxMaxLat = 19.0,
    double? viewboxMaxLng = 54.0,
    List<String> countryCodes = const ['ye'],
    bool bounded = false,
  }) async {
    try {
      final params = <String, dynamic>{
        'q': query,
        'format': 'jsonv2',
        'limit': limit,
        'addressdetails': 1,
        'extratags': 1,
        'namedetails': 1,
      };

      // Bias results toward a position
      if (nearPosition != null) {
        params['lat'] = nearPosition.latitude.toString();
        params['lon'] = nearPosition.longitude.toString();
      }

      // Limit to viewbox
      if (viewboxMinLat != null) {
        params['viewbox'] = '$viewboxMinLng,$viewboxMinLat,$viewboxMaxLng,$viewboxMaxLat';
        if (bounded) params['bounded'] = 1;
      }

      // Country filter
      if (countryCodes.isNotEmpty) {
        params['countrycodes'] = countryCodes.join(',');
      }

      final response = await _dio.get(
        '$baseUrl/search',
        queryParameters: params,
      );

      if (response.statusCode == 200 && response.data is List) {
        return (response.data as List<dynamic>)
            .map((e) => NominatimResult.fromJson(e as Map<String, dynamic>))
            .toList();
      }

      return [];
    } on DioException catch (e) {
      throw NominatimException('Network error: ${e.message}');
    } catch (e) {
      if (e is NominatimException) rethrow;
      throw NominatimException('Search failed: $e');
    }
  }

  // ==================== Reverse Geocoding ====================

  /// Reverse geocode coordinates to address
  ///
  /// Returns the address for the given coordinates.
  Future<NominatimResult> reverseGeocode({
    required double latitude,
    required double longitude,
    int zoom = 18,
  }) async {
    try {
      final response = await _dio.get(
        '$baseUrl/reverse',
        queryParameters: {
          'lat': latitude,
          'lon': longitude,
          'format': 'jsonv2',
          'zoom': zoom,
          'addressdetails': 1,
          'extratags': 1,
          'namedetails': 1,
        },
      );

      if (response.statusCode == 200 && response.data is Map) {
        return NominatimResult.fromJson(response.data as Map<String, dynamic>);
      }

      throw NominatimException('No result found for coordinates');
    } on DioException catch (e) {
      throw NominatimException('Network error: ${e.message}');
    } catch (e) {
      if (e is NominatimException) rethrow;
      throw NominatimException('Reverse geocoding failed: $e');
    }
  }

  // ==================== Autocomplete ====================

  /// Search for places with autocomplete-friendly behavior
  /// Returns results suitable for a dropdown/suggestion list
  Future<List<NominatimResult>> autocomplete(
    String query, {
    int limit = 5,
    LatLng? nearPosition,
  }) async {
    // Nominatim doesn't have a dedicated autocomplete endpoint,
    // but we can use the search endpoint with appropriate parameters
    // Defaults to Yemen bounds via the search method
    return search(
      query,
      limit: limit,
      nearPosition: nearPosition,
      countryCodes: const ['ye'],
      viewboxMinLat: 12.1,
      viewboxMinLng: 42.5,
      viewboxMaxLat: 19.0,
      viewboxMaxLng: 54.0,
    );
  }

  /// Get place details by OSM ID (lookup)
  Future<NominatimResult?> lookup(String osmType, int osmId) async {
    try {
      final response = await _dio.get(
        '$baseUrl/lookup',
        queryParameters: {
          'osm_ids': '$osmType$osmId',
          'format': 'jsonv2',
          'addressdetails': 1,
        },
      );

      if (response.statusCode == 200 && response.data is List) {
        final results = response.data as List<dynamic>;
        if (results.isNotEmpty) {
          return NominatimResult.fromJson(results[0] as Map<String, dynamic>);
        }
      }
      return null;
    } catch (_) {
      return null;
    }
  }
}

// ==================== Data Classes ====================

/// Result from Nominatim geocoding/search
class NominatimResult {
  /// Place ID from Nominatim
  final int? placeId;

  /// OSM type (node, way, relation)
  final String? osmType;

  /// OSM ID
  final int? osmId;

  /// Display name (full address)
  final String displayName;

  /// Latitude
  final double lat;

  /// Longitude
  final double lon;

  /// Address components
  final NominatimAddress? address;

  /// Place type (city, town, village, road, etc.)
  final String? type;

  /// Place class (boundary, highway, place, etc.)
  final String? placeClass;

  /// Importance score (0-1)
  final double? importance;

  /// Short name for display
  final String? name;

  /// Category icon URL
  final String? icon;

  /// Bounding box [south, north, west, east]
  final List<double>? boundingBox;

  /// Extra tags (opening_hours, phone, website, etc.)
  final Map<String, dynamic>? extraTags;

  const NominatimResult({
    this.placeId,
    this.osmType,
    this.osmId,
    required this.displayName,
    required this.lat,
    required this.lon,
    this.address,
    this.type,
    this.placeClass,
    this.importance,
    this.name,
    this.icon,
    this.boundingBox,
    this.extraTags,
  });

  /// Get LatLng from result
  LatLng get location => LatLng(lat, lon);

  /// Parse from Nominatim JSON response
  factory NominatimResult.fromJson(Map<String, dynamic> json) {
    // Extract short name from namedetails or use display_name
    String? shortName;
    final namedetails = json['namedetails'] as Map<String, dynamic>?;
    if (namedetails != null) {
      shortName = namedetails['name:ar'] as String? ??
          namedetails['name:en'] as String? ??
          namedetails['name'] as String?;
    }

    NominatimAddress? addr;
    if (json['address'] is Map<String, dynamic>) {
      addr = NominatimAddress.fromJson(json['address'] as Map<String, dynamic>);
    }

    List<double>? bbox;
    if (json['boundingbox'] is List) {
      bbox = (json['boundingbox'] as List<dynamic>)
          .map((e) => (e as num).toDouble())
          .toList();
    }

    return NominatimResult(
      placeId: json['place_id'] as int?,
      osmType: json['osm_type'] as String?,
      osmId: json['osm_id'] as int?,
      displayName: json['display_name'] as String? ?? '',
      lat: double.tryParse(json['lat']?.toString() ?? '') ?? 0.0,
      lon: double.tryParse(json['lon']?.toString() ?? '') ?? 0.0,
      address: addr,
      type: json['type'] as String?,
      placeClass: json['class'] as String?,
      importance: (json['importance'] as num?)?.toDouble(),
      name: shortName ?? json['name'] as String?,
      icon: json['icon'] as String?,
      boundingBox: bbox,
      extraTags: json['extratags'] as Map<String, dynamic>?,
    );
  }

  /// Convert to a simple map for serialization
  Map<String, dynamic> toJson() => {
    'place_id': placeId,
    'display_name': displayName,
    'lat': lat,
    'lon': lon,
    'type': type,
    'name': name,
  };
}

/// Address components from Nominatim
class NominatimAddress {
  final String? houseNumber;
  final String? road;
  final String? suburb;
  final String? cityDistrict;
  final String? city;
  final String? state;
  final String? stateDistrict;
  final String? postcode;
  final String? country;
  final String? countryCode;

  const NominatimAddress({
    this.houseNumber,
    this.road,
    this.suburb,
    this.cityDistrict,
    this.city,
    this.state,
    this.stateDistrict,
    this.postcode,
    this.country,
    this.countryCode,
  });

  factory NominatimAddress.fromJson(Map<String, dynamic> json) {
    return NominatimAddress(
      houseNumber: json['house_number'] as String?,
      road: json['road'] as String?,
      suburb: json['suburb'] as String?,
      cityDistrict: json['city_district'] as String?,
      city: json['city'] as String? ?? json['town'] as String? ?? json['village'] as String?,
      state: json['state'] as String?,
      stateDistrict: json['state_district'] as String?,
      postcode: json['postcode'] as String?,
      country: json['country'] as String?,
      countryCode: json['country_code'] as String?,
    );
  }

  /// Get a short display address
  String get shortAddress {
    final parts = <String>[
      if (road != null) road!,
      if (city != null) city!,
    ];
    return parts.join(', ');
  }

  /// Get a full display address
  String get fullAddress {
    final parts = <String>[
      if (houseNumber != null) houseNumber!,
      if (road != null) road!,
      if (suburb != null) suburb!,
      if (city != null) city!,
      if (state != null) state!,
      if (postcode != null) postcode!,
    ];
    return parts.join(', ');
  }
}

/// Nominatim exception
class NominatimException implements Exception {
  final String message;
  const NominatimException(this.message);

  @override
  String toString() => 'NominatimException: $message';
}
