/// TileProvider Layer - Abstraction for map tile sources
///
/// Configured for MapTiler streets-v4 tiles with HIGH QUALITY @2x retina tiles.
/// Shows POIs, business names, landmarks, and all geographic features.
/// MapTiler API Key: configured in MapTilerConfig

class TileProviderLayer {
  TileProviderLayer._();

  // ==================== MapTiler Configuration ====================

  /// MapTiler API Key - provided by user
  static const String mapTilerApiKey = 'pVni8BHCWVLgteg9oKlD';

  /// MapTiler Streets v4 - HIGH QUALITY Retina tiles (256px @2x = 512px rendered)
  /// Shows POIs, business names, landmarks - full rich map
  static const String _mapTilerStreetsRetina =
      'https://api.maptiler.com/maps/streets-v4/256/{z}/{x}/{y}@2x.png?key=$mapTilerApiKey';

  /// MapTiler Streets v4 - Standard tiles (256px) - fallback
  static const String _mapTilerStreets256 =
      'https://api.maptiler.com/maps/streets-v4/256/{z}/{x}/{y}.png?key=$mapTilerApiKey';

  // ==================== Public API ====================

  /// Get the tile URL template for MapTiler Streets (Retina)
  static String getTileUrlTemplate() => _mapTilerStreetsRetina;

  /// Get tile provider display name
  static String getProviderName() => 'MapTiler Streets';

  /// MapTiler @2x retina tiles - YES supports retina
  static bool get supportsRetina => true;

  /// Get the user agent string
  static String get userAgent => 'Madar-RideHailing/2.0';

  /// Light theme tile URL (MapTiler Streets Retina)
  static String get lightThemeTileUrl => _mapTilerStreetsRetina;

  /// Light theme retina support
  static bool get lightThemeSupportsRetina => true;

  /// Dark theme tile URL (MapTiler Streets - same for now)
  static String get darkThemeTileUrl => _mapTilerStreetsRetina;

  /// Dark theme retina support
  static bool get darkThemeSupportsRetina => true;
}

/// MapTiler configuration constants
class MapTilerConfig {
  MapTilerConfig._();

  /// MapTiler API Key
  static const String apiKey = 'pVni8BHCWVLgteg9oKlD';

  /// MapTiler Geocoding API base URL
  static const String geocodingBaseUrl = 'https://api.maptiler.com/geocoding';

  /// MapTiler Vector Style URL (for MapLibre GL if needed in future)
  static const String vectorStyleUrl =
      'https://api.maptiler.com/maps/streets-v4/style.json?key=$apiKey';

  /// MapTiler Raster Tiles URL (Retina)
  static const String rasterTilesUrl =
      'https://api.maptiler.com/maps/streets-v4/256/{z}/{x}/{y}@2x.png?key=$apiKey';

  /// MapTiler Directions API base URL
  static const String directionsBaseUrl = 'https://api.maptiler.com/directions';

  /// Default language for geocoding results
  static const String defaultLanguage = 'ar';

  /// Default country codes for search bias
  static const List<String> defaultCountryCodes = ['ye'];

  /// Default bounds for Yemen
  static const double yemenMinLat = 12.1;
  static const double yemenMinLng = 42.5;
  static const double yemenMaxLat = 19.0;
  static const double yemenMaxLng = 54.0;
}
