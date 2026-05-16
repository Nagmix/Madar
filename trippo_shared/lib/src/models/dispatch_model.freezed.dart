// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'dispatch_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

DispatchRequest _$DispatchRequestFromJson(Map<String, dynamic> json) {
  return _DispatchRequest.fromJson(json);
}

/// @nodoc
mixin _$DispatchRequest {
  String get tripId => throw _privateConstructorUsedError;
  double get pickupLatitude => throw _privateConstructorUsedError;
  double get pickupLongitude => throw _privateConstructorUsedError;
  double get dropoffLatitude => throw _privateConstructorUsedError;
  double get dropoffLongitude => throw _privateConstructorUsedError;
  String get vehicleType => throw _privateConstructorUsedError;
  String get riderId => throw _privateConstructorUsedError;
  int get retryCount => throw _privateConstructorUsedError;
  DispatchStatus get status => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;

  /// Serializes this DispatchRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DispatchRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DispatchRequestCopyWith<DispatchRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DispatchRequestCopyWith<$Res> {
  factory $DispatchRequestCopyWith(
          DispatchRequest value, $Res Function(DispatchRequest) then) =
      _$DispatchRequestCopyWithImpl<$Res, DispatchRequest>;
  @useResult
  $Res call(
      {String tripId,
      double pickupLatitude,
      double pickupLongitude,
      double dropoffLatitude,
      double dropoffLongitude,
      String vehicleType,
      String riderId,
      int retryCount,
      DispatchStatus status,
      DateTime? createdAt});
}

