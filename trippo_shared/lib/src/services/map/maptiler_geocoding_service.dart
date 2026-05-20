import 'package:dio/dio.dart';
import 'package:latlong2/latlong.dart';
import 'tile_provider.dart';

/// MapTiler Geocoding Service - Replaces Nominatim
///
/// Uses MapTiler Search & Geocoding API for:
/// - Forward geocoding (search by text)
/// - Reverse geocoding (coordinates to address)
/// - Place autocomplete
///
/// API Docs: https://docs.maptiler.com/cloud/api/geocoding
///
/// Free tier: 100,000 requests/month
/// Rate limit: 10 requests/second

class MapTilerGeocodingService {
  final Dio _dio;
  final String _apiKey;
  final String _language;

  MapTilerGeocodingService({
    Dio? dio,
    String? apiKey,
    String language = 'ar',
  })  : _apiKey = apiKey ?? MapTilerConfig.apiKey,
        _language = language,
        _dio = dio ?? Dio(BaseOptions(
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
          headers: {
            'Accept': 'application/json',
          },
        ));

  // ==================== Forward Geocoding (Search) ====================

  /// Search for places by text query
  ///
  /// Returns a list of matching places with coordinates and addresses.
  /// Uses MapTiler Geocoding API.
  Future<List<MapTilerGeocodingResult>> search(
    String query, {
    int limit = 5,
    LatLng? nearPosition,
    List<String>? countryCodes,
    bool autocomplete = true,
  }) async {
    try {
      final params = <String, dynamic>{
        'key': _apiKey,
        'language': _language,
        'limit': limit,
        'autocomplete': autocomplete,
      };

      // Bias results toward a position
      if (nearPosition != null) {
        params['proximity'] = '${nearPosition.longitude},${nearPosition.latitude}';
      }

      // Country filter
      if (countryCodes != null && countryCodes.isNotEmpty) {
        params['country'] = countryCodes.join(',');
      }

      final response = await _dio.get(
        '${MapTilerConfig.geocodingBaseUrl}/$query.json',
        queryParameters: params,
      );

      if (response.statusCode == 200 && response.data is Map) {
        final data = response.data as Map<String, dynamic>;
        final features = data['features'] as List<dynamic>? ?? [];
        return features
            .map((f) => MapTilerGeocodingResult.fromJson(f as Map<String, dynamic>))
            .toList();
      }

      return [];
    } on DioException catch (e) {
      throw MapTilerGeocodingException('Network error: ${e.message}');
    } catch (e) {
      if (e is MapTilerGeocodingException) rethrow;
      throw MapTilerGeocodingException('Search failed: $e');
    }
  }

  // ==================== Reverse Geocoding ====================

  /// Reverse geocode coordinates to address
  Future<MapTilerGeocodingResult> reverseGeocode({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final response = await _dio.get(
        '${MapTilerConfig.geocodingBaseUrl}/$longitude,$latitude.json',
        queryParameters: {
          'key': _apiKey,
          'language': _language,
          'limit': 1,
        },
      );

      if (response.statusCode == 200 && response.data is Map) {
        final data = response.data as Map<String, dynamic>;
        final features = data['features'] as List<dynamic>? ?? [];
        if (features.isNotEmpty) {
          return MapTilerGeocodingResult.fromJson(features[0] as Map<String, dynamic>);
        }
      }

      throw MapTilerGeocodingException('No result found for coordinates');
    } on DioException catch (e) {
      throw MapTilerGeocodingException('Network error: ${e.message}');
    } catch (e) {
      if (e is MapTilerGeocodingException) rethrow;
      throw MapTilerGeocodingException('Reverse geocoding failed: $e');
    }
  }

  // ==================== Autocomplete ====================

  /// Search for places with autocomplete-friendly behavior
  Future<List<MapTilerGeocodingResult>> autocomplete(
    String query, {
    int limit = 5,
    LatLng? nearPosition,
  }) async {
    return search(
      query,
      limit: limit,
      nearPosition: nearPosition,
      autocomplete: true,
    );
  }
}

// ==================== Result Models ====================

/// Geocoding result from MapTiler API (GeoJSON Feature)
class MapTilerGeocodingResult {
  /// Place name
  final String name;

  /// Full display name / address
  final String displayName;

