// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pricing_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

FareBreakdown _$FareBreakdownFromJson(Map<String, dynamic> json) {
  return _FareBreakdown.fromJson(json);
}

/// @nodoc
mixin _$FareBreakdown {
  double get baseFare => throw _privateConstructorUsedError;
  double get distanceFare => throw _privateConstructorUsedError;
  double get timeFare => throw _privateConstructorUsedError;
  double get totalFare => throw _privateConstructorUsedError;
  double get surgeCharge => throw _privateConstructorUsedError;
  double get nightCharge => throw _privateConstructorUsedError;
  double get areaCharge => throw _privateConstructorUsedError;
  double get waitingCharge => throw _privateConstructorUsedError;
  double get cancellationFee => throw _privateConstructorUsedError;
  double get promoDiscount => throw _privateConstructorUsedError;
  double get surgeMultiplier => throw _privateConstructorUsedError;
  double get nightMultiplier => throw _privateConstructorUsedError;
  double get areaMultiplier => throw _privateConstructorUsedError;
  String get currency => throw _privateConstructorUsedError;
  double get distanceKm => throw _privateConstructorUsedError;
  int get durationMinutes => throw _privateConstructorUsedError;
  int get waitingMinutes => throw _privateConstructorUsedError;
  String get vehicleType => throw _privateConstructorUsedError;

  /// Serializes this FareBreakdown to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of FareBreakdown
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FareBreakdownCopyWith<FareBreakdown> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FareBreakdownCopyWith<$Res> {
  factory $FareBreakdownCopyWith(
          FareBreakdown value, $Res Function(FareBreakdown) then) =
      _$FareBreakdownCopyWithImpl<$Res, FareBreakdown>;
  @useResult
  $Res call(
      {double baseFare,
      double distanceFare,
      double timeFare,
      double totalFare,
      double surgeCharge,
      double nightCharge,
      double areaCharge,
      double waitingCharge,
      double cancellationFee,
      double promoDiscount,
      double surgeMultiplier,
      double nightMultiplier,
      double areaMultiplier,
      String currency,
      double distanceKm,
      int durationMinutes,
      int waitingMinutes,
      String vehicleType});
}

/// @nodoc
class _$FareBreakdownCopyWithImpl<$Res, $Val extends FareBreakdown>
    implements $FareBreakdownCopyWith<$Res> {
  _$FareBreakdownCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FareBreakdown
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? baseFare = null,
    Object? distanceFare = null,
    Object? timeFare = null,
    Object? totalFare = null,
    Object? surgeCharge = null,
    Object? nightCharge = null,
    Object? areaCharge = null,
    Object? waitingCharge = null,
    Object? cancellationFee = null,
    Object? promoDiscount = null,
    Object? surgeMultiplier = null,
    Object? nightMultiplier = null,
    Object? areaMultiplier = null,
    Object? currency = null,
    Object? distanceKm = null,
    Object? durationMinutes = null,
    Object? waitingMinutes = null,
    Object? vehicleType = null,
  }) {
    return _then(_value.copyWith(
      baseFare: null == baseFare
          ? _value.baseFare
          : baseFare // ignore: cast_nullable_to_non_nullable
              as double,
      distanceFare: null == distanceFare
          ? _value.distanceFare
          : distanceFare // ignore: cast_nullable_to_non_nullable
              as double,
      timeFare: null == timeFare
          ? _value.timeFare
          : timeFare // ignore: cast_nullable_to_non_nullable
              as double,
      totalFare: null == totalFare
          ? _value.totalFare
          : totalFare // ignore: cast_nullable_to_non_nullable
              as double,
      surgeCharge: null == surgeCharge
          ? _value.surgeCharge
          : surgeCharge // ignore: cast_nullable_to_non_nullable
              as double,
      nightCharge: null == nightCharge
          ? _value.nightCharge
          : nightCharge // ignore: cast_nullable_to_non_nullable
              as double,
      areaCharge: null == areaCharge
          ? _value.areaCharge
          : areaCharge // ignore: cast_nullable_to_non_nullable
              as double,
      waitingCharge: null == waitingCharge
          ? _value.waitingCharge
          : waitingCharge // ignore: cast_nullable_to_non_nullable
              as double,
      cancellationFee: null == cancellationFee
          ? _value.cancellationFee
          : cancellationFee // ignore: cast_nullable_to_non_nullable
              as double,
      promoDiscount: null == promoDiscount
          ? _value.promoDiscount
          : promoDiscount // ignore: cast_nullable_to_non_nullable
              as double,
      surgeMultiplier: null == surgeMultiplier
          ? _value.surgeMultiplier
          : surgeMultiplier // ignore: cast_nullable_to_non_nullable
              as double,
      nightMultiplier: null == nightMultiplier
          ? _value.nightMultiplier
          : nightMultiplier // ignore: cast_nullable_to_non_nullable
              as double,
      areaMultiplier: null == areaMultiplier
          ? _value.areaMultiplier
          : areaMultiplier // ignore: cast_nullable_to_non_nullable
              as double,
      currency: null == currency
          ? _value.currency
          : currency // ignore: cast_nullable_to_non_nullable
              as String,
      distanceKm: null == distanceKm
          ? _value.distanceKm
          : distanceKm // ignore: cast_nullable_to_non_nullable
              as double,
      durationMinutes: null == durationMinutes
          ? _value.durationMinutes
          : durationMinutes // ignore: cast_nullable_to_non_nullable
              as int,
      waitingMinutes: null == waitingMinutes
          ? _value.waitingMinutes
          : waitingMinutes // ignore: cast_nullable_to_non_nullable
              as int,
      vehicleType: null == vehicleType
          ? _value.vehicleType
          : vehicleType // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$FareBreakdownImplCopyWith<$Res>
    implements $FareBreakdownCopyWith<$Res> {
  factory _$$FareBreakdownImplCopyWith(
          _$FareBreakdownImpl value, $Res Function(_$FareBreakdownImpl) then) =
      __$$FareBreakdownImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {double baseFare,
      double distanceFare,
      double timeFare,
      double totalFare,
      double surgeCharge,
      double nightCharge,
      double areaCharge,
      double waitingCharge,
      double cancellationFee,
      double promoDiscount,
      double surgeMultiplier,
      double nightMultiplier,
      double areaMultiplier,
      String currency,
      double distanceKm,
      int durationMinutes,
      int waitingMinutes,
      String vehicleType});
}

/// @nodoc
class __$$FareBreakdownImplCopyWithImpl<$Res>
    extends _$FareBreakdownCopyWithImpl<$Res, _$FareBreakdownImpl>
    implements _$$FareBreakdownImplCopyWith<$Res> {
  __$$FareBreakdownImplCopyWithImpl(
      _$FareBreakdownImpl _value, $Res Function(_$FareBreakdownImpl) _then)
      : super(_value, _then);

  /// Create a copy of FareBreakdown
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? baseFare = null,
    Object? distanceFare = null,
    Object? timeFare = null,
    Object? totalFare = null,
    Object? surgeCharge = null,
    Object? nightCharge = null,
    Object? areaCharge = null,
    Object? waitingCharge = null,
    Object? cancellationFee = null,
    Object? promoDiscount = null,
    Object? surgeMultiplier = null,
    Object? nightMultiplier = null,
    Object? areaMultiplier = null,
    Object? currency = null,
    Object? distanceKm = null,
    Object? durationMinutes = null,
    Object? waitingMinutes = null,
    Object? vehicleType = null,
  }) {
    return _then(_$FareBreakdownImpl(
      baseFare: null == baseFare
          ? _value.baseFare
          : baseFare // ignore: cast_nullable_to_non_nullable
              as double,
      distanceFare: null == distanceFare
          ? _value.distanceFare
          : distanceFare // ignore: cast_nullable_to_non_nullable
              as double,
      timeFare: null == timeFare
          ? _value.timeFare
          : timeFare // ignore: cast_nullable_to_non_nullable
              as double,
      totalFare: null == totalFare
          ? _value.totalFare
          : totalFare // ignore: cast_nullable_to_non_nullable
              as double,
      surgeCharge: null == surgeCharge
          ? _value.surgeCharge
          : surgeCharge // ignore: cast_nullable_to_non_nullable
              as double,
      nightCharge: null == nightCharge
          ? _value.nightCharge
          : nightCharge // ignore: cast_nullable_to_non_nullable
              as double,
      areaCharge: null == areaCharge
          ? _value.areaCharge
          : areaCharge // ignore: cast_nullable_to_non_nullable
              as double,
      waitingCharge: null == waitingCharge
          ? _value.waitingCharge
          : waitingCharge // ignore: cast_nullable_to_non_nullable
              as double,
      cancellationFee: null == cancellationFee
          ? _value.cancellationFee
          : cancellationFee // ignore: cast_nullable_to_non_nullable
              as double,
      promoDiscount: null == promoDiscount
          ? _value.promoDiscount
          : promoDiscount // ignore: cast_nullable_to_non_nullable
              as double,
      surgeMultiplier: null == surgeMultiplier
          ? _value.surgeMultiplier
          : surgeMultiplier // ignore: cast_nullable_to_non_nullable
              as double,
      nightMultiplier: null == nightMultiplier
          ? _value.nightMultiplier
          : nightMultiplier // ignore: cast_nullable_to_non_nullable
              as double,
      areaMultiplier: null == areaMultiplier
          ? _value.areaMultiplier
          : areaMultiplier // ignore: cast_nullable_to_non_nullable
              as double,
      currency: null == currency
          ? _value.currency
          : currency // ignore: cast_nullable_to_non_nullable
              as String,
      distanceKm: null == distanceKm
          ? _value.distanceKm
          : distanceKm // ignore: cast_nullable_to_non_nullable
              as double,
      durationMinutes: null == durationMinutes
          ? _value.durationMinutes
          : durationMinutes // ignore: cast_nullable_to_non_nullable
              as int,
      waitingMinutes: null == waitingMinutes
          ? _value.waitingMinutes
          : waitingMinutes // ignore: cast_nullable_to_non_nullable
              as int,
      vehicleType: null == vehicleType
          ? _value.vehicleType
          : vehicleType // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$FareBreakdownImpl implements _FareBreakdown {
  const _$FareBreakdownImpl(
      {required this.baseFare,
      required this.distanceFare,
      required this.timeFare,
      required this.totalFare,
      this.surgeCharge = 0.0,
      this.nightCharge = 0.0,
      this.areaCharge = 0.0,
      this.waitingCharge = 0.0,
      this.cancellationFee = 0.0,
      this.promoDiscount = 0.0,
      this.surgeMultiplier = 1.0,
      this.nightMultiplier = 1.0,
      this.areaMultiplier = 1.0,
      required this.currency,
      required this.distanceKm,
      required this.durationMinutes,
      required this.waitingMinutes,
      required this.vehicleType});

  factory _$FareBreakdownImpl.fromJson(Map<String, dynamic> json) =>
      _$$FareBreakdownImplFromJson(json);

  @override
  final double baseFare;
  @override
  final double distanceFare;
  @override
  final double timeFare;
  @override
  final double totalFare;
  @override
  @JsonKey()
  final double surgeCharge;
  @override
  @JsonKey()
  final double nightCharge;
  @override
  @JsonKey()
  final double areaCharge;
  @override
  @JsonKey()
  final double waitingCharge;
  @override
  @JsonKey()
  final double cancellationFee;
  @override
  @JsonKey()
  final double promoDiscount;
  @override
  @JsonKey()
  final double surgeMultiplier;
  @override
  @JsonKey()
  final double nightMultiplier;
  @override
  @JsonKey()
  final double areaMultiplier;
  @override
  final String currency;
  @override
  final double distanceKm;
  @override
  final int durationMinutes;
  @override
  final int waitingMinutes;
  @override
  final String vehicleType;

  @override
  String toString() {
    return 'FareBreakdown(baseFare: $baseFare, distanceFare: $distanceFare, timeFare: $timeFare, totalFare: $totalFare, surgeCharge: $surgeCharge, nightCharge: $nightCharge, areaCharge: $areaCharge, waitingCharge: $waitingCharge, cancellationFee: $cancellationFee, promoDiscount: $promoDiscount, surgeMultiplier: $surgeMultiplier, nightMultiplier: $nightMultiplier, areaMultiplier: $areaMultiplier, currency: $currency, distanceKm: $distanceKm, durationMinutes: $durationMinutes, waitingMinutes: $waitingMinutes, vehicleType: $vehicleType)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FareBreakdownImpl &&
            (identical(other.baseFare, baseFare) ||
                other.baseFare == baseFare) &&
            (identical(other.distanceFare, distanceFare) ||
                other.distanceFare == distanceFare) &&
            (identical(other.timeFare, timeFare) ||
                other.timeFare == timeFare) &&
            (identical(other.totalFare, totalFare) ||
                other.totalFare == totalFare) &&
            (identical(other.surgeCharge, surgeCharge) ||
                other.surgeCharge == surgeCharge) &&
            (identical(other.nightCharge, nightCharge) ||
                other.nightCharge == nightCharge) &&
            (identical(other.areaCharge, areaCharge) ||
                other.areaCharge == areaCharge) &&
            (identical(other.waitingCharge, waitingCharge) ||
                other.waitingCharge == waitingCharge) &&
            (identical(other.cancellationFee, cancellationFee) ||
                other.cancellationFee == cancellationFee) &&
            (identical(other.promoDiscount, promoDiscount) ||
                other.promoDiscount == promoDiscount) &&
            (identical(other.surgeMultiplier, surgeMultiplier) ||
                other.surgeMultiplier == surgeMultiplier) &&
            (identical(other.nightMultiplier, nightMultiplier) ||
                other.nightMultiplier == nightMultiplier) &&
            (identical(other.areaMultiplier, areaMultiplier) ||
                other.areaMultiplier == areaMultiplier) &&
            (identical(other.currency, currency) ||
                other.currency == currency) &&
            (identical(other.distanceKm, distanceKm) ||
                other.distanceKm == distanceKm) &&
            (identical(other.durationMinutes, durationMinutes) ||
                other.durationMinutes == durationMinutes) &&
            (identical(other.waitingMinutes, waitingMinutes) ||
                other.waitingMinutes == waitingMinutes) &&
            (identical(other.vehicleType, vehicleType) ||
                other.vehicleType == vehicleType));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      baseFare,
      distanceFare,
      timeFare,
      totalFare,
      surgeCharge,
      nightCharge,
      areaCharge,
      waitingCharge,
      cancellationFee,
      promoDiscount,
      surgeMultiplier,
      nightMultiplier,
      areaMultiplier,
      currency,
      distanceKm,
      durationMinutes,
      waitingMinutes,
      vehicleType);

  /// Create a copy of FareBreakdown
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FareBreakdownImplCopyWith<_$FareBreakdownImpl> get copyWith =>
      __$$FareBreakdownImplCopyWithImpl<_$FareBreakdownImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$FareBreakdownImplToJson(
      this,
    );
  }
}

abstract class _FareBreakdown implements FareBreakdown {
  const factory _FareBreakdown(
      {required final double baseFare,
      required final double distanceFare,
      required final double timeFare,
      required final double totalFare,
      final double surgeCharge,
      final double nightCharge,
      final double areaCharge,
      final double waitingCharge,
      final double cancellationFee,
      final double promoDiscount,
      final double surgeMultiplier,
      final double nightMultiplier,
      final double areaMultiplier,
      required final String currency,
      required final double distanceKm,
      required final int durationMinutes,
      required final int waitingMinutes,
      required final String vehicleType}) = _$FareBreakdownImpl;

  factory _FareBreakdown.fromJson(Map<String, dynamic> json) =
      _$FareBreakdownImpl.fromJson;

  @override
  double get baseFare;
  @override
  double get distanceFare;
  @override
  double get timeFare;
  @override
  double get totalFare;
  @override
  double get surgeCharge;
  @override
  double get nightCharge;
  @override
  double get areaCharge;
  @override
  double get waitingCharge;
  @override
  double get cancellationFee;
  @override
  double get promoDiscount;
  @override
  double get surgeMultiplier;
  @override
  double get nightMultiplier;
  @override
  double get areaMultiplier;
  @override
  String get currency;
  @override
  double get distanceKm;
  @override
  int get durationMinutes;
  @override
  int get waitingMinutes;
  @override
  String get vehicleType;

  /// Create a copy of FareBreakdown
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FareBreakdownImplCopyWith<_$FareBreakdownImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PricingConfig _$PricingConfigFromJson(Map<String, dynamic> json) {
  return _PricingConfig.fromJson(json);
}

/// @nodoc
mixin _$PricingConfig {
  String get id => throw _privateConstructorUsedError;
  String get vehicleType => throw _privateConstructorUsedError;
  String get zoneId => throw _privateConstructorUsedError;
  double get baseFare => throw _privateConstructorUsedError;
  double get perKmRate => throw _privateConstructorUsedError;
  double get perMinuteRate => throw _privateConstructorUsedError;
  double get minimumFare => throw _privateConstructorUsedError;
  double get cancellationFee => throw _privateConstructorUsedError;
  double get waitingFeePerMinute => throw _privateConstructorUsedError;
  int get freeWaitingMinutes => throw _privateConstructorUsedError;
  double get nightMultiplier => throw _privateConstructorUsedError;
  int get nightStartHour => throw _privateConstructorUsedError;
  int get nightEndHour => throw _privateConstructorUsedError;
  bool get isSurgeEnabled => throw _privateConstructorUsedError;
  double get surgeMultiplierLow => throw _privateConstructorUsedError;
  double get surgeMultiplierMedium => throw _privateConstructorUsedError;
  double get surgeMultiplierHigh => throw _privateConstructorUsedError;
  double get surgeMultiplierExtreme => throw _privateConstructorUsedError;
  String get currency => throw _privateConstructorUsedError;
  bool get isActive => throw _privateConstructorUsedError;
  DateTime? get effectiveFrom => throw _privateConstructorUsedError;
  DateTime? get effectiveTo => throw _privateConstructorUsedError;

  /// Serializes this PricingConfig to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PricingConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PricingConfigCopyWith<PricingConfig> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PricingConfigCopyWith<$Res> {
  factory $PricingConfigCopyWith(
          PricingConfig value, $Res Function(PricingConfig) then) =
      _$PricingConfigCopyWithImpl<$Res, PricingConfig>;
  @useResult
  $Res call(
      {String id,
      String vehicleType,
      String zoneId,
      double baseFare,
      double perKmRate,
      double perMinuteRate,
      double minimumFare,
      double cancellationFee,
      double waitingFeePerMinute,
      int freeWaitingMinutes,
      double nightMultiplier,
      int nightStartHour,
      int nightEndHour,
      bool isSurgeEnabled,
      double surgeMultiplierLow,
      double surgeMultiplierMedium,
      double surgeMultiplierHigh,
      double surgeMultiplierExtreme,
      String currency,
      bool isActive,
      DateTime? effectiveFrom,
      DateTime? effectiveTo});
}

/// @nodoc
class _$PricingConfigCopyWithImpl<$Res, $Val extends PricingConfig>
    implements $PricingConfigCopyWith<$Res> {
  _$PricingConfigCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PricingConfig
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? vehicleType = null,
    Object? zoneId = null,
    Object? baseFare = null,
    Object? perKmRate = null,
    Object? perMinuteRate = null,
    Object? minimumFare = null,
    Object? cancellationFee = null,
    Object? waitingFeePerMinute = null,
    Object? freeWaitingMinutes = null,
    Object? nightMultiplier = null,
    Object? nightStartHour = null,
    Object? nightEndHour = null,
    Object? isSurgeEnabled = null,
    Object? surgeMultiplierLow = null,
    Object? surgeMultiplierMedium = null,
    Object? surgeMultiplierHigh = null,
    Object? surgeMultiplierExtreme = null,
    Object? currency = null,
    Object? isActive = null,
    Object? effectiveFrom = freezed,
    Object? effectiveTo = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      vehicleType: null == vehicleType
          ? _value.vehicleType
          : vehicleType // ignore: cast_nullable_to_non_nullable
              as String,
      zoneId: null == zoneId
          ? _value.zoneId
          : zoneId // ignore: cast_nullable_to_non_nullable
              as String,
      baseFare: null == baseFare
          ? _value.baseFare
          : baseFare // ignore: cast_nullable_to_non_nullable
              as double,
      perKmRate: null == perKmRate
          ? _value.perKmRate
          : perKmRate // ignore: cast_nullable_to_non_nullable
              as double,
      perMinuteRate: null == perMinuteRate
          ? _value.perMinuteRate
          : perMinuteRate // ignore: cast_nullable_to_non_nullable
              as double,
      minimumFare: null == minimumFare
          ? _value.minimumFare
          : minimumFare // ignore: cast_nullable_to_non_nullable
              as double,
      cancellationFee: null == cancellationFee
          ? _value.cancellationFee
          : cancellationFee // ignore: cast_nullable_to_non_nullable
              as double,
      waitingFeePerMinute: null == waitingFeePerMinute
          ? _value.waitingFeePerMinute
          : waitingFeePerMinute // ignore: cast_nullable_to_non_nullable
              as double,
      freeWaitingMinutes: null == freeWaitingMinutes
          ? _value.freeWaitingMinutes
          : freeWaitingMinutes // ignore: cast_nullable_to_non_nullable
              as int,
      nightMultiplier: null == nightMultiplier
          ? _value.nightMultiplier
          : nightMultiplier // ignore: cast_nullable_to_non_nullable
              as double,
      nightStartHour: null == nightStartHour
          ? _value.nightStartHour
          : nightStartHour // ignore: cast_nullable_to_non_nullable
              as int,
      nightEndHour: null == nightEndHour
          ? _value.nightEndHour
          : nightEndHour // ignore: cast_nullable_to_non_nullable
              as int,
      isSurgeEnabled: null == isSurgeEnabled
          ? _value.isSurgeEnabled
          : isSurgeEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      surgeMultiplierLow: null == surgeMultiplierLow
          ? _value.surgeMultiplierLow
          : surgeMultiplierLow // ignore: cast_nullable_to_non_nullable
              as double,
      surgeMultiplierMedium: null == surgeMultiplierMedium
          ? _value.surgeMultiplierMedium
          : surgeMultiplierMedium // ignore: cast_nullable_to_non_nullable
              as double,
      surgeMultiplierHigh: null == surgeMultiplierHigh
          ? _value.surgeMultiplierHigh
          : surgeMultiplierHigh // ignore: cast_nullable_to_non_nullable
              as double,
      surgeMultiplierExtreme: null == surgeMultiplierExtreme
          ? _value.surgeMultiplierExtreme
          : surgeMultiplierExtreme // ignore: cast_nullable_to_non_nullable
              as double,
      currency: null == currency
          ? _value.currency
          : currency // ignore: cast_nullable_to_non_nullable
              as String,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      effectiveFrom: freezed == effectiveFrom
          ? _value.effectiveFrom
          : effectiveFrom // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      effectiveTo: freezed == effectiveTo
          ? _value.effectiveTo
          : effectiveTo // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PricingConfigImplCopyWith<$Res>
    implements $PricingConfigCopyWith<$Res> {
  factory _$$PricingConfigImplCopyWith(
          _$PricingConfigImpl value, $Res Function(_$PricingConfigImpl) then) =
      __$$PricingConfigImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String vehicleType,
      String zoneId,
      double baseFare,
      double perKmRate,
      double perMinuteRate,
      double minimumFare,
      double cancellationFee,
      double waitingFeePerMinute,
      int freeWaitingMinutes,
      double nightMultiplier,
      int nightStartHour,
      int nightEndHour,
      bool isSurgeEnabled,
      double surgeMultiplierLow,
      double surgeMultiplierMedium,
      double surgeMultiplierHigh,
      double surgeMultiplierExtreme,
      String currency,
      bool isActive,
      DateTime? effectiveFrom,
      DateTime? effectiveTo});
}

/// @nodoc
class __$$PricingConfigImplCopyWithImpl<$Res>
    extends _$PricingConfigCopyWithImpl<$Res, _$PricingConfigImpl>
    implements _$$PricingConfigImplCopyWith<$Res> {
  __$$PricingConfigImplCopyWithImpl(
      _$PricingConfigImpl _value, $Res Function(_$PricingConfigImpl) _then)
      : super(_value, _then);

  /// Create a copy of PricingConfig
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? vehicleType = null,
    Object? zoneId = null,
    Object? baseFare = null,
    Object? perKmRate = null,
    Object? perMinuteRate = null,
    Object? minimumFare = null,
    Object? cancellationFee = null,
    Object? waitingFeePerMinute = null,
    Object? freeWaitingMinutes = null,
    Object? nightMultiplier = null,
    Object? nightStartHour = null,
    Object? nightEndHour = null,
    Object? isSurgeEnabled = null,
    Object? surgeMultiplierLow = null,
    Object? surgeMultiplierMedium = null,
    Object? surgeMultiplierHigh = null,
    Object? surgeMultiplierExtreme = null,
    Object? currency = null,
    Object? isActive = null,
    Object? effectiveFrom = freezed,
    Object? effectiveTo = freezed,
  }) {
    return _then(_$PricingConfigImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      vehicleType: null == vehicleType
          ? _value.vehicleType
          : vehicleType // ignore: cast_nullable_to_non_nullable
              as String,
      zoneId: null == zoneId
          ? _value.zoneId
          : zoneId // ignore: cast_nullable_to_non_nullable
              as String,
      baseFare: null == baseFare
          ? _value.baseFare
          : baseFare // ignore: cast_nullable_to_non_nullable
              as double,
      perKmRate: null == perKmRate
          ? _value.perKmRate
          : perKmRate // ignore: cast_nullable_to_non_nullable
              as double,
      perMinuteRate: null == perMinuteRate
          ? _value.perMinuteRate
          : perMinuteRate // ignore: cast_nullable_to_non_nullable
              as double,
      minimumFare: null == minimumFare
          ? _value.minimumFare
          : minimumFare // ignore: cast_nullable_to_non_nullable
              as double,
      cancellationFee: null == cancellationFee
          ? _value.cancellationFee
          : cancellationFee // ignore: cast_nullable_to_non_nullable
              as double,
      waitingFeePerMinute: null == waitingFeePerMinute
          ? _value.waitingFeePerMinute
          : waitingFeePerMinute // ignore: cast_nullable_to_non_nullable
              as double,
      freeWaitingMinutes: null == freeWaitingMinutes
          ? _value.freeWaitingMinutes
          : freeWaitingMinutes // ignore: cast_nullable_to_non_nullable
              as int,
      nightMultiplier: null == nightMultiplier
          ? _value.nightMultiplier
          : nightMultiplier // ignore: cast_nullable_to_non_nullable
              as double,
      nightStartHour: null == nightStartHour
          ? _value.nightStartHour
          : nightStartHour // ignore: cast_nullable_to_non_nullable
              as int,
      nightEndHour: null == nightEndHour
          ? _value.nightEndHour
          : nightEndHour // ignore: cast_nullable_to_non_nullable
              as int,
      isSurgeEnabled: null == isSurgeEnabled
          ? _value.isSurgeEnabled
          : isSurgeEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      surgeMultiplierLow: null == surgeMultiplierLow
          ? _value.surgeMultiplierLow
          : surgeMultiplierLow // ignore: cast_nullable_to_non_nullable
              as double,
      surgeMultiplierMedium: null == surgeMultiplierMedium
          ? _value.surgeMultiplierMedium
          : surgeMultiplierMedium // ignore: cast_nullable_to_non_nullable
              as double,
      surgeMultiplierHigh: null == surgeMultiplierHigh
          ? _value.surgeMultiplierHigh
          : surgeMultiplierHigh // ignore: cast_nullable_to_non_nullable
              as double,
      surgeMultiplierExtreme: null == surgeMultiplierExtreme
          ? _value.surgeMultiplierExtreme
          : surgeMultiplierExtreme // ignore: cast_nullable_to_non_nullable
              as double,
      currency: null == currency
          ? _value.currency
          : currency // ignore: cast_nullable_to_non_nullable
              as String,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      effectiveFrom: freezed == effectiveFrom
          ? _value.effectiveFrom
          : effectiveFrom // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      effectiveTo: freezed == effectiveTo
          ? _value.effectiveTo
          : effectiveTo // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PricingConfigImpl implements _PricingConfig {
  const _$PricingConfigImpl(
      {required this.id,
      required this.vehicleType,
      required this.zoneId,
      required this.baseFare,
      required this.perKmRate,
      required this.perMinuteRate,
      required this.minimumFare,
      required this.cancellationFee,
      required this.waitingFeePerMinute,
      required this.freeWaitingMinutes,
      this.nightMultiplier = 1.0,
      this.nightStartHour = 22,
      this.nightEndHour = 6,
      this.isSurgeEnabled = true,
      this.surgeMultiplierLow = 1.2,
      this.surgeMultiplierMedium = 1.5,
      this.surgeMultiplierHigh = 2.0,
      this.surgeMultiplierExtreme = 3.0,
      required this.currency,
      this.isActive = true,
      this.effectiveFrom,
      this.effectiveTo});

  factory _$PricingConfigImpl.fromJson(Map<String, dynamic> json) =>
      _$$PricingConfigImplFromJson(json);

  @override
  final String id;
  @override
  final String vehicleType;
  @override
  final String zoneId;
  @override
  final double baseFare;
  @override
  final double perKmRate;
  @override
  final double perMinuteRate;
  @override
  final double minimumFare;
  @override
  final double cancellationFee;
  @override
  final double waitingFeePerMinute;
  @override
  final int freeWaitingMinutes;
  @override
  @JsonKey()
  final double nightMultiplier;
  @override
  @JsonKey()
  final int nightStartHour;
  @override
  @JsonKey()
  final int nightEndHour;
  @override
  @JsonKey()
  final bool isSurgeEnabled;
  @override
  @JsonKey()
  final double surgeMultiplierLow;
  @override
  @JsonKey()
  final double surgeMultiplierMedium;
  @override
  @JsonKey()
  final double surgeMultiplierHigh;
  @override
  @JsonKey()
  final double surgeMultiplierExtreme;
  @override
  final String currency;
  @override
  @JsonKey()
  final bool isActive;
  @override
  final DateTime? effectiveFrom;
  @override
  final DateTime? effectiveTo;

  @override
  String toString() {
    return 'PricingConfig(id: $id, vehicleType: $vehicleType, zoneId: $zoneId, baseFare: $baseFare, perKmRate: $perKmRate, perMinuteRate: $perMinuteRate, minimumFare: $minimumFare, cancellationFee: $cancellationFee, waitingFeePerMinute: $waitingFeePerMinute, freeWaitingMinutes: $freeWaitingMinutes, nightMultiplier: $nightMultiplier, nightStartHour: $nightStartHour, nightEndHour: $nightEndHour, isSurgeEnabled: $isSurgeEnabled, surgeMultiplierLow: $surgeMultiplierLow, surgeMultiplierMedium: $surgeMultiplierMedium, surgeMultiplierHigh: $surgeMultiplierHigh, surgeMultiplierExtreme: $surgeMultiplierExtreme, currency: $currency, isActive: $isActive, effectiveFrom: $effectiveFrom, effectiveTo: $effectiveTo)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PricingConfigImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.vehicleType, vehicleType) ||
                other.vehicleType == vehicleType) &&
            (identical(other.zoneId, zoneId) || other.zoneId == zoneId) &&
            (identical(other.baseFare, baseFare) ||
                other.baseFare == baseFare) &&
            (identical(other.perKmRate, perKmRate) ||
                other.perKmRate == perKmRate) &&
            (identical(other.perMinuteRate, perMinuteRate) ||
                other.perMinuteRate == perMinuteRate) &&
            (identical(other.minimumFare, minimumFare) ||
                other.minimumFare == minimumFare) &&
            (identical(other.cancellationFee, cancellationFee) ||
                other.cancellationFee == cancellationFee) &&
            (identical(other.waitingFeePerMinute, waitingFeePerMinute) ||
                other.waitingFeePerMinute == waitingFeePerMinute) &&
            (identical(other.freeWaitingMinutes, freeWaitingMinutes) ||
                other.freeWaitingMinutes == freeWaitingMinutes) &&
            (identical(other.nightMultiplier, nightMultiplier) ||
                other.nightMultiplier == nightMultiplier) &&
            (identical(other.nightStartHour, nightStartHour) ||
                other.nightStartHour == nightStartHour) &&
            (identical(other.nightEndHour, nightEndHour) ||
                other.nightEndHour == nightEndHour) &&
            (identical(other.isSurgeEnabled, isSurgeEnabled) ||
                other.isSurgeEnabled == isSurgeEnabled) &&
            (identical(other.surgeMultiplierLow, surgeMultiplierLow) ||
                other.surgeMultiplierLow == surgeMultiplierLow) &&
            (identical(other.surgeMultiplierMedium, surgeMultiplierMedium) ||
                other.surgeMultiplierMedium == surgeMultiplierMedium) &&
            (identical(other.surgeMultiplierHigh, surgeMultiplierHigh) ||
                other.surgeMultiplierHigh == surgeMultiplierHigh) &&
            (identical(other.surgeMultiplierExtreme, surgeMultiplierExtreme) ||
                other.surgeMultiplierExtreme == surgeMultiplierExtreme) &&
            (identical(other.currency, currency) ||
                other.currency == currency) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.effectiveFrom, effectiveFrom) ||
                other.effectiveFrom == effectiveFrom) &&
            (identical(other.effectiveTo, effectiveTo) ||
                other.effectiveTo == effectiveTo));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        vehicleType,
        zoneId,
        baseFare,
        perKmRate,
        perMinuteRate,
        minimumFare,
        cancellationFee,
        waitingFeePerMinute,
        freeWaitingMinutes,
        nightMultiplier,
        nightStartHour,
        nightEndHour,
        isSurgeEnabled,
        surgeMultiplierLow,
        surgeMultiplierMedium,
        surgeMultiplierHigh,
        surgeMultiplierExtreme,
        currency,
        isActive,
        effectiveFrom,
        effectiveTo
      ]);

  /// Create a copy of PricingConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PricingConfigImplCopyWith<_$PricingConfigImpl> get copyWith =>
      __$$PricingConfigImplCopyWithImpl<_$PricingConfigImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PricingConfigImplToJson(
      this,
    );
  }
}

