// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vehicle_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$VehicleModelImpl _$$VehicleModelImplFromJson(Map<String, dynamic> json) =>
    _$VehicleModelImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      plateNumber: json['plateNumber'] as String,
      type: $enumDecode(_$VehicleTypeEnumMap, json['type']),
      seats: (json['seats'] as num).toInt(),
      color: json['color'] as String?,
      model: json['model'] as String?,
      year: json['year'] as String?,
      imageUrl: json['imageUrl'] as String?,
      isApproved: json['isApproved'] as bool? ?? false,
    );

Map<String, dynamic> _$$VehicleModelImplToJson(_$VehicleModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'plateNumber': instance.plateNumber,
      'type': _$VehicleTypeEnumMap[instance.type]!,
      'seats': instance.seats,
      'color': instance.color,
      'model': instance.model,
      'year': instance.year,
      'imageUrl': instance.imageUrl,
      'isApproved': instance.isApproved,
    };

const _$VehicleTypeEnumMap = {
  VehicleType.motorcycle: 'motorcycle',
  VehicleType.sedan: 'sedan',
  VehicleType.suv: 'suv',
  VehicleType.van: 'van',
  VehicleType.luxury: 'luxury',
};

_$VehicleTypeInfoImpl _$$VehicleTypeInfoImplFromJson(
        Map<String, dynamic> json) =>
    _$VehicleTypeInfoImpl(
      type: $enumDecode(_$VehicleTypeEnumMap, json['type']),
      displayName: json['displayName'] as String,
      description: json['description'] as String,
      baseFare: (json['baseFare'] as num).toDouble(),
      perKmRate: (json['perKmRate'] as num).toDouble(),
      perMinuteRate: (json['perMinuteRate'] as num).toDouble(),
      minimumFare: (json['minimumFare'] as num).toDouble(),
      estimatedArrivalMinutes: (json['estimatedArrivalMinutes'] as num).toInt(),
      iconAsset: json['iconAsset'] as String,
    );

Map<String, dynamic> _$$VehicleTypeInfoImplToJson(
        _$VehicleTypeInfoImpl instance) =>
    <String, dynamic>{
      'type': _$VehicleTypeEnumMap[instance.type]!,
      'displayName': instance.displayName,
      'description': instance.description,
      'baseFare': instance.baseFare,
      'perKmRate': instance.perKmRate,
      'perMinuteRate': instance.perMinuteRate,
      'minimumFare': instance.minimumFare,
      'estimatedArrivalMinutes': instance.estimatedArrivalMinutes,
      'iconAsset': instance.iconAsset,
    };
