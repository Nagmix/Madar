import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:trippo_shared/trippo_shared.dart';
import '../../../../core/app_providers.dart';
import '../../../../core/constants/app_config.dart';

/// Map color constants (avoiding import cycle with app_theme)
class _MapColors {
  static const int mapPickup = 0xFF00C853;
  static const int mapDropoff = 0xFFFF1744;
}

/// Location state for the map
class MapLocationState {
  final LatLng? pickupLocation;
  final String? pickupAddress;
  final LatLng? dropoffLocation;
  final String? dropoffAddress;
  final Set<Marker> markers;
  final Set<Polyline> polylines;
  final Set<Circle> circles;
  final List<DriverModel> nearbyDrivers;
  final bool isLoading;
  final String? error;

  const MapLocationState({
    this.pickupLocation,
    this.pickupAddress,
    this.dropoffLocation,
    this.dropoffAddress,
    this.markers = const {},
    this.polylines = const {},
    this.circles = const {},
    this.nearbyDrivers = const [],
    this.isLoading = false,
    this.error,
  });

  MapLocationState copyWith({
    LatLng? pickupLocation,
    String? pickupAddress,
    LatLng? dropoffLocation,
    String? dropoffAddress,
    Set<Marker>? markers,
    Set<Polyline>? polylines,
    Set<Circle>? circles,
    List<DriverModel>? nearbyDrivers,
    bool? isLoading,
    String? error,
  }) =>
      MapLocationState(
        pickupLocation: pickupLocation ?? this.pickupLocation,
        pickupAddress: pickupAddress ?? this.pickupAddress,
        dropoffLocation: dropoffLocation ?? this.dropoffLocation,
        dropoffAddress: dropoffAddress ?? this.dropoffAddress,
        markers: markers ?? this.markers,
        polylines: polylines ?? this.polylines,
        circles: circles ?? this.circles,
        nearbyDrivers: nearbyDrivers ?? this.nearbyDrivers,
        isLoading: isLoading ?? this.isLoading,
        error: error,
      );
}

/// Map Location Notifier - Manages map state, locations, drivers, routes
class MapLocationNotifier extends StateNotifier<MapLocationState> {
  final Ref _ref;

  MapLocationNotifier(this._ref) : super(const MapLocationState());

  /// Set pickup location from camera position
  void setPickupLocation(LatLng location, String address) {
    state = state.copyWith(
      pickupLocation: location,
      pickupAddress: address,
    );
    _updateMarkersAndCircles();
    _fetchNearbyDrivers();
  }

  /// Set dropoff location
  void setDropoffLocation(LatLng location, String address) {
    state = state.copyWith(
      dropoffLocation: location,
      dropoffAddress: address,
    );
    _updateMarkersAndCircles();
    _fetchRoute();
  }

  /// Clear dropoff location
  void clearDropoff() {
    state = state.copyWith(
      dropoffLocation: null,
      dropoffAddress: null,
      polylines: {},
    );
    _updateMarkersAndCircles();
  }

  void _updateMarkersAndCircles() {
    final markers = <Marker>{};
    final circles = <Circle>{};

    if (state.pickupLocation != null) {
      markers.add(Marker(
        markerId: const MarkerId('pickup'),
        position: state.pickupLocation!,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        infoWindow: InfoWindow(title: 'Pickup', snippet: state.pickupAddress),
      ));
      circles.add(Circle(
        circleId: const CircleId('pickup_circle'),
        center: state.pickupLocation!,
        radius: 500,
        fillColor: const Color(_MapColors.mapPickup).withOpacity(0.1),
        strokeColor: const Color(_MapColors.mapPickup),
        strokeWidth: 1,
      ));
    }

    if (state.dropoffLocation != null) {
      markers.add(Marker(
        markerId: const MarkerId('dropoff'),
        position: state.dropoffLocation!,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        infoWindow: InfoWindow(title: 'Destination', snippet: state.dropoffAddress),
      ));
      circles.add(Circle(
        circleId: const CircleId('dropoff_circle'),
        center: state.dropoffLocation!,
        radius: 500,
        fillColor: const Color(_MapColors.mapDropoff).withOpacity(0.1),
        strokeColor: const Color(_MapColors.mapDropoff),
        strokeWidth: 1,
      ));
    }

    state = state.copyWith(markers: markers, circles: circles);
  }

  Future<void> _fetchNearbyDrivers() async {
    if (state.pickupLocation == null) return;
    state = state.copyWith(isLoading: true);
    try {
      final apiService = _ref.read(apiServiceProvider);
      final response = await apiService.get(
        ApiConstants.nearbyDrivers,
        queryParameters: {
          'latitude': state.pickupLocation!.latitude,
          'longitude': state.pickupLocation!.longitude,
          'radiusKm': 50,
        },
      );
      final drivers = (response.data as List<dynamic>)
          .map((e) => DriverModel.fromJson(e as Map<String, dynamic>))
          .toList();
      final markers = {...state.markers};
      for (final driver in drivers) {
        if (driver.currentLocation != null) {
          markers.add(Marker(
            markerId: MarkerId('driver_${driver.id}'),
            position: LatLng(
              driver.currentLocation!.latitude,
              driver.currentLocation!.longitude,
            ),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
            infoWindow: InfoWindow(title: driver.name),
          ));
        }
      }
      state = state.copyWith(nearbyDrivers: drivers, markers: markers, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> _fetchRoute() async {
    if (state.pickupLocation == null || state.dropoffLocation == null) return;
    try {
      final apiService = _ref.read(apiServiceProvider);
      final response = await apiService.get(
        ApiConstants.googleMapsBase + ApiConstants.googleDirections,
        queryParameters: {
          'origin': '${state.pickupLocation!.latitude},${state.pickupLocation!.longitude}',
          'destination': '${state.dropoffLocation!.latitude},${state.dropoffLocation!.longitude}',
          'mode': 'driving',
        },
      );
      state = state.copyWith(polylines: {});
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}

/// Map Location Provider
final mapLocationProvider = StateNotifierProvider<MapLocationNotifier, MapLocationState>((ref) {
  return MapLocationNotifier(ref);
});