abstract class _PricingConfig implements PricingConfig {
  const factory _PricingConfig(
      {required final String id,
      required final String vehicleType,
      required final String zoneId,
      required final double baseFare,
      required final double perKmRate,
      required final double perMinuteRate,
      required final double minimumFare,
      required final double cancellationFee,
      required final double waitingFeePerMinute,
      required final int freeWaitingMinutes,
      final double nightMultiplier,
      final int nightStartHour,
      final int nightEndHour,
      final bool isSurgeEnabled,
      final double surgeMultiplierLow,
      final double surgeMultiplierMedium,
      final double surgeMultiplierHigh,
      final double surgeMultiplierExtreme,
      required final String currency,
      final bool isActive,
      final DateTime? effectiveFrom,
      final DateTime? effectiveTo}) = _$PricingConfigImpl;

  factory _PricingConfig.fromJson(Map<String, dynamic> json) =
      _$PricingConfigImpl.fromJson;

  @override
  String get id;
  @override
  String get vehicleType;
  @override
  String get zoneId;
  @override
  double get baseFare;
  @override
  double get perKmRate;
  @override
  double get perMinuteRate;
  @override
  double get minimumFare;
  @override
  double get cancellationFee;
  @override
  double get waitingFeePerMinute;
  @override
  int get freeWaitingMinutes;
  @override
  double get nightMultiplier;
  @override
  int get nightStartHour;
  @override
  int get nightEndHour;
  @override
  bool get isSurgeEnabled;
  @override
  double get surgeMultiplierLow;
  @override
  double get surgeMultiplierMedium;
  @override
  double get surgeMultiplierHigh;
  @override
  double get surgeMultiplierExtreme;
  @override
  String get currency;
  @override
  bool get isActive;
  @override
  DateTime? get effectiveFrom;
  @override
  DateTime? get effectiveTo;

