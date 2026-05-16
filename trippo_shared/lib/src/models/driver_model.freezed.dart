// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'driver_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

DriverModel _$DriverModelFromJson(Map<String, dynamic> json) {
  return _DriverModel.fromJson(json);
}

/// @nodoc
mixin _$DriverModel {
  String get id => throw _privateConstructorUsedError;
  String get email => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String? get phone => throw _privateConstructorUsedError;
  String? get countryCode => throw _privateConstructorUsedError;
  String? get profileImageUrl => throw _privateConstructorUsedError;
  VehicleModel get vehicle => throw _privateConstructorUsedError;
  DriverStatus get status => throw _privateConstructorUsedError;
  LocationModel? get currentLocation => throw _privateConstructorUsedError;
  LocationModel? get lastKnownLocation => throw _privateConstructorUsedError;
  double get averageRating => throw _privateConstructorUsedError;
  int get totalTrips => throw _privateConstructorUsedError;
  int get completedTrips => throw _privateConstructorUsedError;
  int get cancelledTrips => throw _privateConstructorUsedError;
  double get acceptanceRate => throw _privateConstructorUsedError;
  double get cancellationRate => throw _privateConstructorUsedError;
  String? get fcmToken => throw _privateConstructorUsedError;
  bool get isEmailVerified => throw _privateConstructorUsedError;
  bool get isPhoneVerified => throw _privateConstructorUsedError;
  bool get isDocumentsVerified => throw _privateConstructorUsedError;
  bool get isBanned => throw _privateConstructorUsedError;
  bool get isActive => throw _privateConstructorUsedError;
  double get walletBalance => throw _privateConstructorUsedError;
  double get totalEarnings => throw _privateConstructorUsedError;
  DateTime? get lastOnlineAt => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this DriverModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DriverModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DriverModelCopyWith<DriverModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DriverModelCopyWith<$Res> {
  factory $DriverModelCopyWith(
          DriverModel value, $Res Function(DriverModel) then) =
      _$DriverModelCopyWithImpl<$Res, DriverModel>;
  @useResult
  $Res call(
      {String id,
      String email,
      String name,
      String? phone,
      String? countryCode,
      String? profileImageUrl,
      VehicleModel vehicle,
      DriverStatus status,
      LocationModel? currentLocation,
      LocationModel? lastKnownLocation,
      double averageRating,
      int totalTrips,
      int completedTrips,
      int cancelledTrips,
      double acceptanceRate,
      double cancellationRate,
      String? fcmToken,
      bool isEmailVerified,
      bool isPhoneVerified,
      bool isDocumentsVerified,
      bool isBanned,
      bool isActive,
      double walletBalance,
      double totalEarnings,
      DateTime? lastOnlineAt,
      DateTime? createdAt,
      DateTime? updatedAt});

  $VehicleModelCopyWith<$Res> get vehicle;
  $LocationModelCopyWith<$Res>? get currentLocation;
  $LocationModelCopyWith<$Res>? get lastKnownLocation;
}

/// @nodoc
class _$DriverModelCopyWithImpl<$Res, $Val extends DriverModel>
    implements $DriverModelCopyWith<$Res> {
  _$DriverModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DriverModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? email = null,
    Object? name = null,
    Object? phone = freezed,
    Object? countryCode = freezed,
    Object? profileImageUrl = freezed,
    Object? vehicle = null,
    Object? status = null,
    Object? currentLocation = freezed,
    Object? lastKnownLocation = freezed,
    Object? averageRating = null,
    Object? totalTrips = null,
    Object? completedTrips = null,
    Object? cancelledTrips = null,
    Object? acceptanceRate = null,
    Object? cancellationRate = null,
    Object? fcmToken = freezed,
    Object? isEmailVerified = null,
    Object? isPhoneVerified = null,
    Object? isDocumentsVerified = null,
    Object? isBanned = null,
    Object? isActive = null,
    Object? walletBalance = null,
    Object? totalEarnings = null,
    Object? lastOnlineAt = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      email: null == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      phone: freezed == phone
          ? _value.phone
          : phone // ignore: cast_nullable_to_non_nullable
              as String?,
      countryCode: freezed == countryCode
          ? _value.countryCode
          : countryCode // ignore: cast_nullable_to_non_nullable
              as String?,
      profileImageUrl: freezed == profileImageUrl
          ? _value.profileImageUrl
          : profileImageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      vehicle: null == vehicle
          ? _value.vehicle
          : vehicle // ignore: cast_nullable_to_non_nullable
              as VehicleModel,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as DriverStatus,
      currentLocation: freezed == currentLocation
          ? _value.currentLocation
          : currentLocation // ignore: cast_nullable_to_non_nullable
              as LocationModel?,
      lastKnownLocation: freezed == lastKnownLocation
          ? _value.lastKnownLocation
          : lastKnownLocation // ignore: cast_nullable_to_non_nullable
              as LocationModel?,
      averageRating: null == averageRating
          ? _value.averageRating
          : averageRating // ignore: cast_nullable_to_non_nullable
              as double,
      totalTrips: null == totalTrips
          ? _value.totalTrips
          : totalTrips // ignore: cast_nullable_to_non_nullable
              as int,
      completedTrips: null == completedTrips
          ? _value.completedTrips
          : completedTrips // ignore: cast_nullable_to_non_nullable
              as int,
      cancelledTrips: null == cancelledTrips
          ? _value.cancelledTrips
          : cancelledTrips // ignore: cast_nullable_to_non_nullable
              as int,
      acceptanceRate: null == acceptanceRate
          ? _value.acceptanceRate
          : acceptanceRate // ignore: cast_nullable_to_non_nullable
              as double,
      cancellationRate: null == cancellationRate
          ? _value.cancellationRate
          : cancellationRate // ignore: cast_nullable_to_non_nullable
              as double,
      fcmToken: freezed == fcmToken
          ? _value.fcmToken
          : fcmToken // ignore: cast_nullable_to_non_nullable
              as String?,
      isEmailVerified: null == isEmailVerified
          ? _value.isEmailVerified
          : isEmailVerified // ignore: cast_nullable_to_non_nullable
              as bool,
      isPhoneVerified: null == isPhoneVerified
          ? _value.isPhoneVerified
          : isPhoneVerified // ignore: cast_nullable_to_non_nullable
              as bool,
      isDocumentsVerified: null == isDocumentsVerified
          ? _value.isDocumentsVerified
          : isDocumentsVerified // ignore: cast_nullable_to_non_nullable
              as bool,
      isBanned: null == isBanned
          ? _value.isBanned
          : isBanned // ignore: cast_nullable_to_non_nullable
              as bool,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      walletBalance: null == walletBalance
          ? _value.walletBalance
          : walletBalance // ignore: cast_nullable_to_non_nullable
              as double,
      totalEarnings: null == totalEarnings
          ? _value.totalEarnings
          : totalEarnings // ignore: cast_nullable_to_non_nullable
              as double,
      lastOnlineAt: freezed == lastOnlineAt
          ? _value.lastOnlineAt
          : lastOnlineAt // ignore: cast_nullable_to_non_nullable
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

  /// Create a copy of DriverModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $VehicleModelCopyWith<$Res> get vehicle {
    return $VehicleModelCopyWith<$Res>(_value.vehicle, (value) {
      return _then(_value.copyWith(vehicle: value) as $Val);
    });
  }

  /// Create a copy of DriverModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $LocationModelCopyWith<$Res>? get currentLocation {
    if (_value.currentLocation == null) {
      return null;
    }

    return $LocationModelCopyWith<$Res>(_value.currentLocation!, (value) {
      return _then(_value.copyWith(currentLocation: value) as $Val);
    });
  }

  /// Create a copy of DriverModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $LocationModelCopyWith<$Res>? get lastKnownLocation {
    if (_value.lastKnownLocation == null) {
      return null;
    }

    return $LocationModelCopyWith<$Res>(_value.lastKnownLocation!, (value) {
      return _then(_value.copyWith(lastKnownLocation: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$DriverModelImplCopyWith<$Res>
    implements $DriverModelCopyWith<$Res> {
  factory _$$DriverModelImplCopyWith(
          _$DriverModelImpl value, $Res Function(_$DriverModelImpl) then) =
      __$$DriverModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String email,
      String name,
      String? phone,
      String? countryCode,
      String? profileImageUrl,
      VehicleModel vehicle,
      DriverStatus status,
      LocationModel? currentLocation,
      LocationModel? lastKnownLocation,
      double averageRating,
      int totalTrips,
      int completedTrips,
      int cancelledTrips,
      double acceptanceRate,
      double cancellationRate,
      String? fcmToken,
      bool isEmailVerified,
      bool isPhoneVerified,
      bool isDocumentsVerified,
      bool isBanned,
      bool isActive,
      double walletBalance,
      double totalEarnings,
      DateTime? lastOnlineAt,
      DateTime? createdAt,
      DateTime? updatedAt});

  @override
  $VehicleModelCopyWith<$Res> get vehicle;
  @override
  $LocationModelCopyWith<$Res>? get currentLocation;
  @override
  $LocationModelCopyWith<$Res>? get lastKnownLocation;
}

/// @nodoc
class __$$DriverModelImplCopyWithImpl<$Res>
    extends _$DriverModelCopyWithImpl<$Res, _$DriverModelImpl>
    implements _$$DriverModelImplCopyWith<$Res> {
  __$$DriverModelImplCopyWithImpl(
      _$DriverModelImpl _value, $Res Function(_$DriverModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of DriverModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? email = null,
    Object? name = null,
    Object? phone = freezed,
    Object? countryCode = freezed,
    Object? profileImageUrl = freezed,
    Object? vehicle = null,
    Object? status = null,
    Object? currentLocation = freezed,
    Object? lastKnownLocation = freezed,
    Object? averageRating = null,
    Object? totalTrips = null,
    Object? completedTrips = null,
    Object? cancelledTrips = null,
    Object? acceptanceRate = null,
    Object? cancellationRate = null,
    Object? fcmToken = freezed,
    Object? isEmailVerified = null,
    Object? isPhoneVerified = null,
    Object? isDocumentsVerified = null,
    Object? isBanned = null,
    Object? isActive = null,
    Object? walletBalance = null,
    Object? totalEarnings = null,
    Object? lastOnlineAt = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_$DriverModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      email: null == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      phone: freezed == phone
          ? _value.phone
          : phone // ignore: cast_nullable_to_non_nullable
              as String?,
      countryCode: freezed == countryCode
          ? _value.countryCode
          : countryCode // ignore: cast_nullable_to_non_nullable
              as String?,
      profileImageUrl: freezed == profileImageUrl
          ? _value.profileImageUrl
          : profileImageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      vehicle: null == vehicle
          ? _value.vehicle
          : vehicle // ignore: cast_nullable_to_non_nullable
              as VehicleModel,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as DriverStatus,
      currentLocation: freezed == currentLocation
          ? _value.currentLocation
          : currentLocation // ignore: cast_nullable_to_non_nullable
              as LocationModel?,
      lastKnownLocation: freezed == lastKnownLocation
          ? _value.lastKnownLocation
          : lastKnownLocation // ignore: cast_nullable_to_non_nullable
              as LocationModel?,
      averageRating: null == averageRating
          ? _value.averageRating
          : averageRating // ignore: cast_nullable_to_non_nullable
              as double,
      totalTrips: null == totalTrips
          ? _value.totalTrips
          : totalTrips // ignore: cast_nullable_to_non_nullable
              as int,
      completedTrips: null == completedTrips
          ? _value.completedTrips
          : completedTrips // ignore: cast_nullable_to_non_nullable
              as int,
      cancelledTrips: null == cancelledTrips
          ? _value.cancelledTrips
          : cancelledTrips // ignore: cast_nullable_to_non_nullable
              as int,
      acceptanceRate: null == acceptanceRate
          ? _value.acceptanceRate
          : acceptanceRate // ignore: cast_nullable_to_non_nullable
              as double,
      cancellationRate: null == cancellationRate
          ? _value.cancellationRate
          : cancellationRate // ignore: cast_nullable_to_non_nullable
              as double,
      fcmToken: freezed == fcmToken
          ? _value.fcmToken
          : fcmToken // ignore: cast_nullable_to_non_nullable
              as String?,
      isEmailVerified: null == isEmailVerified
          ? _value.isEmailVerified
          : isEmailVerified // ignore: cast_nullable_to_non_nullable
              as bool,
      isPhoneVerified: null == isPhoneVerified
          ? _value.isPhoneVerified
          : isPhoneVerified // ignore: cast_nullable_to_non_nullable
              as bool,
      isDocumentsVerified: null == isDocumentsVerified
          ? _value.isDocumentsVerified
          : isDocumentsVerified // ignore: cast_nullable_to_non_nullable
              as bool,
      isBanned: null == isBanned
          ? _value.isBanned
          : isBanned // ignore: cast_nullable_to_non_nullable
              as bool,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      walletBalance: null == walletBalance
          ? _value.walletBalance
          : walletBalance // ignore: cast_nullable_to_non_nullable
              as double,
      totalEarnings: null == totalEarnings
          ? _value.totalEarnings
          : totalEarnings // ignore: cast_nullable_to_non_nullable
              as double,
      lastOnlineAt: freezed == lastOnlineAt
          ? _value.lastOnlineAt
          : lastOnlineAt // ignore: cast_nullable_to_non_nullable
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
class _$DriverModelImpl implements _DriverModel {
  const _$DriverModelImpl(
      {required this.id,
      required this.email,
      required this.name,
      this.phone,
      this.countryCode,
      this.profileImageUrl,
      required this.vehicle,
      this.status = DriverStatus.offline,
      this.currentLocation,
      this.lastKnownLocation,
      this.averageRating = 0.0,
      this.totalTrips = 0,
      this.completedTrips = 0,
      this.cancelledTrips = 0,
      this.acceptanceRate = 0.0,
      this.cancellationRate = 0.0,
      this.fcmToken,
      this.isEmailVerified = false,
      this.isPhoneVerified = false,
      this.isDocumentsVerified = false,
      this.isBanned = false,
      this.isActive = false,
      this.walletBalance = 0,
      this.totalEarnings = 0,
      this.lastOnlineAt,
      this.createdAt,
      this.updatedAt});

  factory _$DriverModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$DriverModelImplFromJson(json);

  @override
  final String id;
  @override
  final String email;
  @override
  final String name;
  @override
  final String? phone;
  @override
  final String? countryCode;
  @override
  final String? profileImageUrl;
  @override
  final VehicleModel vehicle;
  @override
  @JsonKey()
  final DriverStatus status;
  @override
  final LocationModel? currentLocation;
  @override
  final LocationModel? lastKnownLocation;
  @override
  @JsonKey()
  final double averageRating;
  @override
  @JsonKey()
  final int totalTrips;
  @override
  @JsonKey()
  final int completedTrips;
  @override
  @JsonKey()
  final int cancelledTrips;
  @override
  @JsonKey()
  final double acceptanceRate;
  @override
  @JsonKey()
  final double cancellationRate;
  @override
  final String? fcmToken;
  @override
  @JsonKey()
  final bool isEmailVerified;
  @override
  @JsonKey()
  final bool isPhoneVerified;
  @override
  @JsonKey()
  final bool isDocumentsVerified;
  @override
  @JsonKey()
  final bool isBanned;
  @override
  @JsonKey()
  final bool isActive;
  @override
  @JsonKey()
  final double walletBalance;
  @override
  @JsonKey()
  final double totalEarnings;
  @override
  final DateTime? lastOnlineAt;
  @override
  final DateTime? createdAt;
  @override
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'DriverModel(id: $id, email: $email, name: $name, phone: $phone, countryCode: $countryCode, profileImageUrl: $profileImageUrl, vehicle: $vehicle, status: $status, currentLocation: $currentLocation, lastKnownLocation: $lastKnownLocation, averageRating: $averageRating, totalTrips: $totalTrips, completedTrips: $completedTrips, cancelledTrips: $cancelledTrips, acceptanceRate: $acceptanceRate, cancellationRate: $cancellationRate, fcmToken: $fcmToken, isEmailVerified: $isEmailVerified, isPhoneVerified: $isPhoneVerified, isDocumentsVerified: $isDocumentsVerified, isBanned: $isBanned, isActive: $isActive, walletBalance: $walletBalance, totalEarnings: $totalEarnings, lastOnlineAt: $lastOnlineAt, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DriverModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.phone, phone) || other.phone == phone) &&
            (identical(other.countryCode, countryCode) ||
                other.countryCode == countryCode) &&
            (identical(other.profileImageUrl, profileImageUrl) ||
                other.profileImageUrl == profileImageUrl) &&
            (identical(other.vehicle, vehicle) || other.vehicle == vehicle) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.currentLocation, currentLocation) ||
                other.currentLocation == currentLocation) &&
            (identical(other.lastKnownLocation, lastKnownLocation) ||
                other.lastKnownLocation == lastKnownLocation) &&
            (identical(other.averageRating, averageRating) ||
                other.averageRating == averageRating) &&
            (identical(other.totalTrips, totalTrips) ||
                other.totalTrips == totalTrips) &&
            (identical(other.completedTrips, completedTrips) ||
                other.completedTrips == completedTrips) &&
            (identical(other.cancelledTrips, cancelledTrips) ||
                other.cancelledTrips == cancelledTrips) &&
            (identical(other.acceptanceRate, acceptanceRate) ||
                other.acceptanceRate == acceptanceRate) &&
            (identical(other.cancellationRate, cancellationRate) ||
                other.cancellationRate == cancellationRate) &&
            (identical(other.fcmToken, fcmToken) ||
                other.fcmToken == fcmToken) &&
            (identical(other.isEmailVerified, isEmailVerified) ||
                other.isEmailVerified == isEmailVerified) &&
            (identical(other.isPhoneVerified, isPhoneVerified) ||
                other.isPhoneVerified == isPhoneVerified) &&
            (identical(other.isDocumentsVerified, isDocumentsVerified) ||
                other.isDocumentsVerified == isDocumentsVerified) &&
            (identical(other.isBanned, isBanned) ||
                other.isBanned == isBanned) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.walletBalance, walletBalance) ||
                other.walletBalance == walletBalance) &&
            (identical(other.totalEarnings, totalEarnings) ||
                other.totalEarnings == totalEarnings) &&
            (identical(other.lastOnlineAt, lastOnlineAt) ||
                other.lastOnlineAt == lastOnlineAt) &&
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
        email,
        name,
        phone,
        countryCode,
        profileImageUrl,
        vehicle,
        status,
        currentLocation,
        lastKnownLocation,
        averageRating,
        totalTrips,
        completedTrips,
        cancelledTrips,
        acceptanceRate,
        cancellationRate,
        fcmToken,
        isEmailVerified,
        isPhoneVerified,
        isDocumentsVerified,
        isBanned,
        isActive,
        walletBalance,
        totalEarnings,
        lastOnlineAt,
        createdAt,
        updatedAt
      ]);

  /// Create a copy of DriverModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DriverModelImplCopyWith<_$DriverModelImpl> get copyWith =>
      __$$DriverModelImplCopyWithImpl<_$DriverModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DriverModelImplToJson(
      this,
    );
  }
}

