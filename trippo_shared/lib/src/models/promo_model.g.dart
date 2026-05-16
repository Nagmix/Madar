// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'promo_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PromoCodeImpl _$$PromoCodeImplFromJson(Map<String, dynamic> json) =>
    _$PromoCodeImpl(
      id: json['id'] as String,
      code: json['code'] as String,
      description: json['description'] as String,
      type: $enumDecode(_$PromoDiscountTypeEnumMap, json['type']),
      value: (json['value'] as num).toDouble(),
      minFare: (json['minFare'] as num?)?.toDouble() ?? 0.0,
      maxDiscount: (json['maxDiscount'] as num?)?.toDouble(),
      usageLimit: (json['usageLimit'] as num?)?.toInt(),
      usedCount: (json['usedCount'] as num?)?.toInt() ?? 0,
      validFrom: DateTime.parse(json['validFrom'] as String),
      validUntil: DateTime.parse(json['validUntil'] as String),
      isActive: json['isActive'] as bool? ?? true,
      applicableVehicleTypes: (json['applicableVehicleTypes'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      applicableZones: (json['applicableZones'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      firstRideOnly: json['firstRideOnly'] as bool? ?? false,
      maxPerUser: (json['maxPerUser'] as num?)?.toInt() ?? 1,
    );

Map<String, dynamic> _$$PromoCodeImplToJson(_$PromoCodeImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'code': instance.code,
      'description': instance.description,
      'type': _$PromoDiscountTypeEnumMap[instance.type]!,
      'value': instance.value,
      'minFare': instance.minFare,
      'maxDiscount': instance.maxDiscount,
      'usageLimit': instance.usageLimit,
      'usedCount': instance.usedCount,
      'validFrom': instance.validFrom.toIso8601String(),
      'validUntil': instance.validUntil.toIso8601String(),
      'isActive': instance.isActive,
      'applicableVehicleTypes': instance.applicableVehicleTypes,
      'applicableZones': instance.applicableZones,
      'firstRideOnly': instance.firstRideOnly,
      'maxPerUser': instance.maxPerUser,
    };

const _$PromoDiscountTypeEnumMap = {
  PromoDiscountType.percentage: 'percentage',
  PromoDiscountType.fixed: 'fixed',
};

_$PromoValidationResultImpl _$$PromoValidationResultImplFromJson(
        Map<String, dynamic> json) =>
    _$PromoValidationResultImpl(
      isValid: json['isValid'] as bool,
      promoCode: json['promoCode'] == null
          ? null
          : PromoCode.fromJson(json['promoCode'] as Map<String, dynamic>),
      discountAmount: (json['discountAmount'] as num?)?.toDouble() ?? 0.0,
      message: json['message'] as String?,
      errorCode: json['errorCode'] as String?,
    );

Map<String, dynamic> _$$PromoValidationResultImplToJson(
        _$PromoValidationResultImpl instance) =>
    <String, dynamic>{
      'isValid': instance.isValid,
      'promoCode': instance.promoCode,
      'discountAmount': instance.discountAmount,
      'message': instance.message,
      'errorCode': instance.errorCode,
    };

_$PromoApplicationImpl _$$PromoApplicationImplFromJson(
        Map<String, dynamic> json) =>
    _$PromoApplicationImpl(
      promoCodeId: json['promoCodeId'] as String,
      tripId: json['tripId'] as String,
      discountAmount: (json['discountAmount'] as num?)?.toDouble() ?? 0.0,
      appliedAt: DateTime.parse(json['appliedAt'] as String),
    );

Map<String, dynamic> _$$PromoApplicationImplToJson(
        _$PromoApplicationImpl instance) =>
    <String, dynamic>{
      'promoCodeId': instance.promoCodeId,
      'tripId': instance.tripId,
      'discountAmount': instance.discountAmount,
      'appliedAt': instance.appliedAt.toIso8601String(),
    };
