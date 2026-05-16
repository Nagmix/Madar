import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trippo_shared/trippo_shared.dart';
import '../../../../core/app_providers.dart';

/// Promo State - Holds the current promo code application state
class PromoState {
  final PromoCode? appliedPromo;
  final bool isValidating;
  final String? validationError;
  final double discountAmount;
  final bool validationSuccess;

  const PromoState({
    this.appliedPromo,
    this.isValidating = false,
    this.validationError,
    this.discountAmount = 0.0,
    this.validationSuccess = false,
  });

  PromoState copyWith({
    PromoCode? appliedPromo,
    bool clearAppliedPromo = false,
    bool? isValidating,
    String? validationError,
    bool clearValidationError = false,
    double? discountAmount,
    bool? validationSuccess,
  }) {
    return PromoState(
      appliedPromo: clearAppliedPromo ? null : (appliedPromo ?? this.appliedPromo),
      isValidating: isValidating ?? this.isValidating,
      validationError: clearValidationError ? null : (validationError ?? this.validationError),
      discountAmount: discountAmount ?? this.discountAmount,
      validationSuccess: validationSuccess ?? this.validationSuccess,
    );
  }

  /// Calculate the discounted fare from an original fare
  double discountedFare(double originalFare) {
    if (appliedPromo == null) return originalFare;
    final discounted = originalFare - discountAmount;
    return discounted < 0 ? 0 : discounted;
  }

  /// Whether a promo is currently applied
  bool get hasPromo => appliedPromo != null;
}

/// Promo Notifier - Manages promo code validation, application, and removal
class PromoNotifier extends StateNotifier<PromoState> {
  final Ref _ref;

  PromoNotifier(this._ref) : super(const PromoState());

  /// Validate a promo code against the given fare and vehicle type
  Future<void> validatePromo(
    String code,
    double fareAmount,
    String vehicleType,
  ) async {
    // Clear previous state and show loading
    state = state.copyWith(
      isValidating: true,
      clearValidationError: true,
      clearAppliedPromo: true,
      discountAmount: 0.0,
      validationSuccess: false,
    );

    try {
      final apiService = _ref.read(apiServiceProvider);
      final promoService = PromoService(apiService: apiService);

      final result = await promoService.validatePromoCode(
        code,
        fareAmount: fareAmount,
        vehicleType: vehicleType,
      );

      if (result.isValid && result.promoCode != null) {
        state = state.copyWith(
          isValidating: false,
          appliedPromo: result.promoCode,
          discountAmount: result.discountAmount,
          validationSuccess: true,
        );

        // Clear the success flag after a brief delay for the UI animation
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            state = state.copyWith(validationSuccess: false);
          }
        });
      } else {
        state = state.copyWith(
          isValidating: false,
          validationError: result.message ?? 'Invalid promo code',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isValidating: false,
        validationError: 'Unable to validate promo code. Please try again.',
      );
    }
  }

  /// Remove the currently applied promo code
  void removePromo() {
    state = const PromoState();
  }

  /// Clear any validation error message
  void clearError() {
    state = state.copyWith(clearValidationError: true);
  }
}

/// Promo Provider
final promoProvider = StateNotifierProvider<PromoNotifier, PromoState>((ref) {
  return PromoNotifier(ref);
});
