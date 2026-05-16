import 'package:flutter/material.dart';
import 'package:trippo_shared/trippo_shared.dart';

/// Incoming Ride Request Screen - Full screen notification for driver
class IncomingRideRequestScreen extends StatelessWidget {
  final DriverDispatchNotification request;
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  const IncomingRideRequestScreen({
    super.key,
    required this.request,
    required this.onAccept,
    required this.onDecline,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 20),
              
              // New ride indicator
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.notifications_active, color: Colors.green, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'NEW RIDE REQUEST',
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Rider info
              Text(
                request.riderName,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              
              const SizedBox(height: 32),
              
              // Pickup location
              _buildLocationRow(
                icon: Icons.radio_button_checked,
                color: Colors.green,
                title: 'Pickup',
                address: request.pickupAddress,
                distance: '${request.distanceToPickupKm.toStringAsFixed(1)} km away',
                eta: '${request.estimatedEtaMinutes} min',
              ),
              
              const SizedBox(height: 16),
              
              // Dotted line
              Padding(
                padding: const EdgeInsets.only(left: 12),
                child: Row(
                  children: List.generate(
                    10,
                    (_) => Expanded(
                      child: Container(
                        height: 1,
                        color: Colors.grey[300],
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                      ),
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Dropoff location
              _buildLocationRow(
                icon: Icons.location_on,
                color: Colors.red,
                title: 'Destination',
                address: request.dropoffAddress,
                distance: '',
                eta: '',
              ),
              
              const Spacer(),
              
              // Estimated fare
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Estimated Fare', style: TextStyle(fontSize: 16)),
                    Text(
                      '\$${request.estimatedFare.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Accept/Decline buttons
              Row(
                children: [
                  // Decline button
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onDecline,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Decline', style: TextStyle(fontSize: 16)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Accept button
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: onAccept,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Accept Ride', style: TextStyle(fontSize: 16)),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Timeout indicator
              Text(
                'Respond within ${request.responseTimeoutSeconds}s',
                style: TextStyle(color: Colors.grey[500], fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLocationRow({
    required IconData icon,
    required Color color,
    required String title,
    required String address,
    required String distance,
    required String eta,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
              Text(address, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
        if (distance.isNotEmpty || eta.isNotEmpty)
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (eta.isNotEmpty)
                Text(eta, style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.green)),
              if (distance.isNotEmpty)
                Text(distance, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
            ],
          ),
      ],
    );
  }
}
