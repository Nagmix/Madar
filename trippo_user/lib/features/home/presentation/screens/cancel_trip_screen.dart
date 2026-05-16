import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trippo_shared/trippo_shared.dart';
import '../../../../core/constants/app_theme.dart';
import '../../../../core/network/nestjs_api_client.dart';

/// NestJS API Client Provider for cancel trip operations
final cancelTripApiProvider = Provider<NestjsApiClient>((ref) => NestjsApiClient());

/// Cancellation reason options
class CancellationReason {
  final String label;
  final String value;
  final IconData icon;

  const CancellationReason({
    required this.label,
    required this.value,
    required this.icon,
  });
}

/// Cancel Trip Screen - Trip cancellation with reason selection
///
/// Shows trip info, cancellation reasons, and warnings about fees.
/// Calls NestJS: POST /trips/:id/cancel
class CancelTripScreen extends ConsumerStatefulWidget {
  final String tripId;

  const CancelTripScreen({super.key, required this.tripId});

  @override
  ConsumerState<CancelTripScreen> createState() => _CancelTripScreenState();
}

class _CancelTripScreenState extends ConsumerState<CancelTripScreen> {
  TripModel? _trip;
  bool _isLoading = true;
  bool _isCancelling = false;
  String? _error;
  String? _selectedReason;
  final _customReasonController = TextEditingController();
  PricingConfig? _pricingConfig;

