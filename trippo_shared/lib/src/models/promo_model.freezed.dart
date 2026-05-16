// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'promo_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

PromoCode _$PromoCodeFromJson(Map<String, dynamic> json) {
  return _PromoCode.fromJson(json);
}

/// @nodoc
mixin _$PromoCode {
  String get id => throw _privateConstructorUsedError;
  String get code => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  PromoDiscountType get type => throw _privateConstructorUsedError;
  double get value => throw _privateConstructorUsedError;
  double get minFare => throw _privateConstructorUsedError;
  double? get maxDiscount => throw _privateConstructorUsedError;
  int? get usageLimit => throw _privateConstructorUsedError;
  int get usedCount => throw _privateConstructorUsedError;
  DateTime get validFrom => throw _privateConstructorUsedError;
  DateTime get validUntil => throw _privateConstructorUsedError;
  bool get isActive => throw _privateConstructorUsedError;
  List<String> get applicableVehicleTypes => throw _privateConstructorUsedError;
  List<String> get applicableZones => throw _privateConstructorUsedError;
  bool get firstRideOnly => throw _privateConstructorUsedError;
  int get maxPerUser => throw _privateConstructorUsedError;

  /// Serializes this PromoCode to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PromoCode
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PromoCodeCopyWith<PromoCode> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PromoCodeCopyWith<$Res> {
  factory $PromoCodeCopyWith(PromoCode value, $Res Function(PromoCode) then) =
      _$PromoCodeCopyWithImpl<$Res, PromoCode>;
  @useResult
  $Res call(
      {String id,
      String code,
      String description,
      PromoDiscountType type,
      double value,
      double minFare,
      double? maxDiscount,
      int? usageLimit,
      int usedCount,
      DateTime validFrom,
      DateTime validUntil,
      bool isActive,
      List<String> applicableVehicleTypes,
      List<String> applicableZones,
      bool firstRideOnly,
      int maxPerUser});
}

/// @nodoc
class _$PromoCodeCopyWithImpl<$Res, $Val extends PromoCode>
    implements $PromoCodeCopyWith<$Res> {
  _$PromoCodeCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PromoCode
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? code = null,
    Object? description = null,
    Object? type = null,
    Object? value = null,
    Object? minFare = null,
    Object? maxDiscount = freezed,
    Object? usageLimit = freezed,
    Object? usedCount = null,
    Object? validFrom = null,
    Object? validUntil = null,
    Object? isActive = null,
    Object? applicableVehicleTypes = null,
    Object? applicableZones = null,
    Object? firstRideOnly = null,
    Object? maxPerUser = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      code: null == code
          ? _value.code
          : code // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as PromoDiscountType,
      value: null == value
          ? _value.value
          : value // ignore: cast_nullable_to_non_nullable
              as double,
      minFare: null == minFare
          ? _value.minFare
          : minFare // ignore: cast_nullable_to_non_nullable
              as double,
      maxDiscount: freezed == maxDiscount
          ? _value.maxDiscount
          : maxDiscount // ignore: cast_nullable_to_non_nullable
              as double?,
      usageLimit: freezed == usageLimit
          ? _value.usageLimit
          : usageLimit // ignore: cast_nullable_to_non_nullable
              as int?,
      usedCount: null == usedCount
          ? _value.usedCount
          : usedCount // ignore: cast_nullable_to_non_nullable
              as int,
      validFrom: null == validFrom
          ? _value.validFrom
          : validFrom // ignore: cast_nullable_to_non_nullable
              as DateTime,
      validUntil: null == validUntil
          ? _value.validUntil
          : validUntil // ignore: cast_nullable_to_non_nullable
              as DateTime,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      applicableVehicleTypes: null == applicableVehicleTypes
          ? _value.applicableVehicleTypes
          : applicableVehicleTypes // ignore: cast_nullable_to_non_nullable
              as List<String>,
      applicableZones: null == applicableZones
          ? _value.applicableZones
          : applicableZones // ignore: cast_nullable_to_non_nullable
              as List<String>,
      firstRideOnly: null == firstRideOnly
          ? _value.firstRideOnly
          : firstRideOnly // ignore: cast_nullable_to_non_nullable
              as bool,
      maxPerUser: null == maxPerUser
          ? _value.maxPerUser
          : maxPerUser // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PromoCodeImplCopyWith<$Res>
    implements $PromoCodeCopyWith<$Res> {
  factory _$$PromoCodeImplCopyWith(
          _$PromoCodeImpl value, $Res Function(_$PromoCodeImpl) then) =
      __$$PromoCodeImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String code,
      String description,
      PromoDiscountType type,
      double value,
      double minFare,
      double? maxDiscount,
      int? usageLimit,
      int usedCount,
      DateTime validFrom,
      DateTime validUntil,
      bool isActive,
      List<String> applicableVehicleTypes,
      List<String> applicableZones,
      bool firstRideOnly,
      int maxPerUser});
}

