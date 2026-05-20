import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:trippo_shared/trippo_shared.dart';
import 'package:go_router/go_router.dart';
import '../../../auth/presentation/notifiers/driver_auth_notifier.dart';
import '../notifiers/driver_home_notifier.dart';

class DriverHomeScreen extends ConsumerStatefulWidget {
  const DriverHomeScreen({super.key});

  @override
  ConsumerState<DriverHomeScreen> createState() => _DriverHomeScreenState();
}

class _DriverHomeScreenState extends ConsumerState<DriverHomeScreen>
    with TickerProviderStateMixin {
  MapController _mapController = MapController();
  late AnimationController _pulseController;
  LatLng? _currentPosition;
  double _heading = 0;
  bool _isMapReady = false;

  static const LatLng _defaultLocation = LatLng(15.3694, 44.1910);

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
    _initLocation();
  }

  Future<void> _initLocation() async {
    await _goToMyLocation(animate: false);
  }

  Future<Position?> _getCurrentPositionWithPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('يرجى تفعيل خدمات الموقع'), backgroundColor: MadarTheme.error),
        );
      }
      return null;
    }
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تم رفض إذن الموقع. يرجى السماح بالوصول للموقع'), backgroundColor: MadarTheme.warning),
          );
        }
        return null;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('إذن الموقع مرفوض نهائياً. يرجى تفعيله من إعدادات التطبيق'),
            backgroundColor: MadarTheme.error,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(label: 'إعدادات', textColor: Colors.white, onPressed: Geolocator.openAppSettings),
          ),
        );
      }
      await Geolocator.openAppSettings();
      return null;
    }
    try {
      return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high, timeLimit: const Duration(seconds: 10));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('فشل في الحصول على الموقع: $e'), backgroundColor: MadarTheme.error));
      }
      return null;
    }
  }

  Future<void> _goToMyLocation({bool animate = true}) async {
    final position = await _getCurrentPositionWithPermission();
    if (position == null) return;
    final latLng = LatLng(position.latitude, position.longitude);
    setState(() { _currentPosition = latLng; _heading = position.heading; });
    if (_isMapReady && animate) {
      _mapController.move(latLng, 16.0);
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  List<Marker> _buildMarkers(DriverHomeState homeState) {
    final markers = <Marker>[];
    if (_currentPosition != null) {
      if (homeState.isOnline) {
        markers.add(Marker(
          point: _currentPosition!,
          width: 40,
          height: 40,
          child: Transform.rotate(
            angle: _heading * 3.141592653589793 / 180,
            child: const Icon(Icons.local_taxi, color: MadarTheme.accent, size: 32),
          ),
        ));
      } else {
        markers.add(Marker(
          point: _currentPosition!,
          width: 30,
          height: 30,
          child: const Icon(Icons.my_location, color: Colors.blue, size: 26),
        ));
      }
    }
    return markers;
  }

  @override
  Widget build(BuildContext context) {
    final homeState = ref.watch(driverHomeProvider);
    ref.listen<DriverHomeState>(driverHomeProvider, (prev, next) {
      if (next.currentLocation != null) {
        final newLatLng = LatLng(next.currentLocation!.latitude, next.currentLocation!.longitude);
        setState(() { _currentPosition = newLatLng; _heading = next.heading; });
        if (next.isOnline && _isMapReady) {
          try { _mapController.move(newLatLng, _mapController.camera.zoom); } catch (_) {}
        }
      }
      // Show error snackbar
      if (next.error != null && (prev?.error != next.error)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!),
            backgroundColor: MadarTheme.error,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    });

    return Scaffold(
      drawer: _buildAppDrawer(context),
      body: Stack(
        children: [
          // Map
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _currentPosition ?? _defaultLocation,
              initialZoom: 14.0,
              onMapReady: () { _isMapReady = true; },
              minZoom: 10.0,
              maxZoom: 19.0,
            ),
            children: [
              TileLayer(
                urlTemplate: TileProviderLayer.lightThemeTileUrl,
                userAgentPackageName: 'com.madar.driver',
                retinaMode: TileProviderLayer.lightThemeSupportsRetina,
                maxZoom: 19,
                maxNativeZoom: 18,
              ),
              MarkerLayer(markers: _buildMarkers(homeState)),
            ],
          ),
          // Top gradient
          Positioned(top: 0, left: 0, right: 0, height: 100, child: Container(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.black.withOpacity(0.2), Colors.transparent])))),
          // Top bar
          Positioned(top: MediaQuery.of(context).padding.top + 8, left: 16, right: 16, child: _buildTopBar(context)),
          // My location button
          Positioned(right: 16, bottom: 160, child: Container(decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [MadarTheme.shadow(blur: 10)]), child: Material(color: Colors.transparent, child: InkWell(customBorder: const CircleBorder(), onTap: () => _goToMyLocation(), child: const Padding(padding: EdgeInsets.all(12), child: Icon(Icons.my_location, color: MadarTheme.primary, size: 22)))))),
          // Online/Offline button
          Positioned(left: 0, right: 0, bottom: 0, child: _buildOnlineControl(homeState)),
        ],
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Row(
      children: [
        Container(decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [MadarTheme.shadow()]), child: Material(color: Colors.transparent, child: InkWell(customBorder: const CircleBorder(), onTap: () => Scaffold.of(context).openDrawer(), child: const Padding(padding: EdgeInsets.all(10), child: Icon(Icons.menu, color: MadarTheme.primary))))),
        const Spacer(),
        if (_currentPosition != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [MadarTheme.shadow()]),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Container(width: 8, height: 8, decoration: BoxDecoration(color: ref.watch(driverHomeProvider).isOnline ? MadarTheme.mapPickup : Colors.grey, shape: BoxShape.circle)),
              const SizedBox(width: 6),
              Text(ref.watch(driverHomeProvider).isOnline ? 'متصل' : 'غير متصل', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: ref.watch(driverHomeProvider).isOnline ? MadarTheme.mapPickup : Colors.grey[700])),
            ]),
          ),
      ],
    );
  }

  Widget _buildOnlineControl(DriverHomeState homeState) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
      decoration: BoxDecoration(color: Colors.white, borderRadius: const BorderRadius.vertical(top: Radius.circular(24)), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, -4))]),
      child: SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          // Stats when online
          if (homeState.isOnline && homeState.wentOnlineAt != null) ...[
            Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
              _buildStatItem(Icons.access_time, 'مدة الاتصال', _formatDuration(homeState.onlineDuration ?? Duration.zero)),
              _buildStatItem(Icons.local_taxi, 'السائقين القريبين', '${homeState.nearbyStats.nearbyDrivers}'),
              _buildStatItem(Icons.trending_up, 'الطلبات', '${homeState.nearbyStats.activeRequests}'),
            ]),
            const SizedBox(height: 16),
          ],
          // Go Online / Go Offline button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: homeState.isLoading ? null : () => _toggleOnlineStatus(homeState),
              style: ElevatedButton.styleFrom(
                backgroundColor: homeState.isOnline ? MadarTheme.error : MadarTheme.mapPickup,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 4,
              ),
              child: homeState.isLoading
                  ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                  : Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Icon(homeState.isOnline ? Icons.power_settings_new : Icons.play_arrow, size: 24),
                      const SizedBox(width: 8),
                      Text(homeState.isOnline ? 'إيقاف التشغيل' : 'بدء التشغيل', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ]),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String label, String value) {
    return Column(children: [
      Icon(icon, color: MadarTheme.primary, size: 20),
      const SizedBox(height: 4),
      Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
      Text(label, style: TextStyle(fontSize: 10, color: Colors.grey[600])),
    ]);
  }

  String _formatDuration(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes % 60;
    if (h > 0) return '$h س $m د';
    return '$m دقيقة';
  }

  Future<void> _toggleOnlineStatus(DriverHomeState homeState) async {
    if (homeState.isOnline) {
      await ref.read(driverHomeProvider.notifier).goOffline();
    } else {
      try {
        await ref.read(driverHomeProvider.notifier).goOnline();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('فشل في بدء التشغيل: $e'),
              backgroundColor: MadarTheme.error,
              duration: const Duration(seconds: 5),
            ),
          );
        }
      }
    }
  }

  Widget _buildAppDrawer(BuildContext context) {
    final authNotifier = ref.read(driverAuthProvider.notifier);
    return Drawer(
      child: ListView(padding: EdgeInsets.zero, children: [
        DrawerHeader(decoration: const BoxDecoration(color: MadarTheme.primary), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Icon(Icons.drive_eta, size: 50, color: Colors.white), const SizedBox(height: 8), Text('${AppConstants.appName} سائق', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold))])),
        ListTile(leading: const Icon(Icons.person), title: const Text('الملف الشخصي'), onTap: () => context.push('/profile')),
        ListTile(leading: const Icon(Icons.history), title: const Text('سجل الرحلات'), onTap: () => context.push('/history')),
        ListTile(leading: const Icon(Icons.account_balance_wallet), title: const Text('الأرباح'), onTap: () => context.push('/earnings')),
        const Divider(),
        ListTile(leading: const Icon(Icons.logout, color: MadarTheme.error), title: const Text('تسجيل الخروج', style: TextStyle(color: MadarTheme.error)), onTap: () { authNotifier.logout(); context.go('/login'); }),
      ]),
    );
  }
}
