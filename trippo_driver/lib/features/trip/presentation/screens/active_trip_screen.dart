import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:trippo_shared/trippo_shared.dart';
import '../../../../core/constants/app_theme.dart';
import '../../../../core/network/nestjs_api_client.dart';
import '../../trip/presentation/notifiers/driver_trip_notifier.dart';
import '../../../home/services/background_location_service.dart';

/// Active Trip Navigation Screen - Enhanced driver navigation during trip
///
/// Features:
/// - Real-time map with driver location tracking
/// - Route polyline from current location to destination
/// - State-aware action buttons (navigate, arrived, start, complete)
/// - Rider info with call/chat buttons
/// - Trip stats (distance, duration, ETA)
/// - Fare preview
/// - Cancellation option with reason
/// - Background location tracking integration
/// - NestJS API integration for all state transitions
class ActiveTripScreen extends ConsumerStatefulWidget {
  final TripModel trip;

  const ActiveTripScreen({super.key, required this.trip});

  @override
  ConsumerState<ActiveTripScreen> createState() => _ActiveTripScreenState();
}

class _ActiveTripScreenState extends ConsumerState<ActiveTripScreen>
    with TickerProviderStateMixin {
  GoogleMapController? _mapController;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  // Trip state tracking
  TripState _currentState = TripState.driverAssigned;
  Timer? _durationTimer;
  int _elapsedSeconds = 0;
  double _distanceTraveledKm = 0.0;

  // Map state
  final List<LatLng> _routePoints = [];
  Set<Polyline> _polylines = {};
  Set<Marker> _markers = {};
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

    _markers = {
      Marker(
        markerId: const MarkerId('pickup'),
        position: LatLng(pickup.latitude, pickup.longitude),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        infoWindow: InfoWindow(title: 'Pickup: ${pickup.address ?? ""}'),
      ),
      Marker(
        markerId: const MarkerId('dropoff'),
        position: LatLng(dropoff.latitude, dropoff.longitude),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        infoWindow: InfoWindow(title: 'Destination: ${dropoff.address ?? ""}'),
      ),
    };
  }

  void _startDurationTimer() {
    _durationTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() => _elapsedSeconds++);
      }
    });
  }

  void _listenToTripUpdates() {
    // Listen for real-time trip state updates via Socket.IO
    // (handled by the DriverTripNotifier)
  }

  void _listenToBackgroundLocation() {
    // Listen to background location service for driver position updates
    final bgState = ref.read(backgroundLocationProvider);
    if (bgState.currentLocation != null) {
      _updateDriverLocation(
        LatLng(bgState.currentLocation!.latitude, bgState.currentLocation!.longitude),
      );
    }
  }

  void _updateDriverLocation(LatLng location) {
    _currentDriverLocation = location;

    // Update driver marker on map
    setState(() {
      _markers = {
        ..._markers.where((m) => m.markerId.value != 'driver'),
        Marker(
          markerId: const MarkerId('driver'),
          position: location,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
          infoWindow: const InfoWindow(title: 'Your Location'),
          anchor: const Offset(0.5, 0.5),
        ),
      };
    });

    // Animate camera to follow driver
    _mapController?.animateCamera(
      CameraUpdate.newLatLng(location),
    );
  }

  // ==================== API Operations ====================

  Future<void> _notifyArrivedAtPickup() async {
    setState(() => _currentState = TripState.driverArrived);
    try {
      final apiClient = ref.read(tripApiProvider);
      await apiClient.dio.post('/trips/${widget.trip.id}/arrived');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Arrival confirmed. Waiting for rider.'),
            backgroundColor: AppTheme.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to confirm arrival: $e')),
        );
      }
    }
  }

  Future<void> _startTrip() async {
    setState(() => _currentState = TripState.tripStarted);
    try {
      final apiClient = ref.read(tripApiProvider);
      await apiClient.dio.post('/trips/${widget.trip.id}/start');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Trip started! Drive safely.'),
            backgroundColor: AppTheme.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to start trip: $e')),
        );
      }
    }
  }

  Future<void> _completeTrip() async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Complete Trip?'),
        content: const Text(
          'Make sure you have arrived at the destination before completing the trip.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Not Yet'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.success),
            child: const Text('Complete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final apiClient = ref.read(tripApiProvider);
      await apiClient.dio.post('/trips/${widget.trip.id}/complete');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Trip completed! Payment pending.'),
            backgroundColor: AppTheme.success,
          ),
        );
        Navigator.pop(context, true); // Return to home
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to complete trip: $e')),
        );
      }
    }
  }

  Future<void> _cancelTrip() async {
    final reason = await showDialog<String>(
      context: context,
      builder: (context) {
        final controller = TextEditingController();
        return AlertDialog(
          title: const Text('Cancel Trip?'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Please provide a reason for cancellation:'),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'e.g., Rider not showing up, vehicle issue...',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Keep Trip'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, controller.text),
              style: TextButton.styleFrom(foregroundColor: AppTheme.error),
              child: const Text('Cancel Trip'),
            ),
          ],
        );
      },
    );

    if (reason == null) return;

    try {
      final apiClient = ref.read(tripApiProvider);
      await apiClient.dio.post('/trips/${widget.trip.id}/cancel', data: {
        'reason': reason,
        'cancelledBy': 'driver',
      });
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to cancel trip: $e')),
        );
      }
    }
  }

  // ==================== Navigation ====================

  Future<void> _openNavigationApp(double lat, double lng) async {
    // Try Google Maps first, then fallback to generic geo URI
    final googleMapsUrl =
        'google.navigation:q=$lat,$lng&mode=d';
    final genericUrl = 'geo:$lat,$lng?q=$lat,$lng';

    try {
      if (await canLaunchUrl(Uri.parse(googleMapsUrl))) {
        await launchUrl(Uri.parse(googleMapsUrl));
      } else if (await canLaunchUrl(Uri.parse(genericUrl))) {
        await launchUrl(Uri.parse(genericUrl));
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open navigation app')),
        );
      }
    }
  }

  void _navigateToPickup() {
    final pickup = widget.trip.pickupLocation;
    _openNavigationApp(pickup.latitude, pickup.longitude);
  }

  void _navigateToDropoff() {
    final dropoff = widget.trip.dropoffLocation;
    _openNavigationApp(dropoff.latitude, dropoff.longitude);
  }

  // ==================== UI Building ====================

  @override
  Widget build(BuildContext context) {
    final pickup = widget.trip.pickupLocation;
    final dropoff = widget.trip.dropoffLocation;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        // Prevent accidental back navigation during active trip
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Leave Navigation?'),
            content: const Text(
              'You have an active trip. Leaving this screen will not cancel the trip.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Stay'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  Navigator.pop(context); // Leave screen
                },
                child: const Text('Leave'),
              ),
            ],
          ),
        );
      },
      child: Scaffold(
        body: Stack(
          children: [
            // Map
            GoogleMap(
              initialCameraPosition: CameraPosition(
                target: LatLng(pickup.latitude, pickup.longitude),
                zoom: 14.0,
              ),
              onMapCreated: (controller) => _mapController = controller,
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              zoomControlsEnabled: false,
              compassEnabled: true,
              trafficEnabled: true,
              markers: _markers,
              polylines: _polylines,
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).size.height * 0.38,
              ),
            ),

            // Top status bar
            Positioned(
              top: MediaQuery.of(context).padding.top + 8,
              left: 16,
              right: 16,
              child: _buildTripStatusBar(),
            ),

            // Bottom action panel
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _buildActionPanel(),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== Status Bar ====================

  Widget _buildTripStatusBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Pulsing state indicator
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _pulseAnimation.value,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: _getStateColor(),
                    shape: BoxShape.circle,
                  ),
                ),
              );
            },
          ),
          const SizedBox(width: 10),

          // State label
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _getStateColor().withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              _getStateLabel(),
              style: TextStyle(
                color: _getStateColor(),
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ),
          const Spacer(),

          // Trip duration
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _formatDuration(_elapsedSeconds),
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
              Text(
                '${widget.trip.estimatedDistanceKm.toStringAsFixed(1)} km',
                style: TextStyle(color: Colors.grey[500], fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==================== Action Panel ====================

  Widget _buildActionPanel() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 20,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 12),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Rider info
                _buildRiderInfo(),
                const SizedBox(height: 16),

                // Route info
                _buildRouteInfo(),
                const SizedBox(height: 12),

                // Fare preview
                if (widget.trip.fareBreakdown != null) ...[
                  _buildFarePreview(),
                  const SizedBox(height: 12),
                ],

                // State actions
                _buildStateActions(),

                // Cancel option
                if (_currentState != TripState.tripStarted)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: TextButton.icon(
                      onPressed: _cancelTrip,
                      icon: const Icon(Icons.cancel_outlined, size: 18),
                      label: const Text('Cancel Trip'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppTheme.error,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==================== Rider Info ====================

  Widget _buildRiderInfo() {
    final rider = widget.trip.rider;
    if (rider == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Avatar
          CircleAvatar(
            radius: 22,
            backgroundColor: AppTheme.primary.withOpacity(0.1),
            child: Text(
              rider.name.isNotEmpty ? rider.name[0].toUpperCase() : '?',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppTheme.primary,
                fontSize: 18,
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Name & phone
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  rider.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                if (rider.phone != null && rider.phone!.isNotEmpty)
                  Text(
                    rider.phone!,
                    style: TextStyle(color: Colors.grey[500], fontSize: 12),
                  ),
              ],
            ),
          ),

          // Call button
          Container(
            decoration: BoxDecoration(
              color: Colors.green[50],
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.phone, color: Colors.green, size: 22),
              onPressed: () => _callRider(rider.phone ?? ''),
              constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
            ),
          ),
          const SizedBox(width: 8),

          // Chat button
          Container(
            decoration: BoxDecoration(
              color: Colors.blue[50],
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.chat, color: Colors.blue, size: 22),
              onPressed: () {/* Open chat */},
              constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== Route Info ====================

  Widget _buildRouteInfo() {
    return Row(
      children: [
        // Pickup
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.05),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.green.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                const Icon(Icons.radio_button_checked,
                    color: Colors.green, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.trip.pickupLocation.address ?? 'Pickup',
                    style: const TextStyle(fontSize: 12),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),

        // Arrow
        const Icon(Icons.arrow_forward, color: Colors.grey, size: 16),

        const SizedBox(width: 8),

        // Dropoff
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.05),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.red.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                const Icon(Icons.location_on, color: Colors.red, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.trip.dropoffLocation.address ?? 'Destination',
                    style: const TextStyle(fontSize: 12),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ==================== Fare Preview ====================

  Widget _buildFarePreview() {
    final fare = widget.trip.fareBreakdown!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Estimated Fare',
            style: TextStyle(color: Colors.grey[600], fontSize: 13),
          ),
          Text(
            '\$${fare.totalFare.toStringAsFixed(2)}',
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 18,
              color: AppTheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  // ==================== State Actions ====================

  Widget _buildStateActions() {
    return switch (_currentState) {
      TripState.driverAssigned || TripState.driverArriving => Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _navigateToPickup,
                icon: const Icon(Icons.navigation),
                label: const Text('Navigate'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _notifyArrivedAtPickup,
                icon: const Icon(Icons.location_on),
                label: const Text('Arrived'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ],
        ),
      TripState.driverArrived => SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _startTrip,
            icon: const Icon(Icons.play_arrow),
            label: const Text('Start Trip'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
      TripState.tripStarted => Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _navigateToDropoff,
                icon: const Icon(Icons.navigation),
                label: const Text('Navigate'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _completeTrip,
                icon: const Icon(Icons.check_circle),
                label: const Text('Complete'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ],
        ),
      _ => const SizedBox.shrink(),
    };
  }

  // ==================== Helpers ====================

  Color _getStateColor() => switch (_currentState) {
        TripState.driverAssigned => Colors.orange,
        TripState.driverArriving => Colors.orange,
        TripState.driverArrived => Colors.green,
        TripState.tripStarted => Colors.blue,
        TripState.tripPaused => Colors.amber,
        _ => Colors.grey,
      };

  String _getStateLabel() => switch (_currentState) {
        TripState.driverAssigned => 'Heading to Pickup',
        TripState.driverArriving => 'Almost There',
        TripState.driverArrived => 'Waiting for Rider',
        TripState.tripStarted => 'Trip in Progress',
        TripState.tripPaused => 'Trip Paused',
        TripState.tripResumed => 'Trip Resumed',
        _ => 'Active Trip',
      };

  String _formatDuration(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m ${secs}s';
  }

  Future<void> _callRider(String phone) async {
    final telUrl = 'tel:$phone';
    try {
      if (await canLaunchUrl(Uri.parse(telUrl))) {
        await launchUrl(Uri.parse(telUrl));
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not make phone call')),
        );
      }
    }
  }
}

/// Animated builder widget for the pulse animation.
class AnimatedBuilder extends AnimatedWidget {
  final Widget Function(BuildContext context, Widget? child) builder;

  const AnimatedBuilder({
    super.key,
    required super.listenable,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return builder(context, null);
  }
}
