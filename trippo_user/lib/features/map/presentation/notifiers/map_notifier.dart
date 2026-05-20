import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:trippo_shared/trippo_shared.dart' hide CreateTripRequest;
import '../../../../core/app_providers.dart';

const LatLng _defaultLocation = LatLng(15.3694, 44.1910);

class MapLocationState {
  final LatLng? pickupLocation;
  final String? pickupAddress;
  final LatLng? dropoffLocation;
  final String? dropoffAddress;
  final List<DriverModel> nearbyDrivers;
  final bool isLoading;
  final String? error;
  final LatLng? currentUserLocation;
  final OsrmRouteResult? currentRoute;

  const MapLocationState({
    this.pickupLocation, this.pickupAddress,
    this.dropoffLocation, this.dropoffAddress,
    this.nearbyDrivers = const [], this.isLoading = false,
    this.error, this.currentUserLocation, this.currentRoute,
  });

  MapLocationState copyWith({
    LatLng? pickupLocation, String? pickupAddress,
    LatLng? dropoffLocation, String? dropoffAddress,
    List<DriverModel>? nearbyDrivers, bool? isLoading,
    String? error, LatLng? currentUserLocation,
    OsrmRouteResult? currentRoute, bool clearRoute = false,
  }) => MapLocationState(
    pickupLocation: pickupLocation ?? this.pickupLocation,
    pickupAddress: pickupAddress ?? this.pickupAddress,
    dropoffLocation: dropoffLocation ?? this.dropoffLocation,
    dropoffAddress: dropoffAddress ?? this.dropoffAddress,
    nearbyDrivers: nearbyDrivers ?? this.nearbyDrivers,
    isLoading: isLoading ?? this.isLoading,
    error: error,
    currentUserLocation: currentUserLocation ?? this.currentUserLocation,
    currentRoute: clearRoute ? null : (currentRoute ?? this.currentRoute),
  );
}

final mapServiceProvider = Provider<MapService>((ref) => MapService());
final mapLocationProvider = StateNotifierProvider<MapLocationNotifier, MapLocationState>((ref) => MapLocationNotifier(ref));

class MapLocationNotifier extends StateNotifier<MapLocationState> {
  final Ref _ref;
  MapLocationNotifier(this._ref) : super(const MapLocationState()) { _initUserLocation(); }

  Future<void> _initUserLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) { state = state.copyWith(currentUserLocation: _defaultLocation); await setPickupFromCurrentLocation(); return; }
      }
      if (permission == LocationPermission.deniedForever) { state = state.copyWith(currentUserLocation: _defaultLocation); await setPickupFromCurrentLocation(); return; }
      final position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      final userLoc = LatLng(position.latitude, position.longitude);
      state = state.copyWith(currentUserLocation: userLoc);
      await setPickupFromCurrentLocation();
    } catch (e) { state = state.copyWith(currentUserLocation: _defaultLocation); await setPickupFromCurrentLocation(); }
  }

  Future<void> setPickupFromCurrentLocation() async {
    final loc = state.currentUserLocation ?? _defaultLocation;
    state = state.copyWith(isLoading: true);
    try {
      final mapService = MapService();
      final geocode = await mapService.reverseGeocode(latitude: loc.latitude, longitude: loc.longitude);
      state = state.copyWith(pickupLocation: loc, pickupAddress: geocode.shortAddress.isNotEmpty ? geocode.shortAddress : geocode.fullAddress, isLoading: false);
    } catch (e) { state = state.copyWith(pickupLocation: loc, pickupAddress: 'موقعي الحالي', isLoading: false); }
  }

  Future<void> setPickupWithGeocode(LatLng position) async {
    state = state.copyWith(isLoading: true);
    try {
      final mapService = MapService();
      final geocode = await mapService.reverseGeocode(latitude: position.latitude, longitude: position.longitude);
      state = state.copyWith(pickupLocation: position, pickupAddress: geocode.shortAddress.isNotEmpty ? geocode.shortAddress : geocode.fullAddress, isLoading: false);
    } catch (e) { state = state.copyWith(pickupLocation: position, pickupAddress: '${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}', isLoading: false); }
  }

  Future<void> setPickupLocation(LatLng position, String address) async {
    state = state.copyWith(pickupLocation: position, pickupAddress: address, isLoading: false);
  }

  Future<void> setDropoffWithGeocode(LatLng position) async {
    state = state.copyWith(isLoading: true);
    try {
      final mapService = MapService();
      final geocode = await mapService.reverseGeocode(latitude: position.latitude, longitude: position.longitude);
      state = state.copyWith(dropoffLocation: position, dropoffAddress: geocode.shortAddress.isNotEmpty ? geocode.shortAddress : geocode.fullAddress, isLoading: false);
    } catch (e) { state = state.copyWith(dropoffLocation: position, dropoffAddress: '${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}', isLoading: false); }
  }

  Future<void> setDropoffLocation(LatLng position, String address) async {
    state = state.copyWith(dropoffLocation: position, dropoffAddress: address, isLoading: false);
  }

  void updateUserLocation(LatLng location) { state = state.copyWith(currentUserLocation: location); }

  Future<void> calculateRoute() async {
    if (state.pickupLocation == null || state.dropoffLocation == null) return;
    state = state.copyWith(isLoading: true);
    try {
      final mapService = MapService();
      final route = await mapService.getRoute(origin: state.pickupLocation!, destination: state.dropoffLocation!);
      state = state.copyWith(currentRoute: route, isLoading: false);
    } catch (e) { debugPrint('Route error: $e'); state = state.copyWith(isLoading: false, error: e.toString()); }
  }

  Future<void> fetchNearbyDrivers(LatLng position) async {
    try {
      final apiService = _ref.read(apiServiceProvider);
      final response = await apiService.get('${ApiConstants.dispatchNearbyDrivers}?latitude=${position.latitude}&longitude=${position.longitude}&radiusKm=10');
      if (response.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;
        final drivers = <DriverModel>[];
        final list = data['drivers'] as List<dynamic>? ?? data['data'] as List<dynamic>? ?? [];
        for (final d in list) { if (d is Map<String, dynamic>) { try { drivers.add(DriverModel.fromJson(d)); } catch (_) {} } }
        state = state.copyWith(nearbyDrivers: drivers);
      }
    } catch (e) { debugPrint('Nearby drivers error: $e'); }
  }

  Future<List<PlaceResult>> searchPlaces(String query) async {
    try {
      final mapService = MapService();
      final results = await mapService.searchPlaces(query, nearPosition: state.currentUserLocation);
      return results.map((r) => PlaceResult(shortAddress: r.shortAddress, fullAddress: r.fullAddress, location: r.location)).toList();
    } catch (e) { debugPrint('Search error: $e'); return []; }
  }

  void clearDropoff() { state = state.copyWith(dropoffLocation: null, dropoffAddress: null, clearRoute: true); }
  void clearAll() { state = const MapLocationState(); }
}

class PlaceResult {
  final String shortAddress;
  final String fullAddress;
  final LatLng location;
  const PlaceResult({required this.shortAddress, required this.fullAddress, required this.location});
}