abstract class _DriverModel implements DriverModel {
  const factory _DriverModel(
      {required final String id,
      required final String email,
      required final String name,
      final String? phone,
      final String? countryCode,
      final String? profileImageUrl,
      required final VehicleModel vehicle,
      final DriverStatus status,
      final LocationModel? currentLocation,
      final LocationModel? lastKnownLocation,
      final double averageRating,
      final int totalTrips,
      final int completedTrips,
      final int cancelledTrips,
      final double acceptanceRate,
      final double cancellationRate,
      final String? fcmToken,
      final bool isEmailVerified,
      final bool isPhoneVerified,
      final bool isDocumentsVerified,
      final bool isBanned,
      final bool isActive,
      final double walletBalance,
      final double totalEarnings,
      final DateTime? lastOnlineAt,
      final DateTime? createdAt,
      final DateTime? updatedAt}) = _$DriverModelImpl;

  factory _DriverModel.fromJson(Map<String, dynamic> json) =
      _$DriverModelImpl.fromJson;

  @override
  String get id;
  @override
  String get email;
  @override
  String get name;
  @override
  String? get phone;
  @override
  String? get countryCode;
  @override
  String? get profileImageUrl;
  @override
  VehicleModel get vehicle;
  @override
  DriverStatus get status;
  @override
  LocationModel? get currentLocation;
  @override
  LocationModel? get lastKnownLocation;
  @override
  double get averageRating;
  @override
  int get totalTrips;
  @override
  int get completedTrips;
  @override
  int get cancelledTrips;
  @override
  double get acceptanceRate;
  @override
  double get cancellationRate;
  @override
  String? get fcmToken;
  @override
  bool get isEmailVerified;
  @override
  bool get isPhoneVerified;
  @override
  bool get isDocumentsVerified;
  @override
  bool get isBanned;
  @override
  bool get isActive;
  @override
  double get walletBalance;
  @override
  double get totalEarnings;
  @override
  DateTime? get lastOnlineAt;
  @override
  DateTime? get createdAt;
  @override
  DateTime? get updatedAt;

