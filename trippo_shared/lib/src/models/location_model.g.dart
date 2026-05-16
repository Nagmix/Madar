// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'location_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$LocationModelImpl _$$LocationModelImplFromJson(Map<String, dynamic> json) =>
    _$LocationModelImpl(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      address: json['address'] as String?,
      name: json['name'] as String?,
      placeId: json['placeId'] as String?,
      accuracy: (json['accuracy'] as num?)?.toDouble(),
      heading: (json['heading'] as num?)?.toDouble(),
      speed: (json['speed'] as num?)?.toDouble(),
      timestamp: json['timestamp'] == null
          ? null
          : DateTime.parse(json['timestamp'] as String),
    );

Map<String, dynamic> _$$LocationModelImplToJson(_$LocationModelImpl instance) =>
    <String, dynamic>{
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'address': instance.address,
      'name': instance.name,
      'placeId': instance.placeId,
      'accuracy': instance.accuracy,
      'heading': instance.heading,
      'speed': instance.speed,
      'timestamp': instance.timestamp?.toIso8601String(),
    };

_$GeoBoundsImpl _$$GeoBoundsImplFromJson(Map<String, dynamic> json) =>
    _$GeoBoundsImpl(
      northeastLat: (json['northeastLat'] as num).toDouble(),
      northeastLng: (json['northeastLng'] as num).toDouble(),
      southwestLat: (json['southwestLat'] as num).toDouble(),
      southwestLng: (json['southwestLng'] as num).toDouble(),
    );

Map<String, dynamic> _$$GeoBoundsImplToJson(_$GeoBoundsImpl instance) =>
    <String, dynamic>{
      'northeastLat': instance.northeastLat,
      'northeastLng': instance.northeastLng,
      'southwestLat': instance.southwestLat,
      'southwestLng': instance.southwestLng,
    };

_$GeoFenceImpl _$$GeoFenceImplFromJson(Map<String, dynamic> json) =>
    _$GeoFenceImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      polygon: (json['polygon'] as List<dynamic>)
          .map((e) => LocationModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      type: $enumDecode(_$GeoFenceTypeEnumMap, json['type']),
      pricingMultiplier: (json['pricingMultiplier'] as num?)?.toDouble(),
      isActive: json['isActive'] as bool?,
    );

Map<String, dynamic> _$$GeoFenceImplToJson(_$GeoFenceImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'polygon': instance.polygon,
      'type': _$GeoFenceTypeEnumMap[instance.type]!,
      'pricingMultiplier': instance.pricingMultiplier,
      'isActive': instance.isActive,
    };

const _$GeoFenceTypeEnumMap = {
  GeoFenceType.serviceArea: 'service_area',
  GeoFenceType.restricted: 'restricted',
  GeoFenceType.surgeZone: 'surge_zone',
  GeoFenceType.airport: 'airport',
  GeoFenceType.custom: 'custom',
};

_$RouteInfoImpl _$$RouteInfoImplFromJson(Map<String, dynamic> json) =>
    _$RouteInfoImpl(
      origin: LocationModel.fromJson(json['origin'] as Map<String, dynamic>),
      destination:
          LocationModel.fromJson(json['destination'] as Map<String, dynamic>),
      distanceMeters: (json['distanceMeters'] as num).toInt(),
      durationSeconds: (json['durationSeconds'] as num).toInt(),
      encodedPolyline: json['encodedPolyline'] as String,
      distanceText: json['distanceText'] as String?,
      durationText: json['durationText'] as String?,
      steps: (json['steps'] as List<dynamic>?)
          ?.map((e) => RouteStep.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$RouteInfoImplToJson(_$RouteInfoImpl instance) =>
    <String, dynamic>{
      'origin': instance.origin,
      'destination': instance.destination,
      'distanceMeters': instance.distanceMeters,
      'durationSeconds': instance.durationSeconds,
      'encodedPolyline': instance.encodedPolyline,
      'distanceText': instance.distanceText,
      'durationText': instance.durationText,
      'steps': instance.steps,
    };

_$RouteStepImpl _$$RouteStepImplFromJson(Map<String, dynamic> json) =>
    _$RouteStepImpl(
      instruction: json['instruction'] as String,
      distanceMeters: (json['distanceMeters'] as num).toInt(),
      durationSeconds: (json['durationSeconds'] as num).toInt(),
      startLocation:
          LocationModel.fromJson(json['startLocation'] as Map<String, dynamic>),
      endLocation:
          LocationModel.fromJson(json['endLocation'] as Map<String, dynamic>),
      maneuver: json['maneuver'] as String?,
    );

Map<String, dynamic> _$$RouteStepImplToJson(_$RouteStepImpl instance) =>
    <String, dynamic>{
      'instruction': instance.instruction,
      'distanceMeters': instance.distanceMeters,
      'durationSeconds': instance.durationSeconds,
      'startLocation': instance.startLocation,
      'endLocation': instance.endLocation,
      'maneuver': instance.maneuver,
    };
