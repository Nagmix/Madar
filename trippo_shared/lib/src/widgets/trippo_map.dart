import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:trippo_shared/src/services/map/tile_provider.dart';

/// TrippoMap Widget - Open-source map component using flutter_map + OSM
///
/// Replaces Google Maps with a fully open-source alternative:
/// - flutter_map for rendering (pure Dart, no native SDK needed)
/// - OpenStreetMap/CartoDB tiles (no API key required)
/// - Works on all platforms without Google Play Services
class TrippoMap extends StatefulWidget {
  final LatLng initialPosition;
  final double initialZoom;
  final List<Marker>? markers;
  final List<Polyline>? polylines;
  final List<CircleMarker>? circles;
  final bool myLocationEnabled;
  final bool isDarkTheme;
  final Function(MapController)? onMapCreated;
  final Function(LatLng)? onCameraIdle;
  final Function(LatLng)? onCameraMove;
  final bool showCenterPin;
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
    this.circles,
    this.myLocationEnabled = true,
    this.isDarkTheme = true,
    this.onMapCreated,
    this.onCameraIdle,
    this.onCameraMove,
    this.showCenterPin = false,
    this.onTap,
    this.onLongPress,
    this.currentUserLocation,
    this.minZoom = 2.0,
    this.maxZoom = 18.0,
  });

  @override
  State<TrippoMap> createState() => TrippoMapState();
}

class TrippoMapState extends State<TrippoMap> with TickerProviderStateMixin {
  late MapController _mapController;
  LatLng _currentCenter;
  double _currentZoom;

  TrippoMapState()
      : _currentCenter = const LatLng(24.7136, 46.6753),
        _currentZoom = 14.0;

  @override
  void initState() {
    super.initState();
    _currentCenter = widget.initialPosition;
    _currentZoom = widget.initialZoom;
    _mapController = MapController();
  }

  @override
  void didUpdateWidget(TrippoMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialPosition != oldWidget.initialPosition) {
      animateTo(widget.initialPosition, zoom: widget.initialZoom);
    }
  }

  MapController get mapController => _mapController;

  Future<void> animateTo(LatLng position, {double? zoom}) async {
    final targetZoom = zoom ?? _currentZoom;
    try {
      _mapController.move(position, targetZoom);
    } catch (_) {}
    setState(() {
      _currentCenter = position;
      _currentZoom = targetZoom;
    });
  }

  Future<void> animateToFitBounds(List<LatLng> points, {double padding = 0.02}) async {
    if (points.isEmpty) return;
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
    minLat -= padding; maxLat += padding;
    minLng -= padding; maxLng += padding;
    final centerLat = (minLat + maxLat) / 2;
    final centerLng = (minLng + maxLng) / 2;
    final latDiff = maxLat - minLat;
    final lngDiff = maxLng - minLng;
    final maxDiff = latDiff > lngDiff ? latDiff : lngDiff;
    double zoom;
    if (maxDiff > 1.0) zoom = 6.0;
    else if (maxDiff > 0.5) zoom = 8.0;
    else if (maxDiff > 0.1) zoom = 10.0;
    else if (maxDiff > 0.05) zoom = 12.0;
    else if (maxDiff > 0.01) zoom = 14.0;
    else zoom = 16.0;
    animateTo(LatLng(centerLat, centerLng), zoom: zoom);
  }

  LatLng get currentCenter => _currentCenter;
  double get currentZoom => _currentZoom;

  @override
  Widget build(BuildContext context) {
    final allMarkers = <Marker>[
      ...?widget.markers,
      if (widget.myLocationEnabled && widget.currentUserLocation != null)
        Marker(
          point: widget.currentUserLocation!,
          width: 20,
          height: 20,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                  border: Border.fromBorderSide(BorderSide(color: Colors.white, width: 2)),
                ),
              ),
            ),
          ),
        ),
    ];

    final tileUrl = widget.isDarkTheme
        ? TileProviderLayer.darkThemeTileUrl
        : TileProviderLayer.lightThemeTileUrl;

    final children = <Widget>[
      TileLayer(
        urlTemplate: tileUrl,
        userAgentPackageName: 'com.madar.rider',
        retinaMode: true,
        maxZoom: 19,
      ),
      if (widget.circles != null && widget.circles!.isNotEmpty)
        CircleLayer(circles: widget.circles!),
      if (widget.polylines != null && widget.polylines!.isNotEmpty)
        PolylineLayer(polylines: widget.polylines!),
      if (allMarkers.isNotEmpty)
        MarkerLayer(markers: allMarkers),
    ];

    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: widget.initialPosition,
            initialZoom: widget.initialZoom,
            minZoom: widget.minZoom,
            maxZoom: widget.maxZoom,
            onMapReady: () {
              widget.onMapCreated?.call(_mapController);
            },
            onPositionChanged: (position, hasGesture) {
              _currentCenter = position.center ?? _currentCenter;
              _currentZoom = position.zoom ?? _currentZoom;
              if (hasGesture) {
                widget.onCameraMove?.call(position.center ?? _currentCenter);
              }
            },
            onTap: (tapPosition, point) {
              widget.onTap?.call(point);
            },
            onLongPress: (tapPosition, point) {
              widget.onLongPress?.call(point);
            },
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.all,
            ),
          ),
          children: children,
        ),
        if (widget.showCenterPin)
          Center(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 40),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.location_on, color: Colors.green, size: 40),
                  Container(width: 2, height: 10, color: Colors.green),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
