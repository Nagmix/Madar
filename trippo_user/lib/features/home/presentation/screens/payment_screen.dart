import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trippo_shared/trippo_shared.dart';
import '../../../../core/constants/app_theme.dart';
import '../../../../core/network/nestjs_api_client.dart';

/// NestJS API Client Provider for payment operations
final paymentApiProvider = Provider<NestjsApiClient>((ref) => NestjsApiClient());

/// Payment Screen - Professional payment screen after trip completion
///
/// Shows trip summary, fare breakdown, and payment method selection.
/// Calls NestJS: POST /trips/:id/pay
class PaymentScreen extends ConsumerStatefulWidget {
  final String tripId;

  const PaymentScreen({super.key, required this.tripId});

  @override
  ConsumerState<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends ConsumerState<PaymentScreen>
    with TickerProviderStateMixin {
  TripModel? _trip;
  bool _isLoading = true;
  bool _isPaying = false;
  String? _error;
  PaymentMethod _selectedMethod = PaymentMethod.cash;
  bool _paymentSuccess = false;
  late AnimationController _successController;
  late Animation<double> _successAnimation;

  @override
  void initState() {
    super.initState();
    _successController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _successAnimation = CurvedAnimation(
      parent: _successController,
      curve: Curves.elasticOut,
    );
    _loadTripDetails();
  }

  @override
  void dispose() {
    _successController.dispose();
    super.dispose();
  }

  Future<void> _loadTripDetails() async {
    setState(() => _isLoading = true);
    try {
      final apiClient = ref.read(paymentApiProvider);
      final trip = await apiClient.getTripDetails(widget.tripId);
      if (mounted) {
        setState(() {
          _trip = trip;
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

  Future<void> _processPayment() async {
    setState(() => _isPaying = true);
    try {
      final apiClient = ref.read(paymentApiProvider);
      await apiClient.dio.post(
        '/trips/${widget.tripId}/pay',
        data: {'paymentMethod': _selectedMethod.name},
      );

      if (mounted) {
        setState(() => _paymentSuccess = true);
        _successController.forward();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isPaying = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Payment failed: ${e.toString()}'),
            backgroundColor: AppTheme.error,
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: _processPayment,
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment'),
        automaticallyImplyLeading: !_paymentSuccess,
      ),
      body: _paymentSuccess
          ? _buildSuccessView()
          : _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
                  ? _buildErrorView()
                  : _buildPaymentContent(),
    );
  }

  // ==================== Success View ====================

  Widget _buildSuccessView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacing32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ScaleTransition(
              scale: _successAnimation,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppTheme.success.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: AppTheme.success,
                  size: 64,
                ),
              ),
            ),
            const SizedBox(height: AppTheme.spacing24),
            const Text(
              'Payment Successful!',
              style: AppTheme.heading2,
            ),
            const SizedBox(height: AppTheme.spacing8),
            Text(
              'Your trip has been paid successfully',
              style: AppTheme.bodyMedium.copyWith(color: AppTheme.textSecondary),
              textAlign: TextAlign.center,
            ),
            if (_trip?.fareBreakdown != null) ...[
              const SizedBox(height: AppTheme.spacing16),
              Text(
                '\$${_trip!.fareBreakdown!.totalFare.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.success,
                ),
              ),
            ],
            const SizedBox(height: AppTheme.spacing32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Done'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== Error View ====================

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacing32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 64, color: AppTheme.error),
            const SizedBox(height: AppTheme.spacing16),
            Text(
              'Failed to load trip details',
              style: AppTheme.heading3,
            ),
            const SizedBox(height: AppTheme.spacing8),
            Text(
              _error ?? 'Unknown error',
              style: AppTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTheme.spacing24),
            ElevatedButton.icon(
              onPressed: _loadTripDetails,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== Payment Content ====================

  Widget _buildPaymentContent() {
    final fare = _trip?.fareBreakdown;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.spacing16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Trip Summary Card
          _buildTripSummaryCard(),
          const SizedBox(height: AppTheme.spacing16),

          // Fare Breakdown Card
          if (fare != null) ...[
            _buildFareBreakdownCard(fare),
            const SizedBox(height: AppTheme.spacing16),
          ],

          // Payment Method Selection
          _buildPaymentMethodSection(),
          const SizedBox(height: AppTheme.spacing24),

          // Pay Now Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isPaying ? null : _processPayment,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isPaying
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      'Pay \$${fare?.totalFare.toStringAsFixed(2) ?? '0.00'}',
                      style: AppTheme.button,
                    ),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== Trip Summary ====================

  Widget _buildTripSummaryCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacing16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Trip Summary', style: AppTheme.heading3),
            const SizedBox(height: AppTheme.spacing16),
            // Pickup
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppTheme.mapPickup.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.radio_button_checked,
                      color: AppTheme.mapPickup, size: 14),
                ),
                const SizedBox(width: AppTheme.spacing12),
                Expanded(
                  child: Text(
                    _trip?.pickupLocation.address ?? 'Pickup Location',
                    style: AppTheme.bodyMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(left: 11),
              child: Container(
                width: 1,
                height: 16,
                color: AppTheme.divider,
              ),
            ),
            // Dropoff
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppTheme.mapDropoff.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.location_on,
                      color: AppTheme.mapDropoff, size: 14),
                ),
                const SizedBox(width: AppTheme.spacing12),
                Expanded(
                  child: Text(
                    _trip?.dropoffLocation.address ?? 'Dropoff Location',
                    style: AppTheme.bodyMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const Divider(height: AppTheme.spacing24),
            // Stats row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildTripStat(
                  icon: Icons.straighten,
                  label: 'Distance',
                  value:
                      '${(_trip?.estimatedDistanceKm ?? _trip?.fareBreakdown?.distanceKm ?? 0).toStringAsFixed(1)} km',
                ),
                _buildTripStat(
                  icon: Icons.access_time,
                  label: 'Duration',
                  value:
                      '${_trip?.estimatedDurationMinutes ?? _trip?.fareBreakdown?.durationMinutes ?? 0} min',
                ),
                _buildTripStat(
                  icon: Icons.local_taxi,
                  label: 'Vehicle',
                  value: _trip?.vehicleType.isNotEmpty == true
                      ? _trip!.vehicleType.capitalize()
                      : 'Standard',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTripStat({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, color: AppTheme.primary, size: 20),
        const SizedBox(height: 4),
        Text(label, style: AppTheme.bodySmall),
        const SizedBox(height: 2),
        Text(value,
            style: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
      ],
    );
  }

  // ==================== Fare Breakdown ====================

  Widget _buildFareBreakdownCard(FareBreakdown fare) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacing16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Fare Breakdown', style: AppTheme.heading3),
            const SizedBox(height: AppTheme.spacing16),
            // Base fare items
            _buildFareRow('Base Fare', fare.baseFare),
            _buildFareRow('Distance Fare', fare.distanceFare),
            _buildFareRow('Time Fare', fare.timeFare),

            // Conditional charges
            if (fare.surgeCharge > 0) ...[
              const Divider(height: AppTheme.spacing16),
              _buildFareRow(
                'Surge Charge (${fare.surgeMultiplier}x)',
                fare.surgeCharge,
                highlight: true,
                icon: Icons.trending_up,
              ),
            ],
            if (fare.nightCharge > 0) ...[
              _buildFareRow(
                'Night Charge (${fare.nightMultiplier}x)',
                fare.nightCharge,
                highlight: true,
                icon: Icons.nightlight,
              ),
            ],
            if (fare.areaCharge > 0) ...[
              _buildFareRow(
                'Area Charge',
                fare.areaCharge,
                highlight: true,
                icon: Icons.map,
              ),
            ],
            if (fare.waitingCharge > 0) ...[
              _buildFareRow(
                'Waiting Fee (${fare.waitingMinutes} min)',
                fare.waitingCharge,
                icon: Icons.hourglass_bottom,
              ),
            ],

            // Discounts
            if (fare.promoDiscount > 0) ...[
              const Divider(height: AppTheme.spacing16),
              _buildFareRow(
                'Promo Discount',
                -fare.promoDiscount,
                isDiscount: true,
                icon: Icons.discount,
              ),
            ],

            // Cancellation fee
            if (fare.cancellationFee > 0) ...[
              _buildFareRow(
                'Cancellation Fee',
                fare.cancellationFee,
                highlight: true,
                icon: Icons.cancel,
              ),
            ],

            // Total
            const Divider(height: AppTheme.spacing24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total Fare',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
                Text(
                  '\$${fare.totalFare.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFareRow(
    String label,
    double amount, {
    bool highlight = false,
    bool isDiscount = false,
    IconData? icon,
  }) {
    final color = isDiscount
        ? AppTheme.success
        : highlight
            ? AppTheme.accent
            : AppTheme.textSecondary;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spacing8),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 6),
          ],
          Expanded(
            child: Text(
              label,
              style: AppTheme.bodyMedium.copyWith(color: color),
            ),
          ),
          Text(
            '${isDiscount ? "-" : ""}\$${amount.abs().toStringAsFixed(2)}',
            style: AppTheme.bodyMedium.copyWith(
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  // ==================== Payment Method ====================

  Widget _buildPaymentMethodSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacing16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Payment Method', style: AppTheme.heading3),
            const SizedBox(height: AppTheme.spacing12),
            ...PaymentMethod.values.map(
              (method) => _buildPaymentMethodOption(method),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodOption(PaymentMethod method) {
    final isSelected = _selectedMethod == method;
    return InkWell(
      onTap: () => setState(() => _selectedMethod = method),
      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      child: Container(
        margin: const EdgeInsets.only(bottom: AppTheme.spacing8),
        padding: const EdgeInsets.all(AppTheme.spacing12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primary.withOpacity(0.05)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          border: Border.all(
            color: isSelected ? AppTheme.primary : AppTheme.divider,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _getMethodColor(method).withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
              ),
              child: Icon(
                _getMethodIcon(method),
                color: _getMethodColor(method),
                size: 20,
              ),
            ),
            const SizedBox(width: AppTheme.spacing12),
            Expanded(
              child: Text(
                _getMethodLabel(method),
                style: AppTheme.bodyMedium.copyWith(
                  fontWeight:
                      isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: AppTheme.primary),
          ],
        ),
      ),
    );
  }

  IconData _getMethodIcon(PaymentMethod method) => switch (method) {
        PaymentMethod.cash => Icons.money,
        PaymentMethod.card => Icons.credit_card,
        PaymentMethod.wallet => Icons.account_balance_wallet,
      };

  Color _getMethodColor(PaymentMethod method) => switch (method) {
        PaymentMethod.cash => AppTheme.success,
        PaymentMethod.card => AppTheme.info,
        PaymentMethod.wallet => AppTheme.accent,
      };

  String _getMethodLabel(PaymentMethod method) => switch (method) {
        PaymentMethod.cash => 'Cash',
        PaymentMethod.card => 'Credit / Debit Card',
        PaymentMethod.wallet => 'Trippo Wallet',
      };
}

/// Payment method enum for the payment screen
enum PaymentMethod {
  cash,
  card,
  wallet,
}

/// String capitalization extension
extension StringCapitalization on String {
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}