  /// Short address for display
  final String shortAddress;

  /// Latitude
  final double lat;

  /// Longitude
  final double lon;

  /// Place type (e.g., "city", "town", "village", "road", "house")
  final String? placeType;

  /// Feature category (e.g., "poi", "address", "place")
  final String? category;

  /// Relevance score (0.0 to 1.0)
  final double relevance;

  /// Address components
  final MapTilerAddress? address;

  /// Raw GeoJSON properties
  final Map<String, dynamic>? rawProperties;

  const MapTilerGeocodingResult({
    required this.name,
    required this.displayName,
    required this.shortAddress,
    required this.lat,
    required this.lon,
    this.placeType,
    this.category,
    this.relevance = 0.0,
    this.address,
    this.rawProperties,
  });

  factory MapTilerGeocodingResult.fromJson(Map<String, dynamic> json) {
    // Parse geometry coordinates [lng, lat]
    final geometry = json['geometry'] as Map<String, dynamic>?;
    final coords = geometry?['coordinates'] as List<dynamic>?;
    final lng = (coords?[0] as num?)?.toDouble() ?? 0.0;
    final lat = (coords?[1] as num?)?.toDouble() ?? 0.0;

    // Parse properties
    final props = json['properties'] as Map<String, dynamic>? ?? {};

    // Parse context (address components)
    final context = json['context'] as List<dynamic>? ?? [];
    MapTilerAddress? addr;
    if (context.isNotEmpty) {
      String? city, country, countryCode, region, district, street;
      for (final ctx in context) {
        final ctxMap = ctx as Map<String, dynamic>;
        final id = (ctxMap['id'] ?? '') as String;
        final text = (ctxMap['text'] ?? '') as String;
        if (id.startsWith('country.')) {
          country = text;
          countryCode = (ctxMap['short_code'] ?? '') as String;
        } else if (id.startsWith('region.')) {
          region = text;
        } else if (id.startsWith('district.')) {
          district = text;
        } else if (id.startsWith('place.') || id.startsWith('city.')) {
          city = text;
        } else if (id.startsWith('locality.') || id.startsWith('town.') || id.startsWith('village.')) {
          city ??= text;
        } else if (id.startsWith('street.') || id.startsWith('road.')) {
          street = text;
        }
      }
      addr = MapTilerAddress(
        country: country,
        countryCode: countryCode,
        region: region,
        district: district,
        city: city,
        street: street,
      );
    }

    // Build short address
    final List<String> addrParts = [];
    if (props['name'] != null && props['name'] != json['text']) {
      addrParts.add(props['name'] as String);
    }
    if (addr?.street != null) addrParts.add(addr!.street!);
    if (addr?.district != null) addrParts.add(addr!.district!);
    if (addr?.city != null) addrParts.add(addr!.city!);
    final shortAddr = addrParts.isNotEmpty ? addrParts.join(', ') : (json['text'] ?? json['place_name'] ?? '');

    return MapTilerGeocodingResult(
      name: (json['text'] ?? props['name'] ?? '') as String,
      displayName: (json['place_name'] ?? '') as String,
      shortAddress: shortAddr,
      lat: lat,
      lon: lng,
      placeType: (json['place_type'] as List<dynamic>?)?.firstOrNull as String?,
      category: props['category'] as String?,
      relevance: (json['relevance'] as num?)?.toDouble() ?? 0.0,
      address: addr,
      rawProperties: props,
    );
  }
}

/// Address components from MapTiler context
class MapTilerAddress {
  final String? country;
  final String? countryCode;
  final String? region;
  final String? district;
  final String? city;
  final String? street;

  const MapTilerAddress({
    this.country,
    this.countryCode,
    this.region,
    this.district,
    this.city,
    this.street,
  });

  /// Get a short readable address
  String get shortAddress {
    final parts = <String>[];
    if (street != null) parts.add(street!);
    if (district != null) parts.add(district!);
    if (city != null) parts.add(city!);
    return parts.isNotEmpty ? parts.join(', ') : '';
  }
}

/// MapTiler Geocoding Exception
class MapTilerGeocodingException implements Exception {
  final String message;
  const MapTilerGeocodingException(this.message);
  @override
  String toString() => 'MapTilerGeocodingException: $message';
}

