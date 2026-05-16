import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trippo_shared/trippo_shared.dart';
import '../../../trip/presentation/notifiers/trip_notifier.dart';

/// Trip Progress Sheet - Shows during active trip
class TripProgressSheet extends ConsumerWidget {
  const TripProgressSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tripState = ref.watch(tripProvider);
    final currentTrip = ref.read(tripProvider.notifier).currentTrip;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Status indicator
          _buildStatusIndicator(tripState),
          
          const SizedBox(height: 16),
          
          // Driver info (if assigned)
          if (currentTrip?.driver != null)
            _buildDriverInfo(currentTrip!.driver!),
          
          const SizedBox(height: 16),
          
          // Trip details
          if (currentTrip != null) _buildTripDetails(currentTrip, tripState),
          
          // Action buttons
          _buildActionButtons(context, ref, tripState),
        ],
      ),
    );
  }

  Widget _buildStatusIndicator(TripState state) {
    final (String title, String subtitle, IconData icon, Color color) = switch (state) {
      TripState.idle => ('Ready', 'Where would you like to go?', Icons.local_taxi, Colors.grey),
      TripState.searchingDriver => ('Finding driver', 'Looking for nearby drivers', Icons.search, Colors.orange),
      TripState.driverAssigned => ('Driver Assigned', 'Preparing to pick you up', Icons.person, Colors.blue),
      TripState.driverArriving => ('Driver is on the way', 'Heading to your pickup location', Icons.directions_car, Colors.orange),
      TripState.driverArrived => ('Driver has arrived', 'Your driver is waiting for you', Icons.location_on, Colors.green),
      TripState.tripStarted => ('Trip in progress', 'Enjoy your ride!', Icons.route, Colors.blue),
      TripState.tripPaused => ('Trip paused', 'Temporarily stopped', Icons.pause_circle, Colors.orange),
      TripState.tripResumed => ('Trip resumed', 'Back on the road', Icons.play_circle, Colors.green),
      TripState.tripCompleted => ('Trip completed', 'You have arrived!', Icons.check_circle, Colors.green),
      TripState.paymentPending => ('Payment pending', 'Processing your payment', Icons.payment, Colors.orange),
      TripState.paymentCompleted => ('Payment completed', 'Thank you for riding!', Icons.check_circle, Colors.green),
      _ => ('', '', Icons.info, Colors.grey),
    };

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: color,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDriverInfo(DriverModel driver) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[200]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Driver avatar
          CircleAvatar(
            radius: 24,
            backgroundColor: Colors.grey[200],
            child: Text(
              driver.name.isNotEmpty ? driver.name[0].toUpperCase() : '?',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 12),
          // Driver info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  driver.name,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  '${driver.vehicle.name} • ${driver.vehicle.plateNumber}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
                Row(
                  children: [
                    const Icon(Icons.star, size: 14, color: Colors.amber),
                    Text(
                      driver.averageRating.toStringAsFixed(1),
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Contact buttons
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.phone),
                onPressed: () {},
                style: IconButton.styleFrom(
                  backgroundColor: Colors.green[50],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chat),
                onPressed: () {},
                style: IconButton.styleFrom(
                  backgroundColor: Colors.blue[50],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTripDetails(TripModel trip, TripState state) {
    return Column(
      children: [
        // Pickup
        Row(
          children: [
            const Icon(Icons.radio_button_checked, color: Colors.green, size: 16),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                trip.pickupLocation.address ?? 'Pickup location',
                style: const TextStyle(fontSize: 13),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Dropoff
        Row(
          children: [
            const Icon(Icons.location_on, color: Colors.red, size: 16),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                trip.dropoffLocation.address ?? 'Destination',
                style: const TextStyle(fontSize: 13),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        // Fare
        if (trip.fareBreakdown != null) ...[
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Estimated fare', style: TextStyle(color: Colors.grey)),
              Text(
                '\$${trip.fareBreakdown!.totalFare.toStringAsFixed(2)}',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context, WidgetRef ref, TripState state) {
    if (cancelableStates.contains(state)) {
      return Padding(
        padding: const EdgeInsets.only(top: 16),
        child: SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () {
              _showCancelDialog(context, ref);
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: const BorderSide(color: Colors.red),
            ),
            child: const Text('Cancel Trip'),
          ),
        ),
      );
    }
    
    if (state == TripState.paymentCompleted || state == TripState.tripCompleted) {
      return Padding(
        padding: const EdgeInsets.only(top: 16),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              // Show rating dialog
            },
            child: const Text('Rate your trip'),
          ),
        ),
      );
    }
    
    return const SizedBox.shrink();
  }

  void _showCancelDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Trip?'),
        content: const Text('Are you sure you want to cancel this trip? A cancellation fee may apply.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () {
              ref.read(tripProvider.notifier).cancelTrip(reason: 'Rider cancelled');
              Navigator.pop(context);
            },
            child: const Text('Yes, Cancel', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