/// @nodoc
class _$DispatchRequestCopyWithImpl<$Res, $Val extends DispatchRequest>
    implements $DispatchRequestCopyWith<$Res> {
  _$DispatchRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DispatchRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? tripId = null,
    Object? pickupLatitude = null,
    Object? pickupLongitude = null,
    Object? dropoffLatitude = null,
    Object? dropoffLongitude = null,
    Object? vehicleType = null,
    Object? riderId = null,
    Object? retryCount = null,
    Object? status = null,
    Object? createdAt = freezed,
  }) {
    return _then(_value.copyWith(
      tripId: null == tripId
          ? _value.tripId
          : tripId // ignore: cast_nullable_to_non_nullable
              as String,
      pickupLatitude: null == pickupLatitude
          ? _value.pickupLatitude
          : pickupLatitude // ignore: cast_nullable_to_non_nullable
              as double,
      pickupLongitude: null == pickupLongitude
          ? _value.pickupLongitude
          : pickupLongitude // ignore: cast_nullable_to_non_nullable
              as double,
      dropoffLatitude: null == dropoffLatitude
          ? _value.dropoffLatitude
          : dropoffLatitude // ignore: cast_nullable_to_non_nullable
              as double,
      dropoffLongitude: null == dropoffLongitude
          ? _value.dropoffLongitude
          : dropoffLongitude // ignore: cast_nullable_to_non_nullable
              as double,
      vehicleType: null == vehicleType
          ? _value.vehicleType
          : vehicleType // ignore: cast_nullable_to_non_nullable
              as String,
      riderId: null == riderId
          ? _value.riderId
          : riderId // ignore: cast_nullable_to_non_nullable
              as String,
      retryCount: null == retryCount
          ? _value.retryCount
          : retryCount // ignore: cast_nullable_to_non_nullable
              as int,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as DispatchStatus,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$DispatchRequestImplCopyWith<$Res>
    implements $DispatchRequestCopyWith<$Res> {
  factory _$$DispatchRequestImplCopyWith(_$DispatchRequestImpl value,
          $Res Function(_$DispatchRequestImpl) then) =
      __$$DispatchRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String tripId,
      double pickupLatitude,
      double pickupLongitude,
      double dropoffLatitude,
      double dropoffLongitude,
      String vehicleType,
      String riderId,
      int retryCount,
      DispatchStatus status,
      DateTime? createdAt});
}

/// @nodoc
class __$$DispatchRequestImplCopyWithImpl<$Res>
    extends _$DispatchRequestCopyWithImpl<$Res, _$DispatchRequestImpl>
    implements _$$DispatchRequestImplCopyWith<$Res> {
  __$$DispatchRequestImplCopyWithImpl(
      _$DispatchRequestImpl _value, $Res Function(_$DispatchRequestImpl) _then)
      : super(_value, _then);

  /// Create a copy of DispatchRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? tripId = null,
    Object? pickupLatitude = null,
    Object? pickupLongitude = null,
    Object? dropoffLatitude = null,
    Object? dropoffLongitude = null,
    Object? vehicleType = null,
    Object? riderId = null,
    Object? retryCount = null,
    Object? status = null,
    Object? createdAt = freezed,
  }) {
    return _then(_$DispatchRequestImpl(
      tripId: null == tripId
          ? _value.tripId
          : tripId // ignore: cast_nullable_to_non_nullable
              as String,
      pickupLatitude: null == pickupLatitude
          ? _value.pickupLatitude
          : pickupLatitude // ignore: cast_nullable_to_non_nullable
              as double,
      pickupLongitude: null == pickupLongitude
          ? _value.pickupLongitude
          : pickupLongitude // ignore: cast_nullable_to_non_nullable
              as double,
      dropoffLatitude: null == dropoffLatitude
          ? _value.dropoffLatitude
          : dropoffLatitude // ignore: cast_nullable_to_non_nullable
              as double,
      dropoffLongitude: null == dropoffLongitude
          ? _value.dropoffLongitude
          : dropoffLongitude // ignore: cast_nullable_to_non_nullable
              as double,
      vehicleType: null == vehicleType
          ? _value.vehicleType
          : vehicleType // ignore: cast_nullable_to_non_nullable
              as String,
      riderId: null == riderId
          ? _value.riderId
          : riderId // ignore: cast_nullable_to_non_nullable
              as String,
      retryCount: null == retryCount
          ? _value.retryCount
          : retryCount // ignore: cast_nullable_to_non_nullable
              as int,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as DispatchStatus,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$DispatchRequestImpl implements _DispatchRequest {
  const _$DispatchRequestImpl(
      {required this.tripId,
      required this.pickupLatitude,
      required this.pickupLongitude,
      required this.dropoffLatitude,
      required this.dropoffLongitude,
      required this.vehicleType,
      required this.riderId,
      this.retryCount = 1,
      this.status = DispatchStatus.pending,
      this.createdAt});

  factory _$DispatchRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$DispatchRequestImplFromJson(json);

  @override
  final String tripId;
  @override
  final double pickupLatitude;
  @override
  final double pickupLongitude;
  @override
  final double dropoffLatitude;
  @override
  final double dropoffLongitude;
  @override
  final String vehicleType;
  @override
  final String riderId;
  @override
  @JsonKey()
  final int retryCount;
  @override
  @JsonKey()
  final DispatchStatus status;
  @override
  final DateTime? createdAt;

  @override
  String toString() {
    return 'DispatchRequest(tripId: $tripId, pickupLatitude: $pickupLatitude, pickupLongitude: $pickupLongitude, dropoffLatitude: $dropoffLatitude, dropoffLongitude: $dropoffLongitude, vehicleType: $vehicleType, riderId: $riderId, retryCount: $retryCount, status: $status, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DispatchRequestImpl &&
            (identical(other.tripId, tripId) || other.tripId == tripId) &&
            (identical(other.pickupLatitude, pickupLatitude) ||
                other.pickupLatitude == pickupLatitude) &&
            (identical(other.pickupLongitude, pickupLongitude) ||
                other.pickupLongitude == pickupLongitude) &&
            (identical(other.dropoffLatitude, dropoffLatitude) ||
                other.dropoffLatitude == dropoffLatitude) &&
            (identical(other.dropoffLongitude, dropoffLongitude) ||
                other.dropoffLongitude == dropoffLongitude) &&
            (identical(other.vehicleType, vehicleType) ||
                other.vehicleType == vehicleType) &&
            (identical(other.riderId, riderId) || other.riderId == riderId) &&
            (identical(other.retryCount, retryCount) ||
                other.retryCount == retryCount) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      tripId,
      pickupLatitude,
      pickupLongitude,
      dropoffLatitude,
      dropoffLongitude,
      vehicleType,
      riderId,
      retryCount,
      status,
      createdAt);

  /// Create a copy of DispatchRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DispatchRequestImplCopyWith<_$DispatchRequestImpl> get copyWith =>
      __$$DispatchRequestImplCopyWithImpl<_$DispatchRequestImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DispatchRequestImplToJson(
      this,
    );
  }
}

abstract class _DispatchRequest implements DispatchRequest {
  const factory _DispatchRequest(
      {required final String tripId,
      required final double pickupLatitude,
      required final double pickupLongitude,
      required final double dropoffLatitude,
      required final double dropoffLongitude,
      required final String vehicleType,
      required final String riderId,
      final int retryCount,
      final DispatchStatus status,
      final DateTime? createdAt}) = _$DispatchRequestImpl;

  factory _DispatchRequest.fromJson(Map<String, dynamic> json) =
      _$DispatchRequestImpl.fromJson;

  @override
  String get tripId;
  @override
  double get pickupLatitude;
  @override
  double get pickupLongitude;
  @override
  double get dropoffLatitude;
  @override
  double get dropoffLongitude;
  @override
  String get vehicleType;
  @override
  String get riderId;
  @override
  int get retryCount;
  @override
  DispatchStatus get status;
  @override
  DateTime? get createdAt;

  /// Create a copy of DispatchRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DispatchRequestImplCopyWith<_$DispatchRequestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

DispatchResult _$DispatchResultFromJson(Map<String, dynamic> json) {
  return _DispatchResult.fromJson(json);
}

/// @nodoc
mixin _$DispatchResult {
  String get tripId => throw _privateConstructorUsedError;
  DispatchStatus get status => throw _privateConstructorUsedError;
  DriverModel? get assignedDriver => throw _privateConstructorUsedError;
  DriverScore? get driverScore => throw _privateConstructorUsedError;
  List<String> get notifiedDriverIds => throw _privateConstructorUsedError;
  List<String> get rejectedDriverIds => throw _privateConstructorUsedError;
  String? get failureReason => throw _privateConstructorUsedError;
  int? get searchDurationSeconds => throw _privateConstructorUsedError;

  /// Serializes this DispatchResult to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DispatchResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DispatchResultCopyWith<DispatchResult> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DispatchResultCopyWith<$Res> {
  factory $DispatchResultCopyWith(
          DispatchResult value, $Res Function(DispatchResult) then) =
      _$DispatchResultCopyWithImpl<$Res, DispatchResult>;
  @useResult
  $Res call(
      {String tripId,
      DispatchStatus status,
      DriverModel? assignedDriver,
      DriverScore? driverScore,
      List<String> notifiedDriverIds,
      List<String> rejectedDriverIds,
      String? failureReason,
      int? searchDurationSeconds});

  $DriverModelCopyWith<$Res>? get assignedDriver;
  $DriverScoreCopyWith<$Res>? get driverScore;
}

/// @nodoc
class _$DispatchResultCopyWithImpl<$Res, $Val extends DispatchResult>
    implements $DispatchResultCopyWith<$Res> {
  _$DispatchResultCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DispatchResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? tripId = null,
    Object? status = null,
    Object? assignedDriver = freezed,
    Object? driverScore = freezed,
    Object? notifiedDriverIds = null,
    Object? rejectedDriverIds = null,
    Object? failureReason = freezed,
    Object? searchDurationSeconds = freezed,
  }) {
    return _then(_value.copyWith(
      tripId: null == tripId
          ? _value.tripId
          : tripId // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as DispatchStatus,
      assignedDriver: freezed == assignedDriver
          ? _value.assignedDriver
          : assignedDriver // ignore: cast_nullable_to_non_nullable
              as DriverModel?,
      driverScore: freezed == driverScore
          ? _value.driverScore
          : driverScore // ignore: cast_nullable_to_non_nullable
              as DriverScore?,
      notifiedDriverIds: null == notifiedDriverIds
          ? _value.notifiedDriverIds
          : notifiedDriverIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      rejectedDriverIds: null == rejectedDriverIds
          ? _value.rejectedDriverIds
          : rejectedDriverIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      failureReason: freezed == failureReason
          ? _value.failureReason
          : failureReason // ignore: cast_nullable_to_non_nullable
              as String?,
      searchDurationSeconds: freezed == searchDurationSeconds
          ? _value.searchDurationSeconds
          : searchDurationSeconds // ignore: cast_nullable_to_non_nullable
              as int?,
    ) as $Val);
  }

  /// Create a copy of DispatchResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $DriverModelCopyWith<$Res>? get assignedDriver {
    if (_value.assignedDriver == null) {
      return null;
    }

    return $DriverModelCopyWith<$Res>(_value.assignedDriver!, (value) {
      return _then(_value.copyWith(assignedDriver: value) as $Val);
    });
  }

  /// Create a copy of DispatchResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $DriverScoreCopyWith<$Res>? get driverScore {
    if (_value.driverScore == null) {
      return null;
    }

    return $DriverScoreCopyWith<$Res>(_value.driverScore!, (value) {
      return _then(_value.copyWith(driverScore: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$DispatchResultImplCopyWith<$Res>
    implements $DispatchResultCopyWith<$Res> {
  factory _$$DispatchResultImplCopyWith(_$DispatchResultImpl value,
          $Res Function(_$DispatchResultImpl) then) =
      __$$DispatchResultImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String tripId,
      DispatchStatus status,
      DriverModel? assignedDriver,
      DriverScore? driverScore,
      List<String> notifiedDriverIds,
      List<String> rejectedDriverIds,
      String? failureReason,
      int? searchDurationSeconds});

  @override
  $DriverModelCopyWith<$Res>? get assignedDriver;
  @override
  $DriverScoreCopyWith<$Res>? get driverScore;
}

/// @nodoc
class __$$DispatchResultImplCopyWithImpl<$Res>
    extends _$DispatchResultCopyWithImpl<$Res, _$DispatchResultImpl>
    implements _$$DispatchResultImplCopyWith<$Res> {
  __$$DispatchResultImplCopyWithImpl(
      _$DispatchResultImpl _value, $Res Function(_$DispatchResultImpl) _then)
      : super(_value, _then);

  /// Create a copy of DispatchResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? tripId = null,
    Object? status = null,
    Object? assignedDriver = freezed,
    Object? driverScore = freezed,
    Object? notifiedDriverIds = null,
    Object? rejectedDriverIds = null,
    Object? failureReason = freezed,
    Object? searchDurationSeconds = freezed,
  }) {
    return _then(_$DispatchResultImpl(
      tripId: null == tripId
          ? _value.tripId
          : tripId // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as DispatchStatus,
      assignedDriver: freezed == assignedDriver
          ? _value.assignedDriver
          : assignedDriver // ignore: cast_nullable_to_non_nullable
              as DriverModel?,
      driverScore: freezed == driverScore
          ? _value.driverScore
          : driverScore // ignore: cast_nullable_to_non_nullable
              as DriverScore?,
      notifiedDriverIds: null == notifiedDriverIds
          ? _value._notifiedDriverIds
          : notifiedDriverIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      rejectedDriverIds: null == rejectedDriverIds
          ? _value._rejectedDriverIds
          : rejectedDriverIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      failureReason: freezed == failureReason
          ? _value.failureReason
          : failureReason // ignore: cast_nullable_to_non_nullable
              as String?,
      searchDurationSeconds: freezed == searchDurationSeconds
          ? _value.searchDurationSeconds
          : searchDurationSeconds // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$DispatchResultImpl implements _DispatchResult {
  const _$DispatchResultImpl(
      {required this.tripId,
      required this.status,
      this.assignedDriver,
      this.driverScore,
      final List<String> notifiedDriverIds = const [],
      final List<String> rejectedDriverIds = const [],
      this.failureReason,
      this.searchDurationSeconds})
      : _notifiedDriverIds = notifiedDriverIds,
        _rejectedDriverIds = rejectedDriverIds;

  factory _$DispatchResultImpl.fromJson(Map<String, dynamic> json) =>
      _$$DispatchResultImplFromJson(json);

  @override
  final String tripId;
  @override
  final DispatchStatus status;
  @override
  final DriverModel? assignedDriver;
  @override
  final DriverScore? driverScore;
  final List<String> _notifiedDriverIds;
  @override
  @JsonKey()
  List<String> get notifiedDriverIds {
    if (_notifiedDriverIds is EqualUnmodifiableListView)
      return _notifiedDriverIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_notifiedDriverIds);
  }

  final List<String> _rejectedDriverIds;
  @override
  @JsonKey()
  List<String> get rejectedDriverIds {
    if (_rejectedDriverIds is EqualUnmodifiableListView)
      return _rejectedDriverIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_rejectedDriverIds);
  }

  @override
  final String? failureReason;
  @override
  final int? searchDurationSeconds;

  @override
  String toString() {
    return 'DispatchResult(tripId: $tripId, status: $status, assignedDriver: $assignedDriver, driverScore: $driverScore, notifiedDriverIds: $notifiedDriverIds, rejectedDriverIds: $rejectedDriverIds, failureReason: $failureReason, searchDurationSeconds: $searchDurationSeconds)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DispatchResultImpl &&
            (identical(other.tripId, tripId) || other.tripId == tripId) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.assignedDriver, assignedDriver) ||
                other.assignedDriver == assignedDriver) &&
            (identical(other.driverScore, driverScore) ||
                other.driverScore == driverScore) &&
            const DeepCollectionEquality()
                .equals(other._notifiedDriverIds, _notifiedDriverIds) &&
            const DeepCollectionEquality()
                .equals(other._rejectedDriverIds, _rejectedDriverIds) &&
            (identical(other.failureReason, failureReason) ||
                other.failureReason == failureReason) &&
            (identical(other.searchDurationSeconds, searchDurationSeconds) ||
                other.searchDurationSeconds == searchDurationSeconds));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      tripId,
      status,
      assignedDriver,
      driverScore,
      const DeepCollectionEquality().hash(_notifiedDriverIds),
      const DeepCollectionEquality().hash(_rejectedDriverIds),
      failureReason,
      searchDurationSeconds);

  /// Create a copy of DispatchResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DispatchResultImplCopyWith<_$DispatchResultImpl> get copyWith =>
      __$$DispatchResultImplCopyWithImpl<_$DispatchResultImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DispatchResultImplToJson(
      this,
    );
  }
}

