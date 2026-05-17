import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:trippo_shared/trippo_shared.dart';
import '../../../../core/constants/app_theme.dart';

/// الشاشة الرئيسية للسائق - مدار
class DriverHomeScreen extends ConsumerStatefulWidget {
  const DriverHomeScreen({super.key});

  @override
  ConsumerState<DriverHomeScreen> createState() => _DriverHomeScreenState();
}

class _DriverHomeScreenState extends ConsumerState<DriverHomeScreen>
    with TickerProviderStateMixin {
  MapController? _mapController;
  bool _isOnline = false;
  LatLng? _currentPosition;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() => _currentPosition = LatLng(position.latitude, position.longitude));
    } catch (e) {
      setState(() => _currentPosition = const LatLng(24.7136, 46.6753));
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. Full-screen map
          FlutterMap(
            mapController: MapController(),
            options: MapOptions(
              initialCenter: _currentPosition ?? const LatLng(24.7136, 46.6753),
              initialZoom: 14.0,
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.all,
              ),
            ),
            children: [
              TileLayer(
                urlTemplate: TileProviderLayer.darkThemeTileUrl,
                userAgentPackageName: 'com.madar.driver',
                retinaMode: true,
                maxZoom: 19,
              ),
              if (_currentPosition != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _currentPosition!,
                      width: 60,
                      height: 60,
                      child: _buildDriverMarker(),
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
                onPressed: _getCurrentLocation,
              ),
            ),
          ),

          // 4. Bottom panel
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _buildBottomPanel(),
          ),
        ],
      ),
    );
  }

  /// Driver marker with pulse animation
  Widget _buildDriverMarker() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Pulse ring (only when online)
        if (_isOnline)
          AnimatedBuilder(
            animation: _pulseController,
            builder: (_, __) {
              return Opacity(
                opacity: (1 - _pulseController.value) * 0.4,
                child: Transform.scale(
                  scale: 1.0 + _pulseController.value * 0.8,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: MadarTheme.success,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              );
            },
          ),
        // Inner marker
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: _isOnline ? MadarTheme.success : MadarTheme.accent,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 3),
            boxShadow: [
              BoxShadow(
                color: (_isOnline ? MadarTheme.success : MadarTheme.accent)
                    .withOpacity(0.4),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Icon(
            Icons.local_taxi,
            color: Colors.white,
            size: 12,
          ),
        ),
      ],
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
                  'ر.س 0.00',
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
  Widget _buildBottomPanel() {
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

          if (_isOnline) ...[
            // Online state
            _buildOnlinePanel(),
          ] else ...[
            // Offline state
            _buildOfflinePanel(),
          ],
        ],
      ),
    );
  }

  /// Offline panel - large "ابدأ العمل" button
  Widget _buildOfflinePanel() {
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
          onPressed: () => setState(() => _isOnline = true),
        ),
      ],
    );
  }

  /// Online panel - stats and stop button
  Widget _buildOnlinePanel() {
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
              _buildStatItem('أرباح اليوم', 'ر.س 0', Icons.attach_money, MadarTheme.primary),
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
            onPressed: () => setState(() => _isOnline = false),
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
            child: const Text('إيقاف'),
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