  /// Create a copy of PricingConfig
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PricingConfigImplCopyWith<_$PricingConfigImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

FareEstimateRequest _$FareEstimateRequestFromJson(Map<String, dynamic> json) {
  return _FareEstimateRequest.fromJson(json);
}

/// @nodoc
mixin _$FareEstimateRequest {
  double get pickupLatitude => throw _privateConstructorUsedError;
  double get pickupLongitude => throw _privateConstructorUsedError;
  double get dropoffLatitude => throw _privateConstructorUsedError;
  double get dropoffLongitude => throw _privateConstructorUsedError;
  String get vehicleType => throw _privateConstructorUsedError;
  String? get promoCode => throw _privateConstructorUsedError;

  /// Serializes this FareEstimateRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of FareEstimateRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FareEstimateRequestCopyWith<FareEstimateRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FareEstimateRequestCopyWith<$Res> {
  factory $FareEstimateRequestCopyWith(
          FareEstimateRequest value, $Res Function(FareEstimateRequest) then) =
      _$FareEstimateRequestCopyWithImpl<$Res, FareEstimateRequest>;
  @useResult
  $Res call(
      {double pickupLatitude,
      double pickupLongitude,
      double dropoffLatitude,
      double dropoffLongitude,
      String vehicleType,
      String? promoCode});
}

/// @nodoc
class _$FareEstimateRequestCopyWithImpl<$Res, $Val extends FareEstimateRequest>
    implements $FareEstimateRequestCopyWith<$Res> {
  _$FareEstimateRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FareEstimateRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? pickupLatitude = null,
    Object? pickupLongitude = null,
    Object? dropoffLatitude = null,
    Object? dropoffLongitude = null,
    Object? vehicleType = null,
    Object? promoCode = freezed,
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
      promoCode: freezed == promoCode
          ? _value.promoCode
          : promoCode // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$FareEstimateRequestImplCopyWith<$Res>
    implements $FareEstimateRequestCopyWith<$Res> {
  factory _$$FareEstimateRequestImplCopyWith(_$FareEstimateRequestImpl value,
          $Res Function(_$FareEstimateRequestImpl) then) =
      __$$FareEstimateRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {double pickupLatitude,
      double pickupLongitude,
      double dropoffLatitude,
      double dropoffLongitude,
      String vehicleType,
      String? promoCode});
}

/// @nodoc
class __$$FareEstimateRequestImplCopyWithImpl<$Res>
    extends _$FareEstimateRequestCopyWithImpl<$Res, _$FareEstimateRequestImpl>
    implements _$$FareEstimateRequestImplCopyWith<$Res> {
  __$$FareEstimateRequestImplCopyWithImpl(_$FareEstimateRequestImpl _value,
      $Res Function(_$FareEstimateRequestImpl) _then)
      : super(_value, _then);

  /// Create a copy of FareEstimateRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? pickupLatitude = null,
    Object? pickupLongitude = null,
    Object? dropoffLatitude = null,
    Object? dropoffLongitude = null,
    Object? vehicleType = null,
    Object? promoCode = freezed,
  }) {
    return _then(_$FareEstimateRequestImpl(
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
      promoCode: freezed == promoCode
          ? _value.promoCode
          : promoCode // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$FareEstimateRequestImpl implements _FareEstimateRequest {
  const _$FareEstimateRequestImpl(
      {required this.pickupLatitude,
      required this.pickupLongitude,
      required this.dropoffLatitude,
      required this.dropoffLongitude,
      required this.vehicleType,
      this.promoCode});

  factory _$FareEstimateRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$FareEstimateRequestImplFromJson(json);

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
  final String? promoCode;

  @override
  String toString() {
    return 'FareEstimateRequest(pickupLatitude: $pickupLatitude, pickupLongitude: $pickupLongitude, dropoffLatitude: $dropoffLatitude, dropoffLongitude: $dropoffLongitude, vehicleType: $vehicleType, promoCode: $promoCode)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FareEstimateRequestImpl &&
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
            (identical(other.promoCode, promoCode) ||
                other.promoCode == promoCode));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, pickupLatitude, pickupLongitude,
      dropoffLatitude, dropoffLongitude, vehicleType, promoCode);

  /// Create a copy of FareEstimateRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FareEstimateRequestImplCopyWith<_$FareEstimateRequestImpl> get copyWith =>
      __$$FareEstimateRequestImplCopyWithImpl<_$FareEstimateRequestImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$FareEstimateRequestImplToJson(
      this,
    );
  }
}

