import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:trippo_shared/trippo_shared.dart';
import '../../../../core/constants/app_theme.dart';

/// شاشة الرحلة النشطة - مدار
class ActiveTripScreen extends ConsumerStatefulWidget {
  final TripModel trip;
  const ActiveTripScreen({super.key, required this.trip});

  @override
  ConsumerState<ActiveTripScreen> createState() => _ActiveTripScreenState();
}

class _ActiveTripScreenState extends ConsumerState<ActiveTripScreen>
    with TickerProviderStateMixin {
  MapController? _mapController;
  TripState _currentState = TripState.driverAssigned;
  Timer? _durationTimer;
  int _elapsedSeconds = 0;
  List<LatLng> _routePoints = [];
  List<Polyline> _polylines = [];
  List<Marker> _markers = [];
  LatLng? _currentDriverLocation;

  @override
  void initState() {
    super.initState();
    _currentState = widget.trip.state;
    _setupMapElements();
    _startDurationTimer();
    _fetchRoute();
  }

  void _setupMapElements() {
    final pickup = widget.trip.pickupLocation;
    final dropoff = widget.trip.dropoffLocation;
    _markers = [
      Marker(
        point: LatLng(pickup.latitude, pickup.longitude),
        width: 40,
        height: 40,
        child: Container(
          decoration: BoxDecoration(
            color: MadarTheme.mapPickup,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [
              MadarTheme.shadow(
                color: MadarTheme.mapPickup.withOpacity(0.4),
                blur: 8,
              ),
            ],
          ),
          child: const Icon(Icons.location_on, color: Colors.white, size: 20),
        ),
      ),
      Marker(
        point: LatLng(dropoff.latitude, dropoff.longitude),
        width: 40,
        height: 40,
        child: Container(
          decoration: BoxDecoration(
            color: MadarTheme.mapDropoff,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [
              MadarTheme.shadow(
                color: MadarTheme.mapDropoff.withOpacity(0.4),
                blur: 8,
              ),
            ],
          ),
          child: const Icon(Icons.location_on, color: Colors.white, size: 20),
        ),
      ),
    ];
    _currentDriverLocation = LatLng(pickup.latitude, pickup.longitude);
  }

  Future<void> _fetchRoute() async {
    final pickup = widget.trip.pickupLocation;
    final dropoff = widget.trip.dropoffLocation;
    try {
      final mapService = MapService();
      final result = await mapService.getRoute(
        origin: LatLng(pickup.latitude, pickup.longitude),
        destination: LatLng(dropoff.latitude, dropoff.longitude),
      );
      setState(() {
        _routePoints = result.polylinePoints;
        _polylines = [
          Polyline(
            points: _routePoints,
            color: MadarTheme.mapRoute,
            strokeWidth: 5.0,
            borderStrokeWidth: 2.0,
            borderColor: Colors.blue.shade900,
          ),
        ];
      });
    } catch (e) {
      setState(() {
        _routePoints = [
          LatLng(pickup.latitude, pickup.longitude),
          LatLng(dropoff.latitude, dropoff.longitude),
        ];
        _polylines = [
          Polyline(
            points: _routePoints,
            color: MadarTheme.mapRoute,
            strokeWidth: 5.0,
          ),
        ];
      });
    }
  }

  void _startDurationTimer() {
    _durationTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => setState(() => _elapsedSeconds++),
    );
  }

  @override
  void dispose() {
    _durationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Map
          FlutterMap(
            mapController: MapController(),
            options: MapOptions(
              initialCenter: _currentDriverLocation ?? const LatLng(24.7136, 46.6753),
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
              if (_polylines.isNotEmpty) PolylineLayer(polylines: _polylines),
              if (_markers.isNotEmpty) MarkerLayer(markers: _markers),
              if (_currentDriverLocation != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _currentDriverLocation!,
                      width: 30,
                      height: 30,
                      child: Container(
                        decoration: BoxDecoration(
                          color: MadarTheme.mapDriver,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                          boxShadow: [
                            MadarTheme.shadow(
                              color: MadarTheme.mapDriver.withOpacity(0.4),
                              blur: 8,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.navigation,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),

          // Top bar
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 16,
            right: 16,
            child: _buildTopBar(),
          ),

          // Bottom sheet
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _buildBottomSheet(),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return SafeArea(
      child: Row(
        children: [
          // Back button
          Container(
            decoration: BoxDecoration(
              color: MadarTheme.surface,
              borderRadius: BorderRadius.circular(MadarTheme.radiusLg),
              boxShadow: [MadarTheme.shadow(blur: 8)],
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: MadarTheme.textPrimary),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          const SizedBox(width: MadarTheme.space12),
          // Status chip
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: MadarTheme.space16,
                vertical: MadarTheme.space12,
              ),
              decoration: BoxDecoration(
                color: MadarTheme.surface,
                borderRadius: BorderRadius.circular(MadarTheme.radiusLg),
                boxShadow: [MadarTheme.shadow(blur: 8)],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _getStatusColor(),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      _getTripStatusText(),
                      style: const TextStyle(
                        fontFamily: MadarTheme.fontFamily,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: MadarTheme.textPrimary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor() {
    return switch (_currentState) {
      TripState.driverAssigned => MadarTheme.accent,
      TripState.driverArriving => MadarTheme.warning,
      TripState.driverArrived => MadarTheme.primary,
      TripState.tripStarted => MadarTheme.success,
      TripState.tripCompleted => MadarTheme.primary,
      _ => MadarTheme.textSecondary,
    };
  }

  String _getTripStatusText() {
    return switch (_currentState) {
      TripState.driverAssigned => 'في طريقك للاستلام',
      TripState.driverArriving => 'قريب من نقطة الاستلام',
      TripState.driverArrived => 'بانتظار الراكب',
      TripState.tripStarted => 'الرحلة جارية',
      TripState.tripCompleted => 'تمت الرحلة',
      _ => 'رحلة نشطة',
    };
  }

  Widget _buildBottomSheet() {
    final pickup = widget.trip.pickupLocation;
    final dropoff = widget.trip.dropoffLocation;

    return Container(
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
          const SizedBox(height: MadarTheme.space16),

          // Rider info card
          Container(
            padding: const EdgeInsets.all(MadarTheme.space16),
            decoration: MadarTheme.cardDecoration(
              radius: MadarTheme.radiusLg,
              color: MadarTheme.background,
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: MadarTheme.primaryLight,
                  child: const Icon(Icons.person, color: MadarTheme.primary),
                ),
                const SizedBox(width: MadarTheme.space12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.trip.rider?.name ?? 'راكب',
                        style: const TextStyle(
                          fontFamily: MadarTheme.fontFamily,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          color: MadarTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(Icons.star, size: 14, color: MadarTheme.accent),
                          const SizedBox(width: 4),
                          Text(
                            '4.8',
                            style: TextStyle(
                              fontFamily: MadarTheme.fontFamily,
                              color: MadarTheme.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(width: MadarTheme.space12),
                          Text(
                            _formatDuration(_elapsedSeconds),
                            style: TextStyle(
                              fontFamily: MadarTheme.fontFamily,
                              color: MadarTheme.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Contact buttons
                Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: MadarTheme.primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.phone, color: MadarTheme.primary, size: 20),
                        onPressed: () {},
                        constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                        padding: EdgeInsets.zero,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: MadarTheme.error.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.emergency, color: MadarTheme.error, size: 20),
                        onPressed: () {},
                        constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                        padding: EdgeInsets.zero,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: MadarTheme.space16),

          // Pickup location
          MadarLocationPoint(
            isPickup: true,
            address: pickup.address ?? 'نقطة الاستلام',
          ),

          const SizedBox(height: MadarTheme.space8),

          // Dotted line
          Padding(
            padding: const EdgeInsets.only(right: 5),
            child: Row(
              children: List.generate(
                12,
                (_) => Expanded(
                  child: Container(
                    height: 2,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      color: MadarTheme.textHint.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: MadarTheme.space8),

          // Dropoff location
          MadarLocationPoint(
            isPickup: false,
            address: dropoff.address ?? 'الوجهة',
          ),

          const SizedBox(height: MadarTheme.space20),

          // Action buttons
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return switch (_currentState) {
      TripState.driverAssigned || TripState.driverArriving => MadarGradientButton(
          label: 'تم الوصول',
          icon: Icons.location_on,
          gradientColors: const [MadarTheme.primary, MadarTheme.primaryDark],
          onPressed: () => setState(() => _currentState = TripState.driverArrived),
        ),
      TripState.driverArrived => MadarGradientButton(
          label: 'بدء الرحلة',
          icon: Icons.play_arrow,
          gradientColors: const [MadarTheme.accent, MadarTheme.accentDark],
          onPressed: () => setState(() => _currentState = TripState.tripStarted),
        ),
      TripState.tripStarted => MadarGradientButton(
          label: 'إنهاء الرحلة',
          icon: Icons.flag,
          gradientColors: const [MadarTheme.success, Color(0xFF059669)],
          onPressed: () {
            setState(() => _currentState = TripState.tripCompleted);
            Navigator.pop(context, true);
          },
        ),
      _ => const SizedBox.shrink(),
    };
  }

  String _formatDuration(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    if (hours > 0) return '$hoursس $minutesد';
    return '$minutesد ${seconds % 60}ث';
  }
}

