import 'package:freezed_annotation/freezed_annotation.dart';

part 'promo_model.freezed.dart';
part 'promo_model.g.dart';

/// Promo code discount type
enum PromoDiscountType {
  @JsonValue('percentage')
  percentage,
  @JsonValue('fixed')
  fixed,
}

/// Promo Code - Represents a promotional discount code
@freezed
class PromoCode with _$PromoCode {
  const factory PromoCode({
    required String id,
    required String code,
    required String description,
    required PromoDiscountType type,
    required double value,
    @Default(0.0) double minFare,
    double? maxDiscount,
    int? usageLimit,
    @Default(0) int usedCount,
    required DateTime validFrom,
    required DateTime validUntil,
    @Default(true) bool isActive,
    @Default([]) List<String> applicableVehicleTypes,
    @Default([]) List<String> applicableZones,
    @Default(false) bool firstRideOnly,
    @Default(1) int maxPerUser,
  }) = _PromoCode;

  factory PromoCode.fromJson(Map<String, dynamic> json) =>
      _$PromoCodeFromJson(json);
}

/// Promo Validation Result - Response from validating a promo code
@freezed
class PromoValidationResult with _$PromoValidationResult {
  const factory PromoValidationResult({
    required bool isValid,
    PromoCode? promoCode,
    @Default(0.0) double discountAmount,
    String? message,
    String? errorCode,
  }) = _PromoValidationResult;

  factory PromoValidationResult.fromJson(Map<String, dynamic> json) =>
      _$PromoValidationResultFromJson(json);
}

/// Promo Application - Record of a promo code applied to a trip
@freezed
class PromoApplication with _$PromoApplication {
  const factory PromoApplication({
    required String promoCodeId,
    required String tripId,
    @Default(0.0) double discountAmount,
    required DateTime appliedAt,
  }) = _PromoApplication;

  factory PromoApplication.fromJson(Map<String, dynamic> json) =>
      _$PromoApplicationFromJson(json);
}
