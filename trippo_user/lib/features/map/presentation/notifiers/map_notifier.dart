import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:trippo_shared/trippo_shared.dart';
import '../../../../core/app_providers.dart';
import '../../../../core/constants/app_config.dart';

/// Map color constants
class _MapColors {
  static const Color mapPickup = Color(0xFF00C853);
  static const Color mapDropoff = Color(0xFFFF1744);
  static const Color routeLine = Color(0xFF448AFF);
}

/// Location state for the map (flutter_map version)
class MapLocationState {
  final LatLng? pickupLocation;
  final String? pickupAddress;
  final LatLng? dropoffLocation;
  final String? dropoffAddress;
  final List<Marker> markers;
  final List<Polyline> polylines;
  final List<CircleMarker> circles;
  final List<DriverModel> nearbyDrivers;
  final bool isLoading;
  final String? error;
  final LatLng? currentUserLocation;
  final RouteResult? currentRoute;

  const MapLocationState({
    this.pickupLocation,
    this.pickupAddress,
    this.dropoffLocation,
    this.dropoffAddress,
    this.markers = const [],
    this.polylines = const [],
    this.circles = const [],
    this.nearbyDrivers = const [],
    this.isLoading = false,
    this.error,
    this.currentUserLocation,
    this.currentRoute,
  });

  MapLocationState copyWith({
    LatLng? pickupLocation,
    String? pickupAddress,
    LatLng? dropoffLocation,
    String? dropoffAddress,
    List<Marker>? markers,
    List<Polyline>? polylines,
    List<CircleMarker>? circles,
    List<DriverModel>? nearbyDrivers,
    bool? isLoading,
    String? error,
    LatLng? currentUserLocation,
    RouteResult? currentRoute,
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
        currentUserLocation: currentUserLocation ?? this.currentUserLocation,
        currentRoute: currentRoute ?? this.currentRoute,
      );
}

/// MapService provider
final mapServiceProvider = Provider<MapService>((ref) {
  return MapService();
});

/// Map Location Provider
final mapLocationProvider = StateNotifierProvider<MapLocationNotifier, MapLocationState>((ref) {
  return MapLocationNotifier(ref);
});

/// Map Location Notifier - Manages map state using open-source MapService
class MapLocationNotifier extends StateNotifier<MapLocationState> {
  final Ref _ref;

  MapLocationNotifier(this._ref) : super(const MapLocationState()) {
    _initUserLocation();
  }

  /// Initialize user location on startup
  Future<void> _initUserLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      final userLoc = LatLng(position.latitude, position.longitude);
      state = state.copyWith(currentUserLocation: userLoc);

