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
import '../../../../core/constants/app_theme.dart';
import '../../../auth/presentation/notifiers/auth_notifier.dart';

/// الشاشة الرئيسية - مدار
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  MapController? _mapController;
  LatLng? _currentPosition;
  bool _isMapReady = false;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      setState(() => _currentPosition = LatLng(position.latitude, position.longitude));
      if (_mapController != null && _isMapReady) {
        _mapController!.move(_currentPosition!, 14.0);
      }
    } catch (e) {
      setState(() => _currentPosition = const LatLng(24.7136, 46.6753));
    }
  }

  void _goToMyLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      final loc = LatLng(position.latitude, position.longitude);
      _mapController?.move(loc, 14.0);
      setState(() => _currentPosition = loc);
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    final mapState = ref.watch(mapLocationProvider);
    final tripState = ref.watch(tripProvider);

    return Scaffold(
      drawer: _buildAppDrawer(context),
      body: Stack(
        children: [
          // الخريطة
          FlutterMap(
            mapController: MapController(),
            options: MapOptions(
              initialCenter: _currentPosition ?? const LatLng(24.7136, 46.6753),
              initialZoom: 14.0,
              onMapReady: () => _isMapReady = true,
              onPositionChanged: (position, hasGesture) {
                if (hasGesture) _currentPosition = position.center ?? _currentPosition!;
              },
              interactionOptions: const InteractionOptions(flags: InteractiveFlag.all),
            ),
            children: [
              TileLayer(
                urlTemplate: TileProviderLayer.darkThemeTileUrl,
                userAgentPackageName: 'com.madar.rider',
                retinaMode: true,
                maxZoom: 19,
              ),
              if (mapState.circles.isNotEmpty) CircleLayer(circles: mapState.circles),
              if (mapState.polylines.isNotEmpty) PolylineLayer(polylines: mapState.polylines),
              MarkerLayer(markers: [
                if (mapState.currentUserLocation != null)
                  Marker(
                    point: mapState.currentUserLocation!,
                    width: 20, height: 20,
                    child: Container(
                      decoration: BoxDecoration(color: Colors.blue.withOpacity(0.3), shape: BoxShape.circle),
                      child: Center(child: Container(width: 10, height: 10, decoration: const BoxDecoration(color: Colors.blue, shape: BoxShape.circle, border: Border.fromBorderSide(BorderSide(color: Colors.white, width: 2))))),
                    ),
                  ),
                if (mapState.pickupLocation != null)
                  Marker(point: mapState.pickupLocation!, width: 40, height: 40, child: const Icon(Icons.location_on, color: Color(0xFF00C853), size: 40)),
                if (mapState.dropoffLocation != null)
                  Marker(point: mapState.dropoffLocation!, width: 40, height: 40, child: const Icon(Icons.location_on, color: Color(0xFFFF1744), size: 40)),
                ...mapState.nearbyDrivers.where((d) => d.currentLocation != null).map((driver) => Marker(
                  point: LatLng(driver.currentLocation!.latitude, driver.currentLocation!.longitude),
                  width: 30, height: 30,
                  child: const Icon(Icons.directions_car, color: Color(0xFFFF6D00), size: 30),
                )),
              ]),
            ],
          ),

          // دبوس المركز
          if (mapState.dropoffLocation == null)
            Center(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 40),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.location_on, color: Color(0xFF00C853), size: 40),
                  Container(width: 2, height: 10, color: const Color(0xFF00C853)),
                ]),
              ),
            ),

          // زر موقعي
          Positioned(
            right: 16, bottom: 300,
            child: FloatingActionButton.small(
              onPressed: _goToMyLocation,
              backgroundColor: Colors.white,
              child: const Icon(Icons.my_location, color: Colors.black54),
            ),
          ),

          // الشريط العلوي
          Positioned(
            top: MediaQuery.of(context).padding.top + 8, left: 16, right: 16,
            child: _buildTopBar(),
          ),

          // الشريط السفلي
          Positioned(left: 0, right: 0, bottom: 0, child: _buildBottomSheet(tripState, mapState)),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return SafeArea(
      child: Row(children: [
        Container(
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)]),
          child: IconButton(icon: const Icon(Icons.menu), onPressed: () => Scaffold.of(context).openDrawer()),
        ),
        const Spacer(),
        GestureDetector(
          onTap: () => showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.transparent, builder: (context) => const WhereToSheet()),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)]),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.search, color: Colors.grey[600], size: 20),
              const SizedBox(width: 8),
              Text('إلى أين؟', style: TextStyle(color: Colors.grey[600], fontSize: 14, fontWeight: FontWeight.w500)),
            ]),
          ),
        ),
      ]),
    );
  }

  Widget _buildBottomSheet(TripState tripState, MapLocationState mapState) {
    return switch (tripState) {
      TripState.idle => _buildIdleSheet(mapState),
      TripState.searchingDriver => const RideRequestSheet(),
      TripState.driverAssigned || TripState.driverArriving || TripState.driverArrived || TripState.tripStarted || TripState.tripPaused || TripState.tripResumed => const TripProgressSheet(),
      _ => _buildIdleSheet(mapState),
    };
  }

  Widget _buildIdleSheet(MapLocationState mapState) {
    if (mapState.dropoffLocation != null && mapState.currentRoute != null) {
      return _buildRideRequestSheet(mapState);
    }
    return _buildWhereToBar(mapState);
  }

  Widget _buildWhereToBar(MapLocationState mapState) {
    return Container(
      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24)), boxShadow: [BoxShadow(color: Color(0x1A000000), blurRadius: 20, offset: Offset(0, -4))]),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Center(child: Container(margin: const EdgeInsets.only(top: 8), width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)))),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: GestureDetector(
            onTap: () => showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.transparent, builder: (context) => const WhereToSheet()),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12)),
              child: Row(children: [
                Icon(Icons.search, color: Colors.grey[500]),
                const SizedBox(width: 12),
                Text('إلى أين؟', style: TextStyle(color: Colors.grey[500], fontSize: 16, fontWeight: FontWeight.w500)),
              ]),
            ),
          ),
        ),
        if (mapState.pickupAddress != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(children: [
              const Icon(Icons.radio_button_checked, color: Color(0xFF00C853), size: 20),
              const SizedBox(width: 12),
              Expanded(child: Text(mapState.pickupAddress!, style: const TextStyle(fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis)),
            ]),
          ),
      ]),
    );
  }

  Widget _buildRideRequestSheet(MapLocationState mapState) {
    final route = mapState.currentRoute!;
    return Container(
      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      padding: const EdgeInsets.all(24),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)))),
        const SizedBox(height: 16),
        Row(children: [
          Expanded(child: _buildInfoCard('المسافة', '${route.distanceKm.toStringAsFixed(1)} كم', Icons.straighten)),
          const SizedBox(width: 12),
          Expanded(child: _buildInfoCard('المدة', '${route.durationMinutes.toStringAsFixed(0)} دقيقة', Icons.access_time)),
        ]),
        const SizedBox(height: 16),
        _buildVehicleSelection(),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => _requestRide(mapState),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00C853), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: const Text('طلب رحلة', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          ),
        ),
      ]),
    );
  }

  Widget _buildInfoCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey[200]!)),
      child: Column(children: [
        Icon(icon, color: Colors.grey[600], size: 20),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
        Text(title, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
      ]),
    );
  }

  Widget _buildVehicleSelection() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('اختر نوع المركبة', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
      const SizedBox(height: 12),
      Row(children: [
        _buildVehicleOption(Icons.directions_car, 'سيدان', VehicleType.sedan),
        const SizedBox(width: 8),
        _buildVehicleOption(Icons.local_taxi, 'مريح', VehicleType.suv),
        const SizedBox(width: 8),
        _buildVehicleOption(Icons.airport_shuttle, 'فان', VehicleType.van),
      ]),
    ]);
  }

  Widget _buildVehicleOption(IconData icon, String name, VehicleType type) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey[200]!)),
        child: Column(children: [
          Icon(icon, color: AppTheme.primary, size: 28),
          const SizedBox(height: 4),
          Text(name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
        ]),
      ),
    );
  }

  void _requestRide(MapLocationState mapState) {
    if (mapState.pickupLocation == null || mapState.dropoffLocation == null) return;
    ref.read(tripProvider.notifier).createTrip(CreateTripRequest(
      pickupLatitude: mapState.pickupLocation!.latitude,
      pickupLongitude: mapState.pickupLocation!.longitude,
      pickupAddress: mapState.pickupAddress ?? '',
      dropoffLatitude: mapState.dropoffLocation!.latitude,
      dropoffLongitude: mapState.dropoffLocation!.longitude,
      dropoffAddress: mapState.dropoffAddress ?? '',
      vehicleType: 'sedan',
    ));
  }

  Widget _buildAppDrawer(BuildContext context) {
    return Drawer(
      child: Container(
        color: Colors.white,
        child: ListView(padding: EdgeInsets.zero, children: [
          // رأس الدرج
          Container(
            padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [Color(0xFF00C853), Color(0xFF009624)]),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                width: 64, height: 64,
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                child: const Icon(Icons.local_taxi, size: 32, color: Color(0xFF00C853)),
              ),
              const SizedBox(height: 16),
              const Text('مدار', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              Text('رحلتك، طريقتك', style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14)),
            ]),
          ),
          _drawerItem(Icons.person, 'الملف الشخصي', () => context.go('/profile')),
          _drawerItem(Icons.history, 'سجل الرحلات', () => context.go('/history')),
          _drawerItem(Icons.account_balance_wallet, 'المحفظة', () => context.go('/wallet')),
          _drawerItem(Icons.notifications, 'الإشعارات', () => context.go('/notifications')),
          _drawerItem(Icons.star, 'تقييم الرحلة', () => context.go('/rating')),
          const Divider(),
          _drawerItem(Icons.settings, 'الإعدادات', () {}),
          _drawerItem(Icons.help, 'المساعدة', () {}),
          _drawerItem(Icons.info, 'عن مدار', () {}),
          const Divider(),
          _drawerItem(Icons.logout, 'تسجيل الخروج', () {
            ref.read(authProvider.notifier).logout();
            context.go('/login');
          }, color: Colors.red),
        ]),
      ),
    );
  }

  Widget _drawerItem(IconData icon, String title, VoidCallback onTap, {Color? color}) {
    return ListTile(
      leading: Icon(icon, color: color ?? AppTheme.textSecondary),
      title: Text(title, style: TextStyle(color: color ?? AppTheme.textPrimary, fontWeight: FontWeight.w500)),
      onTap: onTap,
    );
  }
}
