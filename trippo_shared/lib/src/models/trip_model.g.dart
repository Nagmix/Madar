// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trip_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TripModelImpl _$$TripModelImplFromJson(Map<String, dynamic> json) =>
    _$TripModelImpl(
      id: json['id'] as String,
      riderId: json['riderId'] as String,
      pickupLocation: LocationModel.fromJson(
          json['pickupLocation'] as Map<String, dynamic>),
      dropoffLocation: LocationModel.fromJson(
          json['dropoffLocation'] as Map<String, dynamic>),
      state: $enumDecodeNullable(_$TripStateEnumMap, json['state']) ??
          TripState.searchingDriver,
      driverId: json['driverId'] as String?,
      driver: json['driver'] == null
          ? null
          : DriverModel.fromJson(json['driver'] as Map<String, dynamic>),
      rider: json['rider'] == null
          ? null
          : UserModel.fromJson(json['rider'] as Map<String, dynamic>),
      stateLog: (json['stateLog'] as List<dynamic>?)
              ?.map((e) => TripStateLog.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      routeInfo: json['routeInfo'] == null
          ? null
          : RouteInfo.fromJson(json['routeInfo'] as Map<String, dynamic>),
      fareBreakdown: json['fareBreakdown'] == null
          ? null
          : FareBreakdown.fromJson(
              json['fareBreakdown'] as Map<String, dynamic>),
      estimatedDurationMinutes:
          (json['estimatedDurationMinutes'] as num?)?.toInt() ?? 0,
      estimatedDistanceKm:
          (json['estimatedDistanceKm'] as num?)?.toDouble() ?? 0.0,
      cancellationReason: json['cancellationReason'] as String?,
      cancelledBy:
          $enumDecodeNullable(_$CancelledByEnumMap, json['cancelledBy']),
      riderRating: (json['riderRating'] as num?)?.toDouble() ?? 0.0,
      driverRating: (json['driverRating'] as num?)?.toDouble() ?? 0.0,
      riderReview: json['riderReview'] as String?,
      driverReview: json['driverReview'] as String?,
      vehicleType: json['vehicleType'] as String? ?? '',
      driverAssignedAt: json['driverAssignedAt'] == null
          ? null
          : DateTime.parse(json['driverAssignedAt'] as String),
      driverArrivedAt: json['driverArrivedAt'] == null
          ? null
          : DateTime.parse(json['driverArrivedAt'] as String),
      tripStartedAt: json['tripStartedAt'] == null
          ? null
          : DateTime.parse(json['tripStartedAt'] as String),
      tripCompletedAt: json['tripCompletedAt'] == null
          ? null
          : DateTime.parse(json['tripCompletedAt'] as String),
      cancelledAt: json['cancelledAt'] == null
          ? null
          : DateTime.parse(json['cancelledAt'] as String),
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$TripModelImplToJson(_$TripModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'riderId': instance.riderId,
      'pickupLocation': instance.pickupLocation,
      'dropoffLocation': instance.dropoffLocation,
      'state': _$TripStateEnumMap[instance.state]!,
      'driverId': instance.driverId,
      'driver': instance.driver,
      'rider': instance.rider,
      'stateLog': instance.stateLog,
      'routeInfo': instance.routeInfo,
      'fareBreakdown': instance.fareBreakdown,
      'estimatedDurationMinutes': instance.estimatedDurationMinutes,
      'estimatedDistanceKm': instance.estimatedDistanceKm,
      'cancellationReason': instance.cancellationReason,
      'cancelledBy': _$CancelledByEnumMap[instance.cancelledBy],
      'riderRating': instance.riderRating,
      'driverRating': instance.driverRating,
      'riderReview': instance.riderReview,
      'driverReview': instance.driverReview,
      'vehicleType': instance.vehicleType,
      'driverAssignedAt': instance.driverAssignedAt?.toIso8601String(),
      'driverArrivedAt': instance.driverArrivedAt?.toIso8601String(),
      'tripStartedAt': instance.tripStartedAt?.toIso8601String(),
      'tripCompletedAt': instance.tripCompletedAt?.toIso8601String(),
      'cancelledAt': instance.cancelledAt?.toIso8601String(),
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

const _$TripStateEnumMap = {
  TripState.searchingDriver: 'searchingDriver',
  TripState.driverAssigned: 'driverAssigned',
  TripState.driverArriving: 'driverArriving',
  TripState.driverArrived: 'driverArrived',
  TripState.tripStarted: 'tripStarted',
  TripState.tripPaused: 'tripPaused',
  TripState.tripResumed: 'tripResumed',
  TripState.tripCompleted: 'tripCompleted',
  TripState.paymentPending: 'paymentPending',
  TripState.paymentCompleted: 'paymentCompleted',
  TripState.tripCancelled: 'tripCancelled',
};

const _$CancelledByEnumMap = {
  CancelledBy.rider: 'rider',
  CancelledBy.driver: 'driver',
  CancelledBy.system: 'system',
  CancelledBy.timeout: 'timeout',
};

_$TripStateLogImpl _$$TripStateLogImplFromJson(Map<String, dynamic> json) =>
    _$TripStateLogImpl(
      state: $enumDecode(_$TripStateEnumMap, json['state']),
      timestamp: DateTime.parse(json['timestamp'] as String),
      changedBy: json['changedBy'] as String?,
      reason: json['reason'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$$TripStateLogImplToJson(_$TripStateLogImpl instance) =>
    <String, dynamic>{
      'state': _$TripStateEnumMap[instance.state]!,
      'timestamp': instance.timestamp.toIso8601String(),
      'changedBy': instance.changedBy,
      'reason': instance.reason,
      'metadata': instance.metadata,
    };

_$CreateTripRequestImpl _$$CreateTripRequestImplFromJson(
        Map<String, dynamic> json) =>
    _$CreateTripRequestImpl(
      pickupLatitude: (json['pickupLatitude'] as num).toDouble(),
      pickupLongitude: (json['pickupLongitude'] as num).toDouble(),
      pickupAddress: json['pickupAddress'] as String,
      dropoffLatitude: (json['dropoffLatitude'] as num).toDouble(),
      dropoffLongitude: (json['dropoffLongitude'] as num).toDouble(),
      dropoffAddress: json['dropoffAddress'] as String,
      vehicleType: json['vehicleType'] as String,
      promoCode: json['promoCode'] as String?,
      note: json['note'] as String?,
      scheduleForLater: json['scheduleForLater'] as bool? ?? false,
      scheduledAt: json['scheduledAt'] == null
          ? null
          : DateTime.parse(json['scheduledAt'] as String),
    );

Map<String, dynamic> _$$CreateTripRequestImplToJson(
        _$CreateTripRequestImpl instance) =>
    <String, dynamic>{
      'pickupLatitude': instance.pickupLatitude,
      'pickupLongitude': instance.pickupLongitude,
      'pickupAddress': instance.pickupAddress,
      'dropoffLatitude': instance.dropoffLatitude,
      'dropoffLongitude': instance.dropoffLongitude,
      'dropoffAddress': instance.dropoffAddress,
      'vehicleType': instance.vehicleType,
      'promoCode': instance.promoCode,
      'note': instance.note,
      'scheduleForLater': instance.scheduleForLater,
      'scheduledAt': instance.scheduledAt?.toIso8601String(),
    };

_$TripRatingRequestImpl _$$TripRatingRequestImplFromJson(
        Map<String, dynamic> json) =>
    _$TripRatingRequestImpl(
      rating: (json['rating'] as num).toDouble(),
      review: json['review'] as String?,
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList(),
    );

Map<String, dynamic> _$$TripRatingRequestImplToJson(
        _$TripRatingRequestImpl instance) =>
    <String, dynamic>{
      'rating': instance.rating,
      'review': instance.review,
      'tags': instance.tags,
    };

_$TripSummaryImpl _$$TripSummaryImplFromJson(Map<String, dynamic> json) =>
    _$TripSummaryImpl(
      id: json['id'] as String,
      pickupAddress: json['pickupAddress'] as String,
      dropoffAddress: json['dropoffAddress'] as String,
      state: $enumDecode(_$TripStateEnumMap, json['state']),
      fare: (json['fare'] as num).toDouble(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      driverName: json['driverName'] as String?,
      vehicleType: json['vehicleType'] as String?,
      rating: (json['rating'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$$TripSummaryImplToJson(_$TripSummaryImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'pickupAddress': instance.pickupAddress,
      'dropoffAddress': instance.dropoffAddress,
      'state': _$TripStateEnumMap[instance.state]!,
      'fare': instance.fare,
      'createdAt': instance.createdAt.toIso8601String(),
      'driverName': instance.driverName,
      'vehicleType': instance.vehicleType,
      'rating': instance.rating,
    };