  static const _cancellationReasons = [
    CancellationReason(
      label: 'Driver is taking too long',
      value: 'driver_taking_too_long',
      icon: Icons.schedule,
    ),
    CancellationReason(
      label: 'Found a better ride',
      value: 'found_better_ride',
      icon: Icons.search,
    ),
    CancellationReason(
      label: 'Changed my mind',
      value: 'changed_mind',
      icon: Icons.psychology,
    ),
    CancellationReason(
      label: 'Driver asked me to cancel',
      value: 'driver_asked_to_cancel',
      icon: Icons.person_off,
    ),
    CancellationReason(
      label: 'Incorrect route shown',
      value: 'incorrect_route',
      icon: Icons.alt_route,
    ),
    CancellationReason(
      label: 'Other',
      value: 'other',
      icon: Icons.more_horiz,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadTripAndPricing();
  }

  @override
  void dispose() {
    _customReasonController.dispose();
    super.dispose();
  }

  Future<void> _loadTripAndPricing() async {
    setState(() => _isLoading = true);
    try {
      final apiClient = ref.read(cancelTripApiProvider);
      final trip = await apiClient.getTripDetails(widget.tripId);

      // Try to load pricing config for cancellation fee info
      PricingConfig? pricing;
      try {
        pricing = await apiClient.getPricingConfig(
          vehicleType: trip.vehicleType.isNotEmpty ? trip.vehicleType : null,
        );
      } catch (_) {
        // Pricing config is optional; proceed without it
      }

      if (mounted) {
        setState(() {
          _trip = trip;
          _pricingConfig = pricing;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  bool get _hasCancellationFee {
    return (_pricingConfig?.cancellationFee ?? 0) > 0 &&
        _trip?.state != TripState.searchingDriver;
  }

  double get _cancellationFee => _pricingConfig?.cancellationFee ?? 0;

  Future<void> _cancelTrip() async {
    final reason = _selectedReason == 'other'
        ? _customReasonController.text.trim()
        : _selectedReason;

    if (reason == null || reason.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a cancellation reason'),
          backgroundColor: AppTheme.warning,
        ),
      );
      return;
    }

    setState(() => _isCancelling = true);
    try {
      final apiClient = ref.read(cancelTripApiProvider);
      await apiClient.cancelTrip(
        tripId: widget.tripId,
        reason: reason,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _hasCancellationFee
                  ? 'Trip cancelled. A cancellation fee of \$${_cancellationFee.toStringAsFixed(2)} has been applied.'
                  : 'Trip cancelled successfully.',
            ),
            backgroundColor: AppTheme.success,
          ),
        );
        Navigator.of(context).pop(true); // Return true to indicate cancellation
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isCancelling = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to cancel trip: ${e.toString()}'),
            backgroundColor: AppTheme.error,
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: _cancelTrip,
            ),
          ),
        );
      }
    }
  }

  void _showConfirmDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Trip?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Are you sure you want to cancel this trip?'),
            if (_hasCancellationFee) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.warning.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  border: Border.all(
                      color: AppTheme.warning.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber, color: AppTheme.warning),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'A cancellation fee of \$${_cancellationFee.toStringAsFixed(2)} will be charged.',
                        style: const TextStyle(
                          color: AppTheme.warning,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Keep Trip'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _cancelTrip();
            },
            style: TextButton.styleFrom(foregroundColor: AppTheme.error),
            child: const Text('Cancel Trip'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cancel Trip'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildErrorView()
              : _buildContent(),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacing32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 64, color: AppTheme.error),
            const SizedBox(height: AppTheme.spacing16),
            Text('Failed to load trip', style: AppTheme.heading3),
            const SizedBox(height: AppTheme.spacing8),
            Text(_error ?? 'Unknown error',
                style: AppTheme.bodySmall, textAlign: TextAlign.center),
            const SizedBox(height: AppTheme.spacing24),
            ElevatedButton.icon(
              onPressed: _loadTripAndPricing,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.spacing16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Trip Info Card
          _buildTripInfoCard(),
          const SizedBox(height: AppTheme.spacing16),

          // Cancellation Fee Warning
          if (_hasCancellationFee) ...[
            _buildCancellationFeeWarning(),
            const SizedBox(height: AppTheme.spacing16),
          ],

          // Cancellation Reasons
          _buildReasonsSection(),
          const SizedBox(height: AppTheme.spacing16),

          // Custom reason field (if Other selected)
          if (_selectedReason == 'other') ...[
            _buildCustomReasonField(),
            const SizedBox(height: AppTheme.spacing16),
          ],

          // Cancel button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isCancelling || _selectedReason == null
                  ? null
                  : _showConfirmDialog,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.error,
                disabledBackgroundColor: AppTheme.error.withOpacity(0.4),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isCancelling
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Cancel Trip'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTripInfoCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacing16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Trip Info', style: AppTheme.heading3),
            const SizedBox(height: AppTheme.spacing12),
            // Pickup
            Row(
              children: [
                const Icon(Icons.radio_button_checked,
                    color: AppTheme.mapPickup, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _trip?.pickupLocation.address ?? 'Pickup',
                    style: AppTheme.bodyMedium,
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
                const Icon(Icons.location_on,
                    color: AppTheme.mapDropoff, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _trip?.dropoffLocation.address ?? 'Destination',
                    style: AppTheme.bodyMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            // Driver info
            if (_trip?.driver != null) ...[
              const Divider(height: AppTheme.spacing16),
              Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: AppTheme.primary.withOpacity(0.1),
                    child: Text(
                      _trip!.driver!.name.isNotEmpty
                          ? _trip!.driver!.name[0].toUpperCase()
                          : '?',
                      style: const TextStyle(
                        color: AppTheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _trip!.driver!.name,
                    style: AppTheme.bodyMedium
                        .copyWith(fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCancellationFeeWarning() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacing16),
      decoration: BoxDecoration(
        color: AppTheme.warning.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(color: AppTheme.warning.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded,
              color: AppTheme.warning, size: 28),
          const SizedBox(width: AppTheme.spacing12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Cancellation Fee Applies',
                  style: TextStyle(
                    color: AppTheme.warning,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Since a driver has been assigned, a cancellation fee of \$${_cancellationFee.toStringAsFixed(2)} will be charged.',
                  style: AppTheme.bodySmall.copyWith(
                    color: AppTheme.warning,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReasonsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacing16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Reason for Cancellation', style: AppTheme.heading3),
            const SizedBox(height: AppTheme.spacing8),
            Text(
              'Please select a reason to help us improve our service',
              style: AppTheme.bodySmall,
            ),
            const SizedBox(height: AppTheme.spacing12),
            ..._cancellationReasons.map(
              (reason) => _buildReasonOption(reason),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReasonOption(CancellationReason reason) {
    final isSelected = _selectedReason == reason.value;
    return InkWell(
      onTap: () => setState(() => _selectedReason = reason.value),
      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      child: Container(
        margin: const EdgeInsets.only(bottom: AppTheme.spacing4),
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacing12,
          vertical: AppTheme.spacing12,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primary.withOpacity(0.05)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        ),
        child: Row(
          children: [
            Icon(reason.icon,
                color: isSelected ? AppTheme.primary : AppTheme.textSecondary,
                size: 20),
            const SizedBox(width: AppTheme.spacing12),
            Expanded(
              child: Text(
                reason.label,
                style: AppTheme.bodyMedium.copyWith(
                  fontWeight:
                      isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected ? AppTheme.primary : AppTheme.textPrimary,
                ),
              ),
            ),
            Radio<String>(
              value: reason.value,
              groupValue: _selectedReason,
              onChanged: (value) => setState(() => _selectedReason = value),
              activeColor: AppTheme.primary,
              visualDensity: VisualDensity.compact,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomReasonField() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacing16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tell us more', style: AppTheme.heading3),
            const SizedBox(height: AppTheme.spacing8),
            TextField(
              controller: _customReasonController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Please describe your reason for cancelling...',
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(AppTheme.radiusMedium),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
