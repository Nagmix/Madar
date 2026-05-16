import 'package:flutter/material.dart';
import 'package:trippo_shared/trippo_shared.dart';

/// Rating Screen - Rate driver and trip after completion
class RatingScreen extends StatefulWidget {
  final TripModel trip;

  const RatingScreen({super.key, required this.trip});

  @override
  State<RatingScreen> createState() => _RatingScreenState();
}

class _RatingScreenState extends State<RatingScreen> {
  double _rating = 0;
  final Set<String> _selectedTags = {};
  final _reviewController = TextEditingController();

  final _ratingTags = [
    ('Friendly driver', Icons.emoji_emotions),
    ('Clean car', Icons.directions_car),
    ('Safe driving', Icons.shield),
    ('Good route', Icons.route),
    ('On time', Icons.schedule),
    ('Good conversation', Icons.chat),
  ];

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rate your trip'),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Trip summary
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  // Pickup
                  Row(
                    children: [
                      const Icon(Icons.radio_button_checked, color: Colors.green, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          widget.trip.pickupLocation.address ?? 'Pickup',
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
                          widget.trip.dropoffLocation.address ?? 'Destination',
                          style: const TextStyle(fontSize: 13),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  // Fare
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total Fare', style: TextStyle(color: Colors.grey)),
                      Text(
                        '\$${widget.trip.fareBreakdown?.totalFare.toStringAsFixed(2) ?? '0.00'}',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Driver info
            if (widget.trip.driver != null) ...[
              CircleAvatar(
                radius: 32,
                backgroundColor: Colors.green.withOpacity(0.1),
                child: Text(
                  widget.trip.driver!.name.isNotEmpty ? widget.trip.driver!.name[0].toUpperCase() : '?',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.trip.driver!.name,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              Text(
                '${widget.trip.driver!.vehicle.name} • ${widget.trip.driver!.vehicle.plateNumber}',
                style: TextStyle(color: Colors.grey[500], fontSize: 13),
              ),
            ],

            const SizedBox(height: 32),

            // Star rating
            const Text('How was your trip?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                final starValue = (index + 1).toDouble();
                return GestureDetector(
                  onTap: () => setState(() => _rating = starValue),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Icon(
                      starValue <= _rating ? Icons.star : Icons.star_border,
                      color: starValue <= _rating ? Colors.amber : Colors.grey[300],
                      size: 44,
                    ),
                  ),
                );
              }),
            ),

            if (_rating > 0) ...[
              const SizedBox(height: 8),
              Text(
                _getRatingLabel(_rating),
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
            ],

            const SizedBox(height: 24),

            // Rating tags
            if (_rating > 0 && _rating <= 3) ...[
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _ratingTags.map((tag) {
                  final isSelected = _selectedTags.contains(tag.$1);
                  return FilterChip(
                    label: Row(mainAxisSize: MainAxisSize.min, children: [Icon(tag.$2, size: 14), const SizedBox(width: 4), Text(tag.$1)]),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedTags.add(tag.$1);
                        } else {
                          _selectedTags.remove(tag.$1);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
            ],

            // Review
            TextField(
              controller: _reviewController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Add a comment (optional)',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),

            const SizedBox(height: 24),

            // Tip section
            if (_rating >= 4) ...[
              const Text('Add a tip for your driver?', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [1.0, 2.0, 5.0].map((tip) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
                    child: Text('\$$tip'),
                  ),
                )).toList(),
              ),
              const SizedBox(height: 24),
            ],

            // Submit button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _rating > 0 ? _submitRating : null,
                child: const Text('Submit Rating'),
              ),
            ),

            const SizedBox(height: 8),

            // Skip
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Skip'),
            ),
          ],
        ),
      ),
    );
  }

  String _getRatingLabel(double rating) => switch (rating) {
    1 => 'Terrible',
    2 => 'Bad',
    3 => 'OK',
    4 => 'Good',
    5 => 'Excellent',
    _ => '',
  };

  void _submitRating() {
    // Submit rating via API
    Navigator.pop(context, {
      'rating': _rating,
      'review': _reviewController.text,
      'tags': _selectedTags.toList(),
    });
  }
}
