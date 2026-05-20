import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:trippo_shared/trippo_shared.dart';
import '../../../map/presentation/notifiers/map_notifier.dart';
import '../../../trip/presentation/notifiers/trip_notifier.dart';
import '../widgets/where_to_sheet.dart';
import '../widgets/ride_request_sheet.dart';
import '../widgets/trip_progress_sheet.dart';
import '../screens/location_picker_screen.dart';
import '../../../auth/presentation/notifiers/auth_notifier.dart';

const LatLng _defaultLocation = LatLng(15.3694, 44.1910);
enum BookingStep { idle, pickupSet, readyToBook, searchingDriver }

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});
  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  MapController _mapController = MapController();
  LatLng? _currentPosition;
  bool _isMapReady = false;
  BookingStep _bookingStep = BookingStep.idle;
  String _selectedVehicleType = 'sedan';

  @override
  void initState() { super.initState(); _getCurrentLocation(); }

  BookingStep _deriveBookingStep(MapLocationState mapState) {
    if (_bookingStep == BookingStep.searchingDriver) return BookingStep.searchingDriver;
    if (mapState.dropoffLocation != null && mapState.pickupLocation != null) return BookingStep.readyToBook;
    if (mapState.pickupLocation != null) return BookingStep.pickupSet;
    return BookingStep.idle;
  }

  Future<void> _getCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) { if (mounted) setState(() => _currentPosition = _defaultLocation); return; }
      }
      if (permission == LocationPermission.deniedForever) { await Geolocator.openAppSettings(); if (mounted) setState(() => _currentPosition = _defaultLocation); return; }
      final position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      if (mounted) { setState(() => _currentPosition = LatLng(position.latitude, position.longitude)); if (_isMapReady) _mapController.move(_currentPosition!, 14.0); }
    } catch (e) { if (mounted) setState(() => _currentPosition = _defaultLocation); }
  }

  Future<void> _goToMyLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) { permission = await Geolocator.requestPermission(); }
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) return;
      final position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      final loc = LatLng(position.latitude, position.longitude);
      if (_isMapReady) _mapController.move(loc, 16.0);
      setState(() => _currentPosition = loc);
      ref.read(mapLocationProvider.notifier).updateUserLocation(loc);
      await ref.read(mapLocationProvider.notifier).setPickupWithGeocode(loc);
    } catch (e) {}
  }

  Future<void> _openPickupPicker() async {
    final result = await Navigator.of(context).push<bool>(MaterialPageRoute(builder: (_) => LocationPickerScreen(mode: LocationPickerMode.pickup, initialPosition: _currentPosition ?? _defaultLocation)));
    if (result == true) _fetchNearbyDrivers();
  }

  Future<void> _openDropoffPicker() async {
    final mapState = ref.read(mapLocationProvider);
    final result = await Navigator.of(context).push<bool>(MaterialPageRoute(builder: (_) => LocationPickerScreen(mode: LocationPickerMode.dropoff, initialPosition: mapState.pickupLocation ?? _currentPosition ?? _defaultLocation)));
    if (result == true) _calculateRouteAndPrice();
  }

  Future<void> _fetchNearbyDrivers() async {
    final mapState = ref.read(mapLocationProvider);
    final pos = mapState.pickupLocation ?? _currentPosition;
    if (pos == null) return;
    try { await ref.read(mapLocationProvider.notifier).fetchNearbyDrivers(pos); } catch (e) { debugPrint('Error fetching nearby drivers: $e'); }
  }

  Future<void> _calculateRouteAndPrice() async {
    final mapState = ref.read(mapLocationProvider);
    if (mapState.pickupLocation == null || mapState.dropoffLocation == null) return;
    try {
      await ref.read(mapLocationProvider.notifier).calculateRoute();
      final updatedState = ref.read(mapLocationProvider);
      if (updatedState.currentRoute != null && updatedState.currentRoute!.polylinePoints.isNotEmpty && _isMapReady) {
        final points = updatedState.currentRoute!.polylinePoints;
        if (points.isNotEmpty) {
          _mapController.fitCamera(CameraFit.bounds(
            bounds: LatLngBounds(
              LatLng(points.map((p) => p.latitude).reduce((a, b) => a < b ? a : b), points.map((p) => p.longitude).reduce((a, b) => a < b ? a : b)),
              LatLng(points.map((p) => p.latitude).reduce((a, b) => a > b ? a : b), points.map((p) => p.longitude).reduce((a, b) => a > b ? a : b)),
            ),
            padding: const EdgeInsets.all(80),
          ));
        }
      }
    } catch (e) { debugPrint('Route error: $e'); }
  }

  Future<void> _findDriver() async {
    final mapState = ref.read(mapLocationProvider);
    if (mapState.pickupLocation == null || mapState.dropoffLocation == null) return;
    setState(() => _bookingStep = BookingStep.searchingDriver);
    try {
      final route = mapState.currentRoute;
      final distanceKm = route?.distanceMeters != null ? route!.distanceMeters / 1000.0 : 0.0;
      final durationMin = route?.durationSeconds != null ? route!.durationSeconds ~/ 60 : 0;
      final pricingService = PricingService();
      final fare = pricingService.calculateFareEstimate(distanceKm: distanceKm, durationMinutes: durationMin, vehicleType: _selectedVehicleType);
      final tripNotifier = ref.read(tripProvider.notifier);
      await tripNotifier.createTrip(CreateTripRequest(
        pickupLatitude: mapState.pickupLocation!.latitude,
        pickupLongitude: mapState.pickupLocation!.longitude,
        pickupAddress: mapState.pickupAddress ?? '',
        dropoffLatitude: mapState.dropoffLocation!.latitude,
        dropoffLongitude: mapState.dropoffLocation!.longitude,
        dropoffAddress: mapState.dropoffAddress ?? '',
        vehicleType: _selectedVehicleType,
      ));
    } catch (e) {
      if (mounted) {
        setState(() => _bookingStep = BookingStep.readyToBook);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('فشل في البحث عن سائق: $e'), backgroundColor: MadarTheme.error, duration: const Duration(seconds: 4)));
      }
    }
  }

  void _onMapTap(LatLng point) {
    final mapState = ref.read(mapLocationProvider);
    if (mapState.pickupLocation == null) { ref.read(mapLocationProvider.notifier).setPickupWithGeocode(point); _fetchNearbyDrivers(); }
    else if (mapState.dropoffLocation == null) { ref.read(mapLocationProvider.notifier).setDropoffWithGeocode(point); _calculateRouteAndPrice(); }
  }

  List<Marker> _buildMarkers(MapLocationState mapState) {
    final markers = <Marker>[];
    if (mapState.pickupLocation != null) markers.add(Marker(point: mapState.pickupLocation!, width: 40, height: 40, child: const Icon(Icons.trip_origin, color: MadarTheme.mapPickup, size: 32)));
    if (mapState.dropoffLocation != null) markers.add(Marker(point: mapState.dropoffLocation!, width: 40, height: 40, child: const Icon(Icons.location_on, color: MadarTheme.mapDropoff, size: 40)));
    for (final driver in mapState.nearbyDrivers) {
      if (driver.currentLocation != null) {
        markers.add(Marker(
          point: LatLng(driver.currentLocation!.latitude, driver.currentLocation!.longitude),
          width: 36, height: 36,
          child: Transform.rotate(angle: (driver.currentLocation!.heading ?? 0) * 3.141592653589793 / 180,
            child: Container(decoration: BoxDecoration(color: MadarTheme.accent, shape: BoxShape.circle, boxShadow: [BoxShadow(color: MadarTheme.accent.withOpacity(0.4), blurRadius: 6)]),
              child: const Icon(Icons.local_taxi, color: Colors.white, size: 20))),
        ));
      }
    }
    return markers;
  }

  List<Polyline> _buildPolylines(MapLocationState mapState) {
    if (mapState.currentRoute == null || mapState.currentRoute!.polylinePoints.isEmpty) return [];
    return [Polyline(points: mapState.currentRoute!.polylinePoints, color: const Color(0xFF448AFF), strokeWidth: 5.0)];
  }

  @override
  Widget build(BuildContext context) {
    final mapState = ref.watch(mapLocationProvider);
    final tripState = ref.watch(tripProvider);
    _bookingStep = _deriveBookingStep(mapState);
    return Scaffold(
      drawer: _buildAppDrawer(context),
      body: Builder(builder: (scaffoldContext) => Stack(children: [
        FlutterMap(mapController: _mapController, options: MapOptions(initialCenter: _currentPosition ?? _defaultLocation, initialZoom: 14.0, onTap: (tapPosition, point) => _onMapTap(point), onMapReady: () { _isMapReady = true; _fetchNearbyDrivers(); }), children: [
          TileLayer(urlTemplate: TileProviderLayer.lightThemeTileUrl, userAgentPackageName: 'com.madar.rider', retinaMode: TileProviderLayer.lightThemeSupportsRetina, maxZoom: 19, maxNativeZoom: 18),
          MarkerLayer(markers: _buildMarkers(mapState)),
          PolylineLayer(polylines: _buildPolylines(mapState)),
        ]),
        Positioned(top: 0, left: 0, right: 0, height: 120, child: Container(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.black.withOpacity(0.3), Colors.transparent])))),
        Positioned(top: MediaQuery.of(scaffoldContext).padding.top + 8, left: 16, right: 16, child: _buildTopBar(scaffoldContext)),
        Positioned(right: 16, bottom: _bookingStep == BookingStep.readyToBook || _bookingStep == BookingStep.searchingDriver ? 420 : _bookingStep == BookingStep.pickupSet ? 280 : 200, child: Container(decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [MadarTheme.shadow(blur: 10)]), child: Material(color: Colors.transparent, child: InkWell(customBorder: const CircleBorder(), onTap: _goToMyLocation, child: const Padding(padding: EdgeInsets.all(12), child: Icon(Icons.my_location, color: MadarTheme.primary, size: 22)))))),
        if (_bookingStep == BookingStep.idle && mapState.pickupLocation == null) Positioned(top: MediaQuery.of(scaffoldContext).padding.top + 70, left: 16, right: 16, child: _buildTapHint(icon: Icons.touch_app, text: 'اضغط على الخريطة لتحديد نقطة الانطلاق', color: MadarTheme.primary)),
        if (_bookingStep == BookingStep.pickupSet) Positioned(top: MediaQuery.of(scaffoldContext).padding.top + 70, left: 16, right: 16, child: _buildTapHint(icon: Icons.touch_app, text: 'اضغط على الخريطة لتحديد الوجهة', color: MadarTheme.mapDropoff)),
        Positioned(left: 0, right: 0, bottom: 0, child: _buildBottomSheet(tripState, mapState)),
      ])),
    );
  }

  Widget _buildTapHint({required IconData icon, required String text, required Color color}) {
    return Container(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10), decoration: BoxDecoration(color: Colors.white.withOpacity(0.92), borderRadius: BorderRadius.circular(MadarTheme.radiusLg), boxShadow: [MadarTheme.shadow()]), child: Row(children: [Icon(icon, color: color, size: 20), const SizedBox(width: 8), Expanded(child: Text(text, style: TextStyle(fontSize: 13, color: color, fontWeight: FontWeight.w600)))]));
  }

  Widget _buildTopBar(BuildContext scaffoldContext) {
    return Row(children: [
      Container(decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [MadarTheme.shadow()]), child: Material(color: Colors.transparent, child: InkWell(customBorder: const CircleBorder(), onTap: () => Scaffold.of(scaffoldContext).openDrawer(), child: const Padding(padding: EdgeInsets.all(10), child: Icon(Icons.menu, color: MadarTheme.primary))))),
      const Spacer(),
      Container(decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [MadarTheme.shadow()]), child: Material(color: Colors.transparent, child: InkWell(customBorder: const CircleBorder(), onTap: () => context.push('/notifications'), child: const Padding(padding: EdgeInsets.all(10), child: Icon(Icons.notifications_none, color: MadarTheme.primary))))),
    ]);
  }

  Widget _buildAppDrawer(BuildContext context) {
    return Drawer(child: ListView(padding: EdgeInsets.zero, children: [
      DrawerHeader(decoration: const BoxDecoration(color: MadarTheme.primary), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Icon(Icons.account_circle, size: 50, color: Colors.white), const SizedBox(height: 8), Text('${AppConstants.appName} ${AppConstants.appSlogan}', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold))])),
      ListTile(leading: const Icon(Icons.person), title: const Text('الملف الشخصي'), onTap: () => context.push('/profile')),
      ListTile(leading: const Icon(Icons.history), title: const Text('سجل الرحلات'), onTap: () => context.push('/history')),
      ListTile(leading: const Icon(Icons.wallet), title: const Text('المحفظة'), onTap: () => context.push('/wallet')),
      const Divider(),
      ListTile(leading: const Icon(Icons.logout, color: MadarTheme.error), title: const Text('تسجيل الخروج', style: TextStyle(color: MadarTheme.error)), onTap: () { ref.read(authProvider.notifier).logout(); context.go('/login'); }),
    ]));
  }

  Widget _buildBottomSheet(TripState tripState, MapLocationState mapState) {
    if (tripState == TripState.driverAssigned || tripState == TripState.driverArriving || tripState == TripState.driverArrived || tripState == TripState.tripStarted) return const TripProgressSheet();
    if (_bookingStep == BookingStep.searchingDriver) return _buildSearchingSheet();
    if (_bookingStep == BookingStep.readyToBook) return _buildBookingSheet(mapState);
    if (_bookingStep == BookingStep.pickupSet) return _buildPickupSetSheet(mapState);
    return WhereToSheet(onPickupSelect: _openPickupPicker, onDropoffSelect: _openDropoffPicker);
  }

  Widget _buildSearchingSheet() {
    return Container(padding: const EdgeInsets.all(24), decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))), child: SafeArea(child: Column(mainAxisSize: MainAxisSize.min, children: [
      const SizedBox(height: 30, width: 30, child: CircularProgressIndicator(strokeWidth: 3, color: MadarTheme.primary)),
      const SizedBox(height: 16), const Text('جارٍ البحث عن سائق...', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      const SizedBox(height: 8), Text('يرجى الانتظار بينما نبحث عن أقرب سائق', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
      const SizedBox(height: 20),
      SizedBox(width: double.infinity, height: 48, child: OutlinedButton(onPressed: () { setState(() => _bookingStep = BookingStep.readyToBook); ref.read(tripProvider.notifier).resetToIdle(); }, style: OutlinedButton.styleFrom(side: const BorderSide(color: MadarTheme.error), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: const Text('إلغاء البحث', style: TextStyle(color: MadarTheme.error, fontSize: 16)))),
    ])));
  }

  Widget _buildBookingSheet(MapLocationState mapState) {
    final route = mapState.currentRoute;
    final distanceKm = route?.distanceMeters != null ? route!.distanceMeters / 1000.0 : 0.0;
    final durationMin = route?.durationSeconds != null ? route!.durationSeconds ~/ 60 : 0;
    final pricingService = PricingService();
    final fare = pricingService.calculateFareEstimate(distanceKm: distanceKm, durationMinutes: durationMin, vehicleType: _selectedVehicleType);
    return Container(padding: const EdgeInsets.all(20), decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))), child: SafeArea(child: Column(mainAxisSize: MainAxisSize.min, children: [
      Center(child: Container(margin: const EdgeInsets.only(bottom: 16), width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)))),
      Row(children: [Icon(Icons.trip_origin, color: MadarTheme.mapPickup, size: 22), const SizedBox(width: 10), Expanded(child: Text(mapState.pickupAddress ?? 'نقطة الانطلاق', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis))]),
      Padding(padding: const EdgeInsets.only(left: 11), child: Container(width: 2, height: 20, color: Colors.grey[300])),
      Row(children: [Icon(Icons.location_on, color: MadarTheme.mapDropoff, size: 22), const SizedBox(width: 10), Expanded(child: Text(mapState.dropoffAddress ?? 'الوجهة', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis))]),
      const SizedBox(height: 16),
      _buildVehicleSelector(),
      const SizedBox(height: 16),
      Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: MadarTheme.primary.withOpacity(0.08), borderRadius: BorderRadius.circular(16)), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('السعر المقدر', style: TextStyle(fontSize: 12, color: Colors.grey)), Text('${fare.totalFare.toStringAsFixed(0)} ر.ي', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: MadarTheme.primary))]),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [Text('${distanceKm.toStringAsFixed(1)} كم', style: TextStyle(fontSize: 13, color: Colors.grey[700])), Text('${durationMin} دقيقة', style: TextStyle(fontSize: 13, color: Colors.grey[700]))]),
      ])),
      const SizedBox(height: 16),
      SizedBox(width: double.infinity, height: 52, child: ElevatedButton(onPressed: _findDriver, style: ElevatedButton.styleFrom(backgroundColor: MadarTheme.primary, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(MadarTheme.radiusLg)), elevation: 3), child: const Text('البحث عن سائق', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)))),
    ])));
  }

  Widget _buildVehicleSelector() {
    final vehicles = [
      {'type': 'sedan', 'name': 'سيدان', 'icon': Icons.directions_car},
      {'type': 'suv', 'name': 'عائلية', 'icon': Icons.airport_shuttle},
      {'type': 'economy', 'name': 'اقتصادية', 'icon': Icons.eco},
    ];
    return Row(children: vehicles.map((v) {
      final isSelected = _selectedVehicleType == v['type'];
      return Expanded(child: GestureDetector(onTap: () => setState(() => _selectedVehicleType = v['type'] as String), child: Container(margin: const EdgeInsets.symmetric(horizontal: 4), padding: const EdgeInsets.symmetric(vertical: 10), decoration: BoxDecoration(color: isSelected ? MadarTheme.primary.withOpacity(0.1) : Colors.grey[100], borderRadius: BorderRadius.circular(12), border: Border.all(color: isSelected ? MadarTheme.primary : Colors.grey[300]!)), child: Column(children: [Icon(v['icon'] as IconData, color: isSelected ? MadarTheme.primary : Colors.grey[600], size: 24), const SizedBox(height: 4), Text(v['name'] as String, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: isSelected ? MadarTheme.primary : Colors.grey[700]))]))));
    }).toList());
  }

  Widget _buildPickupSetSheet(MapLocationState mapState) {
    return Container(padding: const EdgeInsets.all(20), decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))), child: SafeArea(child: Column(mainAxisSize: MainAxisSize.min, children: [
      Center(child: Container(margin: const EdgeInsets.only(bottom: 16), width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)))),
      Row(children: [Icon(Icons.trip_origin, color: MadarTheme.mapPickup, size: 22), const SizedBox(width: 10), Expanded(child: Text(mapState.pickupAddress ?? 'نقطة الانطلاق', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)))]),
      const SizedBox(height: 16),
      SizedBox(width: double.infinity, height: 52, child: ElevatedButton(onPressed: _openDropoffPicker, style: ElevatedButton.styleFrom(backgroundColor: MadarTheme.mapDropoff, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(MadarTheme.radiusLg)), elevation: 3), child: const Text('تحديد الوجهة', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)))),
    ])));
  }
}
