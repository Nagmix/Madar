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

class _ActiveTripScreenState extends ConsumerState<ActiveTripScreen> with TickerProviderStateMixin {
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
      Marker(point: LatLng(pickup.latitude, pickup.longitude), width: 40, height: 40, child: const Icon(Icons.location_on, color: Color(0xFF00C853), size: 40)),
      Marker(point: LatLng(dropoff.latitude, dropoff.longitude), width: 40, height: 40, child: const Icon(Icons.location_on, color: Color(0xFFFF1744), size: 40)),
    ];
    _currentDriverLocation = LatLng(pickup.latitude, pickup.longitude);
  }

  Future<void> _fetchRoute() async {
    final pickup = widget.trip.pickupLocation;
    final dropoff = widget.trip.dropoffLocation;
    try {
      final mapService = MapService();
      final result = await mapService.getRoute(origin: LatLng(pickup.latitude, pickup.longitude), destination: LatLng(dropoff.latitude, dropoff.longitude));
      setState(() {
        _routePoints = result.polylinePoints;
        _polylines = [Polyline(points: _routePoints, color: const Color(0xFF448AFF), strokeWidth: 5.0, borderStrokeWidth: 2.0, borderColor: Colors.blue.shade900)];
      });
    } catch (e) {
      setState(() {
        _routePoints = [LatLng(pickup.latitude, pickup.longitude), LatLng(dropoff.latitude, dropoff.longitude)];
        _polylines = [Polyline(points: _routePoints, color: const Color(0xFF448AFF), strokeWidth: 5.0)];
      });
    }
  }

  void _startDurationTimer() {
    _durationTimer = Timer.periodic(const Duration(seconds: 1), (_) => setState(() => _elapsedSeconds++));
  }

  @override
  void dispose() {
    _durationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(children: [
        FlutterMap(
          mapController: MapController(),
          options: MapOptions(
            initialCenter: _currentDriverLocation ?? const LatLng(24.7136, 46.6753),
            initialZoom: 14.0,
            interactionOptions: const InteractionOptions(flags: InteractiveFlag.all),
          ),
          children: [
            TileLayer(urlTemplate: TileProviderLayer.darkThemeTileUrl, userAgentPackageName: 'com.madar.driver', retinaMode: true, maxZoom: 19),
            if (_polylines.isNotEmpty) PolylineLayer(polylines: _polylines),
            if (_markers.isNotEmpty) MarkerLayer(markers: _markers),
            if (_currentDriverLocation != null) MarkerLayer(markers: [
              Marker(point: _currentDriverLocation!, width: 30, height: 30, child: const Icon(Icons.navigation, color: Color(0xFF00C853), size: 30)),
            ]),
          ],
        ),
        Positioned(top: MediaQuery.of(context).padding.top + 8, left: 16, right: 16, child: _buildTopBar()),
        Positioned(left: 0, right: 0, bottom: 0, child: _buildBottomPanel()),
      ]),
    );
  }

  Widget _buildTopBar() {
    return SafeArea(child: Row(children: [
      Container(
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)]),
        child: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
      ),
      const SizedBox(width: 12),
      Expanded(child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)]),
        child: Text(_getTripStatusText(), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
      )),
    ]));
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

  Widget _buildBottomPanel() {
    final pickup = widget.trip.pickupLocation;
    final dropoff = widget.trip.dropoffLocation;

    return Container(
      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      padding: const EdgeInsets.all(24),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        // معلومات الراكب
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(12)),
          child: Row(children: [
            const CircleAvatar(radius: 20, child: Icon(Icons.person)),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(widget.trip.rider?.name ?? 'راكب', style: const TextStyle(fontWeight: FontWeight.w700)),
              Text(_formatDuration(_elapsedSeconds), style: TextStyle(color: Colors.grey[600], fontSize: 12)),
            ])),
            const Icon(Icons.phone, color: Color(0xFF00C853)),
          ]),
        ),
        const SizedBox(height: 16),
        if (pickup != null) _buildLocationRow('نقطة الاستلام', pickup.address ?? 'نقطة الاستلام', const Color(0xFF00C853)),
        const SizedBox(height: 8),
        if (dropoff != null) _buildLocationRow('الوجهة', dropoff.address ?? 'الوجهة', const Color(0xFFFF1744)),
        const SizedBox(height: 16),
        _buildActionButtons(),
      ]),
    );
  }

  Widget _buildLocationRow(String label, String address, Color color) {
    return Row(children: [
      Icon(Icons.location_on, color: color, size: 20),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
        Text(address, style: const TextStyle(fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
      ])),
    ]);
  }

  Widget _buildActionButtons() {
    return switch (_currentState) {
      TripState.driverAssigned || TripState.driverArriving => SizedBox(
        width: double.infinity,
        child: ElevatedButton(onPressed: () => setState(() => _currentState = TripState.driverArrived), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00C853), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: const Text('وصلت للاستلام', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700))),
      ),
      TripState.driverArrived => SizedBox(
        width: double.infinity,
        child: ElevatedButton(onPressed: () => setState(() => _currentState = TripState.tripStarted), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1565C0), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: const Text('بدء الرحلة', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700))),
      ),
      TripState.tripStarted => SizedBox(
        width: double.infinity,
        child: ElevatedButton(onPressed: () { setState(() => _currentState = TripState.tripCompleted); Navigator.pop(context, true); }, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00C853), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: const Text('إنهاء الرحلة', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700))),
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
