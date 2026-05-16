import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Trippo Map Widget - Shared map component with dark theme and common functionality
class TrippoMap extends StatefulWidget {
  final LatLng initialPosition;
  final double initialZoom;
  final Set<Marker>? markers;
  final Set<Polyline>? polylines;
  final Set<Circle>? circles;
  final bool myLocationEnabled;
  final bool trafficEnabled;
  final bool isDarkTheme;
  final Function(GoogleMapController)? onMapCreated;
  final Function(LatLng)? onCameraIdle;
  final Function(LatLng)? onCameraMove;
  final bool showCenterPin;

  const TrippoMap({
    super.key,
    required this.initialPosition,
    this.initialZoom = 14.0,
    this.markers,
    this.polylines,
    this.circles,
    this.myLocationEnabled = true,
    this.trafficEnabled = true,
    this.isDarkTheme = true,
    this.onMapCreated,
    this.onCameraIdle,
    this.onCameraMove,
    this.showCenterPin = false,
  });

  @override
  State<TrippoMap> createState() => _TrippoMapState();
}

class _TrippoMapState extends State<TrippoMap> {
  GoogleMapController? _mapController;
  String? _mapStyle;

  @override
  void initState() {
    super.initState();
    if (widget.isDarkTheme) {
      _loadDarkMapStyle();
    }
  }

  Future<void> _loadDarkMapStyle() async {
    // Dark map style will be loaded from assets or backend
    _mapStyle = _defaultDarkStyle;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GoogleMap(
          initialCameraPosition: CameraPosition(
            target: widget.initialPosition,
            zoom: widget.initialZoom,
          ),
          onMapCreated: (controller) {
            _mapController = controller;
            if (_mapStyle != null) {
              controller.setMapStyle(_mapStyle);
            }
            widget.onMapCreated?.call(controller);
          },
          markers: widget.markers ?? {},
          polylines: widget.polylines ?? {},
          circles: widget.circles ?? {},
          myLocationEnabled: widget.myLocationEnabled,
          myLocationButtonEnabled: false,
          trafficEnabled: widget.trafficEnabled,
          zoomControlsEnabled: false,
          mapToolbarEnabled: false,
          compassEnabled: false,
          onCameraIdle: () {
            // Will be handled via controller
          },
          onCameraMove: (position) {
            widget.onCameraMove?.call(position.target);
          },
        ),
        if (widget.showCenterPin)
          Center(
            child: Container(
              padding: const EdgeInsets.only(bottom: 40),
              child: const Icon(
                Icons.location_on,
                color: Colors.red,
                size: 40,
              ),
            ),
          ),
      ],
    );
  }

  /// Animate camera to a specific position
  Future<void> animateTo(LatLng position, {double zoom = 14.0}) async {
    await _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(position, zoom),
    );
  }

  /// Animate camera to fit bounds
  Future<void> animateToBounds(LatLngBounds bounds, {double padding = 50}) async {
    await _mapController?.animateCamera(
      CameraUpdate.newLatLngBounds(bounds, padding),
    );
  }

  // Simplified dark style - in production this would be loaded from JSON asset
  static const String _defaultDarkStyle = '''
  [
    {"elementType": "geometry", "stylers": [{"color": "#212121"}]},
    {"elementType": "labels.icon", "stylers": [{"visibility": "off"}]},
    {"elementType": "labels.text.fill", "stylers": [{"color": "#757575"}]},
    {"elementType": "labels.text.stroke", "stylers": [{"color": "#212121"}]}
  ]
  ''';
}
