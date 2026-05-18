/// TileProvider Layer - Abstraction for map tile sources
///
/// This layer decouples the app from specific tile servers,
/// making it easy to switch from public OSM tiles to self-hosted
/// tiles (e.g., tileserver-gl, mapnik) in production.
///
/// Usage:
///   final tiles = TileProviderLayer.getTileUrlTemplate();
///   TileLayer(urlTemplate: tiles, ...)

class TileProviderLayer {
  TileProviderLayer._();

  // ==================== Configuration ====================

  /// Current tile provider mode
  static TileProviderMode _mode = TileProviderMode.cartoLight;

  /// Custom tile server URL (for self-hosted)
  static String? _customTileUrl;

  /// API key for tile services that require one (e.g., MapTiler, Thunderforest)
  static String? _tileApiKey;

  // ==================== Public API ====================

  /// Set the tile provider mode
  static void setMode(TileProviderMode mode, {String? customUrl, String? apiKey}) {
    _mode = mode;
    _customTileUrl = customUrl;
    _tileApiKey = apiKey;
  }

  /// Get the tile URL template for the current provider
  static String getTileUrlTemplate() {
    return switch (_mode) {
      TileProviderMode.openStreetMap => _osmTileUrl,
      TileProviderMode.openStreetMapHot => _osmHotTileUrl,
      TileProviderMode.cartoLight => _cartoLightTileUrl,
      TileProviderMode.cartoDark => _cartoDarkTileUrl,
      TileProviderMode.cartoVoyager => _cartoVoyagerTileUrl,
      TileProviderMode.mapTiler => 'https://api.maptiler.com/maps/streets/{z}/{x}/{y}@2x.png?key=${_tileApiKey ?? ''}',
      TileProviderMode.custom => _customTileUrl ?? _osmTileUrl,
    };
  }

  /// Get tile provider display name
  static String getProviderName() {
    return switch (_mode) {
      TileProviderMode.openStreetMap => 'OpenStreetMap',
      TileProviderMode.openStreetMapHot => 'OpenStreetMap HOT',
      TileProviderMode.cartoLight => 'CartoDB Light',
      TileProviderMode.cartoDark => 'CartoDB Dark',
      TileProviderMode.cartoVoyager => 'CartoDB Voyager',
      TileProviderMode.mapTiler => 'MapTiler',
      TileProviderMode.custom => 'Custom',
    };
  }

  /// Check if current provider requires an API key
  static bool requiresApiKey() {
    return _mode == TileProviderMode.mapTiler;
  }

  /// Get the user agent string for OSM-compliant requests
  static String get userAgent => 'Madar-RideHailing/2.0';

  /// Get the recommended tile provider for dark theme
  static String get darkThemeTileUrl => _cartoDarkTileUrl;

  /// Get the recommended tile provider for light theme
  static String get lightThemeTileUrl => _cartoLightTileUrl;

  // ==================== Tile URLs ====================

  /// OpenStreetMap standard tiles
  static const String _osmTileUrl =
      'https://tile.openstreetmap.org/{z}/{x}/{y}.png';

  /// OpenStreetMap HOT (Humanitarian) tiles
  static const String _osmHotTileUrl =
      'https://tile.openstreetmap.fr/hot/{z}/{x}/{y}.png';

  /// CartoDB Positron (Light) tiles
  static const String _cartoLightTileUrl =
      'https://basemaps.cartocdn.com/light_all/{z}/{x}/{y}@2x.png';

  /// CartoDB Dark Matter tiles - best for ride-hailing dark theme
  static const String _cartoDarkTileUrl =
      'https://basemaps.cartocdn.com/dark_all/{z}/{x}/{y}@2x.png';

  /// CartoDB Voyager (colored, neutral) tiles
  static const String _cartoVoyagerTileUrl =
      'https://basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}@2x.png';
}

/// Available tile provider modes
enum TileProviderMode {
  /// OpenStreetMap standard - good for development/testing
  openStreetMap,

  /// OpenStreetMap HOT - humanitarian style
  openStreetMapHot,

  /// CartoDB Positron - clean light theme
  cartoLight,

  /// CartoDB Dark Matter - dark theme, ideal for ride-hailing
  cartoDark,

  /// CartoDB Voyager - neutral colored style
  cartoVoyager,

  /// MapTiler - requires API key, production quality
  mapTiler,

  /// Self-hosted tile server - set custom URL
  custom,
}
