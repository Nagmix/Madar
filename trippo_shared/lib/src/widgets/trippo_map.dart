import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:trippo_shared/trippo_shared.dart';

/// TrippoMap Widget - flutter_map component with MapTiler tiles
///
/// Wraps FlutterMap with Madar-specific defaults.
/// - flutter_map for rendering
/// - MapTiler Streets v4 @2x Retina tiles (rich POI, landmarks, business names)
/// - MapTiler Geocoding for search (via MapService)
/// - OSRM for routing (via MapService)
class TrippoMap extends StatefulWidget {
  final LatLng initialPosition;
  final double initialZoom;
  final List<Marker>? markers;
  final List<Polyline>? polylines;
  final bool myLocationEnabled;
  final Function(MapController)? onMapCreated;
  final Function(LatLng)? onTap;
  final Function(LatLng)? onLongPress;
  final LatLng? currentUserLocation;
  final double minZoom;
  final double maxZoom;

  const TrippoMap({
    super.key,
    required this.initialPosition,
    this.initialZoom = 14.0,
    this.markers,
    this.polylines,
    this.myLocationEnabled = true,
    this.onMapCreated,
    this.onTap,
    this.onLongPress,
    this.currentUserLocation,
    this.minZoom = 2.0,
    this.maxZoom = 19.0,
  });

  @override
  State<TrippoMap> createState() => TrippoMapState();
}

class TrippoMapState extends State<TrippoMap> {
  MapController _mapController = MapController();
  LatLng _currentCenter;
  double _currentZoom;

  TrippoMapState()
      : _currentCenter = const LatLng(15.3694, 44.1910),
        _currentZoom = 14.0;

  @override
  void initState() {
    super.initState();
    _currentCenter = widget.initialPosition;
    _currentZoom = widget.initialZoom;
  }

  MapController get mapController => _mapController;

  Future<void> animateTo(LatLng position, {double? zoom}) async {
    final targetZoom = zoom ?? _currentZoom;
    _mapController.move(position, targetZoom);
    setState(() { _currentCenter = position; _currentZoom = targetZoom; });
  }

  Future<void> animateToFitBounds(List<LatLng> points, {double padding = 0.02}) async {
    if (points.isEmpty) return;
    double minLat = points.first.latitude, maxLat = points.first.latitude;
    double minLng = points.first.longitude, maxLng = points.first.longitude;
    for (final p in points) {
      if (p.latitude < minLat) minLat = p.latitude;
      if (p.latitude > maxLat) maxLat = p.latitude;
      if (p.longitude < minLng) minLng = p.longitude;
      if (p.longitude > maxLng) maxLng = p.longitude;
    }
    _mapController.fitCamera(CameraFit.bounds(
      bounds: LatLngBounds(LatLng(minLat, minLng), LatLng(maxLat, maxLng)),
      padding: const EdgeInsets.all(100),
    ));
  }

  LatLng get currentCenter => _currentCenter;
  double get currentZoom => _currentZoom;

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: widget.initialPosition,
        initialZoom: widget.initialZoom,
        onTap: widget.onTap != null ? (tapPosition, point) => widget.onTap!(point) : null,
        onLongPress: widget.onLongPress != null ? (tapPosition, point) => widget.onLongPress!(point) : null,
        onMapReady: () {
          widget.onMapCreated?.call(_mapController);
        },
        minZoom: widget.minZoom,
        maxZoom: widget.maxZoom,
      ),
      children: [
        TileLayer(
          urlTemplate: TileProviderLayer.lightThemeTileUrl,
          userAgentPackageName: 'com.madar.app',
          retinaMode: TileProviderLayer.lightThemeSupportsRetina,
          maxZoom: widget.maxZoom,
          maxNativeZoom: 18,
        ),
        if (widget.polylines != null && widget.polylines!.isNotEmpty)
          PolylineLayer(polylines: widget.polylines!),
        if (widget.markers != null && widget.markers!.isNotEmpty)
          MarkerLayer(markers: widget.markers!),
      ],
    );
  }
}
