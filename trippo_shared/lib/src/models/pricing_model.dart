import 'package:freezed_annotation/freezed_annotation.dart';

part 'pricing_model.freezed.dart';
part 'pricing_model.g.dart';

/// Fare breakdown - detailed price calculation
@freezed
class FareBreakdown with _$FareBreakdown {
  const factory FareBreakdown({
    required double baseFare,
    required double distanceFare,
    required double timeFare,
    required double totalFare,
    @Default(0.0) double surgeCharge,
    @Default(0.0) double nightCharge,
    @Default(0.0) double areaCharge,
    @Default(0.0) double waitingCharge,
    @Default(0.0) double cancellationFee,
    @Default(0.0) double promoDiscount,
    @Default(1.0) double surgeMultiplier,
    @Default(1.0) double nightMultiplier,
    @Default(1.0) double areaMultiplier,
    required String currency,
    required double distanceKm,
    required int durationMinutes,
    required int waitingMinutes,
    required String vehicleType,
  }) = _FareBreakdown;

  factory FareBreakdown.fromJson(Map<String, dynamic> json) =>
      _$FareBreakdownFromJson(json);
}

/// Pricing configuration per vehicle type per zone
@freezed
class PricingConfig with _$PricingConfig {
  const factory PricingConfig({
    required String id,
    required String vehicleType,
    required String zoneId,
    required double baseFare,
    required double perKmRate,
    required double perMinuteRate,
    required double minimumFare,
    required double cancellationFee,
    required double waitingFeePerMinute,
    required int freeWaitingMinutes,
    @Default(1.0) double nightMultiplier,
    @Default(22) int nightStartHour,
    @Default(6) int nightEndHour,
    @Default(true) bool isSurgeEnabled,
    @Default(1.2) double surgeMultiplierLow,
    @Default(1.5) double surgeMultiplierMedium,
    @Default(2.0) double surgeMultiplierHigh,
    @Default(3.0) double surgeMultiplierExtreme,
    required String currency,
    @Default(true) bool isActive,
    DateTime? effectiveFrom,
    DateTime? effectiveTo,
  }) = _PricingConfig;

  factory PricingConfig.fromJson(Map<String, dynamic> json) =>
      _$PricingConfigFromJson(json);
}

/// Fare estimation request
@freezed
class FareEstimateRequest with _$FareEstimateRequest {
  const factory FareEstimateRequest({
    required double pickupLatitude,
    required double pickupLongitude,
    required double dropoffLatitude,
    required double dropoffLongitude,
    required String vehicleType,
    String? promoCode,
  }) = _FareEstimateRequest;

  factory FareEstimateRequest.fromJson(Map<String, dynamic> json) =>
      _$FareEstimateRequestFromJson(json);
}

/// Fare estimation response
@freezed
class FareEstimateResponse with _$FareEstimateResponse {
  const factory FareEstimateResponse({
    required FareBreakdown fareBreakdown,
    required int estimatedDurationMinutes,
    required double estimatedDistanceKm,
    required bool isSurgeActive,
    required double surgeMultiplier,
    required String currency,
  }) = _FareEstimateResponse;

  factory FareEstimateResponse.fromJson(Map<String, dynamic> json) =>
      _$FareEstimateResponseFromJson(json);
}

/// Surge pricing status
@freezed
class SurgeStatus with _$SurgeStatus {
  const factory SurgeStatus({
    required bool isActive,
    required double currentMultiplier,
    required String reason,
    required String zoneId,
    required DateTime updatedAt,
  }) = _SurgeStatus;

  factory SurgeStatus.fromJson(Map<String, dynamic> json) =>
      _$SurgeStatusFromJson(json);
}