abstract class _DispatchResult implements DispatchResult {
  const factory _DispatchResult(
      {required final String tripId,
      required final DispatchStatus status,
      final DriverModel? assignedDriver,
      final DriverScore? driverScore,
      final List<String> notifiedDriverIds,
      final List<String> rejectedDriverIds,
      final String? failureReason,
      final int? searchDurationSeconds}) = _$DispatchResultImpl;

  factory _DispatchResult.fromJson(Map<String, dynamic> json) =
      _$DispatchResultImpl.fromJson;

  @override
  String get tripId;
  @override
  DispatchStatus get status;
  @override
  DriverModel? get assignedDriver;
  @override
  DriverScore? get driverScore;
  @override
  List<String> get notifiedDriverIds;
  @override
  List<String> get rejectedDriverIds;
  @override
  String? get failureReason;
  @override
  int? get searchDurationSeconds;

  /// Create a copy of DispatchResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DispatchResultImplCopyWith<_$DispatchResultImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

DriverDispatchNotification _$DriverDispatchNotificationFromJson(
    Map<String, dynamic> json) {
  return _DriverDispatchNotification.fromJson(json);
}

/// @nodoc
mixin _$DriverDispatchNotification {
  String get tripId => throw _privateConstructorUsedError;
  String get riderName => throw _privateConstructorUsedError;
  double get pickupLatitude => throw _privateConstructorUsedError;
  double get pickupLongitude => throw _privateConstructorUsedError;
  String get pickupAddress => throw _privateConstructorUsedError;
  double get dropoffLatitude => throw _privateConstructorUsedError;
  double get dropoffLongitude => throw _privateConstructorUsedError;
  String get dropoffAddress => throw _privateConstructorUsedError;
  double get estimatedFare => throw _privateConstructorUsedError;
  double get distanceToPickupKm => throw _privateConstructorUsedError;
  int get estimatedEtaMinutes => throw _privateConstructorUsedError;
  String get vehicleType => throw _privateConstructorUsedError;
  int get responseTimeoutSeconds => throw _privateConstructorUsedError;

  /// Serializes this DriverDispatchNotification to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DriverDispatchNotification
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DriverDispatchNotificationCopyWith<DriverDispatchNotification>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DriverDispatchNotificationCopyWith<$Res> {
  factory $DriverDispatchNotificationCopyWith(DriverDispatchNotification value,
          $Res Function(DriverDispatchNotification) then) =
      _$DriverDispatchNotificationCopyWithImpl<$Res,
          DriverDispatchNotification>;
  @useResult
  $Res call(
      {String tripId,
      String riderName,
      double pickupLatitude,
      double pickupLongitude,
      String pickupAddress,
      double dropoffLatitude,
      double dropoffLongitude,
      String dropoffAddress,
      double estimatedFare,
      double distanceToPickupKm,
      int estimatedEtaMinutes,
      String vehicleType,
      int responseTimeoutSeconds});
}

/// @nodoc
class _$DriverDispatchNotificationCopyWithImpl<$Res,
        $Val extends DriverDispatchNotification>
    implements $DriverDispatchNotificationCopyWith<$Res> {
  _$DriverDispatchNotificationCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DriverDispatchNotification
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? tripId = null,
    Object? riderName = null,
    Object? pickupLatitude = null,
    Object? pickupLongitude = null,
    Object? pickupAddress = null,
    Object? dropoffLatitude = null,
    Object? dropoffLongitude = null,
    Object? dropoffAddress = null,
    Object? estimatedFare = null,
    Object? distanceToPickupKm = null,
    Object? estimatedEtaMinutes = null,
    Object? vehicleType = null,
    Object? responseTimeoutSeconds = null,
  }) {
    return _then(_value.copyWith(
      tripId: null == tripId
          ? _value.tripId
          : tripId // ignore: cast_nullable_to_non_nullable
              as String,
      riderName: null == riderName
          ? _value.riderName
          : riderName // ignore: cast_nullable_to_non_nullable
              as String,
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
      estimatedFare: null == estimatedFare
          ? _value.estimatedFare
          : estimatedFare // ignore: cast_nullable_to_non_nullable
              as double,
      distanceToPickupKm: null == distanceToPickupKm
          ? _value.distanceToPickupKm
          : distanceToPickupKm // ignore: cast_nullable_to_non_nullable
              as double,
      estimatedEtaMinutes: null == estimatedEtaMinutes
          ? _value.estimatedEtaMinutes
          : estimatedEtaMinutes // ignore: cast_nullable_to_non_nullable
              as int,
      vehicleType: null == vehicleType
          ? _value.vehicleType
          : vehicleType // ignore: cast_nullable_to_non_nullable
              as String,
      responseTimeoutSeconds: null == responseTimeoutSeconds
          ? _value.responseTimeoutSeconds
          : responseTimeoutSeconds // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$DriverDispatchNotificationImplCopyWith<$Res>
    implements $DriverDispatchNotificationCopyWith<$Res> {
  factory _$$DriverDispatchNotificationImplCopyWith(
          _$DriverDispatchNotificationImpl value,
          $Res Function(_$DriverDispatchNotificationImpl) then) =
      __$$DriverDispatchNotificationImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String tripId,
      String riderName,
      double pickupLatitude,
      double pickupLongitude,
      String pickupAddress,
      double dropoffLatitude,
      double dropoffLongitude,
      String dropoffAddress,
      double estimatedFare,
      double distanceToPickupKm,
      int estimatedEtaMinutes,
      String vehicleType,
      int responseTimeoutSeconds});
}

/// @nodoc
class __$$DriverDispatchNotificationImplCopyWithImpl<$Res>
    extends _$DriverDispatchNotificationCopyWithImpl<$Res,
        _$DriverDispatchNotificationImpl>
    implements _$$DriverDispatchNotificationImplCopyWith<$Res> {
  __$$DriverDispatchNotificationImplCopyWithImpl(
      _$DriverDispatchNotificationImpl _value,
      $Res Function(_$DriverDispatchNotificationImpl) _then)
      : super(_value, _then);

  /// Create a copy of DriverDispatchNotification
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? tripId = null,
    Object? riderName = null,
    Object? pickupLatitude = null,
    Object? pickupLongitude = null,
    Object? pickupAddress = null,
    Object? dropoffLatitude = null,
    Object? dropoffLongitude = null,
    Object? dropoffAddress = null,
    Object? estimatedFare = null,
    Object? distanceToPickupKm = null,
    Object? estimatedEtaMinutes = null,
    Object? vehicleType = null,
    Object? responseTimeoutSeconds = null,
  }) {
    return _then(_$DriverDispatchNotificationImpl(
      tripId: null == tripId
          ? _value.tripId
          : tripId // ignore: cast_nullable_to_non_nullable
              as String,
      riderName: null == riderName
          ? _value.riderName
          : riderName // ignore: cast_nullable_to_non_nullable
              as String,
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
      estimatedFare: null == estimatedFare
          ? _value.estimatedFare
          : estimatedFare // ignore: cast_nullable_to_non_nullable
              as double,
      distanceToPickupKm: null == distanceToPickupKm
          ? _value.distanceToPickupKm
          : distanceToPickupKm // ignore: cast_nullable_to_non_nullable
              as double,
      estimatedEtaMinutes: null == estimatedEtaMinutes
          ? _value.estimatedEtaMinutes
          : estimatedEtaMinutes // ignore: cast_nullable_to_non_nullable
              as int,
      vehicleType: null == vehicleType
          ? _value.vehicleType
          : vehicleType // ignore: cast_nullable_to_non_nullable
              as String,
      responseTimeoutSeconds: null == responseTimeoutSeconds
          ? _value.responseTimeoutSeconds
          : responseTimeoutSeconds // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$DriverDispatchNotificationImpl implements _DriverDispatchNotification {
  const _$DriverDispatchNotificationImpl(
      {required this.tripId,
      required this.riderName,
      required this.pickupLatitude,
      required this.pickupLongitude,
      required this.pickupAddress,
      required this.dropoffLatitude,
      required this.dropoffLongitude,
      required this.dropoffAddress,
      required this.estimatedFare,
      required this.distanceToPickupKm,
      required this.estimatedEtaMinutes,
      required this.vehicleType,
      required this.responseTimeoutSeconds});

  factory _$DriverDispatchNotificationImpl.fromJson(
          Map<String, dynamic> json) =>
      _$$DriverDispatchNotificationImplFromJson(json);

  @override
  final String tripId;
  @override
  final String riderName;
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
  final double estimatedFare;
  @override
  final double distanceToPickupKm;
  @override
  final int estimatedEtaMinutes;
  @override
  final String vehicleType;
  @override
  final int responseTimeoutSeconds;

  @override
  String toString() {
    return 'DriverDispatchNotification(tripId: $tripId, riderName: $riderName, pickupLatitude: $pickupLatitude, pickupLongitude: $pickupLongitude, pickupAddress: $pickupAddress, dropoffLatitude: $dropoffLatitude, dropoffLongitude: $dropoffLongitude, dropoffAddress: $dropoffAddress, estimatedFare: $estimatedFare, distanceToPickupKm: $distanceToPickupKm, estimatedEtaMinutes: $estimatedEtaMinutes, vehicleType: $vehicleType, responseTimeoutSeconds: $responseTimeoutSeconds)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DriverDispatchNotificationImpl &&
            (identical(other.tripId, tripId) || other.tripId == tripId) &&
            (identical(other.riderName, riderName) ||
                other.riderName == riderName) &&
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
            (identical(other.estimatedFare, estimatedFare) ||
                other.estimatedFare == estimatedFare) &&
            (identical(other.distanceToPickupKm, distanceToPickupKm) ||
                other.distanceToPickupKm == distanceToPickupKm) &&
            (identical(other.estimatedEtaMinutes, estimatedEtaMinutes) ||
                other.estimatedEtaMinutes == estimatedEtaMinutes) &&
            (identical(other.vehicleType, vehicleType) ||
                other.vehicleType == vehicleType) &&
            (identical(other.responseTimeoutSeconds, responseTimeoutSeconds) ||
                other.responseTimeoutSeconds == responseTimeoutSeconds));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      tripId,
      riderName,
      pickupLatitude,
      pickupLongitude,
      pickupAddress,
      dropoffLatitude,
      dropoffLongitude,
      dropoffAddress,
      estimatedFare,
      distanceToPickupKm,
      estimatedEtaMinutes,
      vehicleType,
      responseTimeoutSeconds);

  /// Create a copy of DriverDispatchNotification
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DriverDispatchNotificationImplCopyWith<_$DriverDispatchNotificationImpl>
      get copyWith => __$$DriverDispatchNotificationImplCopyWithImpl<
          _$DriverDispatchNotificationImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DriverDispatchNotificationImplToJson(
      this,
    );
  }
}

abstract class _DriverDispatchNotification
    implements DriverDispatchNotification {
  const factory _DriverDispatchNotification(
          {required final String tripId,
          required final String riderName,
          required final double pickupLatitude,
          required final double pickupLongitude,
          required final String pickupAddress,
          required final double dropoffLatitude,
          required final double dropoffLongitude,
          required final String dropoffAddress,
          required final double estimatedFare,
          required final double distanceToPickupKm,
          required final int estimatedEtaMinutes,
          required final String vehicleType,
          required final int responseTimeoutSeconds}) =
      _$DriverDispatchNotificationImpl;

  factory _DriverDispatchNotification.fromJson(Map<String, dynamic> json) =
      _$DriverDispatchNotificationImpl.fromJson;

  @override
  String get tripId;
  @override
  String get riderName;
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
  double get estimatedFare;
  @override
  double get distanceToPickupKm;
  @override
  int get estimatedEtaMinutes;
  @override
  String get vehicleType;
  @override
  int get responseTimeoutSeconds;

  /// Create a copy of DriverDispatchNotification
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DriverDispatchNotificationImplCopyWith<_$DriverDispatchNotificationImpl>
      get copyWith => throw _privateConstructorUsedError;
}

DriverDispatchResponse _$DriverDispatchResponseFromJson(
    Map<String, dynamic> json) {
  return _DriverDispatchResponse.fromJson(json);
}

/// @nodoc
mixin _$DriverDispatchResponse {
  String get tripId => throw _privateConstructorUsedError;
  String get driverId => throw _privateConstructorUsedError;
  DispatchResponseType get responseType => throw _privateConstructorUsedError;
  String? get reason => throw _privateConstructorUsedError;

  /// Serializes this DriverDispatchResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DriverDispatchResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DriverDispatchResponseCopyWith<DriverDispatchResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DriverDispatchResponseCopyWith<$Res> {
  factory $DriverDispatchResponseCopyWith(DriverDispatchResponse value,
          $Res Function(DriverDispatchResponse) then) =
      _$DriverDispatchResponseCopyWithImpl<$Res, DriverDispatchResponse>;
  @useResult
  $Res call(
      {String tripId,
      String driverId,
      DispatchResponseType responseType,
      String? reason});
}

/// @nodoc
class _$DriverDispatchResponseCopyWithImpl<$Res,
        $Val extends DriverDispatchResponse>
    implements $DriverDispatchResponseCopyWith<$Res> {
  _$DriverDispatchResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DriverDispatchResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? tripId = null,
    Object? driverId = null,
    Object? responseType = null,
    Object? reason = freezed,
  }) {
    return _then(_value.copyWith(
      tripId: null == tripId
          ? _value.tripId
          : tripId // ignore: cast_nullable_to_non_nullable
              as String,
      driverId: null == driverId
          ? _value.driverId
          : driverId // ignore: cast_nullable_to_non_nullable
              as String,
      responseType: null == responseType
          ? _value.responseType
          : responseType // ignore: cast_nullable_to_non_nullable
              as DispatchResponseType,
      reason: freezed == reason
          ? _value.reason
          : reason // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$DriverDispatchResponseImplCopyWith<$Res>
    implements $DriverDispatchResponseCopyWith<$Res> {
  factory _$$DriverDispatchResponseImplCopyWith(
          _$DriverDispatchResponseImpl value,
          $Res Function(_$DriverDispatchResponseImpl) then) =
      __$$DriverDispatchResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String tripId,
      String driverId,
      DispatchResponseType responseType,
      String? reason});
}

/// @nodoc
class __$$DriverDispatchResponseImplCopyWithImpl<$Res>
    extends _$DriverDispatchResponseCopyWithImpl<$Res,
        _$DriverDispatchResponseImpl>
    implements _$$DriverDispatchResponseImplCopyWith<$Res> {
  __$$DriverDispatchResponseImplCopyWithImpl(
      _$DriverDispatchResponseImpl _value,
      $Res Function(_$DriverDispatchResponseImpl) _then)
      : super(_value, _then);

  /// Create a copy of DriverDispatchResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? tripId = null,
    Object? driverId = null,
    Object? responseType = null,
    Object? reason = freezed,
  }) {
    return _then(_$DriverDispatchResponseImpl(
      tripId: null == tripId
          ? _value.tripId
          : tripId // ignore: cast_nullable_to_non_nullable
              as String,
      driverId: null == driverId
          ? _value.driverId
          : driverId // ignore: cast_nullable_to_non_nullable
              as String,
      responseType: null == responseType
          ? _value.responseType
          : responseType // ignore: cast_nullable_to_non_nullable
              as DispatchResponseType,
      reason: freezed == reason
          ? _value.reason
          : reason // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$DriverDispatchResponseImpl implements _DriverDispatchResponse {
  const _$DriverDispatchResponseImpl(
      {required this.tripId,
      required this.driverId,
      required this.responseType,
      this.reason});

  factory _$DriverDispatchResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$DriverDispatchResponseImplFromJson(json);

  @override
  final String tripId;
  @override
  final String driverId;
  @override
  final DispatchResponseType responseType;
  @override
  final String? reason;

  @override
  String toString() {
    return 'DriverDispatchResponse(tripId: $tripId, driverId: $driverId, responseType: $responseType, reason: $reason)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DriverDispatchResponseImpl &&
            (identical(other.tripId, tripId) || other.tripId == tripId) &&
            (identical(other.driverId, driverId) ||
                other.driverId == driverId) &&
            (identical(other.responseType, responseType) ||
                other.responseType == responseType) &&
            (identical(other.reason, reason) || other.reason == reason));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, tripId, driverId, responseType, reason);

  /// Create a copy of DriverDispatchResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DriverDispatchResponseImplCopyWith<_$DriverDispatchResponseImpl>
      get copyWith => __$$DriverDispatchResponseImplCopyWithImpl<
          _$DriverDispatchResponseImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DriverDispatchResponseImplToJson(
      this,
    );
  }
}

abstract class _DriverDispatchResponse implements DriverDispatchResponse {
  const factory _DriverDispatchResponse(
      {required final String tripId,
      required final String driverId,
      required final DispatchResponseType responseType,
      final String? reason}) = _$DriverDispatchResponseImpl;

  factory _DriverDispatchResponse.fromJson(Map<String, dynamic> json) =
      _$DriverDispatchResponseImpl.fromJson;

  @override
  String get tripId;
  @override
  String get driverId;
  @override
  DispatchResponseType get responseType;
  @override
  String? get reason;

  /// Create a copy of DriverDispatchResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DriverDispatchResponseImplCopyWith<_$DriverDispatchResponseImpl>
      get copyWith => throw _privateConstructorUsedError;
}
