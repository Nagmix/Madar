import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:trippo_shared/trippo_shared.dart';
import '../../../../core/constants/app_theme.dart';
import '../../../../core/network/nestjs_api_client.dart';
import '../notifiers/driver_trip_notifier.dart';
import '../../../home/services/background_location_service.dart';

/// Active Trip Navigation Screen - Enhanced driver navigation during trip
/// Uses flutter_map + OSM tiles instead of Google Maps
class ActiveTripScreen extends ConsumerStatefulWidget {
  final TripModel trip;

  const ActiveTripScreen({super.key, required this.trip});

  @override
  ConsumerState<ActiveTripScreen> createState() => _ActiveTripScreenState();
}

class _ActiveTripScreenState extends ConsumerState<ActiveTripScreen>
    with TickerProviderStateMixin {
  MapController? _mapController;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  // Trip state tracking
  TripState _currentState = TripState.driverAssigned;
  Timer? _durationTimer;
  int _elapsedSeconds = 0;
  double _distanceTraveledKm = 0.0;

  // Map state
  List<LatLng> _routePoints = [];
  List<Polyline> _polylines = [];
  List<Marker> _markers = [];
  LatLng? _currentDriverLocation;

  // API provider
  final tripApiProvider = Provider<NestjsApiClient>((ref) => NestjsApiClient());

  @override
  void initState() {
    super.initState();
    _currentState = widget.trip.state;
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _setupMapElements();
    _startDurationTimer();
    _listenToTripUpdates();
    _listenToBackgroundLocation();
    _fetchRoute();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _durationTimer?.cancel();
    super.dispose();
  }

  // ==================== Setup ====================

  void _setupMapElements() {
    final pickup = widget.trip.pickupLocation;
    final dropoff = widget.trip.dropoffLocation;

    _markers = [
      // Pickup marker (green)
      Marker(
        point: LatLng(pickup.latitude, pickup.longitude),
        width: 40,
        height: 40,
        child: const Icon(Icons.location_on, color: Color(0xFF00C853), size: 40),
      ),
      // Dropoff marker (red)
      Marker(
        point: LatLng(dropoff.latitude, dropoff.longitude),
        width: 40,
        height: 40,
        child: const Icon(Icons.location_on, color: Color(0xFFFF1744), size: 40),
      ),
    ];

    // Set initial driver location
    if (pickup != null) {
      _currentDriverLocation = LatLng(pickup.latitude, pickup.longitude);
    }
  }

  Future<void> _fetchRoute() async {
    final pickup = widget.trip.pickupLocation;
    final dropoff = widget.trip.dropoffLocation;
    if (pickup == null || dropoff == null) return;

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
            color: const Color(0xFF448AFF),
            strokeWidth: 5.0,
            borderStrokeWidth: 2.0,
            borderColor: Colors.blue.shade900,
          ),
        ];
      });

      // Fit map to show entire route
      _fitRouteBounds();
    } catch (e) {
      // Fallback: straight line
      setState(() {
        _routePoints = [
          LatLng(pickup.latitude, pickup.longitude),
          LatLng(dropoff.latitude, dropoff.longitude),
        ];
        _polylines = [
          Polyline(
            points: _routePoints,
            color: const Color(0xFF448AFF),
            strokeWidth: 5.0,
          ),
        ];
      });
    }
  }

  void _fitRouteBounds() {
    if (_mapController != null && _routePoints.isNotEmpty) {
      double minLat = _routePoints.first.latitude;
      double maxLat = _routePoints.first.latitude;
      double minLng = _routePoints.first.longitude;
      double maxLng = _routePoints.first.longitude;

      for (final p in _routePoints) {
        if (p.latitude < minLat) minLat = p.latitude;
        if (p.latitude > maxLat) maxLat = p.latitude;
        if (p.longitude < minLng) minLng = p.longitude;
        if (p.longitude > maxLng) maxLng = p.longitude;
      }

      final center = LatLng((minLat + maxLat) / 2, (minLng + maxLng) / 2);
      _mapController!.move(center, 12.0);
    }
  }

  void _startDurationTimer() {
    _durationTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _elapsedSeconds++);
    });
  }

  void _listenToTripUpdates() {
    // Listen to real-time trip updates via socket
  }

  void _listenToBackgroundLocation() {
    // Listen to background location updates
  }

  @override
  Widget build(BuildContext context) {
    final tripState = ref.watch(driverTripProvider);

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
              // Dark tiles
              TileLayer(
                urlTemplate: TileProviderLayer.darkThemeTileUrl,
                userAgentPackageName: 'com.madar.driver',
                retinaMode: true,
                maxZoom: 19,
              ),

              // Route polyline
              if (_polylines.isNotEmpty)
                PolylineLayer(polylines: _polylines),

              // Markers
              if (_markers.isNotEmpty)
                MarkerLayer(markers: _markers),

              // Driver marker
              if (_currentDriverLocation != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _currentDriverLocation!,
                      width: 30,
                      height: 30,
                      child: const Icon(
                        Icons.navigation,
                        color: Color(0xFF00C853),
                        size: 30,
                      ),
                    ),
                  ],
                ),
            ],
          ),

          // Top bar with back button and trip info
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 16,
            right: 16,
            child: _buildTopBar(),
          ),

          // Bottom panel with trip details and actions
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _buildBottomPanel(tripState.tripState),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return SafeArea(
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)],
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)],
              ),
              child: Text(
                _getTripStatusText(),
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getTripStatusText() {
    return switch (_currentState) {
      TripState.driverAssigned => 'Heading to pickup',
      TripState.driverArriving => 'Almost at pickup',
      TripState.driverArrived => 'Waiting for rider',
      TripState.tripStarted => 'Trip in progress',
      TripState.tripCompleted => 'Trip completed',
      _ => 'Active Trip',
    };
  }

  Widget _buildBottomPanel(TripState tripState) {
    final pickup = widget.trip.pickupLocation;
    final dropoff = widget.trip.dropoffLocation;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Rider info
          _buildRiderInfo(),

          const SizedBox(height: 16),

          // Trip locations
          if (pickup != null) _buildLocationRow('Pickup', pickup.address ?? 'Pickup point', const Color(0xFF00C853)),
          const SizedBox(height: 8),
          if (dropoff != null) _buildLocationRow('Destination', dropoff.address ?? 'Destination', const Color(0xFFFF1744)),

          const SizedBox(height: 16),

          // Action buttons based on state
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildRiderInfo() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 20,
            child: Icon(Icons.person),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.trip.rider?.name ?? 'Rider',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  _formatDuration(_elapsedSeconds),
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.phone, color: Color(0xFF00C853)),
            onPressed: () => _callRider(),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationRow(String label, String address, Color color) {
    return Row(
      children: [
        Icon(Icons.location_on, color: color, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
              Text(address, style: const TextStyle(fontWeight: FontWeight.w500), maxLines: 1, overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return switch (_currentState) {
      TripState.driverAssigned || TripState.driverArriving => SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _arrivedAtPickup,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00C853),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Arrived at Pickup', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          ),
        ),
      TripState.driverArrived => SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _startTrip,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF448AFF),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Start Trip', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          ),
        ),
      TripState.tripStarted => SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _completeTrip,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00C853),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Complete Trip', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          ),
        ),
      _ => const SizedBox.shrink(),
    };
  }

  // ==================== Actions ====================

  void _arrivedAtPickup() {
    setState(() => _currentState = TripState.driverArrived);
  }

  void _startTrip() {
    setState(() => _currentState = TripState.tripStarted);
  }

  void _completeTrip() {
    setState(() => _currentState = TripState.tripCompleted);
    Navigator.pop(context, true);
  }

  void _callRider() {
    // Launch phone call
  }

  String _formatDuration(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    if (hours > 0) return '${hours}h ${minutes}m';
    return '${minutes}m ${seconds % 60}s';
  }
}
