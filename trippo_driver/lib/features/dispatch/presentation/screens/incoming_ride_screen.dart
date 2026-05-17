import 'package:flutter/material.dart';
import 'package:trippo_shared/trippo_shared.dart';

/// شاشة طلب رحلة وارد - مدار
class IncomingRideRequestScreen extends StatefulWidget {
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
  State<IncomingRideRequestScreen> createState() =>
      _IncomingRideRequestScreenState();
}

class _IncomingRideRequestScreenState extends State<IncomingRideRequestScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _countdownController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _countdownController = AnimationController(
      vsync: this,
      duration: Duration(seconds: widget.request.responseTimeoutSeconds),
    )..forward();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _countdownController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MadarTheme.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(MadarTheme.space24),
          child: Column(
            children: [
              const SizedBox(height: MadarTheme.space16),

              // Pulsing "رحلة جديدة!" badge
              AnimatedBuilder(
                animation: _pulseController,
                builder: (_, __) {
                  return Transform.scale(
                    scale: 1.0 + (_pulseController.value * 0.05),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: MadarTheme.space24,
                        vertical: MadarTheme.space8,
                      ),
                      decoration: BoxDecoration(
                        color: MadarTheme.primary.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(MadarTheme.radiusFull),
                        border: Border.all(
                          color: MadarTheme.primary.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AnimatedBuilder(
                            animation: _pulseController,
                            builder: (_, __) {
                              return Opacity(
                                opacity: 0.6 + (_pulseController.value * 0.4),
                                child: const Icon(
                                  Icons.notifications_active,
                                  color: MadarTheme.primary,
                                  size: 20,
                                ),
                              );
                            },
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'رحلة جديدة!',
                            style: TextStyle(
                              fontFamily: MadarTheme.fontFamily,
                              color: MadarTheme.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: MadarTheme.space24),

              // Rider name
              Text(
                widget.request.riderName,
                style: const TextStyle(
                  fontFamily: MadarTheme.fontFamily,
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: MadarTheme.textPrimary,
                ),
              ),

              const SizedBox(height: MadarTheme.space24),

              // Pickup location
              MadarLocationPoint(
                isPickup: true,
                address: widget.request.pickupAddress,
                detail:
                    '${widget.request.distanceToPickupKm.toStringAsFixed(1)} كم • ${widget.request.estimatedEtaMinutes} د',
              ),

              const SizedBox(height: MadarTheme.space8),

              // Dotted line
              Padding(
                padding: const EdgeInsets.only(right: 5),
                child: Row(
                  children: List.generate(
                    12,
                    (_) => Expanded(
                      child: Container(
                        height: 2,
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        decoration: BoxDecoration(
                          color: MadarTheme.textHint.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(1),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: MadarTheme.space8),

              // Dropoff location
              MadarLocationPoint(
                isPickup: false,
                address: widget.request.dropoffAddress,
              ),

              const Spacer(),

              // Estimated fare
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(MadarTheme.space20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      MadarTheme.primary.withOpacity(0.08),
                      MadarTheme.primaryLight.withOpacity(0.15),
                    ],
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                  ),
                  borderRadius: BorderRadius.circular(MadarTheme.radiusLg),
                  border: Border.all(
                    color: MadarTheme.primary.withOpacity(0.2),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'الأجرة المتوقعة',
                      style: TextStyle(
                        fontFamily: MadarTheme.fontFamily,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: MadarTheme.textPrimary,
                      ),
                    ),
                    MadarPriceTag(
                      amount: widget.request.estimatedFare,
                      fontSize: 28,
                      color: MadarTheme.primary,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: MadarTheme.space24),

              // Accept/Decline buttons
              Row(
                children: [
                  // Decline button
                  Expanded(
                    child: SizedBox(
                      height: 56,
                      child: OutlinedButton(
                        onPressed: widget.onDecline,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: MadarTheme.error,
                          side: const BorderSide(
                            color: MadarTheme.error,
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(MadarTheme.radiusLg),
                          ),
                          textStyle: const TextStyle(
                            fontFamily: MadarTheme.fontFamily,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        child: const Text('رفض'),
                      ),
                    ),
                  ),
                  const SizedBox(width: MadarTheme.space16),
                  // Accept button
                  Expanded(
                    flex: 2,
                    child: MadarGradientButton(
                      label: 'قبول',
                      icon: Icons.check_circle,
                      height: 56,
                      gradientColors: const [
                        MadarTheme.success,
                        Color(0xFF059669),
                      ],
                      onPressed: widget.onAccept,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: MadarTheme.space16),

              // Timer countdown indicator
              AnimatedBuilder(
                animation: _countdownController,
                builder: (_, __) {
                  final remaining = (1 - _countdownController.value) *
                      widget.request.responseTimeoutSeconds;
                  final seconds = remaining.ceil();
                  return Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(2),
                        child: LinearProgressIndicator(
                          value: 1 - _countdownController.value,
                          backgroundColor: MadarTheme.textHint.withOpacity(0.2),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            seconds > 10
                                ? MadarTheme.primary
                                : seconds > 5
                                    ? MadarTheme.warning
                                    : MadarTheme.error,
                          ),
                          minHeight: 4,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'الوقت المتبقي: $seconds ثانية',
                        style: TextStyle(
                          fontFamily: MadarTheme.fontFamily,
                          color: MadarTheme.textSecondary,
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

