// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pricing_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$FareBreakdownImpl _$$FareBreakdownImplFromJson(Map<String, dynamic> json) =>
    _$FareBreakdownImpl(
      baseFare: (json['baseFare'] as num).toDouble(),
      distanceFare: (json['distanceFare'] as num).toDouble(),
      timeFare: (json['timeFare'] as num).toDouble(),
      totalFare: (json['totalFare'] as num).toDouble(),
      surgeCharge: (json['surgeCharge'] as num?)?.toDouble() ?? 0.0,
      nightCharge: (json['nightCharge'] as num?)?.toDouble() ?? 0.0,
      areaCharge: (json['areaCharge'] as num?)?.toDouble() ?? 0.0,
      waitingCharge: (json['waitingCharge'] as num?)?.toDouble() ?? 0.0,
      cancellationFee: (json['cancellationFee'] as num?)?.toDouble() ?? 0.0,
      promoDiscount: (json['promoDiscount'] as num?)?.toDouble() ?? 0.0,
      surgeMultiplier: (json['surgeMultiplier'] as num?)?.toDouble() ?? 1.0,
      nightMultiplier: (json['nightMultiplier'] as num?)?.toDouble() ?? 1.0,
      areaMultiplier: (json['areaMultiplier'] as num?)?.toDouble() ?? 1.0,
      currency: json['currency'] as String,
      distanceKm: (json['distanceKm'] as num).toDouble(),
      durationMinutes: (json['durationMinutes'] as num).toInt(),
      waitingMinutes: (json['waitingMinutes'] as num).toInt(),
      vehicleType: json['vehicleType'] as String,
    );

Map<String, dynamic> _$$FareBreakdownImplToJson(_$FareBreakdownImpl instance) =>
    <String, dynamic>{
      'baseFare': instance.baseFare,
      'distanceFare': instance.distanceFare,
      'timeFare': instance.timeFare,
      'totalFare': instance.totalFare,
      'surgeCharge': instance.surgeCharge,
      'nightCharge': instance.nightCharge,
      'areaCharge': instance.areaCharge,
      'waitingCharge': instance.waitingCharge,
      'cancellationFee': instance.cancellationFee,
      'promoDiscount': instance.promoDiscount,
      'surgeMultiplier': instance.surgeMultiplier,
      'nightMultiplier': instance.nightMultiplier,
      'areaMultiplier': instance.areaMultiplier,
      'currency': instance.currency,
      'distanceKm': instance.distanceKm,
      'durationMinutes': instance.durationMinutes,
      'waitingMinutes': instance.waitingMinutes,
      'vehicleType': instance.vehicleType,
    };

_$PricingConfigImpl _$$PricingConfigImplFromJson(Map<String, dynamic> json) =>
    _$PricingConfigImpl(
      id: json['id'] as String,
      vehicleType: json['vehicleType'] as String,
      zoneId: json['zoneId'] as String,
      baseFare: (json['baseFare'] as num).toDouble(),
      perKmRate: (json['perKmRate'] as num).toDouble(),
      perMinuteRate: (json['perMinuteRate'] as num).toDouble(),
      minimumFare: (json['minimumFare'] as num).toDouble(),
      cancellationFee: (json['cancellationFee'] as num).toDouble(),
      waitingFeePerMinute: (json['waitingFeePerMinute'] as num).toDouble(),
      freeWaitingMinutes: (json['freeWaitingMinutes'] as num).toInt(),
      nightMultiplier: (json['nightMultiplier'] as num?)?.toDouble() ?? 1.0,
      nightStartHour: (json['nightStartHour'] as num?)?.toInt() ?? 22,
      nightEndHour: (json['nightEndHour'] as num?)?.toInt() ?? 6,
      isSurgeEnabled: json['isSurgeEnabled'] as bool? ?? true,
      surgeMultiplierLow:
          (json['surgeMultiplierLow'] as num?)?.toDouble() ?? 1.2,
      surgeMultiplierMedium:
          (json['surgeMultiplierMedium'] as num?)?.toDouble() ?? 1.5,
      surgeMultiplierHigh:
          (json['surgeMultiplierHigh'] as num?)?.toDouble() ?? 2.0,
      surgeMultiplierExtreme:
          (json['surgeMultiplierExtreme'] as num?)?.toDouble() ?? 3.0,
      currency: json['currency'] as String,
      isActive: json['isActive'] as bool? ?? true,
      effectiveFrom: json['effectiveFrom'] == null
          ? null
          : DateTime.parse(json['effectiveFrom'] as String),
      effectiveTo: json['effectiveTo'] == null
          ? null
          : DateTime.parse(json['effectiveTo'] as String),
    );

