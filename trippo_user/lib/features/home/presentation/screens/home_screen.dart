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
    _mapController = MapController();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      setState(() =>
          _currentPosition = LatLng(position.latitude, position.longitude));
      if (_mapController != null && _isMapReady) {
        _mapController!.move(_currentPosition!, 14.0);
      }
    } catch (e) {
      setState(() => _currentPosition = const LatLng(24.7136, 46.6753));
    }
  }

  void _goToMyLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
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
          // ── الخريطة ──
          FlutterMap(
            mapController: _mapController!,
            options: MapOptions(
              initialCenter:
                  _currentPosition ?? const LatLng(24.7136, 46.6753),
              initialZoom: 14.0,
              onMapReady: () => _isMapReady = true,
              onPositionChanged: (position, hasGesture) {
                if (hasGesture) {
                  _currentPosition = position.center ?? _currentPosition!;
                }
              },
              interactionOptions:
                  const InteractionOptions(flags: InteractiveFlag.all),
            ),
            children: [
              TileLayer(
                urlTemplate: TileProviderLayer.darkThemeTileUrl,
                userAgentPackageName: 'com.madar.rider',
                retinaMode: true,
                maxZoom: 19,
              ),
              if (mapState.circles.isNotEmpty)
                CircleLayer(circles: mapState.circles),
              if (mapState.polylines.isNotEmpty)
                PolylineLayer(polylines: mapState.polylines),
              MarkerLayer(
                markers: [
                  // موقع المستخدم الحالي مع نبضة
                  if (mapState.currentUserLocation != null)
                    Marker(
                      point: mapState.currentUserLocation!,
                      width: 48,
                      height: 48,
                      child: _CurrentUserMarker(),
                    ),
                  // نقطة الانطلاق
                  if (mapState.pickupLocation != null)
                    Marker(
                      point: mapState.pickupLocation!,
                      width: 40,
                      height: 40,
                      child: const Icon(Icons.location_on,
                          color: MadarTheme.mapPickup, size: 40),
                    ),
                  // نقطة الوصول
                  if (mapState.dropoffLocation != null)
                    Marker(
                      point: mapState.dropoffLocation!,
                      width: 40,
                      height: 40,
                      child: const Icon(Icons.location_on,
                          color: MadarTheme.mapDropoff, size: 40),
                    ),
                  // السائقون القريبون
                  ...mapState.nearbyDrivers
                      .where((d) => d.currentLocation != null)
                      .map((driver) => Marker(
                            point: LatLng(driver.currentLocation!.latitude,
                                driver.currentLocation!.longitude),
                            width: 36,
                            height: 36,
                            child: Container(
                              decoration: BoxDecoration(
                                color: MadarTheme.mapDriver.withOpacity(0.15),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.directions_car,
                                  color: MadarTheme.mapDriver, size: 24),
                            ),
                          )),
                ],
              ),
            ],
          ),

          // ── دبوس المركز ──
          if (mapState.dropoffLocation == null)
            Center(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 40),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.location_on,
                        color: MadarTheme.mapPickup, size: 40),
                    Container(
                        width: 2,
                        height: 10,
                        color: MadarTheme.mapPickup),
                  ],
                ),
              ),
            ),

          // ── تدرج علوي شفاف ──
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 120,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.4),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // ── الشريط العلوي ──
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 16,
            right: 16,
            child: _buildTopBar(),
          ),

          // ── زر موقعي ──
          Positioned(
            right: 16,
            bottom: 300,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  MadarTheme.shadow(blur: 10),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: _goToMyLocation,
                  child: const Padding(
                    padding: EdgeInsets.all(12),
                    child: Icon(Icons.my_location,
                        color: MadarTheme.primary, size: 22),
                  ),
                ),
              ),
            ),
          ),

          // ── الشريط السفلي ──
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _buildBottomSheet(tripState, mapState),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // الشريط العلوي
  // ─────────────────────────────────────────────────────────────
  Widget _buildTopBar() {
    return SafeArea(
      child: Row(
        children: [
          // زر القائمة
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [MadarTheme.shadow(blur: 10)],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: () => Scaffold.of(context).openDrawer(),
                child: const Padding(
                  padding: EdgeInsets.all(10),
                  child: Icon(Icons.menu, color: MadarTheme.textPrimary, size: 22),
                ),
              ),
            ),
          ),
          const Spacer(),
          // زر الإشعارات
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [MadarTheme.shadow(blur: 10)],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: () => context.go('/notifications'),
                child: const Padding(
                  padding: EdgeInsets.all(10),
                  child:
                      Icon(Icons.notifications_none, color: MadarTheme.textPrimary, size: 22),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // الشريط السفلي
  // ─────────────────────────────────────────────────────────────
  Widget _buildBottomSheet(TripState tripState, MapLocationState mapState) {
    return switch (tripState) {
      TripState.idle => _buildIdleSheet(mapState),
      TripState.searchingDriver => const RideRequestSheet(),
      TripState.driverAssigned ||
      TripState.driverArriving ||
      TripState.driverArrived ||
      TripState.tripStarted ||
      TripState.tripPaused ||
      TripState.tripResumed =>
        const TripProgressSheet(),
      _ => _buildIdleSheet(mapState),
    };
  }

  Widget _buildIdleSheet(MapLocationState mapState) {
    if (mapState.dropoffLocation != null && mapState.currentRoute != null) {
      return _buildRideRequestSheet(mapState);
    }
    return _buildWhereToBar(mapState);
  }

  // ── شريط "أين تريد الذهاب؟" مع تأثير الزجاج ──
  Widget _buildWhereToBar(MapLocationState mapState) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(MadarTheme.radiusXxl),
        ),
        boxShadow: [
          MadarTheme.shadow(
            color: Colors.black.withOpacity(0.12),
            blur: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // مقبض السحب
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: MadarTheme.space12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: MadarTheme.textHint.withOpacity(0.3),
                borderRadius: BorderRadius.circular(MadarTheme.radiusFull),
              ),
            ),
          ),
          // شريط البحث
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
            child: GestureDetector(
              onTap: () => showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => const WhereToSheet(),
              ),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  color: MadarTheme.background,
                  borderRadius: BorderRadius.circular(MadarTheme.radiusXl),
                  border: Border.all(
                    color: MadarTheme.primary.withOpacity(0.15),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.search, color: MadarTheme.primary, size: 22),
                    const SizedBox(width: MadarTheme.space12),
                    Expanded(
                      child: Text(
                        'أين تريد الذهاب؟',
                        style: TextStyle(
                          color: MadarTheme.textSecondary,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          fontFamily: MadarTheme.fontFamily,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: MadarTheme.primary.withOpacity(0.1),
                        borderRadius:
                            BorderRadius.circular(MadarTheme.radiusSm),
                      ),
                      child: const Icon(Icons.arrow_forward,
                          color: MadarTheme.primary, size: 18),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // عنوان نقطة الانطلاق
          if (mapState.pickupAddress != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: MadarTheme.mapPickup,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: MadarTheme.space12),
                  Expanded(
                    child: Text(
                      mapState.pickupAddress!,
                      style: const TextStyle(
                        fontSize: 14,
                        fontFamily: MadarTheme.fontFamily,
                        color: MadarTheme.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // ── ورقة طلب الرحلة ──
  Widget _buildRideRequestSheet(MapLocationState mapState) {
    final route = mapState.currentRoute!;
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(MadarTheme.radiusXxl),
        ),
      ),
      padding: const EdgeInsets.all(MadarTheme.space24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: MadarTheme.textHint.withOpacity(0.3),
                borderRadius: BorderRadius.circular(MadarTheme.radiusFull),
              ),
            ),
          ),
          const SizedBox(height: MadarTheme.space16),
          Row(
            children: [
              Expanded(
                child: _buildInfoCard(
                  'المسافة',
                  '${route.distanceKm.toStringAsFixed(1)} كم',
                  Icons.straighten,
                ),
              ),
              const SizedBox(width: MadarTheme.space12),
              Expanded(
                child: _buildInfoCard(
                  'المدة',
                  '${route.durationMinutes.toStringAsFixed(0)} دقيقة',
                  Icons.access_time,
                ),
              ),
            ],
          ),
          const SizedBox(height: MadarTheme.space16),
          _buildVehicleSelection(),
          const SizedBox(height: MadarTheme.space20),
          MadarGradientButton(
            label: 'طلب رحلة',
            onPressed: () => _requestRide(mapState),
            gradientColors: const [
              MadarTheme.primary,
              MadarTheme.primaryDark,
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(MadarTheme.space12),
      decoration: BoxDecoration(
        color: MadarTheme.background,
        borderRadius: BorderRadius.circular(MadarTheme.radiusLg),
        border: Border.all(
            color: MadarTheme.primary.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Icon(icon, color: MadarTheme.primary, size: 22),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 16,
              fontFamily: MadarTheme.fontFamily,
              color: MadarTheme.textPrimary,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              color: MadarTheme.textSecondary,
              fontSize: 12,
              fontFamily: MadarTheme.fontFamily,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVehicleSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'اختر نوع المركبة',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 16,
            fontFamily: MadarTheme.fontFamily,
            color: MadarTheme.textPrimary,
          ),
        ),
        const SizedBox(height: MadarTheme.space12),
        Row(
          children: [
            _buildVehicleOption(Icons.directions_car, 'سيدان', VehicleType.sedan),
            const SizedBox(width: 8),
            _buildVehicleOption(Icons.local_taxi, 'مريح', VehicleType.suv),
            const SizedBox(width: 8),
            _buildVehicleOption(Icons.airport_shuttle, 'فان', VehicleType.van),
          ],
        ),
      ],
    );
  }

  Widget _buildVehicleOption(IconData icon, String name, VehicleType type) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(MadarTheme.space12),
        decoration: BoxDecoration(
          color: MadarTheme.background,
          borderRadius: BorderRadius.circular(MadarTheme.radiusLg),
          border: Border.all(
            color: MadarTheme.primary.withOpacity(0.15),
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: MadarTheme.primary, size: 28),
            const SizedBox(height: 4),
            Text(
              name,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                fontFamily: MadarTheme.fontFamily,
                color: MadarTheme.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _requestRide(MapLocationState mapState) {
    if (mapState.pickupLocation == null || mapState.dropoffLocation == null) {
      return;
    }
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

  // ─────────────────────────────────────────────────────────────
  // الدرج الجانبي
  // ─────────────────────────────────────────────────────────────
  Widget _buildAppDrawer(BuildContext context) {
    final authState = ref.watch(authProvider);
    final user = authState.user;

    return Drawer(
      child: Container(
        color: MadarTheme.surface,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // رأس الدرج
            Container(
              padding: const EdgeInsets.fromLTRB(20, 50, 20, 24),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [MadarTheme.primary, MadarTheme.primaryDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Center(
                      child: Icon(Icons.local_taxi,
                          size: 32, color: MadarTheme.primary),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user?.name ?? 'مدار',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      fontFamily: MadarTheme.fontFamily,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user?.email ?? 'رحلتك، طريقتك',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 13,
                      fontFamily: MadarTheme.fontFamily,
                    ),
                  ),
                ],
              ),
            ),
            _drawerItem(Icons.home, 'الرئيسية', () => context.go('/home')),
            _drawerItem(
                Icons.account_balance_wallet, 'المحفظة', () => context.go('/wallet')),
            _drawerItem(
                Icons.history, 'سجل الرحلات', () => context.go('/history')),
            _drawerItem(Icons.notifications, 'الإشعارات',
                () => context.go('/notifications')),
            _drawerItem(
                Icons.person, 'الملف الشخصي', () => context.go('/profile')),
            const Divider(),
            _drawerItem(Icons.logout, 'تسجيل الخروج', () {
              ref.read(authProvider.notifier).logout();
              context.go('/login');
            }, color: MadarTheme.error),
          ],
        ),
      ),
    );
  }

  Widget _drawerItem(IconData icon, String title, VoidCallback onTap,
      {Color? color}) {
    return ListTile(
      leading: Icon(icon, color: color ?? MadarTheme.textSecondary),
      title: Text(
        title,
        style: TextStyle(
          color: color ?? MadarTheme.textPrimary,
          fontWeight: FontWeight.w500,
          fontFamily: MadarTheme.fontFamily,
        ),
      ),
      onTap: onTap,
    );
  }
}

// ─────────────────────────────────────────────────────────────
// علامة موقع المستخدم مع نبضة
// ─────────────────────────────────────────────────────────────
class _CurrentUserMarker extends StatefulWidget {
  @override
  State<_CurrentUserMarker> createState() => _CurrentUserMarkerState();
}

class _CurrentUserMarkerState extends State<_CurrentUserMarker>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final progress = _controller.value;
        return Stack(
          alignment: Alignment.center,
          children: [
            // حلقة النبضة
            Opacity(
              opacity: (1 - progress) * 0.3,
              child: Container(
                width: 48 * (1 + progress * 0.8),
                height: 48 * (1 + progress * 0.8),
                decoration: BoxDecoration(
                  color: MadarTheme.primary,
                  shape: BoxShape.circle,
                ),
              ),
            ),
            // النقطة الخارجية
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: MadarTheme.primary.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
            ),
            // النقطة الداخلية
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: MadarTheme.primary,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2.5),
              ),
            ),
          ],
        );
      },
    );
  }
}