/// @nodoc
class __$$PromoCodeImplCopyWithImpl<$Res>
    extends _$PromoCodeCopyWithImpl<$Res, _$PromoCodeImpl>
    implements _$$PromoCodeImplCopyWith<$Res> {
  __$$PromoCodeImplCopyWithImpl(
      _$PromoCodeImpl _value, $Res Function(_$PromoCodeImpl) _then)
      : super(_value, _then);

  /// Create a copy of PromoCode
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? code = null,
    Object? description = null,
    Object? type = null,
    Object? value = null,
    Object? minFare = null,
    Object? maxDiscount = freezed,
    Object? usageLimit = freezed,
    Object? usedCount = null,
    Object? validFrom = null,
    Object? validUntil = null,
    Object? isActive = null,
    Object? applicableVehicleTypes = null,
    Object? applicableZones = null,
    Object? firstRideOnly = null,
    Object? maxPerUser = null,
  }) {
    return _then(_$PromoCodeImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      code: null == code
          ? _value.code
          : code // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as PromoDiscountType,
      value: null == value
          ? _value.value
          : value // ignore: cast_nullable_to_non_nullable
              as double,
      minFare: null == minFare
          ? _value.minFare
          : minFare // ignore: cast_nullable_to_non_nullable
              as double,
      maxDiscount: freezed == maxDiscount
          ? _value.maxDiscount
          : maxDiscount // ignore: cast_nullable_to_non_nullable
              as double?,
      usageLimit: freezed == usageLimit
          ? _value.usageLimit
          : usageLimit // ignore: cast_nullable_to_non_nullable
              as int?,
      usedCount: null == usedCount
          ? _value.usedCount
          : usedCount // ignore: cast_nullable_to_non_nullable
              as int,
      validFrom: null == validFrom
          ? _value.validFrom
          : validFrom // ignore: cast_nullable_to_non_nullable
              as DateTime,
      validUntil: null == validUntil
          ? _value.validUntil
          : validUntil // ignore: cast_nullable_to_non_nullable
              as DateTime,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      applicableVehicleTypes: null == applicableVehicleTypes
          ? _value._applicableVehicleTypes
          : applicableVehicleTypes // ignore: cast_nullable_to_non_nullable
              as List<String>,
      applicableZones: null == applicableZones
          ? _value._applicableZones
          : applicableZones // ignore: cast_nullable_to_non_nullable
              as List<String>,
      firstRideOnly: null == firstRideOnly
          ? _value.firstRideOnly
          : firstRideOnly // ignore: cast_nullable_to_non_nullable
              as bool,
      maxPerUser: null == maxPerUser
          ? _value.maxPerUser
          : maxPerUser // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PromoCodeImpl implements _PromoCode {
  const _$PromoCodeImpl(
      {required this.id,
      required this.code,
      required this.description,
      required this.type,
      required this.value,
      this.minFare = 0.0,
      this.maxDiscount,
      this.usageLimit,
      this.usedCount = 0,
      required this.validFrom,
      required this.validUntil,
      this.isActive = true,
      final List<String> applicableVehicleTypes = const [],
      final List<String> applicableZones = const [],
      this.firstRideOnly = false,
      this.maxPerUser = 1})
      : _applicableVehicleTypes = applicableVehicleTypes,
        _applicableZones = applicableZones;

  factory _$PromoCodeImpl.fromJson(Map<String, dynamic> json) =>
      _$$PromoCodeImplFromJson(json);

  @override
  final String id;
  @override
  final String code;
  @override
  final String description;
  @override
  final PromoDiscountType type;
  @override
  final double value;
  @override
  @JsonKey()
  final double minFare;
  @override
  final double? maxDiscount;
  @override
  final int? usageLimit;
  @override
  @JsonKey()
  final int usedCount;
  @override
  final DateTime validFrom;
  @override
  final DateTime validUntil;
  @override
  @JsonKey()
  final bool isActive;
  final List<String> _applicableVehicleTypes;
  @override
  @JsonKey()
  List<String> get applicableVehicleTypes {
    if (_applicableVehicleTypes is EqualUnmodifiableListView)
      return _applicableVehicleTypes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_applicableVehicleTypes);
  }

  final List<String> _applicableZones;
  @override
  @JsonKey()
  List<String> get applicableZones {
    if (_applicableZones is EqualUnmodifiableListView) return _applicableZones;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_applicableZones);
  }

  @override
  @JsonKey()
  final bool firstRideOnly;
  @override
  @JsonKey()
  final int maxPerUser;

  @override
  String toString() {
    return 'PromoCode(id: $id, code: $code, description: $description, type: $type, value: $value, minFare: $minFare, maxDiscount: $maxDiscount, usageLimit: $usageLimit, usedCount: $usedCount, validFrom: $validFrom, validUntil: $validUntil, isActive: $isActive, applicableVehicleTypes: $applicableVehicleTypes, applicableZones: $applicableZones, firstRideOnly: $firstRideOnly, maxPerUser: $maxPerUser)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PromoCodeImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.code, code) || other.code == code) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.value, value) || other.value == value) &&
            (identical(other.minFare, minFare) || other.minFare == minFare) &&
            (identical(other.maxDiscount, maxDiscount) ||
                other.maxDiscount == maxDiscount) &&
            (identical(other.usageLimit, usageLimit) ||
                other.usageLimit == usageLimit) &&
            (identical(other.usedCount, usedCount) ||
                other.usedCount == usedCount) &&
            (identical(other.validFrom, validFrom) ||
                other.validFrom == validFrom) &&
            (identical(other.validUntil, validUntil) ||
                other.validUntil == validUntil) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            const DeepCollectionEquality().equals(
                other._applicableVehicleTypes, _applicableVehicleTypes) &&
            const DeepCollectionEquality()
                .equals(other._applicableZones, _applicableZones) &&
            (identical(other.firstRideOnly, firstRideOnly) ||
                other.firstRideOnly == firstRideOnly) &&
            (identical(other.maxPerUser, maxPerUser) ||
                other.maxPerUser == maxPerUser));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      code,
      description,
      type,
      value,
      minFare,
      maxDiscount,
      usageLimit,
      usedCount,
      validFrom,
      validUntil,
      isActive,
      const DeepCollectionEquality().hash(_applicableVehicleTypes),
      const DeepCollectionEquality().hash(_applicableZones),
      firstRideOnly,
      maxPerUser);

  /// Create a copy of PromoCode
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PromoCodeImplCopyWith<_$PromoCodeImpl> get copyWith =>
      __$$PromoCodeImplCopyWithImpl<_$PromoCodeImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PromoCodeImplToJson(
      this,
    );
  }
}