Map<String, dynamic> _$$PricingConfigImplToJson(_$PricingConfigImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'vehicleType': instance.vehicleType,
      'zoneId': instance.zoneId,
      'baseFare': instance.baseFare,
      'perKmRate': instance.perKmRate,
      'perMinuteRate': instance.perMinuteRate,
      'minimumFare': instance.minimumFare,
      'cancellationFee': instance.cancellationFee,
      'waitingFeePerMinute': instance.waitingFeePerMinute,
      'freeWaitingMinutes': instance.freeWaitingMinutes,
      'nightMultiplier': instance.nightMultiplier,
      'nightStartHour': instance.nightStartHour,
      'nightEndHour': instance.nightEndHour,
      'isSurgeEnabled': instance.isSurgeEnabled,
      'surgeMultiplierLow': instance.surgeMultiplierLow,
      'surgeMultiplierMedium': instance.surgeMultiplierMedium,
      'surgeMultiplierHigh': instance.surgeMultiplierHigh,
      'surgeMultiplierExtreme': instance.surgeMultiplierExtreme,
      'currency': instance.currency,
      'isActive': instance.isActive,
      'effectiveFrom': instance.effectiveFrom?.toIso8601String(),
      'effectiveTo': instance.effectiveTo?.toIso8601String(),
    };

_$FareEstimateRequestImpl _$$FareEstimateRequestImplFromJson(
        Map<String, dynamic> json) =>
    _$FareEstimateRequestImpl(
      pickupLatitude: (json['pickupLatitude'] as num).toDouble(),
      pickupLongitude: (json['pickupLongitude'] as num).toDouble(),
      dropoffLatitude: (json['dropoffLatitude'] as num).toDouble(),
      dropoffLongitude: (json['dropoffLongitude'] as num).toDouble(),
      vehicleType: json['vehicleType'] as String,
      promoCode: json['promoCode'] as String?,
    );

Map<String, dynamic> _$$FareEstimateRequestImplToJson(
        _$FareEstimateRequestImpl instance) =>
    <String, dynamic>{
      'pickupLatitude': instance.pickupLatitude,
      'pickupLongitude': instance.pickupLongitude,
      'dropoffLatitude': instance.dropoffLatitude,
      'dropoffLongitude': instance.dropoffLongitude,
      'vehicleType': instance.vehicleType,
      'promoCode': instance.promoCode,
    };

_$FareEstimateResponseImpl _$$FareEstimateResponseImplFromJson(
        Map<String, dynamic> json) =>
    _$FareEstimateResponseImpl(
      fareBreakdown:
          FareBreakdown.fromJson(json['fareBreakdown'] as Map<String, dynamic>),
      estimatedDurationMinutes:
          (json['estimatedDurationMinutes'] as num).toInt(),
      estimatedDistanceKm: (json['estimatedDistanceKm'] as num).toDouble(),
      isSurgeActive: json['isSurgeActive'] as bool,
      surgeMultiplier: (json['surgeMultiplier'] as num).toDouble(),
      currency: json['currency'] as String,
    );

Map<String, dynamic> _$$FareEstimateResponseImplToJson(
        _$FareEstimateResponseImpl instance) =>
    <String, dynamic>{
      'fareBreakdown': instance.fareBreakdown,
      'estimatedDurationMinutes': instance.estimatedDurationMinutes,
      'estimatedDistanceKm': instance.estimatedDistanceKm,
      'isSurgeActive': instance.isSurgeActive,
      'surgeMultiplier': instance.surgeMultiplier,
      'currency': instance.currency,
    };

_$SurgeStatusImpl _$$SurgeStatusImplFromJson(Map<String, dynamic> json) =>
    _$SurgeStatusImpl(
      isActive: json['isActive'] as bool,
      currentMultiplier: (json['currentMultiplier'] as num).toDouble(),
      reason: json['reason'] as String,
      zoneId: json['zoneId'] as String,
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$SurgeStatusImplToJson(_$SurgeStatusImpl instance) =>
    <String, dynamic>{
      'isActive': instance.isActive,
      'currentMultiplier': instance.currentMultiplier,
      'reason': instance.reason,
      'zoneId': instance.zoneId,
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
