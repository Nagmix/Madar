import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:trippo_shared/trippo_shared.dart';
import '../notifiers/driver_home_notifier.dart';

/// الشاشة الرئيسية للسائق - مدار
class DriverHomeScreen extends ConsumerStatefulWidget {
  const DriverHomeScreen({super.key});

  @override
  ConsumerState<DriverHomeScreen> createState() => _DriverHomeScreenState();
}

class _DriverHomeScreenState extends ConsumerState<DriverHomeScreen>
    with TickerProviderStateMixin {
  MapController? _mapController;
  late AnimationController _pulseController;
  LatLng? _currentPosition;
  double _heading = 0;

  /// Default location: Sana'a, Yemen
  static const LatLng _defaultLocation = LatLng(15.3694, 44.1910);

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
    _mapController = MapController();
    _initLocation();
  }

  /// Initialize: get current location and move map
  Future<void> _initLocation() async {
    await _goToMyLocation(animate: false);
  }

  /// Get current GPS position with full permission handling
  Future<Position?> _getCurrentPositionWithPermission() async {
    // 1. Check if location services are enabled
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('يرجى تفعيل خدمات الموقع'),
            backgroundColor: MadarTheme.error,
          ),
        );
      }
      return null;
    }

    // 2. Check current permission
    LocationPermission permission = await Geolocator.checkPermission();

    // 3. If denied, request permission
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم رفض إذن الموقع. يرجى السماح بالوصول للموقع'),
              backgroundColor: MadarTheme.warning,
            ),
          );
        }
        return null;
      }
    }

    // 4. If denied forever, open app settings
    if (permission == LocationPermission.deniedForever) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('إذن الموقع مرفوض نهائياً. يرجى تفعيله من إعدادات التطبيق'),
            backgroundColor: MadarTheme.error,
            duration: Duration(seconds: 5),
            action: SnackBarAction(
              label: 'إعدادات',
              textColor: Colors.white,
              onPressed: Geolocator.openAppSettings,
            ),
          ),
        );
      }
      // Try to open app settings
      await Geolocator.openAppSettings();
      return null;
    }

    // 5. Permission granted - get current position
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );
      return position;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل في الحصول على الموقع: $e'),
            backgroundColor: MadarTheme.error,
          ),
        );
      }
      return null;
    }
  }

  /// Go to my current location
  Future<void> _goToMyLocation({bool animate = true}) async {
    final position = await _getCurrentPositionWithPermission();
    if (position == null) return;

    final latLng = LatLng(position.latitude, position.longitude);
    setState(() {
      _currentPosition = latLng;
      _heading = position.heading;
    });

    if (_mapController != null) {
      if (animate) {
        _mapController!.move(latLng, 16.0);
      }
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final homeState = ref.watch(driverHomeProvider);
    // Update local position from notifier
    ref.listen<DriverHomeState>(driverHomeProvider, (prev, next) {
      if (next.currentLocation != null) {
        final newLatLng = LatLng(
          next.currentLocation!.latitude,
          next.currentLocation!.longitude,
        );
        setState(() {
          _currentPosition = newLatLng;
          _heading = next.heading;
        });
        // Animate map to follow driver when online
        if (next.isOnline && _mapController != null) {
          try {
            _mapController!.move(newLatLng, _mapController!.camera.zoom);
          } catch (_) {}
        }
      }
    });

    return Scaffold(
      body: Stack(
        children: [
          // 1. Full-screen map
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _currentPosition ?? _defaultLocation,
              initialZoom: 14.0,
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.all,
              ),
            ),
            children: [
              // Light theme tiles
              TileLayer(
                urlTemplate: TileProviderLayer.lightThemeTileUrl,
                userAgentPackageName: 'com.madar.driver',
                retinaMode: true,
                maxZoom: 19,
              ),
              // Current location blue pulsing dot marker
              if (_currentPosition != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _currentPosition!,
                      width: 30,
                      height: 30,
                      child: CurrentLocationMarker(animation: _pulseController),
                    ),
                  ],
                ),
              // Car marker showing driver position (when online)
              if (homeState.isOnline && _currentPosition != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _currentPosition!,
                      width: 44,
                      height: 44,
                      child: CarMarker(
                        heading: _heading,
                        color: MadarTheme.primary,
                        size: 44,
                      ),
                    ),
                  ],
                ),
            ],
          ),

          // 2. Top bar
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 16,
            right: 16,
            child: _buildTopBar(),
          ),

          // 3. My location FAB
          Positioned(
            right: 16,
            bottom: 220,
            child: Container(
              decoration: BoxDecoration(
                color: MadarTheme.surface,
                shape: BoxShape.circle,
                boxShadow: [
                  MadarTheme.shadow(blur: 12, offset: const Offset(0, 4)),
                ],
              ),
              child: IconButton(
                icon: const Icon(Icons.my_location, color: MadarTheme.primary),
                onPressed: _goToMyLocation,
              ),
            ),
          ),

          // 4. Bottom panel
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _buildBottomPanel(homeState),
          ),
        ],
      ),
    );
  }

  /// Semi-transparent top bar
  Widget _buildTopBar() {
    return SafeArea(
      child: Row(
        children: [
          // Menu button
          Container(
            decoration: BoxDecoration(
              color: MadarTheme.surface.withOpacity(0.95),
              borderRadius: BorderRadius.circular(MadarTheme.radiusLg),
              boxShadow: [
                MadarTheme.shadow(blur: 8),
              ],
            ),
            child: IconButton(
              icon: const Icon(Icons.menu, color: MadarTheme.textPrimary),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          ),
          const Spacer(),
          // Earnings display
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: MadarTheme.space16,
              vertical: MadarTheme.space8,
            ),
            decoration: BoxDecoration(
              color: MadarTheme.surface.withOpacity(0.95),
              borderRadius: BorderRadius.circular(MadarTheme.radiusLg),
              boxShadow: [
                MadarTheme.shadow(blur: 8),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: MadarTheme.success.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.account_balance_wallet,
                    size: 16,
                    color: MadarTheme.success,
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'ر.ي 0.00',
                  style: TextStyle(
                    fontFamily: MadarTheme.fontFamily,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: MadarTheme.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Bottom panel with online/offline toggle
  Widget _buildBottomPanel(DriverHomeState homeState) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: MadarTheme.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(MadarTheme.radiusXxl),
        ),
        boxShadow: [
          MadarTheme.shadow(
            blur: 20,
            offset: const Offset(0, -4),
            color: Colors.black.withOpacity(0.1),
          ),
        ],
      ),
      padding: const EdgeInsets.all(MadarTheme.space24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
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
          const SizedBox(height: MadarTheme.space20),

          // Show error if any
          if (homeState.error != null) ...[
            Container(
              padding: const EdgeInsets.all(MadarTheme.space12),
              decoration: BoxDecoration(
                color: MadarTheme.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(MadarTheme.radiusMd),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: MadarTheme.error, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      homeState.error!,
                      style: const TextStyle(
                        fontFamily: MadarTheme.fontFamily,
                        fontSize: 13,
                        color: MadarTheme.error,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: MadarTheme.space12),
          ],

          if (homeState.isOnline) ...[
            // Online state
            _buildOnlinePanel(homeState),
          ] else ...[
            // Offline state
            _buildOfflinePanel(homeState),
          ],
        ],
      ),
    );
  }

  /// Offline panel - large "ابدأ العمل" button
  Widget _buildOfflinePanel(DriverHomeState homeState) {
    return Column(
      children: [
        // Status text
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: MadarTheme.textHint,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'أنت غير متصل',
              style: TextStyle(
                fontFamily: MadarTheme.fontFamily,
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: MadarTheme.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: MadarTheme.space8),
        Text(
          'اتصل لبدء استقبال طلبات الرحلات',
          style: TextStyle(
            fontFamily: MadarTheme.fontFamily,
            color: MadarTheme.textHint,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: MadarTheme.space24),

        // Large start button
        MadarGradientButton(
          label: 'ابدأ العمل',
          icon: Icons.power_settings_new,
          height: 60,
          gradientColors: const [MadarTheme.accent, MadarTheme.accentDark],
          isLoading: homeState.isLoading,
          onPressed: homeState.isLoading
              ? null
              : () => ref.read(driverHomeProvider.notifier).goOnline(),
        ),
      ],
    );
  }

  /// Online panel - stats and stop button
  Widget _buildOnlinePanel(DriverHomeState homeState) {
    return Column(
      children: [
        // Green pulsing indicator + status
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: _pulseController,
              builder: (_, __) {
                return Opacity(
                  opacity: 0.5 + (_pulseController.value * 0.5),
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: MadarTheme.success,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: MadarTheme.success.withOpacity(0.4),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(width: 10),
            const Text(
              'متصل الآن',
              style: TextStyle(
                fontFamily: MadarTheme.fontFamily,
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: MadarTheme.success,
              ),
            ),
          ],
        ),
        const SizedBox(height: MadarTheme.space4),
        Text(
          'جاهز لاستقبال طلبات الرحلات',
          style: TextStyle(
            fontFamily: MadarTheme.fontFamily,
            color: MadarTheme.textSecondary,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: MadarTheme.space20),

        // Daily earnings summary
        Container(
          padding: const EdgeInsets.all(MadarTheme.space16),
          decoration: MadarTheme.cardDecoration(
            color: MadarTheme.primaryLight.withOpacity(0.5),
            radius: MadarTheme.radiusLg,
          ),
          child: Row(
            children: [
              _buildStatItem('أرباح اليوم', 'ر.ي 0', Icons.attach_money, MadarTheme.primary),
              Container(
                width: 1,
                height: 40,
                color: MadarTheme.primary.withOpacity(0.2),
              ),
              _buildStatItem('الرحلات', '0', Icons.directions_car, MadarTheme.accent),
              Container(
                width: 1,
                height: 40,
                color: MadarTheme.primary.withOpacity(0.2),
              ),
              _buildStatItem('الساعات', '0س', Icons.access_time, MadarTheme.secondary),
            ],
          ),
        ),
        const SizedBox(height: MadarTheme.space16),

        // Stop button
        SizedBox(
          width: double.infinity,
          height: 52,
          child: OutlinedButton(
            onPressed: homeState.isLoading
                ? null
                : () => ref.read(driverHomeProvider.notifier).goOffline(),
            style: OutlinedButton.styleFrom(
              foregroundColor: MadarTheme.error,
              side: const BorderSide(color: MadarTheme.error, width: 1.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(MadarTheme.radiusMd),
              ),
              textStyle: const TextStyle(
                fontFamily: MadarTheme.fontFamily,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            child: homeState.isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(MadarTheme.error),
                    ),
                  )
                : const Text('إيقاف'),
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontFamily: MadarTheme.fontFamily,
              fontWeight: FontWeight.w700,
              fontSize: 15,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontFamily: MadarTheme.fontFamily,
              color: MadarTheme.textSecondary,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