abstract class _FareEstimateRequest implements FareEstimateRequest {
  const factory _FareEstimateRequest(
      {required final double pickupLatitude,
      required final double pickupLongitude,
      required final double dropoffLatitude,
      required final double dropoffLongitude,
      required final String vehicleType,
      final String? promoCode}) = _$FareEstimateRequestImpl;

  factory _FareEstimateRequest.fromJson(Map<String, dynamic> json) =
      _$FareEstimateRequestImpl.fromJson;

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
  String? get promoCode;

  /// Create a copy of FareEstimateRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FareEstimateRequestImplCopyWith<_$FareEstimateRequestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

FareEstimateResponse _$FareEstimateResponseFromJson(Map<String, dynamic> json) {
  return _FareEstimateResponse.fromJson(json);
}

/// @nodoc
mixin _$FareEstimateResponse {
  FareBreakdown get fareBreakdown => throw _privateConstructorUsedError;
  int get estimatedDurationMinutes => throw _privateConstructorUsedError;
  double get estimatedDistanceKm => throw _privateConstructorUsedError;
  bool get isSurgeActive => throw _privateConstructorUsedError;
  double get surgeMultiplier => throw _privateConstructorUsedError;
  String get currency => throw _privateConstructorUsedError;

  /// Serializes this FareEstimateResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of FareEstimateResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FareEstimateResponseCopyWith<FareEstimateResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FareEstimateResponseCopyWith<$Res> {
  factory $FareEstimateResponseCopyWith(FareEstimateResponse value,
          $Res Function(FareEstimateResponse) then) =
      _$FareEstimateResponseCopyWithImpl<$Res, FareEstimateResponse>;
  @useResult
  $Res call(
      {FareBreakdown fareBreakdown,
      int estimatedDurationMinutes,
      double estimatedDistanceKm,
      bool isSurgeActive,
      double surgeMultiplier,
      String currency});

  $FareBreakdownCopyWith<$Res> get fareBreakdown;
}

/// @nodoc
class _$FareEstimateResponseCopyWithImpl<$Res,
        $Val extends FareEstimateResponse>
    implements $FareEstimateResponseCopyWith<$Res> {
  _$FareEstimateResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FareEstimateResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? fareBreakdown = null,
    Object? estimatedDurationMinutes = null,
    Object? estimatedDistanceKm = null,
    Object? isSurgeActive = null,
    Object? surgeMultiplier = null,
    Object? currency = null,
  }) {
    return _then(_value.copyWith(
      fareBreakdown: null == fareBreakdown
          ? _value.fareBreakdown
          : fareBreakdown // ignore: cast_nullable_to_non_nullable
              as FareBreakdown,
      estimatedDurationMinutes: null == estimatedDurationMinutes
          ? _value.estimatedDurationMinutes
          : estimatedDurationMinutes // ignore: cast_nullable_to_non_nullable
              as int,
      estimatedDistanceKm: null == estimatedDistanceKm
          ? _value.estimatedDistanceKm
          : estimatedDistanceKm // ignore: cast_nullable_to_non_nullable
              as double,
      isSurgeActive: null == isSurgeActive
          ? _value.isSurgeActive
          : isSurgeActive // ignore: cast_nullable_to_non_nullable
              as bool,
      surgeMultiplier: null == surgeMultiplier
          ? _value.surgeMultiplier
          : surgeMultiplier // ignore: cast_nullable_to_non_nullable
              as double,
      currency: null == currency
          ? _value.currency
          : currency // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }

  /// Create a copy of FareEstimateResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $FareBreakdownCopyWith<$Res> get fareBreakdown {
    return $FareBreakdownCopyWith<$Res>(_value.fareBreakdown, (value) {
      return _then(_value.copyWith(fareBreakdown: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$FareEstimateResponseImplCopyWith<$Res>
    implements $FareEstimateResponseCopyWith<$Res> {
  factory _$$FareEstimateResponseImplCopyWith(_$FareEstimateResponseImpl value,
          $Res Function(_$FareEstimateResponseImpl) then) =
      __$$FareEstimateResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {FareBreakdown fareBreakdown,
      int estimatedDurationMinutes,
      double estimatedDistanceKm,
      bool isSurgeActive,
      double surgeMultiplier,
      String currency});

  @override
  $FareBreakdownCopyWith<$Res> get fareBreakdown;
}

/// @nodoc
class __$$FareEstimateResponseImplCopyWithImpl<$Res>
    extends _$FareEstimateResponseCopyWithImpl<$Res, _$FareEstimateResponseImpl>
    implements _$$FareEstimateResponseImplCopyWith<$Res> {
  __$$FareEstimateResponseImplCopyWithImpl(_$FareEstimateResponseImpl _value,
      $Res Function(_$FareEstimateResponseImpl) _then)
      : super(_value, _then);

  /// Create a copy of FareEstimateResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? fareBreakdown = null,
    Object? estimatedDurationMinutes = null,
    Object? estimatedDistanceKm = null,
    Object? isSurgeActive = null,
    Object? surgeMultiplier = null,
    Object? currency = null,
  }) {
    return _then(_$FareEstimateResponseImpl(
      fareBreakdown: null == fareBreakdown
          ? _value.fareBreakdown
          : fareBreakdown // ignore: cast_nullable_to_non_nullable
              as FareBreakdown,
      estimatedDurationMinutes: null == estimatedDurationMinutes
          ? _value.estimatedDurationMinutes
          : estimatedDurationMinutes // ignore: cast_nullable_to_non_nullable
              as int,
      estimatedDistanceKm: null == estimatedDistanceKm
          ? _value.estimatedDistanceKm
          : estimatedDistanceKm // ignore: cast_nullable_to_non_nullable
              as double,
      isSurgeActive: null == isSurgeActive
          ? _value.isSurgeActive
          : isSurgeActive // ignore: cast_nullable_to_non_nullable
              as bool,
      surgeMultiplier: null == surgeMultiplier
          ? _value.surgeMultiplier
          : surgeMultiplier // ignore: cast_nullable_to_non_nullable
              as double,
      currency: null == currency
          ? _value.currency
          : currency // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$FareEstimateResponseImpl implements _FareEstimateResponse {
  const _$FareEstimateResponseImpl(
      {required this.fareBreakdown,
      required this.estimatedDurationMinutes,
      required this.estimatedDistanceKm,
      required this.isSurgeActive,
      required this.surgeMultiplier,
      required this.currency});

  factory _$FareEstimateResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$FareEstimateResponseImplFromJson(json);

  @override
  final FareBreakdown fareBreakdown;
  @override
  final int estimatedDurationMinutes;
  @override
  final double estimatedDistanceKm;
  @override
  final bool isSurgeActive;
  @override
  final double surgeMultiplier;
  @override
  final String currency;

  @override
  String toString() {
    return 'FareEstimateResponse(fareBreakdown: $fareBreakdown, estimatedDurationMinutes: $estimatedDurationMinutes, estimatedDistanceKm: $estimatedDistanceKm, isSurgeActive: $isSurgeActive, surgeMultiplier: $surgeMultiplier, currency: $currency)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FareEstimateResponseImpl &&
            (identical(other.fareBreakdown, fareBreakdown) ||
                other.fareBreakdown == fareBreakdown) &&
            (identical(
                    other.estimatedDurationMinutes, estimatedDurationMinutes) ||
                other.estimatedDurationMinutes == estimatedDurationMinutes) &&
            (identical(other.estimatedDistanceKm, estimatedDistanceKm) ||
                other.estimatedDistanceKm == estimatedDistanceKm) &&
            (identical(other.isSurgeActive, isSurgeActive) ||
                other.isSurgeActive == isSurgeActive) &&
            (identical(other.surgeMultiplier, surgeMultiplier) ||
                other.surgeMultiplier == surgeMultiplier) &&
            (identical(other.currency, currency) ||
                other.currency == currency));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      fareBreakdown,
      estimatedDurationMinutes,
      estimatedDistanceKm,
      isSurgeActive,
      surgeMultiplier,
      currency);

  /// Create a copy of FareEstimateResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FareEstimateResponseImplCopyWith<_$FareEstimateResponseImpl>
      get copyWith =>
          __$$FareEstimateResponseImplCopyWithImpl<_$FareEstimateResponseImpl>(
              this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$FareEstimateResponseImplToJson(
      this,
    );
  }
}

abstract class _FareEstimateResponse implements FareEstimateResponse {
  const factory _FareEstimateResponse(
      {required final FareBreakdown fareBreakdown,
      required final int estimatedDurationMinutes,
      required final double estimatedDistanceKm,
      required final bool isSurgeActive,
      required final double surgeMultiplier,
      required final String currency}) = _$FareEstimateResponseImpl;

  factory _FareEstimateResponse.fromJson(Map<String, dynamic> json) =
      _$FareEstimateResponseImpl.fromJson;

  @override
  FareBreakdown get fareBreakdown;
  @override
  int get estimatedDurationMinutes;
  @override
  double get estimatedDistanceKm;
  @override
  bool get isSurgeActive;
  @override
  double get surgeMultiplier;
  @override
  String get currency;

  /// Create a copy of FareEstimateResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FareEstimateResponseImplCopyWith<_$FareEstimateResponseImpl>
      get copyWith => throw _privateConstructorUsedError;
}

SurgeStatus _$SurgeStatusFromJson(Map<String, dynamic> json) {
  return _SurgeStatus.fromJson(json);
}

/// @nodoc
mixin _$SurgeStatus {
  bool get isActive => throw _privateConstructorUsedError;
  double get currentMultiplier => throw _privateConstructorUsedError;
  String get reason => throw _privateConstructorUsedError;
  String get zoneId => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this SurgeStatus to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SurgeStatus
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SurgeStatusCopyWith<SurgeStatus> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SurgeStatusCopyWith<$Res> {
  factory $SurgeStatusCopyWith(
          SurgeStatus value, $Res Function(SurgeStatus) then) =
      _$SurgeStatusCopyWithImpl<$Res, SurgeStatus>;
  @useResult
  $Res call(
      {bool isActive,
      double currentMultiplier,
      String reason,
      String zoneId,
      DateTime updatedAt});
}

/// @nodoc
class _$SurgeStatusCopyWithImpl<$Res, $Val extends SurgeStatus>
    implements $SurgeStatusCopyWith<$Res> {
  _$SurgeStatusCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SurgeStatus
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isActive = null,
    Object? currentMultiplier = null,
    Object? reason = null,
    Object? zoneId = null,
    Object? updatedAt = null,
  }) {
    return _then(_value.copyWith(
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      currentMultiplier: null == currentMultiplier
          ? _value.currentMultiplier
          : currentMultiplier // ignore: cast_nullable_to_non_nullable
              as double,
      reason: null == reason
          ? _value.reason
          : reason // ignore: cast_nullable_to_non_nullable
              as String,
      zoneId: null == zoneId
          ? _value.zoneId
          : zoneId // ignore: cast_nullable_to_non_nullable
              as String,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SurgeStatusImplCopyWith<$Res>
    implements $SurgeStatusCopyWith<$Res> {
  factory _$$SurgeStatusImplCopyWith(
          _$SurgeStatusImpl value, $Res Function(_$SurgeStatusImpl) then) =
      __$$SurgeStatusImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {bool isActive,
      double currentMultiplier,
      String reason,
      String zoneId,
      DateTime updatedAt});
}

/// @nodoc
class __$$SurgeStatusImplCopyWithImpl<$Res>
    extends _$SurgeStatusCopyWithImpl<$Res, _$SurgeStatusImpl>
    implements _$$SurgeStatusImplCopyWith<$Res> {
  __$$SurgeStatusImplCopyWithImpl(
      _$SurgeStatusImpl _value, $Res Function(_$SurgeStatusImpl) _then)
      : super(_value, _then);

  /// Create a copy of SurgeStatus
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isActive = null,
    Object? currentMultiplier = null,
    Object? reason = null,
    Object? zoneId = null,
    Object? updatedAt = null,
  }) {
    return _then(_$SurgeStatusImpl(
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      currentMultiplier: null == currentMultiplier
          ? _value.currentMultiplier
          : currentMultiplier // ignore: cast_nullable_to_non_nullable
              as double,
      reason: null == reason
          ? _value.reason
          : reason // ignore: cast_nullable_to_non_nullable
              as String,
      zoneId: null == zoneId
          ? _value.zoneId
          : zoneId // ignore: cast_nullable_to_non_nullable
              as String,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SurgeStatusImpl implements _SurgeStatus {
  const _$SurgeStatusImpl(
      {required this.isActive,
      required this.currentMultiplier,
      required this.reason,
      required this.zoneId,
      required this.updatedAt});

  factory _$SurgeStatusImpl.fromJson(Map<String, dynamic> json) =>
      _$$SurgeStatusImplFromJson(json);

  @override
  final bool isActive;
  @override
  final double currentMultiplier;
  @override
  final String reason;
  @override
  final String zoneId;
  @override
  final DateTime updatedAt;

  @override
  String toString() {
    return 'SurgeStatus(isActive: $isActive, currentMultiplier: $currentMultiplier, reason: $reason, zoneId: $zoneId, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SurgeStatusImpl &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.currentMultiplier, currentMultiplier) ||
                other.currentMultiplier == currentMultiplier) &&
            (identical(other.reason, reason) || other.reason == reason) &&
            (identical(other.zoneId, zoneId) || other.zoneId == zoneId) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, isActive, currentMultiplier, reason, zoneId, updatedAt);

  /// Create a copy of SurgeStatus
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SurgeStatusImplCopyWith<_$SurgeStatusImpl> get copyWith =>
      __$$SurgeStatusImplCopyWithImpl<_$SurgeStatusImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SurgeStatusImplToJson(
      this,
    );
  }
}

abstract class _SurgeStatus implements SurgeStatus {
  const factory _SurgeStatus(
      {required final bool isActive,
      required final double currentMultiplier,
      required final String reason,
      required final String zoneId,
      required final DateTime updatedAt}) = _$SurgeStatusImpl;

  factory _SurgeStatus.fromJson(Map<String, dynamic> json) =
      _$SurgeStatusImpl.fromJson;

  @override
  bool get isActive;
  @override
  double get currentMultiplier;
  @override
  String get reason;
  @override
  String get zoneId;
  @override
  DateTime get updatedAt;

  /// Create a copy of SurgeStatus
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SurgeStatusImplCopyWith<_$SurgeStatusImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