abstract class _PromoCode implements PromoCode {
  const factory _PromoCode(
      {required final String id,
      required final String code,
      required final String description,
      required final PromoDiscountType type,
      required final double value,
      final double minFare,
      final double? maxDiscount,
      final int? usageLimit,
      final int usedCount,
      required final DateTime validFrom,
      required final DateTime validUntil,
      final bool isActive,
      final List<String> applicableVehicleTypes,
      final List<String> applicableZones,
      final bool firstRideOnly,
      final int maxPerUser}) = _$PromoCodeImpl;

  factory _PromoCode.fromJson(Map<String, dynamic> json) =
      _$PromoCodeImpl.fromJson;

  @override
  String get id;
  @override
  String get code;
  @override
  String get description;
  @override
  PromoDiscountType get type;
  @override
  double get value;
  @override
  double get minFare;
  @override
  double? get maxDiscount;
  @override
  int? get usageLimit;
  @override
  int get usedCount;
  @override
  DateTime get validFrom;
  @override
  DateTime get validUntil;
  @override
  bool get isActive;
  @override
  List<String> get applicableVehicleTypes;
  @override
  List<String> get applicableZones;
  @override
  bool get firstRideOnly;
  @override
  int get maxPerUser;

  /// Create a copy of PromoCode
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PromoCodeImplCopyWith<_$PromoCodeImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PromoValidationResult _$PromoValidationResultFromJson(
    Map<String, dynamic> json) {
  return _PromoValidationResult.fromJson(json);
}

/// @nodoc
mixin _$PromoValidationResult {
  bool get isValid => throw _privateConstructorUsedError;
  PromoCode? get promoCode => throw _privateConstructorUsedError;
  double get discountAmount => throw _privateConstructorUsedError;
  String? get message => throw _privateConstructorUsedError;
  String? get errorCode => throw _privateConstructorUsedError;

  /// Serializes this PromoValidationResult to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PromoValidationResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PromoValidationResultCopyWith<PromoValidationResult> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PromoValidationResultCopyWith<$Res> {
  factory $PromoValidationResultCopyWith(PromoValidationResult value,
          $Res Function(PromoValidationResult) then) =
      _$PromoValidationResultCopyWithImpl<$Res, PromoValidationResult>;
  @useResult
  $Res call(
      {bool isValid,
      PromoCode? promoCode,
      double discountAmount,
      String? message,
      String? errorCode});

  $PromoCodeCopyWith<$Res>? get promoCode;
}

/// @nodoc
class _$PromoValidationResultCopyWithImpl<$Res,
        $Val extends PromoValidationResult>
    implements $PromoValidationResultCopyWith<$Res> {
  _$PromoValidationResultCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PromoValidationResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isValid = null,
    Object? promoCode = freezed,
    Object? discountAmount = null,
    Object? message = freezed,
    Object? errorCode = freezed,
  }) {
    return _then(_value.copyWith(
      isValid: null == isValid
          ? _value.isValid
          : isValid // ignore: cast_nullable_to_non_nullable
              as bool,
      promoCode: freezed == promoCode
          ? _value.promoCode
          : promoCode // ignore: cast_nullable_to_non_nullable
              as PromoCode?,
      discountAmount: null == discountAmount
          ? _value.discountAmount
          : discountAmount // ignore: cast_nullable_to_non_nullable
              as double,
      message: freezed == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String?,
      errorCode: freezed == errorCode
          ? _value.errorCode
          : errorCode // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }

  /// Create a copy of PromoValidationResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $PromoCodeCopyWith<$Res>? get promoCode {
    if (_value.promoCode == null) {
      return null;
    }

    return $PromoCodeCopyWith<$Res>(_value.promoCode!, (value) {
      return _then(_value.copyWith(promoCode: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$PromoValidationResultImplCopyWith<$Res>
    implements $PromoValidationResultCopyWith<$Res> {
  factory _$$PromoValidationResultImplCopyWith(
          _$PromoValidationResultImpl value,
          $Res Function(_$PromoValidationResultImpl) then) =
      __$$PromoValidationResultImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {bool isValid,
      PromoCode? promoCode,
      double discountAmount,
      String? message,
      String? errorCode});

  @override
  $PromoCodeCopyWith<$Res>? get promoCode;
}

/// @nodoc
class __$$PromoValidationResultImplCopyWithImpl<$Res>
    extends _$PromoValidationResultCopyWithImpl<$Res,
        _$PromoValidationResultImpl>
    implements _$$PromoValidationResultImplCopyWith<$Res> {
  __$$PromoValidationResultImplCopyWithImpl(_$PromoValidationResultImpl _value,
      $Res Function(_$PromoValidationResultImpl) _then)
      : super(_value, _then);

  /// Create a copy of PromoValidationResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isValid = null,
    Object? promoCode = freezed,
    Object? discountAmount = null,
    Object? message = freezed,
    Object? errorCode = freezed,
  }) {
    return _then(_$PromoValidationResultImpl(
      isValid: null == isValid
          ? _value.isValid
          : isValid // ignore: cast_nullable_to_non_nullable
              as bool,
      promoCode: freezed == promoCode
          ? _value.promoCode
          : promoCode // ignore: cast_nullable_to_non_nullable
              as PromoCode?,
      discountAmount: null == discountAmount
          ? _value.discountAmount
          : discountAmount // ignore: cast_nullable_to_non_nullable
              as double,
      message: freezed == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String?,
      errorCode: freezed == errorCode
          ? _value.errorCode
          : errorCode // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PromoValidationResultImpl implements _PromoValidationResult {
  const _$PromoValidationResultImpl(
      {required this.isValid,
      this.promoCode,
      this.discountAmount = 0.0,
      this.message,
      this.errorCode});

  factory _$PromoValidationResultImpl.fromJson(Map<String, dynamic> json) =>
      _$$PromoValidationResultImplFromJson(json);

  @override
  final bool isValid;
  @override
  final PromoCode? promoCode;
  @override
  @JsonKey()
  final double discountAmount;
  @override
  final String? message;
  @override
  final String? errorCode;

  @override
  String toString() {
    return 'PromoValidationResult(isValid: $isValid, promoCode: $promoCode, discountAmount: $discountAmount, message: $message, errorCode: $errorCode)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PromoValidationResultImpl &&
            (identical(other.isValid, isValid) || other.isValid == isValid) &&
            (identical(other.promoCode, promoCode) ||
                other.promoCode == promoCode) &&
            (identical(other.discountAmount, discountAmount) ||
                other.discountAmount == discountAmount) &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.errorCode, errorCode) ||
                other.errorCode == errorCode));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, isValid, promoCode, discountAmount, message, errorCode);

  /// Create a copy of PromoValidationResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PromoValidationResultImplCopyWith<_$PromoValidationResultImpl>
      get copyWith => __$$PromoValidationResultImplCopyWithImpl<
          _$PromoValidationResultImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PromoValidationResultImplToJson(
      this,
    );
  }
}

abstract class _PromoValidationResult implements PromoValidationResult {
  const factory _PromoValidationResult(
      {required final bool isValid,
      final PromoCode? promoCode,
      final double discountAmount,
      final String? message,
      final String? errorCode}) = _$PromoValidationResultImpl;

  factory _PromoValidationResult.fromJson(Map<String, dynamic> json) =
      _$PromoValidationResultImpl.fromJson;

  @override
  bool get isValid;
  @override
  PromoCode? get promoCode;
  @override
  double get discountAmount;
  @override
  String? get message;
  @override
  String? get errorCode;

  /// Create a copy of PromoValidationResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PromoValidationResultImplCopyWith<_$PromoValidationResultImpl>
      get copyWith => throw _privateConstructorUsedError;
}

PromoApplication _$PromoApplicationFromJson(Map<String, dynamic> json) {
  return _PromoApplication.fromJson(json);
}

/// @nodoc
mixin _$PromoApplication {
  String get promoCodeId => throw _privateConstructorUsedError;
  String get tripId => throw _privateConstructorUsedError;
  double get discountAmount => throw _privateConstructorUsedError;
  DateTime get appliedAt => throw _privateConstructorUsedError;

  /// Serializes this PromoApplication to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PromoApplication
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PromoApplicationCopyWith<PromoApplication> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PromoApplicationCopyWith<$Res> {
  factory $PromoApplicationCopyWith(
          PromoApplication value, $Res Function(PromoApplication) then) =
      _$PromoApplicationCopyWithImpl<$Res, PromoApplication>;
  @useResult
  $Res call(
      {String promoCodeId,
      String tripId,
      double discountAmount,
      DateTime appliedAt});
}

/// @nodoc
class _$PromoApplicationCopyWithImpl<$Res, $Val extends PromoApplication>
    implements $PromoApplicationCopyWith<$Res> {
  _$PromoApplicationCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PromoApplication
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? promoCodeId = null,
    Object? tripId = null,
    Object? discountAmount = null,
    Object? appliedAt = null,
  }) {
    return _then(_value.copyWith(
      promoCodeId: null == promoCodeId
          ? _value.promoCodeId
          : promoCodeId // ignore: cast_nullable_to_non_nullable
              as String,
      tripId: null == tripId
          ? _value.tripId
          : tripId // ignore: cast_nullable_to_non_nullable
              as String,
      discountAmount: null == discountAmount
          ? _value.discountAmount
          : discountAmount // ignore: cast_nullable_to_non_nullable
              as double,
      appliedAt: null == appliedAt
          ? _value.appliedAt
          : appliedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PromoApplicationImplCopyWith<$Res>
    implements $PromoApplicationCopyWith<$Res> {
  factory _$$PromoApplicationImplCopyWith(_$PromoApplicationImpl value,
          $Res Function(_$PromoApplicationImpl) then) =
      __$$PromoApplicationImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String promoCodeId,
      String tripId,
      double discountAmount,
      DateTime appliedAt});
}

/// @nodoc
class __$$PromoApplicationImplCopyWithImpl<$Res>
    extends _$PromoApplicationCopyWithImpl<$Res, _$PromoApplicationImpl>
    implements _$$PromoApplicationImplCopyWith<$Res> {
  __$$PromoApplicationImplCopyWithImpl(_$PromoApplicationImpl _value,
      $Res Function(_$PromoApplicationImpl) _then)
      : super(_value, _then);

  /// Create a copy of PromoApplication
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? promoCodeId = null,
    Object? tripId = null,
    Object? discountAmount = null,
    Object? appliedAt = null,
  }) {
    return _then(_$PromoApplicationImpl(
      promoCodeId: null == promoCodeId
          ? _value.promoCodeId
          : promoCodeId // ignore: cast_nullable_to_non_nullable
              as String,
      tripId: null == tripId
          ? _value.tripId
          : tripId // ignore: cast_nullable_to_non_nullable
              as String,
      discountAmount: null == discountAmount
          ? _value.discountAmount
          : discountAmount // ignore: cast_nullable_to_non_nullable
              as double,
      appliedAt: null == appliedAt
          ? _value.appliedAt
          : appliedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PromoApplicationImpl implements _PromoApplication {
  const _$PromoApplicationImpl(
      {required this.promoCodeId,
      required this.tripId,
      this.discountAmount = 0.0,
      required this.appliedAt});

  factory _$PromoApplicationImpl.fromJson(Map<String, dynamic> json) =>
      _$$PromoApplicationImplFromJson(json);

  @override
  final String promoCodeId;
  @override
  final String tripId;
  @override
  @JsonKey()
  final double discountAmount;
  @override
  final DateTime appliedAt;

  @override
  String toString() {
    return 'PromoApplication(promoCodeId: $promoCodeId, tripId: $tripId, discountAmount: $discountAmount, appliedAt: $appliedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PromoApplicationImpl &&
            (identical(other.promoCodeId, promoCodeId) ||
                other.promoCodeId == promoCodeId) &&
            (identical(other.tripId, tripId) || other.tripId == tripId) &&
            (identical(other.discountAmount, discountAmount) ||
                other.discountAmount == discountAmount) &&
            (identical(other.appliedAt, appliedAt) ||
                other.appliedAt == appliedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, promoCodeId, tripId, discountAmount, appliedAt);

  /// Create a copy of PromoApplication
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PromoApplicationImplCopyWith<_$PromoApplicationImpl> get copyWith =>
      __$$PromoApplicationImplCopyWithImpl<_$PromoApplicationImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PromoApplicationImplToJson(
      this,
    );
  }
}

abstract class _PromoApplication implements PromoApplication {
  const factory _PromoApplication(
      {required final String promoCodeId,
      required final String tripId,
      final double discountAmount,
      required final DateTime appliedAt}) = _$PromoApplicationImpl;

  factory _PromoApplication.fromJson(Map<String, dynamic> json) =
      _$PromoApplicationImpl.fromJson;

  @override
  String get promoCodeId;
  @override
  String get tripId;
  @override
  double get discountAmount;
  @override
  DateTime get appliedAt;

  /// Create a copy of PromoApplication
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PromoApplicationImplCopyWith<_$PromoApplicationImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