  /// Create a copy of DriverModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DriverModelImplCopyWith<_$DriverModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

DriverDocument _$DriverDocumentFromJson(Map<String, dynamic> json) {
  return _DriverDocument.fromJson(json);
}

/// @nodoc
mixin _$DriverDocument {
  String get id => throw _privateConstructorUsedError;
  String get driverId => throw _privateConstructorUsedError;
  DocumentType get type => throw _privateConstructorUsedError;
  String get documentUrl => throw _privateConstructorUsedError;
  DocumentStatus get status => throw _privateConstructorUsedError;
  String? get rejectionReason => throw _privateConstructorUsedError;
  DateTime? get uploadedAt => throw _privateConstructorUsedError;
  DateTime? get verifiedAt => throw _privateConstructorUsedError;
  DateTime? get expiresAt => throw _privateConstructorUsedError;

  /// Serializes this DriverDocument to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DriverDocument
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DriverDocumentCopyWith<DriverDocument> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DriverDocumentCopyWith<$Res> {
  factory $DriverDocumentCopyWith(
          DriverDocument value, $Res Function(DriverDocument) then) =
      _$DriverDocumentCopyWithImpl<$Res, DriverDocument>;
  @useResult
  $Res call(
      {String id,
      String driverId,
      DocumentType type,
      String documentUrl,
      DocumentStatus status,
      String? rejectionReason,
      DateTime? uploadedAt,
      DateTime? verifiedAt,
      DateTime? expiresAt});
}

/// @nodoc
class _$DriverDocumentCopyWithImpl<$Res, $Val extends DriverDocument>
    implements $DriverDocumentCopyWith<$Res> {
  _$DriverDocumentCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DriverDocument
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? driverId = null,
    Object? type = null,
    Object? documentUrl = null,
    Object? status = null,
    Object? rejectionReason = freezed,
    Object? uploadedAt = freezed,
    Object? verifiedAt = freezed,
    Object? expiresAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      driverId: null == driverId
          ? _value.driverId
          : driverId // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as DocumentType,
      documentUrl: null == documentUrl
          ? _value.documentUrl
          : documentUrl // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as DocumentStatus,
      rejectionReason: freezed == rejectionReason
          ? _value.rejectionReason
          : rejectionReason // ignore: cast_nullable_to_non_nullable
              as String?,
      uploadedAt: freezed == uploadedAt
          ? _value.uploadedAt
          : uploadedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      verifiedAt: freezed == verifiedAt
          ? _value.verifiedAt
          : verifiedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      expiresAt: freezed == expiresAt
          ? _value.expiresAt
          : expiresAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$DriverDocumentImplCopyWith<$Res>
    implements $DriverDocumentCopyWith<$Res> {
  factory _$$DriverDocumentImplCopyWith(_$DriverDocumentImpl value,
          $Res Function(_$DriverDocumentImpl) then) =
      __$$DriverDocumentImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String driverId,
      DocumentType type,
      String documentUrl,
      DocumentStatus status,
      String? rejectionReason,
      DateTime? uploadedAt,
      DateTime? verifiedAt,
      DateTime? expiresAt});
}

/// @nodoc
class __$$DriverDocumentImplCopyWithImpl<$Res>
    extends _$DriverDocumentCopyWithImpl<$Res, _$DriverDocumentImpl>
    implements _$$DriverDocumentImplCopyWith<$Res> {
  __$$DriverDocumentImplCopyWithImpl(
      _$DriverDocumentImpl _value, $Res Function(_$DriverDocumentImpl) _then)
      : super(_value, _then);

  /// Create a copy of DriverDocument
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? driverId = null,
    Object? type = null,
    Object? documentUrl = null,
    Object? status = null,
    Object? rejectionReason = freezed,
    Object? uploadedAt = freezed,
    Object? verifiedAt = freezed,
    Object? expiresAt = freezed,
  }) {
    return _then(_$DriverDocumentImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      driverId: null == driverId
          ? _value.driverId
          : driverId // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as DocumentType,
      documentUrl: null == documentUrl
          ? _value.documentUrl
          : documentUrl // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as DocumentStatus,
      rejectionReason: freezed == rejectionReason
          ? _value.rejectionReason
          : rejectionReason // ignore: cast_nullable_to_non_nullable
              as String?,
      uploadedAt: freezed == uploadedAt
          ? _value.uploadedAt
          : uploadedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      verifiedAt: freezed == verifiedAt
          ? _value.verifiedAt
          : verifiedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      expiresAt: freezed == expiresAt
          ? _value.expiresAt
          : expiresAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$DriverDocumentImpl implements _DriverDocument {
  const _$DriverDocumentImpl(
      {required this.id,
      required this.driverId,
      required this.type,
      required this.documentUrl,
      this.status = DocumentStatus.pending,
      this.rejectionReason,
      this.uploadedAt,
      this.verifiedAt,
      this.expiresAt});

  factory _$DriverDocumentImpl.fromJson(Map<String, dynamic> json) =>
      _$$DriverDocumentImplFromJson(json);

  @override
  final String id;
  @override
  final String driverId;
  @override
  final DocumentType type;
  @override
  final String documentUrl;
  @override
  @JsonKey()
  final DocumentStatus status;
  @override
  final String? rejectionReason;
  @override
  final DateTime? uploadedAt;
  @override
  final DateTime? verifiedAt;
  @override
  final DateTime? expiresAt;

  @override
  String toString() {
    return 'DriverDocument(id: $id, driverId: $driverId, type: $type, documentUrl: $documentUrl, status: $status, rejectionReason: $rejectionReason, uploadedAt: $uploadedAt, verifiedAt: $verifiedAt, expiresAt: $expiresAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DriverDocumentImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.driverId, driverId) ||
                other.driverId == driverId) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.documentUrl, documentUrl) ||
                other.documentUrl == documentUrl) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.rejectionReason, rejectionReason) ||
                other.rejectionReason == rejectionReason) &&
            (identical(other.uploadedAt, uploadedAt) ||
                other.uploadedAt == uploadedAt) &&
            (identical(other.verifiedAt, verifiedAt) ||
                other.verifiedAt == verifiedAt) &&
            (identical(other.expiresAt, expiresAt) ||
                other.expiresAt == expiresAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, driverId, type, documentUrl,
      status, rejectionReason, uploadedAt, verifiedAt, expiresAt);

  /// Create a copy of DriverDocument
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DriverDocumentImplCopyWith<_$DriverDocumentImpl> get copyWith =>
      __$$DriverDocumentImplCopyWithImpl<_$DriverDocumentImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DriverDocumentImplToJson(
      this,
    );
  }
}

