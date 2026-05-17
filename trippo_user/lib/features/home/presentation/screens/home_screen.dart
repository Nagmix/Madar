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

/// Home Screen - Main screen with open-source map and ride booking
/// Uses flutter_map + OSM tiles instead of Google Maps
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  MapController? _mapController;
  LatLng? _currentPosition;
  bool _showCenterPin = true;
  bool _isMapReady = false;

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
      if (_mapController != null && _isMapReady) {
        _mapController!.move(_currentPosition!, 14.0);
      }
    } catch (e) {
      // Handle location error - use default Riyadh position
      setState(() {
        _currentPosition = const LatLng(24.7136, 46.6753);
      });
    }
  }

  void _onMapCreated(MapController controller) {
    _mapController = controller;
    _isMapReady = true;
    // Move to current location if available
    if (_currentPosition != null) {
      controller.move(_currentPosition!, 14.0);
    }
  }

  void _onCameraIdle(LatLng position) {
    // When camera stops moving, update pickup location
    if (_showCenterPin) {
      ref.read(mapLocationProvider.notifier).setPickupWithGeocode(position);
    }
  }

  void _goToMyLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      final loc = LatLng(position.latitude, position.longitude);
      _mapController?.move(loc, 14.0);
      setState(() {
        _currentPosition = loc;
      });
    } catch (e) {
      // Handle error
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
          // Open-source Map (flutter_map + OSM tiles)
          FlutterMap(
            mapController: MapController(),
            options: MapOptions(
              initialCenter: _currentPosition ?? const LatLng(24.7136, 46.6753),
              initialZoom: 14.0,
              onMapReady: () {
                _isMapReady = true;
              },
              onPositionChanged: (position, hasGesture) {
                if (hasGesture) {
                  setState(() {
                    _currentPosition = position.center;
                  });
                }
              },
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.all,
              ),
            ),
            children: [
              // Dark theme tiles (CartoDB Dark Matter)
              TileLayer(
                urlTemplate: TileProviderLayer.darkThemeTileUrl,
                userAgentPackageName: 'com.madar.rider',
                retinaMode: true,
                maxZoom: 19,
              ),

              // Circle layer (pickup radius, service areas)
              if (mapState.circles.isNotEmpty)
                CircleLayer(circles: mapState.circles),

              // Route polyline
              if (mapState.polylines.isNotEmpty)
                PolylineLayer(polylines: mapState.polylines),

              // Markers (pickup, dropoff, drivers, user)
              MarkerLayer(
                markers: [
                  // User location (blue dot)
                  if (mapState.currentUserLocation != null)
                    Marker(
                      point: mapState.currentUserLocation!,
                      width: 20,
                      height: 20,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.3),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Container(
                            width: 10,
                            height: 10,
                            decoration: const BoxDecoration(
                              color: Colors.blue,
                              shape: BoxShape.circle,
                              border: Border.fromBorderSide(
                                BorderSide(color: Colors.white, width: 2),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                  // Pickup marker (green)
                  if (mapState.pickupLocation != null)
                    Marker(
                      point: mapState.pickupLocation!,
                      width: 40,
                      height: 40,
                      child: const Icon(Icons.location_on, color: Color(0xFF00C853), size: 40),
                    ),

                  // Dropoff marker (red)
                  if (mapState.dropoffLocation != null)
                    Marker(
                      point: mapState.dropoffLocation!,
                      width: 40,
                      height: 40,
                      child: const Icon(Icons.location_on, color: Color(0xFFFF1744), size: 40),
                    ),

                  // Nearby drivers (yellow car icons)
                  ...mapState.nearbyDrivers.where((d) => d.currentLocation != null).map((driver) => Marker(
                    point: LatLng(driver.currentLocation!.latitude, driver.currentLocation!.longitude),
                    width: 30,
                    height: 30,
                    child: Transform.rotate(
                      angle: (0) * 3.14159 / 180,
                      child: const Icon(Icons.directions_car, color: Colors.yellow, size: 30),
                    ),
                  )),
                ],
              ),
            ],
          ),

          // Center pin for pickup selection
          if (_showCenterPin && mapState.dropoffLocation == null)
            Center(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 40),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.location_on, color: Color(0xFF00C853), size: 40),
                    Container(width: 2, height: 10, color: const Color(0xFF00C853)),
                  ],
                ),
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
          // Menu button
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10),
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
          // Search bar shortcut
          GestureDetector(
            onTap: () => _openSearch(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.search, color: Colors.grey[600], size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Where to?',
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _openSearch(BuildContext context) {
    // Show where to sheet
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const WhereToSheet(),
    );
  }

  Widget _buildBottomSheet(TripState tripState, MapLocationState mapState) {
    // Show different bottom sheets based on trip state
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

  Widget _buildWhereToBar(MapLocationState mapState) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(color: Color(0x1A000000), blurRadius: 20, offset: Offset(0, -4)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Where to? search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: GestureDetector(
              onTap: () => _openSearch(context),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.search, color: Colors.grey[500]),
                    const SizedBox(width: 12),
                    Text(
                      'Where to?',
                      style: TextStyle(color: Colors.grey[500], fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Pickup location info
          if (mapState.pickupAddress != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Row(
                children: [
                  const Icon(Icons.radio_button_checked, color: Color(0xFF00C853), size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      mapState.pickupAddress!,
                      style: const TextStyle(fontSize: 14),
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

  Widget _buildRideRequestSheet(MapLocationState mapState) {
    final route = mapState.currentRoute!;
    final distanceKm = route.distanceKm.toStringAsFixed(1);
    final durationMin = route.durationMinutes.toStringAsFixed(0);

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 16),

          // Route info
          Row(
            children: [
              Expanded(
                child: _buildInfoCard('Distance', '$distanceKm km', Icons.straighten),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildInfoCard('Duration', '$durationMin min', Icons.access_time),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Vehicle types
          _buildVehicleSelection(),

          const SizedBox(height: 16),

          // Request ride button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                _requestRide(mapState);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00C853),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Request Ride', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.grey[600], size: 20),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
          Text(title, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildVehicleSelection() {
    // Vehicle type selection
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Select Vehicle', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
        const SizedBox(height: 12),
        Row(
          children: [
            _buildVehicleOption(Icons.directions_car, 'Sedan', '\$12', true),
            const SizedBox(width: 12),
            _buildVehicleOption(Icons.local_taxi, 'Comfort', '\$18', false),
            const SizedBox(width: 12),
            _buildVehicleOption(Icons.airport_shuttle, 'Van', '\$25', false),
          ],
        ),
      ],
    );
  }

  Widget _buildVehicleOption(IconData icon, String name, String price, bool selected) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF00C853).withOpacity(0.1) : Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: selected ? const Color(0xFF00C853) : Colors.grey[200]!),
        ),
        child: Column(
          children: [
            Icon(icon, color: selected ? const Color(0xFF00C853) : Colors.grey[600], size: 28),
            const SizedBox(height: 4),
            Text(name, style: TextStyle(fontSize: 12, fontWeight: selected ? FontWeight.w600 : FontWeight.normal)),
            Text(price, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: selected ? const Color(0xFF00C853) : Colors.grey[800])),
          ],
        ),
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
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Color(0xFF00C853)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CircleAvatar(radius: 30, backgroundColor: Colors.white, child: Icon(Icons.person, color: Color(0xFF00C853))),
                SizedBox(height: 12),
                Text('Madar Rider', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          ListTile(leading: const Icon(Icons.person), title: const Text('Profile'), onTap: () => context.go('/profile')),
          ListTile(leading: const Icon(Icons.history), title: const Text('Trip History'), onTap: () => context.go('/history')),
          ListTile(leading: const Icon(Icons.account_balance_wallet), title: const Text('Wallet'), onTap: () => context.go('/wallet')),
          ListTile(leading: const Icon(Icons.notifications), title: const Text('Notifications'), onTap: () => context.go('/notifications')),
          const Divider(),
          ListTile(leading: const Icon(Icons.settings), title: const Text('Settings'), onTap: () {}),
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
}