      // Auto-set pickup to current location
      await setPickupFromCurrentLocation();
    } catch (e) {
      // Location permission denied or unavailable
    }
  }

  /// Set pickup from current location with reverse geocoding
  Future<void> setPickupFromCurrentLocation() async {
    if (state.currentUserLocation == null) return;
    state = state.copyWith(isLoading: true);

    try {
      final mapService = _ref.read(mapServiceProvider);
      final result = await mapService.reverseGeocode(
        latitude: state.currentUserLocation!.latitude,
        longitude: state.currentUserLocation!.longitude,
      );

      state = state.copyWith(
        pickupLocation: state.currentUserLocation,
        pickupAddress: result.shortAddress,
        isLoading: false,
      );
      _updateMarkersAndCircles();
      _fetchNearbyDrivers();
    } catch (e) {
      // Still set the location even if geocoding fails
      state = state.copyWith(
        pickupLocation: state.currentUserLocation,
        pickupAddress: 'Current Location',
        isLoading: false,
      );
      _updateMarkersAndCircles();
      _fetchNearbyDrivers();
    }
  }

  /// Set pickup location from camera position
  void setPickupLocation(LatLng location, String address) {
    state = state.copyWith(
      pickupLocation: location,
      pickupAddress: address,
    );
    _updateMarkersAndCircles();
    _fetchNearbyDrivers();
  }

  /// Set pickup location with reverse geocoding
  Future<void> setPickupWithGeocode(LatLng location) async {
    state = state.copyWith(isLoading: true);
    try {
      final mapService = _ref.read(mapServiceProvider);
      final result = await mapService.reverseGeocode(
        latitude: location.latitude,
        longitude: location.longitude,
      );

      state = state.copyWith(
        pickupLocation: location,
        pickupAddress: result.shortAddress,
        isLoading: false,
      );
      _updateMarkersAndCircles();
      _fetchNearbyDrivers();
    } catch (e) {
      state = state.copyWith(
        pickupLocation: location,
        pickupAddress: '${location.latitude.toStringAsFixed(4)}, ${location.longitude.toStringAsFixed(4)}',
        isLoading: false,
      );
      _updateMarkersAndCircles();
      _fetchNearbyDrivers();
    }
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

  /// Set dropoff location with reverse geocoding
  Future<void> setDropoffWithGeocode(LatLng location, {String? address}) async {
    if (address != null) {
      state = state.copyWith(
        dropoffLocation: location,
        dropoffAddress: address,
      );
      _updateMarkersAndCircles();
      _fetchRoute();
      return;
    }

    state = state.copyWith(isLoading: true);
    try {
      final mapService = _ref.read(mapServiceProvider);
      final result = await mapService.reverseGeocode(
        latitude: location.latitude,
        longitude: location.longitude,
      );

      state = state.copyWith(
        dropoffLocation: location,
        dropoffAddress: result.shortAddress,
        isLoading: false,
      );
      _updateMarkersAndCircles();
      _fetchRoute();
    } catch (e) {
      state = state.copyWith(
        dropoffLocation: location,
        dropoffAddress: '${location.latitude.toStringAsFixed(4)}, ${location.longitude.toStringAsFixed(4)}',
        isLoading: false,
      );
      _updateMarkersAndCircles();
      _fetchRoute();
    }
  }

  /// Clear dropoff location
  void clearDropoff() {
    state = state.copyWith(
      dropoffLocation: null,
      dropoffAddress: null,
      polylines: [],
      currentRoute: null,
    );
    _updateMarkersAndCircles();
  }

  /// Clear all
  void clearAll() {
    state = const MapLocationState();
  }

  /// Update user location in real-time
  void updateUserLocation(LatLng location) {
    state = state.copyWith(currentUserLocation: location);
  }

  /// Update driver marker position (for real-time tracking)
  void updateDriverMarker(String driverId, LatLng position, {double? bearing}) {
    // For now, update the markers list
    // In production, this would smoothly animate the marker
    _updateMarkersAndCircles();
  }

  void _updateMarkersAndCircles() {
    final markers = <Marker>[];
    final circles = <CircleMarker>[];

    // Pickup marker
    if (state.pickupLocation != null) {
      markers.add(Marker(
        point: state.pickupLocation!,
        width: 40,
        height: 40,
        child: const Icon(Icons.location_on, color: _MapColors.mapPickup, size: 40),
      ));

      // Pickup radius circle
      circles.add(CircleMarker(
        point: state.pickupLocation!,
        radius: 500,
        color: _MapColors.mapPickup.withOpacity(0.1),
        borderColor: _MapColors.mapPickup,
        borderStrokeWidth: 1,
      ));
    }

    // Dropoff marker
    if (state.dropoffLocation != null) {
      markers.add(Marker(
        point: state.dropoffLocation!,
        width: 40,
        height: 40,
        child: const Icon(Icons.location_on, color: _MapColors.mapDropoff, size: 40),
      ));
    }

    // Nearby drivers markers
    for (final driver in state.nearbyDrivers) {
      if (driver.currentLocation != null) {
        markers.add(Marker(
          point: LatLng(driver.currentLocation!.latitude, driver.currentLocation!.longitude),
          width: 30,
          height: 30,
          child: Transform.rotate(
            angle: (0) * 3.14159 / 180,
            child: const Icon(
              Icons.directions_car,
              color: Colors.yellow,
              size: 30,
            ),
          ),
        ));
      }
    }

    state = state.copyWith(markers: markers, circles: circles);
  }

  /// Fetch route between pickup and dropoff using OSRM
  Future<void> _fetchRoute() async {
    if (state.pickupLocation == null || state.dropoffLocation == null) return;

    state = state.copyWith(isLoading: true);

    try {
      final mapService = _ref.read(mapServiceProvider);
      final routeResult = await mapService.getRoute(
        origin: state.pickupLocation!,
        destination: state.dropoffLocation!,
      );

      // Create polyline from route points
      final routePolyline = Polyline(
        points: routeResult.polylinePoints,
        color: _MapColors.routeLine,
        strokeWidth: 5.0,
        borderStrokeWidth: 2.0,
        borderColor: Colors.blue.shade900,
      );

      state = state.copyWith(
        polylines: [routePolyline],
        currentRoute: routeResult,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to fetch route: $e',
        isLoading: false,
      );
    }
  }

  /// Fetch nearby drivers from backend
  Future<void> _fetchNearbyDrivers() async {
    if (state.pickupLocation == null) return;

    try {
      final apiService = _ref.read(apiServiceProvider);
      final response = await apiService.get(
        ApiConstants.nearbyDrivers,
        queryParameters: {
          'latitude': state.pickupLocation!.latitude,
          'longitude': state.pickupLocation!.longitude,
          'radius': 5000, // 5km radius
        },
      );

      final data = response.data;
      if (data is List) {
        final drivers = data
            .map((e) => DriverModel.fromJson(e as Map<String, dynamic>))
            .toList();
        state = state.copyWith(nearbyDrivers: drivers);
        _updateMarkersAndCircles();
      }
    } catch (e) {
      // Silently fail - drivers will not be shown
    }
  }

  /// Search places using Nominatim
  Future<List<PlaceResult>> searchPlaces(String query, {LatLng? nearPosition}) async {
    try {
      final mapService = _ref.read(mapServiceProvider);
      return mapService.searchPlace(query, nearPosition: nearPosition ?? state.currentUserLocation);
    } catch (e) {
      return [];
    }
  }

  /// Get estimated fare for current route
  double? estimateFare({
    required double baseFare,
    required double perKmRate,
    required double perMinRate,
    double? surgeMultiplier,
  }) {
    if (state.currentRoute == null) return null;

    final multiplier = surgeMultiplier ?? 1.0;
    final distanceKm = state.currentRoute!.distanceKm;
    final durationMin = state.currentRoute!.durationMinutes;

    return (baseFare + (distanceKm * perKmRate) + (durationMin * perMinRate)) * multiplier;
  }
}
