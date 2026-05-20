import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trippo_shared/trippo_shared.dart';
import '../../../../core/network/nestjs_api_client.dart';

/// مزود عميل API للدفع
final paymentApiProvider = Provider<NestjsApiClient>((ref) => NestjsApiClient());

/// شاشة الدفع - مدار
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
            content: Text('فشل الدفع: ${e.toString()}'),
            backgroundColor: MadarTheme.error,
            action: SnackBarAction(
              label: 'إعادة المحاولة',
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
      appBar: MadarAppBar(
        title: 'الدفع',
        showBack: !_paymentSuccess,
      ),
      body: _paymentSuccess
          ? _buildSuccessView()
          : _isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: MadarTheme.primary))
              : _error != null
                  ? _buildErrorView()
                  : _buildPaymentContent(),
    );
  }

  // ── عرض النجاح ──
  Widget _buildSuccessView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(MadarTheme.space32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ScaleTransition(
              scale: _successAnimation,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: MadarTheme.success.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: MadarTheme.success,
                  size: 64,
                ),
              ),
            ),
            const SizedBox(height: MadarTheme.space24),
            Text(
              'تم الدفع بنجاح!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                fontFamily: MadarTheme.fontFamily,
                color: MadarTheme.textPrimary,
              ),
            ),
            const SizedBox(height: MadarTheme.space8),
            Text(
              'تم سداد أجرة الرحلة بنجاح',
              style: TextStyle(
                color: MadarTheme.textSecondary,
                fontFamily: MadarTheme.fontFamily,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            if (_trip?.fareBreakdown != null) ...[
              const SizedBox(height: MadarTheme.space16),
              MadarPriceTag(
                amount: _trip!.fareBreakdown!.totalFare,
                fontSize: 32,
                color: MadarTheme.success,
              ),
            ],
            const SizedBox(height: MadarTheme.space32),
            SizedBox(
              width: double.infinity,
              child: MadarGradientButton(
                label: 'تم',
                onPressed: () => Navigator.of(context).pop(),
                gradientColors: const [
                  MadarTheme.primary,
                  MadarTheme.primaryDark,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── عرض الخطأ ──
  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(MadarTheme.space32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 64, color: MadarTheme.error),
            const SizedBox(height: MadarTheme.space16),
            Text(
              'فشل تحميل تفاصيل الرحلة',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                fontFamily: MadarTheme.fontFamily,
              ),
            ),
            const SizedBox(height: MadarTheme.space8),
            Text(
              _error ?? 'خطأ غير معروف',
              style: TextStyle(
                fontSize: 12,
                fontFamily: MadarTheme.fontFamily,
                color: MadarTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: MadarTheme.space24),
            MadarButton(
              label: 'إعادة المحاولة',
              onPressed: _loadTripDetails,
              icon: Icons.refresh,
            ),
          ],
        ),
      ),
    );
  }

  // ── محتوى الدفع ──
  Widget _buildPaymentContent() {
    final fare = _trip?.fareBreakdown;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(MadarTheme.space16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTripSummaryCard(),
          const SizedBox(height: MadarTheme.space16),
          if (fare != null) ...[
            _buildFareBreakdownCard(fare),
            const SizedBox(height: MadarTheme.space16),
          ],
          _buildPaymentMethodSection(),
          const SizedBox(height: MadarTheme.space24),
          MadarGradientButton(
            label:
                'ادفع الآن ${fare != null ? "${fare.totalFare.toStringAsFixed(2)} ر.ي" : ""}',
            onPressed: _isPaying ? null : _processPayment,
            isLoading: _isPaying,
            gradientColors: const [MadarTheme.primary, MadarTheme.primaryDark],
          ),
        ],
      ),
    );
  }

  // ── ملخص الرحلة ──
  Widget _buildTripSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(MadarTheme.space16),
      decoration: MadarTheme.cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ملخص الرحلة',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              fontFamily: MadarTheme.fontFamily,
              color: MadarTheme.textPrimary,
            ),
          ),
          const SizedBox(height: MadarTheme.space16),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: MadarTheme.mapPickup.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.radio_button_checked,
                    color: MadarTheme.mapPickup, size: 14),
              ),
              const SizedBox(width: MadarTheme.space12),
              Expanded(
                child: Text(
                  _trip?.pickupLocation.address ?? 'نقطة الانطلاق',
                  style: TextStyle(
                    fontSize: 14,
                    fontFamily: MadarTheme.fontFamily,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(right: 11),
            child: Container(
              width: 1,
              height: 16,
              color: MadarTheme.textHint.withOpacity(0.3),
            ),
          ),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: MadarTheme.mapDropoff.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.location_on,
                    color: MadarTheme.mapDropoff, size: 14),
              ),
              const SizedBox(width: MadarTheme.space12),
              Expanded(
                child: Text(
                  _trip?.dropoffLocation.address ?? 'نقطة الوصول',
                  style: TextStyle(
                    fontSize: 14,
                    fontFamily: MadarTheme.fontFamily,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const Divider(height: MadarTheme.space24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildTripStat(
                icon: Icons.straighten,
                label: 'المسافة',
                value:
                    '${(_trip?.estimatedDistanceKm ?? _trip?.fareBreakdown?.distanceKm ?? 0).toStringAsFixed(1)} كم',
              ),
              _buildTripStat(
                icon: Icons.access_time,
                label: 'المدة',
                value:
                    '${_trip?.estimatedDurationMinutes ?? _trip?.fareBreakdown?.durationMinutes ?? 0} د',
              ),
              _buildTripStat(
                icon: Icons.local_taxi,
                label: 'المركبة',
                value: _trip?.vehicleType.isNotEmpty == true
                    ? _trip!.vehicleType
                    : 'قياسي',
              ),
            ],
          ),
        ],
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
        Icon(icon, color: MadarTheme.primary, size: 20),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontFamily: MadarTheme.fontFamily,
            color: MadarTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            fontFamily: MadarTheme.fontFamily,
          ),
        ),
      ],
    );
  }

  // ── تفاصيل الأجرة ──
  Widget _buildFareBreakdownCard(FareBreakdown fare) {
    return Container(
      padding: const EdgeInsets.all(MadarTheme.space16),
      decoration: MadarTheme.cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'تفاصيل الأجرة',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              fontFamily: MadarTheme.fontFamily,
              color: MadarTheme.textPrimary,
            ),
          ),
          const SizedBox(height: MadarTheme.space16),
          _buildFareRow('الأجرة الأساسية', fare.baseFare),
          _buildFareRow('أجرة المسافة', fare.distanceFare),
          _buildFareRow('أجرة الوقت', fare.timeFare),
          if (fare.surgeCharge > 0) ...[
            const Divider(height: MadarTheme.space16),
            _buildFareRow(
              'رسوم الازدحام (${fare.surgeMultiplier}x)',
              fare.surgeCharge,
              highlight: true,
              icon: Icons.trending_up,
            ),
          ],
          if (fare.nightCharge > 0) ...[
            _buildFareRow(
              'رسوم الليل (${fare.nightMultiplier}x)',
              fare.nightCharge,
              highlight: true,
              icon: Icons.nightlight,
            ),
          ],
          if (fare.areaCharge > 0) ...[
            _buildFareRow(
              'رسوم المنطقة',
              fare.areaCharge,
              highlight: true,
              icon: Icons.map,
            ),
          ],
          if (fare.waitingCharge > 0) ...[
            _buildFareRow(
              'رسوم الانتظار (${fare.waitingMinutes} د)',
              fare.waitingCharge,
              icon: Icons.hourglass_bottom,
            ),
          ],
          if (fare.promoDiscount > 0) ...[
            const Divider(height: MadarTheme.space16),
            _buildFareRow(
              'خصم العرض',
              -fare.promoDiscount,
              isDiscount: true,
              icon: Icons.discount,
            ),
          ],
          if (fare.cancellationFee > 0) ...[
            _buildFareRow(
              'رسوم الإلغاء',
              fare.cancellationFee,
              highlight: true,
              icon: Icons.cancel,
            ),
          ],
          const Divider(height: MadarTheme.space24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'الإجمالي',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  fontFamily: MadarTheme.fontFamily,
                  color: MadarTheme.textPrimary,
                ),
              ),
              MadarPriceTag(
                amount: fare.totalFare,
                fontSize: 22,
                color: MadarTheme.primary,
              ),
            ],
          ),
        ],
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
        ? MadarTheme.success
        : highlight
            ? MadarTheme.accent
            : MadarTheme.textSecondary;

    return Padding(
      padding: const EdgeInsets.only(bottom: MadarTheme.space8),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 6),
          ],
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontFamily: MadarTheme.fontFamily,
                color: color,
              ),
            ),
          ),
          Text(
            '${isDiscount ? "-" : ""}${amount.abs().toStringAsFixed(2)} ر.ي',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              fontFamily: MadarTheme.fontFamily,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  // ── طريقة الدفع ──
  Widget _buildPaymentMethodSection() {
    return Container(
      padding: const EdgeInsets.all(MadarTheme.space16),
      decoration: MadarTheme.cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'طريقة الدفع',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              fontFamily: MadarTheme.fontFamily,
              color: MadarTheme.textPrimary,
            ),
          ),
          const SizedBox(height: MadarTheme.space12),
          ...PaymentMethod.values.map(
            (method) => _buildPaymentMethodOption(method),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodOption(PaymentMethod method) {
    final isSelected = _selectedMethod == method;
    return InkWell(
      onTap: () => setState(() => _selectedMethod = method),
      borderRadius: BorderRadius.circular(MadarTheme.radiusMd),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: MadarTheme.space8),
        padding: const EdgeInsets.all(MadarTheme.space12),
        decoration: BoxDecoration(
          color: isSelected
              ? MadarTheme.primary.withOpacity(0.05)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(MadarTheme.radiusMd),
          border: Border.all(
            color: isSelected ? MadarTheme.primary : MadarTheme.textHint.withOpacity(0.2),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _getMethodColor(method).withOpacity(0.1),
                borderRadius: BorderRadius.circular(MadarTheme.radiusSm),
              ),
              child: Icon(
                _getMethodIcon(method),
                color: _getMethodColor(method),
                size: 20,
              ),
            ),
            const SizedBox(width: MadarTheme.space12),
            Expanded(
              child: Text(
                _getMethodLabel(method),
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: MadarTheme.fontFamily,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: MadarTheme.primary),
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
        PaymentMethod.cash => MadarTheme.success,
        PaymentMethod.card => MadarTheme.primary,
        PaymentMethod.wallet => MadarTheme.accent,
      };

  String _getMethodLabel(PaymentMethod method) => switch (method) {
        PaymentMethod.cash => 'نقدي',
        PaymentMethod.card => 'بطاقة ائتمان / خصم',
        PaymentMethod.wallet => 'محفظة مدار',
      };
}

/// طريقة الدفع
enum PaymentMethod {
  cash,
  card,
  wallet,
}

/// امتداد تحويل الحرف الأول لكبير
extension StringCapitalization on String {
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}

