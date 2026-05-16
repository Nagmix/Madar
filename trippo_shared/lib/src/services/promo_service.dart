import 'api_service.dart';
import '../constants/api_constants.dart';
import '../models/promo_model.dart';

/// PromoService - Client-side promo code validation, application, and discovery
/// Integrates with NestJS Promo Module (POST /pricing/promo/*)
///
/// Flow:
/// 1. User enters promo code on ride request screen
/// 2. [validatePromoCode] checks code validity and returns discount preview
/// 3. [applyPromoCode] applies the code to a specific trip after creation
/// 4. [getAvailablePromos] fetches currently available promos for the user
class PromoService {
  final ApiService _apiService;

  PromoService({required ApiService apiService}) : _apiService = apiService;

  // ==================== Validate Promo Code ====================

  /// Validate a promo code before applying it
  /// POST /pricing/promo/validate
  ///
  /// Checks:
  /// - Code exists and is active
  /// - Not expired (validFrom <= now <= validUntil)
  /// - Usage limit not exceeded
  /// - User has not exceeded per-user limit
  /// - Fare meets minimum fare requirement
  /// - Vehicle type is applicable (if specified)
  /// - Zone is applicable (if specified)
  /// - First-ride-only constraint (if applicable)
  ///
  /// Returns [PromoValidationResult] with discount preview
  Future<PromoValidationResult> validatePromoCode(
    String code, {
    String? tripId,
    double? fareAmount,
    String? vehicleType,
  }) async {
    try {
      final response = await _apiService.post(
        ApiConstants.validatePromo,
        data: {
          'code': code.trim().toUpperCase(),
          if (tripId != null) 'tripId': tripId,
          if (fareAmount != null) 'fareAmount': fareAmount,
          if (vehicleType != null) 'vehicleType': vehicleType,
        },
      );

      return PromoValidationResult.fromJson(
        response.data as Map<String, dynamic>,
      );
    } catch (e) {
      // Return invalid result on error instead of throwing
      return PromoValidationResult(
        isValid: false,
        message: _mapErrorToMessage(e),
        errorCode: 'VALIDATION_FAILED',
      );
    }
  }

  // ==================== Apply Promo Code ====================

  /// Apply a validated promo code to a trip
  /// POST /pricing/promo/apply
  ///
  /// This should be called after trip creation, when the user confirms
  /// they want to use the promo code. The server performs a final
  /// validation before applying.
  ///
  /// Returns [PromoApplication] with the applied discount
  Future<PromoApplication> applyPromoCode(
    String code,
    String tripId,
  ) async {
    try {
      final response = await _apiService.post(
        ApiConstants.applyPromo,
        data: {
          'code': code.trim().toUpperCase(),
          'tripId': tripId,
        },
      );

      return PromoApplication.fromJson(
        response.data as Map<String, dynamic>,
      );
    } catch (e) {
      rethrow;
    }
  }

  // ==================== Available Promos ====================

  /// Get available promo codes for the current user
  /// GET /pricing/promo/available
  ///
  /// Returns promos that:
  /// - Are currently active and within valid date range
  /// - User hasn't exceeded usage limit for
  /// - Apply to user's typical vehicle types/zones (if configured)
  Future<List<PromoCode>> getAvailablePromos() async {
    try {
      final response = await _apiService.get(
        ApiConstants.availablePromos,
      );

      final data = response.data;
      if (data is Map<String, dynamic> && data.containsKey('items')) {
        final items = data['items'] as List<dynamic>;
        return items
            .map((e) => PromoCode.fromJson(e as Map<String, dynamic>))
            .toList();
      } else if (data is List) {
        return data
            .map((e) => PromoCode.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }

  // ==================== Helpers ====================

  /// Map API error to user-friendly message
  String _mapErrorToMessage(dynamic error) {
    if (error is AppException) {
      switch (error.type) {
        case AppExceptionType.notFound:
          return 'Promo code not found';
        case AppExceptionType.unauthorized:
          return 'Please log in to use promo codes';
        case AppExceptionType.rateLimited:
          return 'Too many attempts. Please try again later.';
        case AppExceptionType.serverError:
          return 'Unable to validate promo code. Please try again.';
        case AppExceptionType.noConnection:
          return 'No internet connection';
        case AppExceptionType.timeout:
          return 'Request timed out. Please try again.';
        default:
          return error.message.isNotEmpty
              ? error.message
              : 'Invalid promo code';
      }
    }
    return 'Unable to validate promo code';
  }
}