abstract class _DriverDocument implements DriverDocument {
  const factory _DriverDocument(
      {required final String id,
      required final String driverId,
      required final DocumentType type,
      required final String documentUrl,
      final DocumentStatus status,
      final String? rejectionReason,
      final DateTime? uploadedAt,
      final DateTime? verifiedAt,
      final DateTime? expiresAt}) = _$DriverDocumentImpl;

  factory _DriverDocument.fromJson(Map<String, dynamic> json) =
      _$DriverDocumentImpl.fromJson;

  @override
  String get id;
  @override
  String get driverId;
  @override
  DocumentType get type;
  @override
  String get documentUrl;
  @override
  DocumentStatus get status;
  @override
  String? get rejectionReason;
  @override
  DateTime? get uploadedAt;
  @override
  DateTime? get verifiedAt;
  @override
  DateTime? get expiresAt;

  /// Create a copy of DriverDocument
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DriverDocumentImplCopyWith<_$DriverDocumentImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

DriverScore _$DriverScoreFromJson(Map<String, dynamic> json) {
  return _DriverScore.fromJson(json);
}

/// @nodoc
mixin _$DriverScore {
  String get driverId => throw _privateConstructorUsedError;
  double get totalScore => throw _privateConstructorUsedError;
  double get proximityScore => throw _privateConstructorUsedError;
  double get ratingScore => throw _privateConstructorUsedError;
  double get acceptanceRateScore => throw _privateConstructorUsedError;
  double get etaScore => throw _privateConstructorUsedError;
  int get estimatedEtaMinutes => throw _privateConstructorUsedError;
  double get distanceToPickupKm => throw _privateConstructorUsedError;

  /// Serializes this DriverScore to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DriverScore
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DriverScoreCopyWith<DriverScore> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DriverScoreCopyWith<$Res> {
  factory $DriverScoreCopyWith(
          DriverScore value, $Res Function(DriverScore) then) =
      _$DriverScoreCopyWithImpl<$Res, DriverScore>;
  @useResult
  $Res call(
      {String driverId,
      double totalScore,
      double proximityScore,
      double ratingScore,
      double acceptanceRateScore,
      double etaScore,
      int estimatedEtaMinutes,
      double distanceToPickupKm});
}

/// @nodoc
class _$DriverScoreCopyWithImpl<$Res, $Val extends DriverScore>
    implements $DriverScoreCopyWith<$Res> {
  _$DriverScoreCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DriverScore
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? driverId = null,
    Object? totalScore = null,
    Object? proximityScore = null,
    Object? ratingScore = null,
    Object? acceptanceRateScore = null,
    Object? etaScore = null,
    Object? estimatedEtaMinutes = null,
    Object? distanceToPickupKm = null,
  }) {
    return _then(_value.copyWith(
      driverId: null == driverId
          ? _value.driverId
          : driverId // ignore: cast_nullable_to_non_nullable
              as String,
      totalScore: null == totalScore
          ? _value.totalScore
          : totalScore // ignore: cast_nullable_to_non_nullable
              as double,
      proximityScore: null == proximityScore
          ? _value.proximityScore
          : proximityScore // ignore: cast_nullable_to_non_nullable
              as double,
      ratingScore: null == ratingScore
          ? _value.ratingScore
          : ratingScore // ignore: cast_nullable_to_non_nullable
              as double,
      acceptanceRateScore: null == acceptanceRateScore
          ? _value.acceptanceRateScore
          : acceptanceRateScore // ignore: cast_nullable_to_non_nullable
              as double,
      etaScore: null == etaScore
          ? _value.etaScore
          : etaScore // ignore: cast_nullable_to_non_nullable
              as double,
      estimatedEtaMinutes: null == estimatedEtaMinutes
          ? _value.estimatedEtaMinutes
          : estimatedEtaMinutes // ignore: cast_nullable_to_non_nullable
              as int,
      distanceToPickupKm: null == distanceToPickupKm
          ? _value.distanceToPickupKm
          : distanceToPickupKm // ignore: cast_nullable_to_non_nullable
              as double,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$DriverScoreImplCopyWith<$Res>
    implements $DriverScoreCopyWith<$Res> {
  factory _$$DriverScoreImplCopyWith(
          _$DriverScoreImpl value, $Res Function(_$DriverScoreImpl) then) =
      __$$DriverScoreImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String driverId,
      double totalScore,
      double proximityScore,
      double ratingScore,
      double acceptanceRateScore,
      double etaScore,
      int estimatedEtaMinutes,
      double distanceToPickupKm});
}

/// @nodoc
class __$$DriverScoreImplCopyWithImpl<$Res>
    extends _$DriverScoreCopyWithImpl<$Res, _$DriverScoreImpl>
    implements _$$DriverScoreImplCopyWith<$Res> {
  __$$DriverScoreImplCopyWithImpl(
      _$DriverScoreImpl _value, $Res Function(_$DriverScoreImpl) _then)
      : super(_value, _then);

  /// Create a copy of DriverScore
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? driverId = null,
    Object? totalScore = null,
    Object? proximityScore = null,
    Object? ratingScore = null,
    Object? acceptanceRateScore = null,
    Object? etaScore = null,
    Object? estimatedEtaMinutes = null,
    Object? distanceToPickupKm = null,
  }) {
    return _then(_$DriverScoreImpl(
      driverId: null == driverId
          ? _value.driverId
          : driverId // ignore: cast_nullable_to_non_nullable
              as String,
      totalScore: null == totalScore
          ? _value.totalScore
          : totalScore // ignore: cast_nullable_to_non_nullable
              as double,
      proximityScore: null == proximityScore
          ? _value.proximityScore
          : proximityScore // ignore: cast_nullable_to_non_nullable
              as double,
      ratingScore: null == ratingScore
          ? _value.ratingScore
          : ratingScore // ignore: cast_nullable_to_non_nullable
              as double,
      acceptanceRateScore: null == acceptanceRateScore
          ? _value.acceptanceRateScore
          : acceptanceRateScore // ignore: cast_nullable_to_non_nullable
              as double,
      etaScore: null == etaScore
          ? _value.etaScore
          : etaScore // ignore: cast_nullable_to_non_nullable
              as double,
      estimatedEtaMinutes: null == estimatedEtaMinutes
          ? _value.estimatedEtaMinutes
          : estimatedEtaMinutes // ignore: cast_nullable_to_non_nullable
              as int,
      distanceToPickupKm: null == distanceToPickupKm
          ? _value.distanceToPickupKm
          : distanceToPickupKm // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$DriverScoreImpl implements _DriverScore {
  const _$DriverScoreImpl(
      {required this.driverId,
      required this.totalScore,
      required this.proximityScore,
      required this.ratingScore,
      required this.acceptanceRateScore,
      required this.etaScore,
      required this.estimatedEtaMinutes,
      required this.distanceToPickupKm});

  factory _$DriverScoreImpl.fromJson(Map<String, dynamic> json) =>
      _$$DriverScoreImplFromJson(json);

  @override
  final String driverId;
  @override
  final double totalScore;
  @override
  final double proximityScore;
  @override
  final double ratingScore;
  @override
  final double acceptanceRateScore;
  @override
  final double etaScore;
  @override
  final int estimatedEtaMinutes;
  @override
  final double distanceToPickupKm;

  @override
  String toString() {
    return 'DriverScore(driverId: $driverId, totalScore: $totalScore, proximityScore: $proximityScore, ratingScore: $ratingScore, acceptanceRateScore: $acceptanceRateScore, etaScore: $etaScore, estimatedEtaMinutes: $estimatedEtaMinutes, distanceToPickupKm: $distanceToPickupKm)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DriverScoreImpl &&
            (identical(other.driverId, driverId) ||
                other.driverId == driverId) &&
            (identical(other.totalScore, totalScore) ||
                other.totalScore == totalScore) &&
            (identical(other.proximityScore, proximityScore) ||
                other.proximityScore == proximityScore) &&
            (identical(other.ratingScore, ratingScore) ||
                other.ratingScore == ratingScore) &&
            (identical(other.acceptanceRateScore, acceptanceRateScore) ||
                other.acceptanceRateScore == acceptanceRateScore) &&
            (identical(other.etaScore, etaScore) ||
                other.etaScore == etaScore) &&
            (identical(other.estimatedEtaMinutes, estimatedEtaMinutes) ||
                other.estimatedEtaMinutes == estimatedEtaMinutes) &&
            (identical(other.distanceToPickupKm, distanceToPickupKm) ||
                other.distanceToPickupKm == distanceToPickupKm));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      driverId,
      totalScore,
      proximityScore,
      ratingScore,
      acceptanceRateScore,
      etaScore,
      estimatedEtaMinutes,
      distanceToPickupKm);

  /// Create a copy of DriverScore
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DriverScoreImplCopyWith<_$DriverScoreImpl> get copyWith =>
      __$$DriverScoreImplCopyWithImpl<_$DriverScoreImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DriverScoreImplToJson(
      this,
    );
  }
}

abstract class _DriverScore implements DriverScore {
  const factory _DriverScore(
      {required final String driverId,
      required final double totalScore,
      required final double proximityScore,
      required final double ratingScore,
      required final double acceptanceRateScore,
      required final double etaScore,
      required final int estimatedEtaMinutes,
      required final double distanceToPickupKm}) = _$DriverScoreImpl;

  factory _DriverScore.fromJson(Map<String, dynamic> json) =
      _$DriverScoreImpl.fromJson;

  @override
  String get driverId;
  @override
  double get totalScore;
  @override
  double get proximityScore;
  @override
  double get ratingScore;
  @override
  double get acceptanceRateScore;
  @override
  double get etaScore;
  @override
  int get estimatedEtaMinutes;
  @override
  double get distanceToPickupKm;

  /// Create a copy of DriverScore
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DriverScoreImplCopyWith<_$DriverScoreImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
