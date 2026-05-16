// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dispatch_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DispatchRequestImpl _$$DispatchRequestImplFromJson(
        Map<String, dynamic> json) =>
    _$DispatchRequestImpl(
      tripId: json['tripId'] as String,
      pickupLatitude: (json['pickupLatitude'] as num).toDouble(),
      pickupLongitude: (json['pickupLongitude'] as num).toDouble(),
      dropoffLatitude: (json['dropoffLatitude'] as num).toDouble(),
      dropoffLongitude: (json['dropoffLongitude'] as num).toDouble(),
      vehicleType: json['vehicleType'] as String,
      riderId: json['riderId'] as String,
      retryCount: (json['retryCount'] as num?)?.toInt() ?? 1,
      status: $enumDecodeNullable(_$DispatchStatusEnumMap, json['status']) ??
          DispatchStatus.pending,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$DispatchRequestImplToJson(
        _$DispatchRequestImpl instance) =>
    <String, dynamic>{
      'tripId': instance.tripId,
      'pickupLatitude': instance.pickupLatitude,
      'pickupLongitude': instance.pickupLongitude,
      'dropoffLatitude': instance.dropoffLatitude,
      'dropoffLongitude': instance.dropoffLongitude,
      'vehicleType': instance.vehicleType,
      'riderId': instance.riderId,
      'retryCount': instance.retryCount,
      'status': _$DispatchStatusEnumMap[instance.status]!,
      'createdAt': instance.createdAt?.toIso8601String(),
    };

const _$DispatchStatusEnumMap = {
  DispatchStatus.pending: 'pending',
  DispatchStatus.searching: 'searching',
  DispatchStatus.driverNotified: 'driver_notified',
  DispatchStatus.driverAccepted: 'driver_accepted',
  DispatchStatus.allDriversBusy: 'all_drivers_busy',
  DispatchStatus.timeout: 'timeout',
  DispatchStatus.cancelled: 'cancelled',
};

_$DispatchResultImpl _$$DispatchResultImplFromJson(Map<String, dynamic> json) =>
    _$DispatchResultImpl(
      tripId: json['tripId'] as String,
      status: $enumDecode(_$DispatchStatusEnumMap, json['status']),
      assignedDriver: json['assignedDriver'] == null
          ? null
          : DriverModel.fromJson(
              json['assignedDriver'] as Map<String, dynamic>),
      driverScore: json['driverScore'] == null
          ? null
          : DriverScore.fromJson(json['driverScore'] as Map<String, dynamic>),
      notifiedDriverIds: (json['notifiedDriverIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      rejectedDriverIds: (json['rejectedDriverIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      failureReason: json['failureReason'] as String?,
      searchDurationSeconds: (json['searchDurationSeconds'] as num?)?.toInt(),
    );

Map<String, dynamic> _$$DispatchResultImplToJson(
        _$DispatchResultImpl instance) =>
    <String, dynamic>{
      'tripId': instance.tripId,
      'status': _$DispatchStatusEnumMap[instance.status]!,
      'assignedDriver': instance.assignedDriver,
      'driverScore': instance.driverScore,
      'notifiedDriverIds': instance.notifiedDriverIds,
      'rejectedDriverIds': instance.rejectedDriverIds,
      'failureReason': instance.failureReason,
      'searchDurationSeconds': instance.searchDurationSeconds,
    };

_$DriverDispatchNotificationImpl _$$DriverDispatchNotificationImplFromJson(
        Map<String, dynamic> json) =>
    _$DriverDispatchNotificationImpl(
      tripId: json['tripId'] as String,
      riderName: json['riderName'] as String,
      pickupLatitude: (json['pickupLatitude'] as num).toDouble(),
      pickupLongitude: (json['pickupLongitude'] as num).toDouble(),
      pickupAddress: json['pickupAddress'] as String,
      dropoffLatitude: (json['dropoffLatitude'] as num).toDouble(),
      dropoffLongitude: (json['dropoffLongitude'] as num).toDouble(),
      dropoffAddress: json['dropoffAddress'] as String,
      estimatedFare: (json['estimatedFare'] as num).toDouble(),
      distanceToPickupKm: (json['distanceToPickupKm'] as num).toDouble(),
      estimatedEtaMinutes: (json['estimatedEtaMinutes'] as num).toInt(),
      vehicleType: json['vehicleType'] as String,
      responseTimeoutSeconds: (json['responseTimeoutSeconds'] as num).toInt(),
    );

Map<String, dynamic> _$$DriverDispatchNotificationImplToJson(
        _$DriverDispatchNotificationImpl instance) =>
    <String, dynamic>{
      'tripId': instance.tripId,
      'riderName': instance.riderName,
      'pickupLatitude': instance.pickupLatitude,
      'pickupLongitude': instance.pickupLongitude,
      'pickupAddress': instance.pickupAddress,
      'dropoffLatitude': instance.dropoffLatitude,
      'dropoffLongitude': instance.dropoffLongitude,
      'dropoffAddress': instance.dropoffAddress,
      'estimatedFare': instance.estimatedFare,
      'distanceToPickupKm': instance.distanceToPickupKm,
      'estimatedEtaMinutes': instance.estimatedEtaMinutes,
      'vehicleType': instance.vehicleType,
      'responseTimeoutSeconds': instance.responseTimeoutSeconds,
    };

_$DriverDispatchResponseImpl _$$DriverDispatchResponseImplFromJson(
        Map<String, dynamic> json) =>
    _$DriverDispatchResponseImpl(
      tripId: json['tripId'] as String,
      driverId: json['driverId'] as String,
      responseType:
          $enumDecode(_$DispatchResponseTypeEnumMap, json['responseType']),
      reason: json['reason'] as String?,
    );

Map<String, dynamic> _$$DriverDispatchResponseImplToJson(
        _$DriverDispatchResponseImpl instance) =>
    <String, dynamic>{
      'tripId': instance.tripId,
      'driverId': instance.driverId,
      'responseType': _$DispatchResponseTypeEnumMap[instance.responseType]!,
      'reason': instance.reason,
    };

const _$DispatchResponseTypeEnumMap = {
  DispatchResponseType.accepted: 'accepted',
  DispatchResponseType.rejected: 'rejected',
  DispatchResponseType.timeout: 'timeout',
  DispatchResponseType.ignored: 'ignored',
};
