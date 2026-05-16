// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'location_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

LocationModel _$LocationModelFromJson(Map<String, dynamic> json) {
  return _LocationModel.fromJson(json);
}

/// @nodoc
mixin _$LocationModel {
  double get latitude => throw _privateConstructorUsedError;
  double get longitude => throw _privateConstructorUsedError;
  String? get address => throw _privateConstructorUsedError;
  String? get name => throw _privateConstructorUsedError;
  String? get placeId => throw _privateConstructorUsedError;
  double? get accuracy => throw _privateConstructorUsedError;
  double? get heading => throw _privateConstructorUsedError;
  double? get speed => throw _privateConstructorUsedError;
  DateTime? get timestamp => throw _privateConstructorUsedError;

  /// Serializes this LocationModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of LocationModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LocationModelCopyWith<LocationModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LocationModelCopyWith<$Res> {
  factory $LocationModelCopyWith(
          LocationModel value, $Res Function(LocationModel) then) =
      _$LocationModelCopyWithImpl<$Res, LocationModel>;
  @useResult
  $Res call(
      {double latitude,
      double longitude,
      String? address,
      String? name,
      String? placeId,
      double? accuracy,
      double? heading,
      double? speed,
      DateTime? timestamp});
}

/// @nodoc
class _$LocationModelCopyWithImpl<$Res, $Val extends LocationModel>
    implements $LocationModelCopyWith<$Res> {
  _$LocationModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LocationModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? latitude = null,
    Object? longitude = null,
    Object? address = freezed,
    Object? name = freezed,
    Object? placeId = freezed,
    Object? accuracy = freezed,
    Object? heading = freezed,
    Object? speed = freezed,
    Object? timestamp = freezed,
  }) {
    return _then(_value.copyWith(
      latitude: null == latitude
          ? _value.latitude
          : latitude // ignore: cast_nullable_to_non_nullable
              as double,
      longitude: null == longitude
          ? _value.longitude
          : longitude // ignore: cast_nullable_to_non_nullable
              as double,
      address: freezed == address
          ? _value.address
          : address // ignore: cast_nullable_to_non_nullable
              as String?,
      name: freezed == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String?,
      placeId: freezed == placeId
          ? _value.placeId
          : placeId // ignore: cast_nullable_to_non_nullable
              as String?,
      accuracy: freezed == accuracy
          ? _value.accuracy
          : accuracy // ignore: cast_nullable_to_non_nullable
              as double?,
      heading: freezed == heading
          ? _value.heading
          : heading // ignore: cast_nullable_to_non_nullable
              as double?,
      speed: freezed == speed
          ? _value.speed
          : speed // ignore: cast_nullable_to_non_nullable
              as double?,
      timestamp: freezed == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$LocationModelImplCopyWith<$Res>
    implements $LocationModelCopyWith<$Res> {
  factory _$$LocationModelImplCopyWith(
          _$LocationModelImpl value, $Res Function(_$LocationModelImpl) then) =
      __$$LocationModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {double latitude,
      double longitude,
      String? address,
      String? name,
      String? placeId,
      double? accuracy,
      double? heading,
      double? speed,
      DateTime? timestamp});
}

/// @nodoc
class __$$LocationModelImplCopyWithImpl<$Res>
    extends _$LocationModelCopyWithImpl<$Res, _$LocationModelImpl>
    implements _$$LocationModelImplCopyWith<$Res> {
  __$$LocationModelImplCopyWithImpl(
      _$LocationModelImpl _value, $Res Function(_$LocationModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of LocationModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? latitude = null,
    Object? longitude = null,
    Object? address = freezed,
    Object? name = freezed,
    Object? placeId = freezed,
    Object? accuracy = freezed,
    Object? heading = freezed,
    Object? speed = freezed,
    Object? timestamp = freezed,
  }) {
    return _then(_$LocationModelImpl(
      latitude: null == latitude
          ? _value.latitude
          : latitude // ignore: cast_nullable_to_non_nullable
              as double,
      longitude: null == longitude
          ? _value.longitude
          : longitude // ignore: cast_nullable_to_non_nullable
              as double,
      address: freezed == address
          ? _value.address
          : address // ignore: cast_nullable_to_non_nullable
              as String?,
      name: freezed == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String?,
      placeId: freezed == placeId
          ? _value.placeId
          : placeId // ignore: cast_nullable_to_non_nullable
              as String?,
      accuracy: freezed == accuracy
          ? _value.accuracy
          : accuracy // ignore: cast_nullable_to_non_nullable
              as double?,
      heading: freezed == heading
          ? _value.heading
          : heading // ignore: cast_nullable_to_non_nullable
              as double?,
      speed: freezed == speed
          ? _value.speed
          : speed // ignore: cast_nullable_to_non_nullable
              as double?,
      timestamp: freezed == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$LocationModelImpl implements _LocationModel {
  const _$LocationModelImpl(
      {required this.latitude,
      required this.longitude,
      this.address,
      this.name,
      this.placeId,
      this.accuracy,
      this.heading,
      this.speed,
      this.timestamp});

  factory _$LocationModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$LocationModelImplFromJson(json);

  @override
  final double latitude;
  @override
  final double longitude;
  @override
  final String? address;
  @override
  final String? name;
  @override
  final String? placeId;
  @override
  final double? accuracy;
  @override
  final double? heading;
  @override
  final double? speed;
  @override
  final DateTime? timestamp;

  @override
  String toString() {
    return 'LocationModel(latitude: $latitude, longitude: $longitude, address: $address, name: $name, placeId: $placeId, accuracy: $accuracy, heading: $heading, speed: $speed, timestamp: $timestamp)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LocationModelImpl &&
            (identical(other.latitude, latitude) ||
                other.latitude == latitude) &&
            (identical(other.longitude, longitude) ||
                other.longitude == longitude) &&
            (identical(other.address, address) || other.address == address) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.placeId, placeId) || other.placeId == placeId) &&
            (identical(other.accuracy, accuracy) ||
                other.accuracy == accuracy) &&
            (identical(other.heading, heading) || other.heading == heading) &&
            (identical(other.speed, speed) || other.speed == speed) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, latitude, longitude, address,
      name, placeId, accuracy, heading, speed, timestamp);

  /// Create a copy of LocationModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LocationModelImplCopyWith<_$LocationModelImpl> get copyWith =>
      __$$LocationModelImplCopyWithImpl<_$LocationModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LocationModelImplToJson(
      this,
    );
  }
}

abstract class _LocationModel implements LocationModel {
  const factory _LocationModel(
      {required final double latitude,
      required final double longitude,
      final String? address,
      final String? name,
      final String? placeId,
      final double? accuracy,
      final double? heading,
      final double? speed,
      final DateTime? timestamp}) = _$LocationModelImpl;

  factory _LocationModel.fromJson(Map<String, dynamic> json) =
      _$LocationModelImpl.fromJson;

  @override
  double get latitude;
  @override
  double get longitude;
  @override
  String? get address;
  @override
  String? get name;
  @override
  String? get placeId;
  @override
  double? get accuracy;
  @override
  double? get heading;
  @override
  double? get speed;
  @override
  DateTime? get timestamp;

  /// Create a copy of LocationModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LocationModelImplCopyWith<_$LocationModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

GeoBounds _$GeoBoundsFromJson(Map<String, dynamic> json) {
  return _GeoBounds.fromJson(json);
}

/// @nodoc
mixin _$GeoBounds {
  double get northeastLat => throw _privateConstructorUsedError;
  double get northeastLng => throw _privateConstructorUsedError;
  double get southwestLat => throw _privateConstructorUsedError;
  double get southwestLng => throw _privateConstructorUsedError;

  /// Serializes this GeoBounds to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of GeoBounds
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $GeoBoundsCopyWith<GeoBounds> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GeoBoundsCopyWith<$Res> {
  factory $GeoBoundsCopyWith(GeoBounds value, $Res Function(GeoBounds) then) =
      _$GeoBoundsCopyWithImpl<$Res, GeoBounds>;
  @useResult
  $Res call(
      {double northeastLat,
      double northeastLng,
      double southwestLat,
      double southwestLng});
}

/// @nodoc
class _$GeoBoundsCopyWithImpl<$Res, $Val extends GeoBounds>
    implements $GeoBoundsCopyWith<$Res> {
  _$GeoBoundsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of GeoBounds
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? northeastLat = null,
    Object? northeastLng = null,
    Object? southwestLat = null,
    Object? southwestLng = null,
  }) {
    return _then(_value.copyWith(
      northeastLat: null == northeastLat
          ? _value.northeastLat
          : northeastLat // ignore: cast_nullable_to_non_nullable
              as double,
      northeastLng: null == northeastLng
          ? _value.northeastLng
          : northeastLng // ignore: cast_nullable_to_non_nullable
              as double,
      southwestLat: null == southwestLat
          ? _value.southwestLat
          : southwestLat // ignore: cast_nullable_to_non_nullable
              as double,
      southwestLng: null == southwestLng
          ? _value.southwestLng
          : southwestLng // ignore: cast_nullable_to_non_nullable
              as double,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$GeoBoundsImplCopyWith<$Res>
    implements $GeoBoundsCopyWith<$Res> {
  factory _$$GeoBoundsImplCopyWith(
          _$GeoBoundsImpl value, $Res Function(_$GeoBoundsImpl) then) =
      __$$GeoBoundsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {double northeastLat,
      double northeastLng,
      double southwestLat,
      double southwestLng});
}

/// @nodoc
class __$$GeoBoundsImplCopyWithImpl<$Res>
    extends _$GeoBoundsCopyWithImpl<$Res, _$GeoBoundsImpl>
    implements _$$GeoBoundsImplCopyWith<$Res> {
  __$$GeoBoundsImplCopyWithImpl(
      _$GeoBoundsImpl _value, $Res Function(_$GeoBoundsImpl) _then)
      : super(_value, _then);

  /// Create a copy of GeoBounds
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? northeastLat = null,
    Object? northeastLng = null,
    Object? southwestLat = null,
    Object? southwestLng = null,
  }) {
    return _then(_$GeoBoundsImpl(
      northeastLat: null == northeastLat
          ? _value.northeastLat
          : northeastLat // ignore: cast_nullable_to_non_nullable
              as double,
      northeastLng: null == northeastLng
          ? _value.northeastLng
          : northeastLng // ignore: cast_nullable_to_non_nullable
              as double,
      southwestLat: null == southwestLat
          ? _value.southwestLat
          : southwestLat // ignore: cast_nullable_to_non_nullable
              as double,
      southwestLng: null == southwestLng
          ? _value.southwestLng
          : southwestLng // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$GeoBoundsImpl implements _GeoBounds {
  const _$GeoBoundsImpl(
      {required this.northeastLat,
      required this.northeastLng,
      required this.southwestLat,
      required this.southwestLng});

  factory _$GeoBoundsImpl.fromJson(Map<String, dynamic> json) =>
      _$$GeoBoundsImplFromJson(json);

  @override
  final double northeastLat;
  @override
  final double northeastLng;
  @override
  final double southwestLat;
  @override
  final double southwestLng;

  @override
  String toString() {
    return 'GeoBounds(northeastLat: $northeastLat, northeastLng: $northeastLng, southwestLat: $southwestLat, southwestLng: $southwestLng)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GeoBoundsImpl &&
            (identical(other.northeastLat, northeastLat) ||
                other.northeastLat == northeastLat) &&
            (identical(other.northeastLng, northeastLng) ||
                other.northeastLng == northeastLng) &&
            (identical(other.southwestLat, southwestLat) ||
                other.southwestLat == southwestLat) &&
            (identical(other.southwestLng, southwestLng) ||
                other.southwestLng == southwestLng));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, northeastLat, northeastLng, southwestLat, southwestLng);

  /// Create a copy of GeoBounds
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GeoBoundsImplCopyWith<_$GeoBoundsImpl> get copyWith =>
      __$$GeoBoundsImplCopyWithImpl<_$GeoBoundsImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$GeoBoundsImplToJson(
      this,
    );
  }
}

abstract class _GeoBounds implements GeoBounds {
  const factory _GeoBounds(
      {required final double northeastLat,
      required final double northeastLng,
      required final double southwestLat,
      required final double southwestLng}) = _$GeoBoundsImpl;

  factory _GeoBounds.fromJson(Map<String, dynamic> json) =
      _$GeoBoundsImpl.fromJson;

  @override
  double get northeastLat;
  @override
  double get northeastLng;
  @override
  double get southwestLat;
  @override
  double get southwestLng;

  /// Create a copy of GeoBounds
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GeoBoundsImplCopyWith<_$GeoBoundsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

GeoFence _$GeoFenceFromJson(Map<String, dynamic> json) {
  return _GeoFence.fromJson(json);
}

/// @nodoc
mixin _$GeoFence {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  List<LocationModel> get polygon => throw _privateConstructorUsedError;
  GeoFenceType get type => throw _privateConstructorUsedError;
  double? get pricingMultiplier => throw _privateConstructorUsedError;
  bool? get isActive => throw _privateConstructorUsedError;

  /// Serializes this GeoFence to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of GeoFence
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $GeoFenceCopyWith<GeoFence> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GeoFenceCopyWith<$Res> {
  factory $GeoFenceCopyWith(GeoFence value, $Res Function(GeoFence) then) =
      _$GeoFenceCopyWithImpl<$Res, GeoFence>;
  @useResult
  $Res call(
      {String id,
      String name,
      List<LocationModel> polygon,
      GeoFenceType type,
      double? pricingMultiplier,
      bool? isActive});
}

/// @nodoc
class _$GeoFenceCopyWithImpl<$Res, $Val extends GeoFence>
    implements $GeoFenceCopyWith<$Res> {
  _$GeoFenceCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of GeoFence
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? polygon = null,
    Object? type = null,
    Object? pricingMultiplier = freezed,
    Object? isActive = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      polygon: null == polygon
          ? _value.polygon
          : polygon // ignore: cast_nullable_to_non_nullable
              as List<LocationModel>,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as GeoFenceType,
      pricingMultiplier: freezed == pricingMultiplier
          ? _value.pricingMultiplier
          : pricingMultiplier // ignore: cast_nullable_to_non_nullable
              as double?,
      isActive: freezed == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$GeoFenceImplCopyWith<$Res>
    implements $GeoFenceCopyWith<$Res> {
  factory _$$GeoFenceImplCopyWith(
          _$GeoFenceImpl value, $Res Function(_$GeoFenceImpl) then) =
      __$$GeoFenceImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      List<LocationModel> polygon,
      GeoFenceType type,
      double? pricingMultiplier,
      bool? isActive});
}

/// @nodoc
class __$$GeoFenceImplCopyWithImpl<$Res>
    extends _$GeoFenceCopyWithImpl<$Res, _$GeoFenceImpl>
    implements _$$GeoFenceImplCopyWith<$Res> {
  __$$GeoFenceImplCopyWithImpl(
      _$GeoFenceImpl _value, $Res Function(_$GeoFenceImpl) _then)
      : super(_value, _then);

  /// Create a copy of GeoFence
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? polygon = null,
    Object? type = null,
    Object? pricingMultiplier = freezed,
    Object? isActive = freezed,
  }) {
    return _then(_$GeoFenceImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      polygon: null == polygon
          ? _value._polygon
          : polygon // ignore: cast_nullable_to_non_nullable
              as List<LocationModel>,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as GeoFenceType,
      pricingMultiplier: freezed == pricingMultiplier
          ? _value.pricingMultiplier
          : pricingMultiplier // ignore: cast_nullable_to_non_nullable
              as double?,
      isActive: freezed == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$GeoFenceImpl implements _GeoFence {
  const _$GeoFenceImpl(
      {required this.id,
      required this.name,
      required final List<LocationModel> polygon,
      required this.type,
      this.pricingMultiplier,
      this.isActive})
      : _polygon = polygon;

  factory _$GeoFenceImpl.fromJson(Map<String, dynamic> json) =>
      _$$GeoFenceImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  final List<LocationModel> _polygon;
  @override
  List<LocationModel> get polygon {
    if (_polygon is EqualUnmodifiableListView) return _polygon;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_polygon);
  }

  @override
  final GeoFenceType type;
  @override
  final double? pricingMultiplier;
  @override
  final bool? isActive;

  @override
  String toString() {
    return 'GeoFence(id: $id, name: $name, polygon: $polygon, type: $type, pricingMultiplier: $pricingMultiplier, isActive: $isActive)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GeoFenceImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            const DeepCollectionEquality().equals(other._polygon, _polygon) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.pricingMultiplier, pricingMultiplier) ||
                other.pricingMultiplier == pricingMultiplier) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      name,
      const DeepCollectionEquality().hash(_polygon),
      type,
      pricingMultiplier,
      isActive);

  /// Create a copy of GeoFence
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GeoFenceImplCopyWith<_$GeoFenceImpl> get copyWith =>
      __$$GeoFenceImplCopyWithImpl<_$GeoFenceImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$GeoFenceImplToJson(
      this,
    );
  }
}

abstract class _GeoFence implements GeoFence {
  const factory _GeoFence(
      {required final String id,
      required final String name,
      required final List<LocationModel> polygon,
      required final GeoFenceType type,
      final double? pricingMultiplier,
      final bool? isActive}) = _$GeoFenceImpl;

  factory _GeoFence.fromJson(Map<String, dynamic> json) =
      _$GeoFenceImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  List<LocationModel> get polygon;
  @override
  GeoFenceType get type;
  @override
  double? get pricingMultiplier;
  @override
  bool? get isActive;

  /// Create a copy of GeoFence
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GeoFenceImplCopyWith<_$GeoFenceImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

RouteInfo _$RouteInfoFromJson(Map<String, dynamic> json) {
  return _RouteInfo.fromJson(json);
}

/// @nodoc
mixin _$RouteInfo {
  LocationModel get origin => throw _privateConstructorUsedError;
  LocationModel get destination => throw _privateConstructorUsedError;
  int get distanceMeters => throw _privateConstructorUsedError;
  int get durationSeconds => throw _privateConstructorUsedError;
  String get encodedPolyline => throw _privateConstructorUsedError;
  String? get distanceText => throw _privateConstructorUsedError;
  String? get durationText => throw _privateConstructorUsedError;
  List<RouteStep>? get steps => throw _privateConstructorUsedError;

  /// Serializes this RouteInfo to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of RouteInfo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RouteInfoCopyWith<RouteInfo> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RouteInfoCopyWith<$Res> {
  factory $RouteInfoCopyWith(RouteInfo value, $Res Function(RouteInfo) then) =
      _$RouteInfoCopyWithImpl<$Res, RouteInfo>;
  @useResult
  $Res call(
      {LocationModel origin,
      LocationModel destination,
      int distanceMeters,
      int durationSeconds,
      String encodedPolyline,
      String? distanceText,
      String? durationText,
      List<RouteStep>? steps});

  $LocationModelCopyWith<$Res> get origin;
  $LocationModelCopyWith<$Res> get destination;
}

/// @nodoc
class _$RouteInfoCopyWithImpl<$Res, $Val extends RouteInfo>
    implements $RouteInfoCopyWith<$Res> {
  _$RouteInfoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RouteInfo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? origin = null,
    Object? destination = null,
    Object? distanceMeters = null,
    Object? durationSeconds = null,
    Object? encodedPolyline = null,
    Object? distanceText = freezed,
    Object? durationText = freezed,
    Object? steps = freezed,
  }) {
    return _then(_value.copyWith(
      origin: null == origin
          ? _value.origin
          : origin // ignore: cast_nullable_to_non_nullable
              as LocationModel,
      destination: null == destination
          ? _value.destination
          : destination // ignore: cast_nullable_to_non_nullable
              as LocationModel,
      distanceMeters: null == distanceMeters
          ? _value.distanceMeters
          : distanceMeters // ignore: cast_nullable_to_non_nullable
              as int,
      durationSeconds: null == durationSeconds
          ? _value.durationSeconds
          : durationSeconds // ignore: cast_nullable_to_non_nullable
              as int,
      encodedPolyline: null == encodedPolyline
          ? _value.encodedPolyline
          : encodedPolyline // ignore: cast_nullable_to_non_nullable
              as String,
      distanceText: freezed == distanceText
          ? _value.distanceText
          : distanceText // ignore: cast_nullable_to_non_nullable
              as String?,
      durationText: freezed == durationText
          ? _value.durationText
          : durationText // ignore: cast_nullable_to_non_nullable
              as String?,
      steps: freezed == steps
          ? _value.steps
          : steps // ignore: cast_nullable_to_non_nullable
              as List<RouteStep>?,
    ) as $Val);
  }

  /// Create a copy of RouteInfo
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $LocationModelCopyWith<$Res> get origin {
    return $LocationModelCopyWith<$Res>(_value.origin, (value) {
      return _then(_value.copyWith(origin: value) as $Val);
    });
  }

  /// Create a copy of RouteInfo
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $LocationModelCopyWith<$Res> get destination {
    return $LocationModelCopyWith<$Res>(_value.destination, (value) {
      return _then(_value.copyWith(destination: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$RouteInfoImplCopyWith<$Res>
    implements $RouteInfoCopyWith<$Res> {
  factory _$$RouteInfoImplCopyWith(
          _$RouteInfoImpl value, $Res Function(_$RouteInfoImpl) then) =
      __$$RouteInfoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {LocationModel origin,
      LocationModel destination,
      int distanceMeters,
      int durationSeconds,
      String encodedPolyline,
      String? distanceText,
      String? durationText,
      List<RouteStep>? steps});

  @override
  $LocationModelCopyWith<$Res> get origin;
  @override
  $LocationModelCopyWith<$Res> get destination;
}

/// @nodoc
class __$$RouteInfoImplCopyWithImpl<$Res>
    extends _$RouteInfoCopyWithImpl<$Res, _$RouteInfoImpl>
    implements _$$RouteInfoImplCopyWith<$Res> {
  __$$RouteInfoImplCopyWithImpl(
      _$RouteInfoImpl _value, $Res Function(_$RouteInfoImpl) _then)
      : super(_value, _then);

  /// Create a copy of RouteInfo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? origin = null,
    Object? destination = null,
    Object? distanceMeters = null,
    Object? durationSeconds = null,
    Object? encodedPolyline = null,
    Object? distanceText = freezed,
    Object? durationText = freezed,
    Object? steps = freezed,
  }) {
    return _then(_$RouteInfoImpl(
      origin: null == origin
          ? _value.origin
          : origin // ignore: cast_nullable_to_non_nullable
              as LocationModel,
      destination: null == destination
          ? _value.destination
          : destination // ignore: cast_nullable_to_non_nullable
              as LocationModel,
      distanceMeters: null == distanceMeters
          ? _value.distanceMeters
          : distanceMeters // ignore: cast_nullable_to_non_nullable
              as int,
      durationSeconds: null == durationSeconds
          ? _value.durationSeconds
          : durationSeconds // ignore: cast_nullable_to_non_nullable
              as int,
      encodedPolyline: null == encodedPolyline
          ? _value.encodedPolyline
          : encodedPolyline // ignore: cast_nullable_to_non_nullable
              as String,
      distanceText: freezed == distanceText
          ? _value.distanceText
          : distanceText // ignore: cast_nullable_to_non_nullable
              as String?,
      durationText: freezed == durationText
          ? _value.durationText
          : durationText // ignore: cast_nullable_to_non_nullable
              as String?,
      steps: freezed == steps
          ? _value._steps
          : steps // ignore: cast_nullable_to_non_nullable
              as List<RouteStep>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$RouteInfoImpl implements _RouteInfo {
  const _$RouteInfoImpl(
      {required this.origin,
      required this.destination,
      required this.distanceMeters,
      required this.durationSeconds,
      required this.encodedPolyline,
      this.distanceText,
      this.durationText,
      final List<RouteStep>? steps})
      : _steps = steps;

  factory _$RouteInfoImpl.fromJson(Map<String, dynamic> json) =>
      _$$RouteInfoImplFromJson(json);

  @override
  final LocationModel origin;
  @override
  final LocationModel destination;
  @override
  final int distanceMeters;
  @override
  final int durationSeconds;
  @override
  final String encodedPolyline;
  @override
  final String? distanceText;
  @override
  final String? durationText;
  final List<RouteStep>? _steps;
  @override
  List<RouteStep>? get steps {
    final value = _steps;
    if (value == null) return null;
    if (_steps is EqualUnmodifiableListView) return _steps;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  String toString() {
    return 'RouteInfo(origin: $origin, destination: $destination, distanceMeters: $distanceMeters, durationSeconds: $durationSeconds, encodedPolyline: $encodedPolyline, distanceText: $distanceText, durationText: $durationText, steps: $steps)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RouteInfoImpl &&
            (identical(other.origin, origin) || other.origin == origin) &&
            (identical(other.destination, destination) ||
                other.destination == destination) &&
            (identical(other.distanceMeters, distanceMeters) ||
                other.distanceMeters == distanceMeters) &&
            (identical(other.durationSeconds, durationSeconds) ||
                other.durationSeconds == durationSeconds) &&
            (identical(other.encodedPolyline, encodedPolyline) ||
                other.encodedPolyline == encodedPolyline) &&
            (identical(other.distanceText, distanceText) ||
                other.distanceText == distanceText) &&
            (identical(other.durationText, durationText) ||
                other.durationText == durationText) &&
            const DeepCollectionEquality().equals(other._steps, _steps));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      origin,
      destination,
      distanceMeters,
      durationSeconds,
      encodedPolyline,
      distanceText,
      durationText,
      const DeepCollectionEquality().hash(_steps));

  /// Create a copy of RouteInfo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RouteInfoImplCopyWith<_$RouteInfoImpl> get copyWith =>
      __$$RouteInfoImplCopyWithImpl<_$RouteInfoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RouteInfoImplToJson(
      this,
    );
  }
}

abstract class _RouteInfo implements RouteInfo {
  const factory _RouteInfo(
      {required final LocationModel origin,
      required final LocationModel destination,
      required final int distanceMeters,
      required final int durationSeconds,
      required final String encodedPolyline,
      final String? distanceText,
      final String? durationText,
      final List<RouteStep>? steps}) = _$RouteInfoImpl;

  factory _RouteInfo.fromJson(Map<String, dynamic> json) =
      _$RouteInfoImpl.fromJson;

  @override
  LocationModel get origin;
  @override
  LocationModel get destination;
  @override
  int get distanceMeters;
  @override
  int get durationSeconds;
  @override
  String get encodedPolyline;
  @override
  String? get distanceText;
  @override
  String? get durationText;
  @override
  List<RouteStep>? get steps;

  /// Create a copy of RouteInfo
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RouteInfoImplCopyWith<_$RouteInfoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

RouteStep _$RouteStepFromJson(Map<String, dynamic> json) {
  return _RouteStep.fromJson(json);
}

/// @nodoc
mixin _$RouteStep {
  String get instruction => throw _privateConstructorUsedError;
  int get distanceMeters => throw _privateConstructorUsedError;
  int get durationSeconds => throw _privateConstructorUsedError;
  LocationModel get startLocation => throw _privateConstructorUsedError;
  LocationModel get endLocation => throw _privateConstructorUsedError;
  String? get maneuver => throw _privateConstructorUsedError;

  /// Serializes this RouteStep to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of RouteStep
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RouteStepCopyWith<RouteStep> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RouteStepCopyWith<$Res> {
  factory $RouteStepCopyWith(RouteStep value, $Res Function(RouteStep) then) =
      _$RouteStepCopyWithImpl<$Res, RouteStep>;
  @useResult
  $Res call(
      {String instruction,
      int distanceMeters,
      int durationSeconds,
      LocationModel startLocation,
      LocationModel endLocation,
      String? maneuver});

  $LocationModelCopyWith<$Res> get startLocation;
  $LocationModelCopyWith<$Res> get endLocation;
}

/// @nodoc
class _$RouteStepCopyWithImpl<$Res, $Val extends RouteStep>
    implements $RouteStepCopyWith<$Res> {
  _$RouteStepCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RouteStep
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? instruction = null,
    Object? distanceMeters = null,
    Object? durationSeconds = null,
    Object? startLocation = null,
    Object? endLocation = null,
    Object? maneuver = freezed,
  }) {
    return _then(_value.copyWith(
      instruction: null == instruction
          ? _value.instruction
          : instruction // ignore: cast_nullable_to_non_nullable
              as String,
      distanceMeters: null == distanceMeters
          ? _value.distanceMeters
          : distanceMeters // ignore: cast_nullable_to_non_nullable
              as int,
      durationSeconds: null == durationSeconds
          ? _value.durationSeconds
          : durationSeconds // ignore: cast_nullable_to_non_nullable
              as int,
      startLocation: null == startLocation
          ? _value.startLocation
          : startLocation // ignore: cast_nullable_to_non_nullable
              as LocationModel,
      endLocation: null == endLocation
          ? _value.endLocation
          : endLocation // ignore: cast_nullable_to_non_nullable
              as LocationModel,
      maneuver: freezed == maneuver
          ? _value.maneuver
          : maneuver // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }

  /// Create a copy of RouteStep
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $LocationModelCopyWith<$Res> get startLocation {
    return $LocationModelCopyWith<$Res>(_value.startLocation, (value) {
      return _then(_value.copyWith(startLocation: value) as $Val);
    });
  }

  /// Create a copy of RouteStep
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $LocationModelCopyWith<$Res> get endLocation {
    return $LocationModelCopyWith<$Res>(_value.endLocation, (value) {
      return _then(_value.copyWith(endLocation: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$RouteStepImplCopyWith<$Res>
    implements $RouteStepCopyWith<$Res> {
  factory _$$RouteStepImplCopyWith(
          _$RouteStepImpl value, $Res Function(_$RouteStepImpl) then) =
      __$$RouteStepImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String instruction,
      int distanceMeters,
      int durationSeconds,
      LocationModel startLocation,
      LocationModel endLocation,
      String? maneuver});

  @override
  $LocationModelCopyWith<$Res> get startLocation;
  @override
  $LocationModelCopyWith<$Res> get endLocation;
}

/// @nodoc
class __$$RouteStepImplCopyWithImpl<$Res>
    extends _$RouteStepCopyWithImpl<$Res, _$RouteStepImpl>
    implements _$$RouteStepImplCopyWith<$Res> {
  __$$RouteStepImplCopyWithImpl(
      _$RouteStepImpl _value, $Res Function(_$RouteStepImpl) _then)
      : super(_value, _then);

  /// Create a copy of RouteStep
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? instruction = null,
    Object? distanceMeters = null,
    Object? durationSeconds = null,
    Object? startLocation = null,
    Object? endLocation = null,
    Object? maneuver = freezed,
  }) {
    return _then(_$RouteStepImpl(
      instruction: null == instruction
          ? _value.instruction
          : instruction // ignore: cast_nullable_to_non_nullable
              as String,
      distanceMeters: null == distanceMeters
          ? _value.distanceMeters
          : distanceMeters // ignore: cast_nullable_to_non_nullable
              as int,
      durationSeconds: null == durationSeconds
          ? _value.durationSeconds
          : durationSeconds // ignore: cast_nullable_to_non_nullable
              as int,
      startLocation: null == startLocation
          ? _value.startLocation
          : startLocation // ignore: cast_nullable_to_non_nullable
              as LocationModel,
      endLocation: null == endLocation
          ? _value.endLocation
          : endLocation // ignore: cast_nullable_to_non_nullable
              as LocationModel,
      maneuver: freezed == maneuver
          ? _value.maneuver
          : maneuver // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$RouteStepImpl implements _RouteStep {
  const _$RouteStepImpl(
      {required this.instruction,
      required this.distanceMeters,
      required this.durationSeconds,
      required this.startLocation,
      required this.endLocation,
      this.maneuver});

  factory _$RouteStepImpl.fromJson(Map<String, dynamic> json) =>
      _$$RouteStepImplFromJson(json);

  @override
  final String instruction;
  @override
  final int distanceMeters;
  @override
  final int durationSeconds;
  @override
  final LocationModel startLocation;
  @override
  final LocationModel endLocation;
  @override
  final String? maneuver;

  @override
  String toString() {
    return 'RouteStep(instruction: $instruction, distanceMeters: $distanceMeters, durationSeconds: $durationSeconds, startLocation: $startLocation, endLocation: $endLocation, maneuver: $maneuver)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RouteStepImpl &&
            (identical(other.instruction, instruction) ||
                other.instruction == instruction) &&
            (identical(other.distanceMeters, distanceMeters) ||
                other.distanceMeters == distanceMeters) &&
            (identical(other.durationSeconds, durationSeconds) ||
                other.durationSeconds == durationSeconds) &&
            (identical(other.startLocation, startLocation) ||
                other.startLocation == startLocation) &&
            (identical(other.endLocation, endLocation) ||
                other.endLocation == endLocation) &&
            (identical(other.maneuver, maneuver) ||
                other.maneuver == maneuver));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, instruction, distanceMeters,
      durationSeconds, startLocation, endLocation, maneuver);

  /// Create a copy of RouteStep
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RouteStepImplCopyWith<_$RouteStepImpl> get copyWith =>
      __$$RouteStepImplCopyWithImpl<_$RouteStepImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RouteStepImplToJson(
      this,
    );
  }
}

abstract class _RouteStep implements RouteStep {
  const factory _RouteStep(
      {required final String instruction,
      required final int distanceMeters,
      required final int durationSeconds,
      required final LocationModel startLocation,
      required final LocationModel endLocation,
      final String? maneuver}) = _$RouteStepImpl;

  factory _RouteStep.fromJson(Map<String, dynamic> json) =
      _$RouteStepImpl.fromJson;

  @override
  String get instruction;
  @override
  int get distanceMeters;
  @override
  int get durationSeconds;
  @override
  LocationModel get startLocation;
  @override
  LocationModel get endLocation;
  @override
  String? get maneuver;

  /// Create a copy of RouteStep
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RouteStepImplCopyWith<_$RouteStepImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
