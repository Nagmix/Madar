// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'trip_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

TripModel _$TripModelFromJson(Map<String, dynamic> json) {
  return _TripModel.fromJson(json);
}

/// @nodoc
mixin _$TripModel {
  String get id => throw _privateConstructorUsedError;
  String get riderId => throw _privateConstructorUsedError;
  LocationModel get pickupLocation => throw _privateConstructorUsedError;
  LocationModel get dropoffLocation => throw _privateConstructorUsedError;
  TripState get state => throw _privateConstructorUsedError;
  String? get driverId => throw _privateConstructorUsedError;
  DriverModel? get driver => throw _privateConstructorUsedError;
  UserModel? get rider => throw _privateConstructorUsedError;
  List<TripStateLog> get stateLog => throw _privateConstructorUsedError;
  RouteInfo? get routeInfo => throw _privateConstructorUsedError;
  FareBreakdown? get fareBreakdown => throw _privateConstructorUsedError;
  int get estimatedDurationMinutes => throw _privateConstructorUsedError;
  double get estimatedDistanceKm => throw _privateConstructorUsedError;
  String? get cancellationReason => throw _privateConstructorUsedError;
  CancelledBy? get cancelledBy => throw _privateConstructorUsedError;
  double get riderRating => throw _privateConstructorUsedError;
  double get driverRating => throw _privateConstructorUsedError;
  String? get riderReview => throw _privateConstructorUsedError;
  String? get driverReview => throw _privateConstructorUsedError;
  String get vehicleType => throw _privateConstructorUsedError;
  DateTime? get driverAssignedAt => throw _privateConstructorUsedError;
  DateTime? get driverArrivedAt => throw _privateConstructorUsedError;
  DateTime? get tripStartedAt => throw _privateConstructorUsedError;
  DateTime? get tripCompletedAt => throw _privateConstructorUsedError;
  DateTime? get cancelledAt => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this TripModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TripModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TripModelCopyWith<TripModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TripModelCopyWith<$Res> {
  factory $TripModelCopyWith(TripModel value, $Res Function(TripModel) then) =
      _$TripModelCopyWithImpl<$Res, TripModel>;
  @useResult
  $Res call(
      {String id,
      String riderId,
      LocationModel pickupLocation,
      LocationModel dropoffLocation,
      TripState state,
      String? driverId,
      DriverModel? driver,
      UserModel? rider,
      List<TripStateLog> stateLog,
      RouteInfo? routeInfo,
      FareBreakdown? fareBreakdown,
      int estimatedDurationMinutes,
      double estimatedDistanceKm,
      String? cancellationReason,
      CancelledBy? cancelledBy,
      double riderRating,
      double driverRating,
      String? riderReview,
      String? driverReview,
      String vehicleType,
      DateTime? driverAssignedAt,
      DateTime? driverArrivedAt,
      DateTime? tripStartedAt,
      DateTime? tripCompletedAt,
      DateTime? cancelledAt,
      DateTime? createdAt,
      DateTime? updatedAt});

  $LocationModelCopyWith<$Res> get pickupLocation;
  $LocationModelCopyWith<$Res> get dropoffLocation;
  $DriverModelCopyWith<$Res>? get driver;
  $UserModelCopyWith<$Res>? get rider;
  $RouteInfoCopyWith<$Res>? get routeInfo;
  $FareBreakdownCopyWith<$Res>? get fareBreakdown;
}

/// @nodoc
class _$TripModelCopyWithImpl<$Res, $Val extends TripModel>
    implements $TripModelCopyWith<$Res> {
  _$TripModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TripModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? riderId = null,
    Object? pickupLocation = null,
    Object? dropoffLocation = null,
    Object? state = null,
    Object? driverId = freezed,
    Object? driver = freezed,
    Object? rider = freezed,
    Object? stateLog = null,
    Object? routeInfo = freezed,
    Object? fareBreakdown = freezed,
    Object? estimatedDurationMinutes = null,
    Object? estimatedDistanceKm = null,
    Object? cancellationReason = freezed,
    Object? cancelledBy = freezed,
    Object? riderRating = null,
    Object? driverRating = null,
    Object? riderReview = freezed,
    Object? driverReview = freezed,
    Object? vehicleType = null,
    Object? driverAssignedAt = freezed,
    Object? driverArrivedAt = freezed,
    Object? tripStartedAt = freezed,
    Object? tripCompletedAt = freezed,
    Object? cancelledAt = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      riderId: null == riderId
          ? _value.riderId
          : riderId // ignore: cast_nullable_to_non_nullable
              as String,
      pickupLocation: null == pickupLocation
          ? _value.pickupLocation
          : pickupLocation // ignore: cast_nullable_to_non_nullable
              as LocationModel,
      dropoffLocation: null == dropoffLocation
          ? _value.dropoffLocation
          : dropoffLocation // ignore: cast_nullable_to_non_nullable
              as LocationModel,
      state: null == state
          ? _value.state
          : state // ignore: cast_nullable_to_non_nullable
              as TripState,
      driverId: freezed == driverId
          ? _value.driverId
          : driverId // ignore: cast_nullable_to_non_nullable
              as String?,
      driver: freezed == driver
          ? _value.driver
          : driver // ignore: cast_nullable_to_non_nullable
              as DriverModel?,
      rider: freezed == rider
          ? _value.rider
          : rider // ignore: cast_nullable_to_non_nullable
              as UserModel?,
      stateLog: null == stateLog
          ? _value.stateLog
          : stateLog // ignore: cast_nullable_to_non_nullable
              as List<TripStateLog>,
      routeInfo: freezed == routeInfo
          ? _value.routeInfo
          : routeInfo // ignore: cast_nullable_to_non_nullable
              as RouteInfo?,
      fareBreakdown: freezed == fareBreakdown
          ? _value.fareBreakdown
          : fareBreakdown // ignore: cast_nullable_to_non_nullable
              as FareBreakdown?,
      estimatedDurationMinutes: null == estimatedDurationMinutes
          ? _value.estimatedDurationMinutes
          : estimatedDurationMinutes // ignore: cast_nullable_to_non_nullable
              as int,
      estimatedDistanceKm: null == estimatedDistanceKm
          ? _value.estimatedDistanceKm
          : estimatedDistanceKm // ignore: cast_nullable_to_non_nullable
              as double,
      cancellationReason: freezed == cancellationReason
          ? _value.cancellationReason
          : cancellationReason // ignore: cast_nullable_to_non_nullable
              as String?,
      cancelledBy: freezed == cancelledBy
          ? _value.cancelledBy
          : cancelledBy // ignore: cast_nullable_to_non_nullable
              as CancelledBy?,
      riderRating: null == riderRating
          ? _value.riderRating
          : riderRating // ignore: cast_nullable_to_non_nullable
              as double,
      driverRating: null == driverRating
          ? _value.driverRating
          : driverRating // ignore: cast_nullable_to_non_nullable
              as double,
      riderReview: freezed == riderReview
          ? _value.riderReview
          : riderReview // ignore: cast_nullable_to_non_nullable
              as String?,
      driverReview: freezed == driverReview
          ? _value.driverReview
          : driverReview // ignore: cast_nullable_to_non_nullable
              as String?,
      vehicleType: null == vehicleType
          ? _value.vehicleType
          : vehicleType // ignore: cast_nullable_to_non_nullable
              as String,
      driverAssignedAt: freezed == driverAssignedAt
          ? _value.driverAssignedAt
          : driverAssignedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      driverArrivedAt: freezed == driverArrivedAt
          ? _value.driverArrivedAt
          : driverArrivedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      tripStartedAt: freezed == tripStartedAt
          ? _value.tripStartedAt
          : tripStartedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      tripCompletedAt: freezed == tripCompletedAt
          ? _value.tripCompletedAt
          : tripCompletedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      cancelledAt: freezed == cancelledAt
          ? _value.cancelledAt
          : cancelledAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }

  /// Create a copy of TripModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $LocationModelCopyWith<$Res> get pickupLocation {
    return $LocationModelCopyWith<$Res>(_value.pickupLocation, (value) {
      return _then(_value.copyWith(pickupLocation: value) as $Val);
    });
  }

  /// Create a copy of TripModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $LocationModelCopyWith<$Res> get dropoffLocation {
    return $LocationModelCopyWith<$Res>(_value.dropoffLocation, (value) {
      return _then(_value.copyWith(dropoffLocation: value) as $Val);
    });
  }

  /// Create a copy of TripModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $DriverModelCopyWith<$Res>? get driver {
    if (_value.driver == null) {
      return null;
    }

    return $DriverModelCopyWith<$Res>(_value.driver!, (value) {
      return _then(_value.copyWith(driver: value) as $Val);
    });
  }

  /// Create a copy of TripModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $UserModelCopyWith<$Res>? get rider {
    if (_value.rider == null) {
      return null;
    }

    return $UserModelCopyWith<$Res>(_value.rider!, (value) {
      return _then(_value.copyWith(rider: value) as $Val);
    });
  }

  /// Create a copy of TripModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $RouteInfoCopyWith<$Res>? get routeInfo {
    if (_value.routeInfo == null) {
      return null;
    }

    return $RouteInfoCopyWith<$Res>(_value.routeInfo!, (value) {
      return _then(_value.copyWith(routeInfo: value) as $Val);
    });
  }

  /// Create a copy of TripModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $FareBreakdownCopyWith<$Res>? get fareBreakdown {
    if (_value.fareBreakdown == null) {
      return null;
    }

    return $FareBreakdownCopyWith<$Res>(_value.fareBreakdown!, (value) {
      return _then(_value.copyWith(fareBreakdown: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$TripModelImplCopyWith<$Res>
    implements $TripModelCopyWith<$Res> {
  factory _$$TripModelImplCopyWith(
          _$TripModelImpl value, $Res Function(_$TripModelImpl) then) =
      __$$TripModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String riderId,
      LocationModel pickupLocation,
      LocationModel dropoffLocation,
      TripState state,
      String? driverId,
      DriverModel? driver,
      UserModel? rider,
      List<TripStateLog> stateLog,
      RouteInfo? routeInfo,
      FareBreakdown? fareBreakdown,
      int estimatedDurationMinutes,
      double estimatedDistanceKm,
      String? cancellationReason,
      CancelledBy? cancelledBy,
      double riderRating,
      double driverRating,
      String? riderReview,
      String? driverReview,
      String vehicleType,
      DateTime? driverAssignedAt,
      DateTime? driverArrivedAt,
      DateTime? tripStartedAt,
      DateTime? tripCompletedAt,
      DateTime? cancelledAt,
      DateTime? createdAt,
      DateTime? updatedAt});

  @override
  $LocationModelCopyWith<$Res> get pickupLocation;
  @override
  $LocationModelCopyWith<$Res> get dropoffLocation;
  @override
  $DriverModelCopyWith<$Res>? get driver;
  @override
  $UserModelCopyWith<$Res>? get rider;
  @override
  $RouteInfoCopyWith<$Res>? get routeInfo;
  @override
  $FareBreakdownCopyWith<$Res>? get fareBreakdown;
}

/// @nodoc
class __$$TripModelImplCopyWithImpl<$Res>
    extends _$TripModelCopyWithImpl<$Res, _$TripModelImpl>
    implements _$$TripModelImplCopyWith<$Res> {
  __$$TripModelImplCopyWithImpl(
      _$TripModelImpl _value, $Res Function(_$TripModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of TripModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? riderId = null,
    Object? pickupLocation = null,
    Object? dropoffLocation = null,
    Object? state = null,
    Object? driverId = freezed,
    Object? driver = freezed,
    Object? rider = freezed,
    Object? stateLog = null,
    Object? routeInfo = freezed,
    Object? fareBreakdown = freezed,
    Object? estimatedDurationMinutes = null,
    Object? estimatedDistanceKm = null,
    Object? cancellationReason = freezed,
    Object? cancelledBy = freezed,
    Object? riderRating = null,
    Object? driverRating = null,
    Object? riderReview = freezed,
    Object? driverReview = freezed,
    Object? vehicleType = null,
    Object? driverAssignedAt = freezed,
    Object? driverArrivedAt = freezed,
    Object? tripStartedAt = freezed,
    Object? tripCompletedAt = freezed,
    Object? cancelledAt = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_$TripModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      riderId: null == riderId
          ? _value.riderId
          : riderId // ignore: cast_nullable_to_non_nullable
              as String,
      pickupLocation: null == pickupLocation
          ? _value.pickupLocation
          : pickupLocation // ignore: cast_nullable_to_non_nullable
              as LocationModel,
      dropoffLocation: null == dropoffLocation
          ? _value.dropoffLocation
          : dropoffLocation // ignore: cast_nullable_to_non_nullable
              as LocationModel,
      state: null == state
          ? _value.state
          : state // ignore: cast_nullable_to_non_nullable
              as TripState,
      driverId: freezed == driverId
          ? _value.driverId
          : driverId // ignore: cast_nullable_to_non_nullable
              as String?,
      driver: freezed == driver
          ? _value.driver
          : driver // ignore: cast_nullable_to_non_nullable
              as DriverModel?,
      rider: freezed == rider
          ? _value.rider
          : rider // ignore: cast_nullable_to_non_nullable
              as UserModel?,
      stateLog: null == stateLog
          ? _value._stateLog
          : stateLog // ignore: cast_nullable_to_non_nullable
              as List<TripStateLog>,
      routeInfo: freezed == routeInfo
          ? _value.routeInfo
          : routeInfo // ignore: cast_nullable_to_non_nullable
              as RouteInfo?,
      fareBreakdown: freezed == fareBreakdown
          ? _value.fareBreakdown
          : fareBreakdown // ignore: cast_nullable_to_non_nullable
              as FareBreakdown?,
      estimatedDurationMinutes: null == estimatedDurationMinutes
          ? _value.estimatedDurationMinutes
          : estimatedDurationMinutes // ignore: cast_nullable_to_non_nullable
              as int,
      estimatedDistanceKm: null == estimatedDistanceKm
          ? _value.estimatedDistanceKm
          : estimatedDistanceKm // ignore: cast_nullable_to_non_nullable
              as double,
      cancellationReason: freezed == cancellationReason
          ? _value.cancellationReason
          : cancellationReason // ignore: cast_nullable_to_non_nullable
              as String?,
      cancelledBy: freezed == cancelledBy
          ? _value.cancelledBy
          : cancelledBy // ignore: cast_nullable_to_non_nullable
              as CancelledBy?,
      riderRating: null == riderRating
          ? _value.riderRating
          : riderRating // ignore: cast_nullable_to_non_nullable
              as double,
      driverRating: null == driverRating
          ? _value.driverRating
          : driverRating // ignore: cast_nullable_to_non_nullable
              as double,
      riderReview: freezed == riderReview
          ? _value.riderReview
          : riderReview // ignore: cast_nullable_to_non_nullable
              as String?,
      driverReview: freezed == driverReview
          ? _value.driverReview
          : driverReview // ignore: cast_nullable_to_non_nullable
              as String?,
      vehicleType: null == vehicleType
          ? _value.vehicleType
          : vehicleType // ignore: cast_nullable_to_non_nullable
              as String,
      driverAssignedAt: freezed == driverAssignedAt
          ? _value.driverAssignedAt
          : driverAssignedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      driverArrivedAt: freezed == driverArrivedAt
          ? _value.driverArrivedAt
          : driverArrivedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      tripStartedAt: freezed == tripStartedAt
          ? _value.tripStartedAt
          : tripStartedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      tripCompletedAt: freezed == tripCompletedAt
          ? _value.tripCompletedAt
          : tripCompletedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      cancelledAt: freezed == cancelledAt
          ? _value.cancelledAt
          : cancelledAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TripModelImpl implements _TripModel {
  const _$TripModelImpl(
      {required this.id,
      required this.riderId,
      required this.pickupLocation,
      required this.dropoffLocation,
      this.state = TripState.searchingDriver,
      this.driverId,
      this.driver,
      this.rider,
      final List<TripStateLog> stateLog = const [],
      this.routeInfo,
      this.fareBreakdown,
      this.estimatedDurationMinutes = 0,
      this.estimatedDistanceKm = 0.0,
      this.cancellationReason,
      this.cancelledBy,
      this.riderRating = 0.0,
      this.driverRating = 0.0,
      this.riderReview,
      this.driverReview,
      this.vehicleType = '',
      this.driverAssignedAt,
      this.driverArrivedAt,
      this.tripStartedAt,
      this.tripCompletedAt,
      this.cancelledAt,
      this.createdAt,
      this.updatedAt})
      : _stateLog = stateLog;

  factory _$TripModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$TripModelImplFromJson(json);

  @override
  final String id;
  @override
  final String riderId;
  @override
  final LocationModel pickupLocation;
  @override
  final LocationModel dropoffLocation;
  @override
  @JsonKey()
  final TripState state;
  @override
  final String? driverId;
  @override
  final DriverModel? driver;
  @override
  final UserModel? rider;
  final List<TripStateLog> _stateLog;
  @override
  @JsonKey()
  List<TripStateLog> get stateLog {
    if (_stateLog is EqualUnmodifiableListView) return _stateLog;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_stateLog);
  }

  @override
  final RouteInfo? routeInfo;
  @override
  final FareBreakdown? fareBreakdown;
  @override
  @JsonKey()
  final int estimatedDurationMinutes;
  @override
  @JsonKey()
  final double estimatedDistanceKm;
  @override
  final String? cancellationReason;
  @override
  final CancelledBy? cancelledBy;
  @override
  @JsonKey()
  final double riderRating;
  @override
  @JsonKey()
  final double driverRating;
  @override
  final String? riderReview;
  @override
  final String? driverReview;
  @override
  @JsonKey()
  final String vehicleType;
  @override
  final DateTime? driverAssignedAt;
  @override
  final DateTime? driverArrivedAt;
  @override
  final DateTime? tripStartedAt;
  @override
  final DateTime? tripCompletedAt;
  @override
  final DateTime? cancelledAt;
  @override
  final DateTime? createdAt;
  @override
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'TripModel(id: $id, riderId: $riderId, pickupLocation: $pickupLocation, dropoffLocation: $dropoffLocation, state: $state, driverId: $driverId, driver: $driver, rider: $rider, stateLog: $stateLog, routeInfo: $routeInfo, fareBreakdown: $fareBreakdown, estimatedDurationMinutes: $estimatedDurationMinutes, estimatedDistanceKm: $estimatedDistanceKm, cancellationReason: $cancellationReason, cancelledBy: $cancelledBy, riderRating: $riderRating, driverRating: $driverRating, riderReview: $riderReview, driverReview: $driverReview, vehicleType: $vehicleType, driverAssignedAt: $driverAssignedAt, driverArrivedAt: $driverArrivedAt, tripStartedAt: $tripStartedAt, tripCompletedAt: $tripCompletedAt, cancelledAt: $cancelledAt, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TripModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.riderId, riderId) || other.riderId == riderId) &&
            (identical(other.pickupLocation, pickupLocation) ||
                other.pickupLocation == pickupLocation) &&
            (identical(other.dropoffLocation, dropoffLocation) ||
                other.dropoffLocation == dropoffLocation) &&
            (identical(other.state, state) || other.state == state) &&
            (identical(other.driverId, driverId) ||
                other.driverId == driverId) &&
            (identical(other.driver, driver) || other.driver == driver) &&
            (identical(other.rider, rider) || other.rider == rider) &&
            const DeepCollectionEquality().equals(other._stateLog, _stateLog) &&
            (identical(other.routeInfo, routeInfo) ||
                other.routeInfo == routeInfo) &&
            (identical(other.fareBreakdown, fareBreakdown) ||
                other.fareBreakdown == fareBreakdown) &&
            (identical(
                    other.estimatedDurationMinutes, estimatedDurationMinutes) ||
                other.estimatedDurationMinutes == estimatedDurationMinutes) &&
            (identical(other.estimatedDistanceKm, estimatedDistanceKm) ||
                other.estimatedDistanceKm == estimatedDistanceKm) &&
            (identical(other.cancellationReason, cancellationReason) ||
                other.cancellationReason == cancellationReason) &&
            (identical(other.cancelledBy, cancelledBy) ||
                other.cancelledBy == cancelledBy) &&
            (identical(other.riderRating, riderRating) ||
                other.riderRating == riderRating) &&
            (identical(other.driverRating, driverRating) ||
                other.driverRating == driverRating) &&
            (identical(other.riderReview, riderReview) ||
                other.riderReview == riderReview) &&
            (identical(other.driverReview, driverReview) ||
                other.driverReview == driverReview) &&
            (identical(other.vehicleType, vehicleType) ||
                other.vehicleType == vehicleType) &&
            (identical(other.driverAssignedAt, driverAssignedAt) ||
                other.driverAssignedAt == driverAssignedAt) &&
            (identical(other.driverArrivedAt, driverArrivedAt) ||
                other.driverArrivedAt == driverArrivedAt) &&
            (identical(other.tripStartedAt, tripStartedAt) ||
                other.tripStartedAt == tripStartedAt) &&
            (identical(other.tripCompletedAt, tripCompletedAt) ||
                other.tripCompletedAt == tripCompletedAt) &&
            (identical(other.cancelledAt, cancelledAt) ||
                other.cancelledAt == cancelledAt) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        riderId,
        pickupLocation,
        dropoffLocation,
        state,
        driverId,
        driver,
        rider,
        const DeepCollectionEquality().hash(_stateLog),
        routeInfo,
        fareBreakdown,
        estimatedDurationMinutes,
        estimatedDistanceKm,
        cancellationReason,
        cancelledBy,
        riderRating,
        driverRating,
        riderReview,
        driverReview,
        vehicleType,
        driverAssignedAt,
        driverArrivedAt,
        tripStartedAt,
        tripCompletedAt,
        cancelledAt,
        createdAt,
        updatedAt
      ]);

  /// Create a copy of TripModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TripModelImplCopyWith<_$TripModelImpl> get copyWith =>
      __$$TripModelImplCopyWithImpl<_$TripModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TripModelImplToJson(
      this,
    );
  }
}

abstract class _TripModel implements TripModel {
  const factory _TripModel(
      {required final String id,
      required final String riderId,
      required final LocationModel pickupLocation,
      required final LocationModel dropoffLocation,
      final TripState state,
      final String? driverId,
      final DriverModel? driver,
      final UserModel? rider,
      final List<TripStateLog> stateLog,
      final RouteInfo? routeInfo,
      final FareBreakdown? fareBreakdown,
      final int estimatedDurationMinutes,
      final double estimatedDistanceKm,
      final String? cancellationReason,
      final CancelledBy? cancelledBy,
      final double riderRating,
      final double driverRating,
      final String? riderReview,
      final String? driverReview,
      final String vehicleType,
      final DateTime? driverAssignedAt,
      final DateTime? driverArrivedAt,
      final DateTime? tripStartedAt,
      final DateTime? tripCompletedAt,
      final DateTime? cancelledAt,
      final DateTime? createdAt,
      final DateTime? updatedAt}) = _$TripModelImpl;

  factory _TripModel.fromJson(Map<String, dynamic> json) =
      _$TripModelImpl.fromJson;

  @override
  String get id;
  @override
  String get riderId;
  @override
  LocationModel get pickupLocation;
  @override
  LocationModel get dropoffLocation;
  @override
  TripState get state;
  @override
  String? get driverId;
  @override
  DriverModel? get driver;
  @override
  UserModel? get rider;
  @override
  List<TripStateLog> get stateLog;
  @override
  RouteInfo? get routeInfo;
  @override
  FareBreakdown? get fareBreakdown;
  @override
  int get estimatedDurationMinutes;
  @override
  double get estimatedDistanceKm;
  @override
  String? get cancellationReason;
  @override
  CancelledBy? get cancelledBy;
  @override
  double get riderRating;
  @override
  double get driverRating;
  @override
  String? get riderReview;
  @override
  String? get driverReview;
  @override
  String get vehicleType;
  @override
  DateTime? get driverAssignedAt;
  @override
  DateTime? get driverArrivedAt;
  @override
  DateTime? get tripStartedAt;
  @override
  DateTime? get tripCompletedAt;
  @override
  DateTime? get cancelledAt;
  @override
  DateTime? get createdAt;
  @override
  DateTime? get updatedAt;

  /// Create a copy of TripModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TripModelImplCopyWith<_$TripModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

TripStateLog _$TripStateLogFromJson(Map<String, dynamic> json) {
  return _TripStateLog.fromJson(json);
}

/// @nodoc
mixin _$TripStateLog {
  TripState get state => throw _privateConstructorUsedError;
  DateTime get timestamp => throw _privateConstructorUsedError;
  String? get changedBy => throw _privateConstructorUsedError;
  String? get reason => throw _privateConstructorUsedError;
  Map<String, dynamic>? get metadata => throw _privateConstructorUsedError;

  /// Serializes this TripStateLog to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TripStateLog
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TripStateLogCopyWith<TripStateLog> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TripStateLogCopyWith<$Res> {
  factory $TripStateLogCopyWith(
          TripStateLog value, $Res Function(TripStateLog) then) =
      _$TripStateLogCopyWithImpl<$Res, TripStateLog>;
  @useResult
  $Res call(
      {TripState state,
      DateTime timestamp,
      String? changedBy,
      String? reason,
      Map<String, dynamic>? metadata});
}

/// @nodoc
class _$TripStateLogCopyWithImpl<$Res, $Val extends TripStateLog>
    implements $TripStateLogCopyWith<$Res> {
  _$TripStateLogCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TripStateLog
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? state = null,
    Object? timestamp = null,
    Object? changedBy = freezed,
    Object? reason = freezed,
    Object? metadata = freezed,
  }) {
    return _then(_value.copyWith(
      state: null == state
          ? _value.state
          : state // ignore: cast_nullable_to_non_nullable
              as TripState,
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
      changedBy: freezed == changedBy
          ? _value.changedBy
          : changedBy // ignore: cast_nullable_to_non_nullable
              as String?,
      reason: freezed == reason
          ? _value.reason
          : reason // ignore: cast_nullable_to_non_nullable
              as String?,
      metadata: freezed == metadata
          ? _value.metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TripStateLogImplCopyWith<$Res>
    implements $TripStateLogCopyWith<$Res> {
  factory _$$TripStateLogImplCopyWith(
          _$TripStateLogImpl value, $Res Function(_$TripStateLogImpl) then) =
      __$$TripStateLogImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {TripState state,
      DateTime timestamp,
      String? changedBy,
      String? reason,
      Map<String, dynamic>? metadata});
}

/// @nodoc
class __$$TripStateLogImplCopyWithImpl<$Res>
    extends _$TripStateLogCopyWithImpl<$Res, _$TripStateLogImpl>
    implements _$$TripStateLogImplCopyWith<$Res> {
  __$$TripStateLogImplCopyWithImpl(
      _$TripStateLogImpl _value, $Res Function(_$TripStateLogImpl) _then)
      : super(_value, _then);

  /// Create a copy of TripStateLog
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? state = null,
    Object? timestamp = null,
    Object? changedBy = freezed,
    Object? reason = freezed,
    Object? metadata = freezed,
  }) {
    return _then(_$TripStateLogImpl(
      state: null == state
          ? _value.state
          : state // ignore: cast_nullable_to_non_nullable
              as TripState,
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
      changedBy: freezed == changedBy
          ? _value.changedBy
          : changedBy // ignore: cast_nullable_to_non_nullable
              as String?,
      reason: freezed == reason
          ? _value.reason
          : reason // ignore: cast_nullable_to_non_nullable
              as String?,
      metadata: freezed == metadata
          ? _value._metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TripStateLogImpl implements _TripStateLog {
  const _$TripStateLogImpl(
      {required this.state,
      required this.timestamp,
      this.changedBy,
      this.reason,
      final Map<String, dynamic>? metadata})
      : _metadata = metadata;

  factory _$TripStateLogImpl.fromJson(Map<String, dynamic> json) =>
      _$$TripStateLogImplFromJson(json);

  @override
  final TripState state;
  @override
  final DateTime timestamp;
  @override
  final String? changedBy;
  @override
  final String? reason;
  final Map<String, dynamic>? _metadata;
  @override
  Map<String, dynamic>? get metadata {
    final value = _metadata;
    if (value == null) return null;
    if (_metadata is EqualUnmodifiableMapView) return _metadata;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  String toString() {
    return 'TripStateLog(state: $state, timestamp: $timestamp, changedBy: $changedBy, reason: $reason, metadata: $metadata)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TripStateLogImpl &&
            (identical(other.state, state) || other.state == state) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp) &&
            (identical(other.changedBy, changedBy) ||
                other.changedBy == changedBy) &&
            (identical(other.reason, reason) || other.reason == reason) &&
            const DeepCollectionEquality().equals(other._metadata, _metadata));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, state, timestamp, changedBy,
      reason, const DeepCollectionEquality().hash(_metadata));

  /// Create a copy of TripStateLog
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TripStateLogImplCopyWith<_$TripStateLogImpl> get copyWith =>
      __$$TripStateLogImplCopyWithImpl<_$TripStateLogImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TripStateLogImplToJson(
      this,
    );
  }
}

abstract class _TripStateLog implements TripStateLog {
  const factory _TripStateLog(
      {required final TripState state,
      required final DateTime timestamp,
      final String? changedBy,
      final String? reason,
      final Map<String, dynamic>? metadata}) = _$TripStateLogImpl;

  factory _TripStateLog.fromJson(Map<String, dynamic> json) =
      _$TripStateLogImpl.fromJson;

  @override
  TripState get state;
  @override
  DateTime get timestamp;
  @override
  String? get changedBy;
  @override
  String? get reason;
  @override
  Map<String, dynamic>? get metadata;

  /// Create a copy of TripStateLog
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TripStateLogImplCopyWith<_$TripStateLogImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

CreateTripRequest _$CreateTripRequestFromJson(Map<String, dynamic> json) {
  return _CreateTripRequest.fromJson(json);
}

/// @nodoc
mixin _$CreateTripRequest {
  double get pickupLatitude => throw _privateConstructorUsedError;
  double get pickupLongitude => throw _privateConstructorUsedError;
  String get pickupAddress => throw _privateConstructorUsedError;
  double get dropoffLatitude => throw _privateConstructorUsedError;
  double get dropoffLongitude => throw _privateConstructorUsedError;
  String get dropoffAddress => throw _privateConstructorUsedError;
  String get vehicleType => throw _privateConstructorUsedError;
  String? get promoCode => throw _privateConstructorUsedError;
  String? get note => throw _privateConstructorUsedError;
  bool get scheduleForLater => throw _privateConstructorUsedError;
  DateTime? get scheduledAt => throw _privateConstructorUsedError;

  /// Serializes this CreateTripRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CreateTripRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CreateTripRequestCopyWith<CreateTripRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CreateTripRequestCopyWith<$Res> {
  factory $CreateTripRequestCopyWith(
          CreateTripRequest value, $Res Function(CreateTripRequest) then) =
      _$CreateTripRequestCopyWithImpl<$Res, CreateTripRequest>;
  @useResult
  $Res call(
      {double pickupLatitude,
      double pickupLongitude,
      String pickupAddress,
      double dropoffLatitude,
      double dropoffLongitude,
      String dropoffAddress,
      String vehicleType,
      String? promoCode,
      String? note,
      bool scheduleForLater,
      DateTime? scheduledAt});
}

/// @nodoc
class _$CreateTripRequestCopyWithImpl<$Res, $Val extends CreateTripRequest>
    implements $CreateTripRequestCopyWith<$Res> {
  _$CreateTripRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CreateTripRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? pickupLatitude = null,
    Object? pickupLongitude = null,
    Object? pickupAddress = null,
    Object? dropoffLatitude = null,
    Object? dropoffLongitude = null,
    Object? dropoffAddress = null,
    Object? vehicleType = null,
    Object? promoCode = freezed,
    Object? note = freezed,
    Object? scheduleForLater = null,
    Object? scheduledAt = freezed,
  }) {
    return _then(_value.copyWith(
      pickupLatitude: null == pickupLatitude
          ? _value.pickupLatitude
          : pickupLatitude // ignore: cast_nullable_to_non_nullable
              as double,
      pickupLongitude: null == pickupLongitude
          ? _value.pickupLongitude
          : pickupLongitude // ignore: cast_nullable_to_non_nullable
              as double,
      pickupAddress: null == pickupAddress
          ? _value.pickupAddress
          : pickupAddress // ignore: cast_nullable_to_non_nullable
              as String,
      dropoffLatitude: null == dropoffLatitude
          ? _value.dropoffLatitude
          : dropoffLatitude // ignore: cast_nullable_to_non_nullable
              as double,
      dropoffLongitude: null == dropoffLongitude
          ? _value.dropoffLongitude
          : dropoffLongitude // ignore: cast_nullable_to_non_nullable
              as double,
      dropoffAddress: null == dropoffAddress
          ? _value.dropoffAddress
          : dropoffAddress // ignore: cast_nullable_to_non_nullable
              as String,
      vehicleType: null == vehicleType
          ? _value.vehicleType
          : vehicleType // ignore: cast_nullable_to_non_nullable
              as String,
      promoCode: freezed == promoCode
          ? _value.promoCode
          : promoCode // ignore: cast_nullable_to_non_nullable
              as String?,
      note: freezed == note
          ? _value.note
          : note // ignore: cast_nullable_to_non_nullable
              as String?,
      scheduleForLater: null == scheduleForLater
          ? _value.scheduleForLater
          : scheduleForLater // ignore: cast_nullable_to_non_nullable
              as bool,
      scheduledAt: freezed == scheduledAt
          ? _value.scheduledAt
          : scheduledAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CreateTripRequestImplCopyWith<$Res>
    implements $CreateTripRequestCopyWith<$Res> {
  factory _$$CreateTripRequestImplCopyWith(_$CreateTripRequestImpl value,
          $Res Function(_$CreateTripRequestImpl) then) =
      __$$CreateTripRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {double pickupLatitude,
      double pickupLongitude,
      String pickupAddress,
      double dropoffLatitude,
      double dropoffLongitude,
      String dropoffAddress,
      String vehicleType,
      String? promoCode,
      String? note,
      bool scheduleForLater,
      DateTime? scheduledAt});
}

/// @nodoc
class __$$CreateTripRequestImplCopyWithImpl<$Res>
    extends _$CreateTripRequestCopyWithImpl<$Res, _$CreateTripRequestImpl>
    implements _$$CreateTripRequestImplCopyWith<$Res> {
  __$$CreateTripRequestImplCopyWithImpl(_$CreateTripRequestImpl _value,
      $Res Function(_$CreateTripRequestImpl) _then)
      : super(_value, _then);

  /// Create a copy of CreateTripRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? pickupLatitude = null,
    Object? pickupLongitude = null,
    Object? pickupAddress = null,
    Object? dropoffLatitude = null,
    Object? dropoffLongitude = null,
    Object? dropoffAddress = null,
    Object? vehicleType = null,
    Object? promoCode = freezed,
    Object? note = freezed,
    Object? scheduleForLater = null,
    Object? scheduledAt = freezed,
  }) {
    return _then(_$CreateTripRequestImpl(
      pickupLatitude: null == pickupLatitude
          ? _value.pickupLatitude
          : pickupLatitude // ignore: cast_nullable_to_non_nullable
              as double,
      pickupLongitude: null == pickupLongitude
          ? _value.pickupLongitude
          : pickupLongitude // ignore: cast_nullable_to_non_nullable
              as double,
      pickupAddress: null == pickupAddress
          ? _value.pickupAddress
          : pickupAddress // ignore: cast_nullable_to_non_nullable
              as String,
      dropoffLatitude: null == dropoffLatitude
          ? _value.dropoffLatitude
          : dropoffLatitude // ignore: cast_nullable_to_non_nullable
              as double,
      dropoffLongitude: null == dropoffLongitude
          ? _value.dropoffLongitude
          : dropoffLongitude // ignore: cast_nullable_to_non_nullable
              as double,
      dropoffAddress: null == dropoffAddress
          ? _value.dropoffAddress
          : dropoffAddress // ignore: cast_nullable_to_non_nullable
              as String,
      vehicleType: null == vehicleType
          ? _value.vehicleType
          : vehicleType // ignore: cast_nullable_to_non_nullable
              as String,
      promoCode: freezed == promoCode
          ? _value.promoCode
          : promoCode // ignore: cast_nullable_to_non_nullable
              as String?,
      note: freezed == note
          ? _value.note
          : note // ignore: cast_nullable_to_non_nullable
              as String?,
      scheduleForLater: null == scheduleForLater
          ? _value.scheduleForLater
          : scheduleForLater // ignore: cast_nullable_to_non_nullable
              as bool,
      scheduledAt: freezed == scheduledAt
          ? _value.scheduledAt
          : scheduledAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CreateTripRequestImpl implements _CreateTripRequest {
  const _$CreateTripRequestImpl(
      {required this.pickupLatitude,
      required this.pickupLongitude,
      required this.pickupAddress,
      required this.dropoffLatitude,
      required this.dropoffLongitude,
      required this.dropoffAddress,
      required this.vehicleType,
      this.promoCode,
      this.note,
      this.scheduleForLater = false,
      this.scheduledAt});

  factory _$CreateTripRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$CreateTripRequestImplFromJson(json);

  @override
  final double pickupLatitude;
  @override
  final double pickupLongitude;
  @override
  final String pickupAddress;
  @override
  final double dropoffLatitude;
  @override
  final double dropoffLongitude;
  @override
  final String dropoffAddress;
  @override
  final String vehicleType;
  @override
  final String? promoCode;
  @override
  final String? note;
  @override
  @JsonKey()
  final bool scheduleForLater;
  @override
  final DateTime? scheduledAt;

  @override
  String toString() {
    return 'CreateTripRequest(pickupLatitude: $pickupLatitude, pickupLongitude: $pickupLongitude, pickupAddress: $pickupAddress, dropoffLatitude: $dropoffLatitude, dropoffLongitude: $dropoffLongitude, dropoffAddress: $dropoffAddress, vehicleType: $vehicleType, promoCode: $promoCode, note: $note, scheduleForLater: $scheduleForLater, scheduledAt: $scheduledAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CreateTripRequestImpl &&
            (identical(other.pickupLatitude, pickupLatitude) ||
                other.pickupLatitude == pickupLatitude) &&
            (identical(other.pickupLongitude, pickupLongitude) ||
                other.pickupLongitude == pickupLongitude) &&
            (identical(other.pickupAddress, pickupAddress) ||
                other.pickupAddress == pickupAddress) &&
            (identical(other.dropoffLatitude, dropoffLatitude) ||
                other.dropoffLatitude == dropoffLatitude) &&
            (identical(other.dropoffLongitude, dropoffLongitude) ||
                other.dropoffLongitude == dropoffLongitude) &&
            (identical(other.dropoffAddress, dropoffAddress) ||
                other.dropoffAddress == dropoffAddress) &&
            (identical(other.vehicleType, vehicleType) ||
                other.vehicleType == vehicleType) &&
            (identical(other.promoCode, promoCode) ||
                other.promoCode == promoCode) &&
            (identical(other.note, note) || other.note == note) &&
            (identical(other.scheduleForLater, scheduleForLater) ||
                other.scheduleForLater == scheduleForLater) &&
            (identical(other.scheduledAt, scheduledAt) ||
                other.scheduledAt == scheduledAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      pickupLatitude,
      pickupLongitude,
      pickupAddress,
      dropoffLatitude,
      dropoffLongitude,
      dropoffAddress,
      vehicleType,
      promoCode,
      note,
      scheduleForLater,
      scheduledAt);

  /// Create a copy of CreateTripRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CreateTripRequestImplCopyWith<_$CreateTripRequestImpl> get copyWith =>
      __$$CreateTripRequestImplCopyWithImpl<_$CreateTripRequestImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CreateTripRequestImplToJson(
      this,
    );
  }
}

abstract class _CreateTripRequest implements CreateTripRequest {
  const factory _CreateTripRequest(
      {required final double pickupLatitude,
      required final double pickupLongitude,
      required final String pickupAddress,
      required final double dropoffLatitude,
      required final double dropoffLongitude,
      required final String dropoffAddress,
      required final String vehicleType,
      final String? promoCode,
      final String? note,
      final bool scheduleForLater,
      final DateTime? scheduledAt}) = _$CreateTripRequestImpl;

  factory _CreateTripRequest.fromJson(Map<String, dynamic> json) =
      _$CreateTripRequestImpl.fromJson;

  @override
  double get pickupLatitude;
  @override
  double get pickupLongitude;
  @override
  String get pickupAddress;
  @override
  double get dropoffLatitude;
  @override
  double get dropoffLongitude;
  @override
  String get dropoffAddress;
  @override
  String get vehicleType;
  @override
  String? get promoCode;
  @override
  String? get note;
  @override
  bool get scheduleForLater;
  @override
  DateTime? get scheduledAt;

  /// Create a copy of CreateTripRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CreateTripRequestImplCopyWith<_$CreateTripRequestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

TripRatingRequest _$TripRatingRequestFromJson(Map<String, dynamic> json) {
  return _TripRatingRequest.fromJson(json);
}

/// @nodoc
mixin _$TripRatingRequest {
  double get rating => throw _privateConstructorUsedError;
  String? get review => throw _privateConstructorUsedError;
  List<String>? get tags => throw _privateConstructorUsedError;

  /// Serializes this TripRatingRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TripRatingRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TripRatingRequestCopyWith<TripRatingRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TripRatingRequestCopyWith<$Res> {
  factory $TripRatingRequestCopyWith(
          TripRatingRequest value, $Res Function(TripRatingRequest) then) =
      _$TripRatingRequestCopyWithImpl<$Res, TripRatingRequest>;
  @useResult
  $Res call({double rating, String? review, List<String>? tags});
}

/// @nodoc
class _$TripRatingRequestCopyWithImpl<$Res, $Val extends TripRatingRequest>
    implements $TripRatingRequestCopyWith<$Res> {
  _$TripRatingRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TripRatingRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? rating = null,
    Object? review = freezed,
    Object? tags = freezed,
  }) {
    return _then(_value.copyWith(
      rating: null == rating
          ? _value.rating
          : rating // ignore: cast_nullable_to_non_nullable
              as double,
      review: freezed == review
          ? _value.review
          : review // ignore: cast_nullable_to_non_nullable
              as String?,
      tags: freezed == tags
          ? _value.tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TripRatingRequestImplCopyWith<$Res>
    implements $TripRatingRequestCopyWith<$Res> {
  factory _$$TripRatingRequestImplCopyWith(_$TripRatingRequestImpl value,
          $Res Function(_$TripRatingRequestImpl) then) =
      __$$TripRatingRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({double rating, String? review, List<String>? tags});
}

/// @nodoc
class __$$TripRatingRequestImplCopyWithImpl<$Res>
    extends _$TripRatingRequestCopyWithImpl<$Res, _$TripRatingRequestImpl>
    implements _$$TripRatingRequestImplCopyWith<$Res> {
  __$$TripRatingRequestImplCopyWithImpl(_$TripRatingRequestImpl _value,
      $Res Function(_$TripRatingRequestImpl) _then)
      : super(_value, _then);

  /// Create a copy of TripRatingRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? rating = null,
    Object? review = freezed,
    Object? tags = freezed,
  }) {
    return _then(_$TripRatingRequestImpl(
      rating: null == rating
          ? _value.rating
          : rating // ignore: cast_nullable_to_non_nullable
              as double,
      review: freezed == review
          ? _value.review
          : review // ignore: cast_nullable_to_non_nullable
              as String?,
      tags: freezed == tags
          ? _value._tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TripRatingRequestImpl implements _TripRatingRequest {
  const _$TripRatingRequestImpl(
      {required this.rating, this.review, final List<String>? tags})
      : _tags = tags;

  factory _$TripRatingRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$TripRatingRequestImplFromJson(json);

  @override
  final double rating;
  @override
  final String? review;
  final List<String>? _tags;
  @override
  List<String>? get tags {
    final value = _tags;
    if (value == null) return null;
    if (_tags is EqualUnmodifiableListView) return _tags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  String toString() {
    return 'TripRatingRequest(rating: $rating, review: $review, tags: $tags)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TripRatingRequestImpl &&
            (identical(other.rating, rating) || other.rating == rating) &&
            (identical(other.review, review) || other.review == review) &&
            const DeepCollectionEquality().equals(other._tags, _tags));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, rating, review, const DeepCollectionEquality().hash(_tags));

  /// Create a copy of TripRatingRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TripRatingRequestImplCopyWith<_$TripRatingRequestImpl> get copyWith =>
      __$$TripRatingRequestImplCopyWithImpl<_$TripRatingRequestImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TripRatingRequestImplToJson(
      this,
    );
  }
}

abstract class _TripRatingRequest implements TripRatingRequest {
  const factory _TripRatingRequest(
      {required final double rating,
      final String? review,
      final List<String>? tags}) = _$TripRatingRequestImpl;

  factory _TripRatingRequest.fromJson(Map<String, dynamic> json) =
      _$TripRatingRequestImpl.fromJson;

  @override
  double get rating;
  @override
  String? get review;
  @override
  List<String>? get tags;

  /// Create a copy of TripRatingRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TripRatingRequestImplCopyWith<_$TripRatingRequestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

TripSummary _$TripSummaryFromJson(Map<String, dynamic> json) {
  return _TripSummary.fromJson(json);
}

/// @nodoc
mixin _$TripSummary {
  String get id => throw _privateConstructorUsedError;
  String get pickupAddress => throw _privateConstructorUsedError;
  String get dropoffAddress => throw _privateConstructorUsedError;
  TripState get state => throw _privateConstructorUsedError;
  double get fare => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  String? get driverName => throw _privateConstructorUsedError;
  String? get vehicleType => throw _privateConstructorUsedError;
  double? get rating => throw _privateConstructorUsedError;

  /// Serializes this TripSummary to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TripSummary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TripSummaryCopyWith<TripSummary> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TripSummaryCopyWith<$Res> {
  factory $TripSummaryCopyWith(
          TripSummary value, $Res Function(TripSummary) then) =
      _$TripSummaryCopyWithImpl<$Res, TripSummary>;
  @useResult
  $Res call(
      {String id,
      String pickupAddress,
      String dropoffAddress,
      TripState state,
      double fare,
      DateTime createdAt,
      String? driverName,
      String? vehicleType,
      double? rating});
}

/// @nodoc
class _$TripSummaryCopyWithImpl<$Res, $Val extends TripSummary>
    implements $TripSummaryCopyWith<$Res> {
  _$TripSummaryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TripSummary
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? pickupAddress = null,
    Object? dropoffAddress = null,
    Object? state = null,
    Object? fare = null,
    Object? createdAt = null,
    Object? driverName = freezed,
    Object? vehicleType = freezed,
    Object? rating = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      pickupAddress: null == pickupAddress
          ? _value.pickupAddress
          : pickupAddress // ignore: cast_nullable_to_non_nullable
              as String,
      dropoffAddress: null == dropoffAddress
          ? _value.dropoffAddress
          : dropoffAddress // ignore: cast_nullable_to_non_nullable
              as String,
      state: null == state
          ? _value.state
          : state // ignore: cast_nullable_to_non_nullable
              as TripState,
      fare: null == fare
          ? _value.fare
          : fare // ignore: cast_nullable_to_non_nullable
              as double,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      driverName: freezed == driverName
          ? _value.driverName
          : driverName // ignore: cast_nullable_to_non_nullable
              as String?,
      vehicleType: freezed == vehicleType
          ? _value.vehicleType
          : vehicleType // ignore: cast_nullable_to_non_nullable
              as String?,
      rating: freezed == rating
          ? _value.rating
          : rating // ignore: cast_nullable_to_non_nullable
              as double?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TripSummaryImplCopyWith<$Res>
    implements $TripSummaryCopyWith<$Res> {
  factory _$$TripSummaryImplCopyWith(
          _$TripSummaryImpl value, $Res Function(_$TripSummaryImpl) then) =
      __$$TripSummaryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String pickupAddress,
      String dropoffAddress,
      TripState state,
      double fare,
      DateTime createdAt,
      String? driverName,
      String? vehicleType,
      double? rating});
}

/// @nodoc
class __$$TripSummaryImplCopyWithImpl<$Res>
    extends _$TripSummaryCopyWithImpl<$Res, _$TripSummaryImpl>
    implements _$$TripSummaryImplCopyWith<$Res> {
  __$$TripSummaryImplCopyWithImpl(
      _$TripSummaryImpl _value, $Res Function(_$TripSummaryImpl) _then)
      : super(_value, _then);

  /// Create a copy of TripSummary
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? pickupAddress = null,
    Object? dropoffAddress = null,
    Object? state = null,
    Object? fare = null,
    Object? createdAt = null,
    Object? driverName = freezed,
    Object? vehicleType = freezed,
    Object? rating = freezed,
  }) {
    return _then(_$TripSummaryImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      pickupAddress: null == pickupAddress
          ? _value.pickupAddress
          : pickupAddress // ignore: cast_nullable_to_non_nullable
              as String,
      dropoffAddress: null == dropoffAddress
          ? _value.dropoffAddress
          : dropoffAddress // ignore: cast_nullable_to_non_nullable
              as String,
      state: null == state
          ? _value.state
          : state // ignore: cast_nullable_to_non_nullable
              as TripState,
      fare: null == fare
          ? _value.fare
          : fare // ignore: cast_nullable_to_non_nullable
              as double,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      driverName: freezed == driverName
          ? _value.driverName
          : driverName // ignore: cast_nullable_to_non_nullable
              as String?,
      vehicleType: freezed == vehicleType
          ? _value.vehicleType
          : vehicleType // ignore: cast_nullable_to_non_nullable
              as String?,
      rating: freezed == rating
          ? _value.rating
          : rating // ignore: cast_nullable_to_non_nullable
              as double?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TripSummaryImpl implements _TripSummary {
  const _$TripSummaryImpl(
      {required this.id,
      required this.pickupAddress,
      required this.dropoffAddress,
      required this.state,
      required this.fare,
      required this.createdAt,
      this.driverName,
      this.vehicleType,
      this.rating});

  factory _$TripSummaryImpl.fromJson(Map<String, dynamic> json) =>
      _$$TripSummaryImplFromJson(json);

  @override
  final String id;
  @override
  final String pickupAddress;
  @override
  final String dropoffAddress;
  @override
  final TripState state;
  @override
  final double fare;
  @override
  final DateTime createdAt;
  @override
  final String? driverName;
  @override
  final String? vehicleType;
  @override
  final double? rating;

  @override
  String toString() {
    return 'TripSummary(id: $id, pickupAddress: $pickupAddress, dropoffAddress: $dropoffAddress, state: $state, fare: $fare, createdAt: $createdAt, driverName: $driverName, vehicleType: $vehicleType, rating: $rating)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TripSummaryImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.pickupAddress, pickupAddress) ||
                other.pickupAddress == pickupAddress) &&
            (identical(other.dropoffAddress, dropoffAddress) ||
                other.dropoffAddress == dropoffAddress) &&
            (identical(other.state, state) || other.state == state) &&
            (identical(other.fare, fare) || other.fare == fare) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.driverName, driverName) ||
                other.driverName == driverName) &&
            (identical(other.vehicleType, vehicleType) ||
                other.vehicleType == vehicleType) &&
            (identical(other.rating, rating) || other.rating == rating));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, pickupAddress,
      dropoffAddress, state, fare, createdAt, driverName, vehicleType, rating);

  /// Create a copy of TripSummary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TripSummaryImplCopyWith<_$TripSummaryImpl> get copyWith =>
      __$$TripSummaryImplCopyWithImpl<_$TripSummaryImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TripSummaryImplToJson(
      this,
    );
  }
}

abstract class _TripSummary implements TripSummary {
  const factory _TripSummary(
      {required final String id,
      required final String pickupAddress,
      required final String dropoffAddress,
      required final TripState state,
      required final double fare,
      required final DateTime createdAt,
      final String? driverName,
      final String? vehicleType,
      final double? rating}) = _$TripSummaryImpl;

  factory _TripSummary.fromJson(Map<String, dynamic> json) =
      _$TripSummaryImpl.fromJson;

  @override
  String get id;
  @override
  String get pickupAddress;
  @override
  String get dropoffAddress;
  @override
  TripState get state;
  @override
  double get fare;
  @override
  DateTime get createdAt;
  @override
  String? get driverName;
  @override
  String? get vehicleType;
  @override
  double? get rating;

  /// Create a copy of TripSummary
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TripSummaryImplCopyWith<_$TripSummaryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
