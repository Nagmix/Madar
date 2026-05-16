import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:trippo_shared/trippo_shared.dart';
import '../../../map/presentation/notifiers/map_notifier.dart';
import '../../../trip/presentation/notifiers/trip_notifier.dart';
import '../widgets/where_to_sheet.dart';
import '../widgets/ride_request_sheet.dart';
import '../widgets/trip_progress_sheet.dart';
import '../../../../core/constants/app_theme.dart';
import '../../../auth/presentation/notifiers/auth_notifier.dart';

/// Home Screen - Main screen with map and ride booking
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  GoogleMapController? _mapController;
  LatLng? _currentPosition;
  bool _showCenterPin = true;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
      });
      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(_currentPosition!, 14.0),
      );
    } catch (e) {
      // Handle location error
    }
  }

  @override
  Widget build(BuildContext context) {
    final mapState = ref.watch(mapLocationProvider);
    final tripState = ref.watch(tripProvider);

    return Scaffold(
      drawer: _buildAppDrawer(context),
      body: Stack(
        children: [
          // Google Map
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _currentPosition ?? const LatLng(24.7136, 46.6753),
              zoom: 14.0,
            ),
            onMapCreated: (controller) {
              _mapController = controller;
              // Set dark map style
              controller.setMapStyle(_darkMapStyle);
            },
            markers: mapState.markers,
            polylines: mapState.polylines,
            circles: mapState.circles,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            trafficEnabled: true,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
            compassEnabled: false,
            onCameraIdle: _onCameraIdle,
            onCameraMove: _onCameraMove,
            padding: const EdgeInsets.only(bottom: 200),
          ),

          // Center pin for pickup selection
          if (_showCenterPin && mapState.dropoffLocation == null)
            const Center(
              child: Padding(
                padding: EdgeInsets.only(bottom: 40),
                child: Icon(Icons.location_on, color: Colors.green, size: 40),
              ),
            ),

          // My Location Button
          Positioned(
            right: 16,
            bottom: 300,
            child: FloatingActionButton.small(
              onPressed: _goToMyLocation,
              backgroundColor: Colors.white,
              child: const Icon(Icons.my_location, color: Colors.black54),
            ),
          ),

          // Top bar with menu
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 16,
            right: 16,
            child: _buildTopBar(),
          ),

          // Bottom sheet based on trip state
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

  Widget _buildTopBar() {
    return SafeArea(
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            ),
          ),
          const Spacer(),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              icon: const Icon(Icons.notifications_outlined),
              onPressed: () {
                context.go('/notifications');
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSheet(TripState tripState, MapLocationState mapState) {
    // Show different bottom sheets based on trip state
    // idle = no active trip, show WhereTo sheet
    return switch (tripState) {
      TripState.idle => const WhereToSheet(),
      TripState.searchingDriver => const RideRequestSheet(),
      TripState.driverAssigned => const TripProgressSheet(),
      TripState.driverArriving => const TripProgressSheet(),
      TripState.driverArrived => const TripProgressSheet(),
      TripState.tripStarted => const TripProgressSheet(),
      TripState.tripPaused => const TripProgressSheet(),
      TripState.tripResumed => const TripProgressSheet(),
      TripState.tripCompleted => const TripProgressSheet(),
      TripState.paymentPending => const TripProgressSheet(),
      TripState.paymentCompleted => const WhereToSheet(),
      TripState.tripCancelled => const WhereToSheet(),
      _ => const WhereToSheet(),
    };
  }

  void _onCameraMove(CameraPosition position) {
    // Update center pin position
  }

  void _onCameraIdle() {
    // Reverse geocode the center position to get address
    // Update pickup location
  }

  void _goToMyLocation() {
    if (_currentPosition != null) {
      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(_currentPosition!, 14.0),
      );
    }
  }

  Widget _buildAppDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: AppTheme.primary),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(Icons.local_taxi, color: Colors.white, size: 40),
                SizedBox(height: 8),
                Text('Madar', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                Text('Your ride, your way', style: TextStyle(color: Colors.white70, fontSize: 14)),
              ],
            ),
          ),
          ListTile(leading: const Icon(Icons.home), title: const Text('Home'), onTap: () { context.go('/home'); Navigator.pop(context); }),
          ListTile(leading: const Icon(Icons.history), title: const Text('Trip History'), onTap: () { context.go('/trip-history'); Navigator.pop(context); }),
          ListTile(leading: const Icon(Icons.account_balance_wallet), title: const Text('Wallet'), onTap: () { context.go('/wallet'); Navigator.pop(context); }),
          ListTile(leading: const Icon(Icons.notifications_outlined), title: const Text('Notifications'), onTap: () { context.go('/notifications'); Navigator.pop(context); }),
          ListTile(leading: const Icon(Icons.person_outline), title: const Text('Profile'), onTap: () { context.go('/profile'); Navigator.pop(context); }),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout', style: TextStyle(color: Colors.red)),
            onTap: () {
              ref.read(authProvider.notifier).logout();
              context.go('/login');
            },
          ),
        ],
      ),
    );
  }

  static const String _darkMapStyle = r'''
  [
    {"elementType": "geometry", "stylers": [{"color": "#212121"}]},
    {"elementType": "labels.icon", "stylers": [{"visibility": "off"}]},
    {"elementType": "labels.text.fill", "stylers": [{"color": "#757575"}]},
    {"elementType": "labels.text.stroke", "stylers": [{"color": "#212121"}]},
    {"featureType": "administrative", "elementType": "geometry", "stylers": [{"color": "#757575"}]},
    {"featureType": "road", "elementType": "geometry.fill", "stylers": [{"color": "#2c2c2c"}]},
    {"featureType": "road", "elementType": "labels.text.fill", "stylers": [{"color": "#8a8a8a"}]},
    {"featureType": "road.arterial", "elementType": "geometry", "stylers": [{"color": "#373737"}]},
    {"featureType": "road.highway", "elementType": "geometry", "stylers": [{"color": "#3c3c3c"}]},
    {"featureType": "water", "elementType": "geometry", "stylers": [{"color": "#000000"}]}
  ]
  ''';
}
