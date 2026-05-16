// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'notification_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

NotificationModel _$NotificationModelFromJson(Map<String, dynamic> json) {
  return _NotificationModel.fromJson(json);
}

/// @nodoc
mixin _$NotificationModel {
  String get id => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get body => throw _privateConstructorUsedError;
  NotificationType get type => throw _privateConstructorUsedError;
  NotificationChannel get channel => throw _privateConstructorUsedError;
  NotificationStatus get status => throw _privateConstructorUsedError;
  Map<String, dynamic>? get data => throw _privateConstructorUsedError;
  String? get imageUrl => throw _privateConstructorUsedError;
  String? get actionUrl => throw _privateConstructorUsedError;
  DateTime? get readAt => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Serializes this NotificationModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of NotificationModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $NotificationModelCopyWith<NotificationModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $NotificationModelCopyWith<$Res> {
  factory $NotificationModelCopyWith(
          NotificationModel value, $Res Function(NotificationModel) then) =
      _$NotificationModelCopyWithImpl<$Res, NotificationModel>;
  @useResult
  $Res call(
      {String id,
      String userId,
      String title,
      String body,
      NotificationType type,
      NotificationChannel channel,
      NotificationStatus status,
      Map<String, dynamic>? data,
      String? imageUrl,
      String? actionUrl,
      DateTime? readAt,
      DateTime createdAt});
}

/// @nodoc
class _$NotificationModelCopyWithImpl<$Res, $Val extends NotificationModel>
    implements $NotificationModelCopyWith<$Res> {
  _$NotificationModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of NotificationModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? title = null,
    Object? body = null,
    Object? type = null,
    Object? channel = null,
    Object? status = null,
    Object? data = freezed,
    Object? imageUrl = freezed,
    Object? actionUrl = freezed,
    Object? readAt = freezed,
    Object? createdAt = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      body: null == body
          ? _value.body
          : body // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as NotificationType,
      channel: null == channel
          ? _value.channel
          : channel // ignore: cast_nullable_to_non_nullable
              as NotificationChannel,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as NotificationStatus,
      data: freezed == data
          ? _value.data
          : data // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      imageUrl: freezed == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      actionUrl: freezed == actionUrl
          ? _value.actionUrl
          : actionUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      readAt: freezed == readAt
          ? _value.readAt
          : readAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$NotificationModelImplCopyWith<$Res>
    implements $NotificationModelCopyWith<$Res> {
  factory _$$NotificationModelImplCopyWith(_$NotificationModelImpl value,
          $Res Function(_$NotificationModelImpl) then) =
      __$$NotificationModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String userId,
      String title,
      String body,
      NotificationType type,
      NotificationChannel channel,
      NotificationStatus status,
      Map<String, dynamic>? data,
      String? imageUrl,
      String? actionUrl,
      DateTime? readAt,
      DateTime createdAt});
}

/// @nodoc
class __$$NotificationModelImplCopyWithImpl<$Res>
    extends _$NotificationModelCopyWithImpl<$Res, _$NotificationModelImpl>
    implements _$$NotificationModelImplCopyWith<$Res> {
  __$$NotificationModelImplCopyWithImpl(_$NotificationModelImpl _value,
      $Res Function(_$NotificationModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of NotificationModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? title = null,
    Object? body = null,
    Object? type = null,
    Object? channel = null,
    Object? status = null,
    Object? data = freezed,
    Object? imageUrl = freezed,
    Object? actionUrl = freezed,
    Object? readAt = freezed,
    Object? createdAt = null,
  }) {
    return _then(_$NotificationModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      body: null == body
          ? _value.body
          : body // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as NotificationType,
      channel: null == channel
          ? _value.channel
          : channel // ignore: cast_nullable_to_non_nullable
              as NotificationChannel,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as NotificationStatus,
      data: freezed == data
          ? _value._data
          : data // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      imageUrl: freezed == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      actionUrl: freezed == actionUrl
          ? _value.actionUrl
          : actionUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      readAt: freezed == readAt
          ? _value.readAt
          : readAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$NotificationModelImpl implements _NotificationModel {
  const _$NotificationModelImpl(
      {required this.id,
      required this.userId,
      required this.title,
      required this.body,
      required this.type,
      required this.channel,
      this.status = NotificationStatus.unread,
      final Map<String, dynamic>? data,
      this.imageUrl,
      this.actionUrl,
      this.readAt,
      required this.createdAt})
      : _data = data;

  factory _$NotificationModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$NotificationModelImplFromJson(json);

  @override
  final String id;
  @override
  final String userId;
  @override
  final String title;
  @override
  final String body;
  @override
  final NotificationType type;
  @override
  final NotificationChannel channel;
  @override
  @JsonKey()
  final NotificationStatus status;
  final Map<String, dynamic>? _data;
  @override
  Map<String, dynamic>? get data {
    final value = _data;
    if (value == null) return null;
    if (_data is EqualUnmodifiableMapView) return _data;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  final String? imageUrl;
  @override
  final String? actionUrl;
  @override
  final DateTime? readAt;
  @override
  final DateTime createdAt;

  @override
  String toString() {
    return 'NotificationModel(id: $id, userId: $userId, title: $title, body: $body, type: $type, channel: $channel, status: $status, data: $data, imageUrl: $imageUrl, actionUrl: $actionUrl, readAt: $readAt, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NotificationModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.body, body) || other.body == body) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.channel, channel) || other.channel == channel) &&
            (identical(other.status, status) || other.status == status) &&
            const DeepCollectionEquality().equals(other._data, _data) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            (identical(other.actionUrl, actionUrl) ||
                other.actionUrl == actionUrl) &&
            (identical(other.readAt, readAt) || other.readAt == readAt) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      userId,
      title,
      body,
      type,
      channel,
      status,
      const DeepCollectionEquality().hash(_data),
      imageUrl,
      actionUrl,
      readAt,
      createdAt);

  /// Create a copy of NotificationModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$NotificationModelImplCopyWith<_$NotificationModelImpl> get copyWith =>
      __$$NotificationModelImplCopyWithImpl<_$NotificationModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$NotificationModelImplToJson(
      this,
    );
  }
}

abstract class _NotificationModel implements NotificationModel {
  const factory _NotificationModel(
      {required final String id,
      required final String userId,
      required final String title,
      required final String body,
      required final NotificationType type,
      required final NotificationChannel channel,
      final NotificationStatus status,
      final Map<String, dynamic>? data,
      final String? imageUrl,
      final String? actionUrl,
      final DateTime? readAt,
      required final DateTime createdAt}) = _$NotificationModelImpl;

  factory _NotificationModel.fromJson(Map<String, dynamic> json) =
      _$NotificationModelImpl.fromJson;

  @override
  String get id;
  @override
  String get userId;
  @override
  String get title;
  @override
  String get body;
  @override
  NotificationType get type;
  @override
  NotificationChannel get channel;
  @override
  NotificationStatus get status;
  @override
  Map<String, dynamic>? get data;
  @override
  String? get imageUrl;
  @override
  String? get actionUrl;
  @override
  DateTime? get readAt;
  @override
  DateTime get createdAt;

  /// Create a copy of NotificationModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$NotificationModelImplCopyWith<_$NotificationModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

NotificationPreferences _$NotificationPreferencesFromJson(
    Map<String, dynamic> json) {
  return _NotificationPreferences.fromJson(json);
}

/// @nodoc
mixin _$NotificationPreferences {
  String get userId => throw _privateConstructorUsedError;
  bool get pushEnabled => throw _privateConstructorUsedError;
  bool get smsEnabled => throw _privateConstructorUsedError;
  bool get whatsappEnabled => throw _privateConstructorUsedError;
  bool get emailEnabled => throw _privateConstructorUsedError;
  bool get tripUpdatesEnabled => throw _privateConstructorUsedError;
  bool get promotionsEnabled => throw _privateConstructorUsedError;
  bool get walletUpdatesEnabled => throw _privateConstructorUsedError;
  bool get systemAlertsEnabled => throw _privateConstructorUsedError;

  /// Serializes this NotificationPreferences to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of NotificationPreferences
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $NotificationPreferencesCopyWith<NotificationPreferences> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $NotificationPreferencesCopyWith<$Res> {
  factory $NotificationPreferencesCopyWith(NotificationPreferences value,
          $Res Function(NotificationPreferences) then) =
      _$NotificationPreferencesCopyWithImpl<$Res, NotificationPreferences>;
  @useResult
  $Res call(
      {String userId,
      bool pushEnabled,
      bool smsEnabled,
      bool whatsappEnabled,
      bool emailEnabled,
      bool tripUpdatesEnabled,
      bool promotionsEnabled,
      bool walletUpdatesEnabled,
      bool systemAlertsEnabled});
}

/// @nodoc
class _$NotificationPreferencesCopyWithImpl<$Res,
        $Val extends NotificationPreferences>
    implements $NotificationPreferencesCopyWith<$Res> {
  _$NotificationPreferencesCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of NotificationPreferences
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? pushEnabled = null,
    Object? smsEnabled = null,
    Object? whatsappEnabled = null,
    Object? emailEnabled = null,
    Object? tripUpdatesEnabled = null,
    Object? promotionsEnabled = null,
    Object? walletUpdatesEnabled = null,
    Object? systemAlertsEnabled = null,
  }) {
    return _then(_value.copyWith(
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      pushEnabled: null == pushEnabled
          ? _value.pushEnabled
          : pushEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      smsEnabled: null == smsEnabled
          ? _value.smsEnabled
          : smsEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      whatsappEnabled: null == whatsappEnabled
          ? _value.whatsappEnabled
          : whatsappEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      emailEnabled: null == emailEnabled
          ? _value.emailEnabled
          : emailEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      tripUpdatesEnabled: null == tripUpdatesEnabled
          ? _value.tripUpdatesEnabled
          : tripUpdatesEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      promotionsEnabled: null == promotionsEnabled
          ? _value.promotionsEnabled
          : promotionsEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      walletUpdatesEnabled: null == walletUpdatesEnabled
          ? _value.walletUpdatesEnabled
          : walletUpdatesEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      systemAlertsEnabled: null == systemAlertsEnabled
          ? _value.systemAlertsEnabled
          : systemAlertsEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$NotificationPreferencesImplCopyWith<$Res>
    implements $NotificationPreferencesCopyWith<$Res> {
  factory _$$NotificationPreferencesImplCopyWith(
          _$NotificationPreferencesImpl value,
          $Res Function(_$NotificationPreferencesImpl) then) =
      __$$NotificationPreferencesImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String userId,
      bool pushEnabled,
      bool smsEnabled,
      bool whatsappEnabled,
      bool emailEnabled,
      bool tripUpdatesEnabled,
      bool promotionsEnabled,
      bool walletUpdatesEnabled,
      bool systemAlertsEnabled});
}

/// @nodoc
class __$$NotificationPreferencesImplCopyWithImpl<$Res>
    extends _$NotificationPreferencesCopyWithImpl<$Res,
        _$NotificationPreferencesImpl>
    implements _$$NotificationPreferencesImplCopyWith<$Res> {
  __$$NotificationPreferencesImplCopyWithImpl(
      _$NotificationPreferencesImpl _value,
      $Res Function(_$NotificationPreferencesImpl) _then)
      : super(_value, _then);

  /// Create a copy of NotificationPreferences
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? pushEnabled = null,
    Object? smsEnabled = null,
    Object? whatsappEnabled = null,
    Object? emailEnabled = null,
    Object? tripUpdatesEnabled = null,
    Object? promotionsEnabled = null,
    Object? walletUpdatesEnabled = null,
    Object? systemAlertsEnabled = null,
  }) {
    return _then(_$NotificationPreferencesImpl(
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      pushEnabled: null == pushEnabled
          ? _value.pushEnabled
          : pushEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      smsEnabled: null == smsEnabled
          ? _value.smsEnabled
          : smsEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      whatsappEnabled: null == whatsappEnabled
          ? _value.whatsappEnabled
          : whatsappEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      emailEnabled: null == emailEnabled
          ? _value.emailEnabled
          : emailEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      tripUpdatesEnabled: null == tripUpdatesEnabled
          ? _value.tripUpdatesEnabled
          : tripUpdatesEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      promotionsEnabled: null == promotionsEnabled
          ? _value.promotionsEnabled
          : promotionsEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      walletUpdatesEnabled: null == walletUpdatesEnabled
          ? _value.walletUpdatesEnabled
          : walletUpdatesEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      systemAlertsEnabled: null == systemAlertsEnabled
          ? _value.systemAlertsEnabled
          : systemAlertsEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$NotificationPreferencesImpl implements _NotificationPreferences {
  const _$NotificationPreferencesImpl(
      {required this.userId,
      this.pushEnabled = true,
      this.smsEnabled = true,
      this.whatsappEnabled = false,
      this.emailEnabled = true,
      this.tripUpdatesEnabled = true,
      this.promotionsEnabled = true,
      this.walletUpdatesEnabled = true,
      this.systemAlertsEnabled = true});

  factory _$NotificationPreferencesImpl.fromJson(Map<String, dynamic> json) =>
      _$$NotificationPreferencesImplFromJson(json);

  @override
  final String userId;
  @override
  @JsonKey()
  final bool pushEnabled;
  @override
  @JsonKey()
  final bool smsEnabled;
  @override
  @JsonKey()
  final bool whatsappEnabled;
  @override
  @JsonKey()
  final bool emailEnabled;
  @override
  @JsonKey()
  final bool tripUpdatesEnabled;
  @override
  @JsonKey()
  final bool promotionsEnabled;
  @override
  @JsonKey()
  final bool walletUpdatesEnabled;
  @override
  @JsonKey()
  final bool systemAlertsEnabled;

  @override
  String toString() {
    return 'NotificationPreferences(userId: $userId, pushEnabled: $pushEnabled, smsEnabled: $smsEnabled, whatsappEnabled: $whatsappEnabled, emailEnabled: $emailEnabled, tripUpdatesEnabled: $tripUpdatesEnabled, promotionsEnabled: $promotionsEnabled, walletUpdatesEnabled: $walletUpdatesEnabled, systemAlertsEnabled: $systemAlertsEnabled)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NotificationPreferencesImpl &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.pushEnabled, pushEnabled) ||
                other.pushEnabled == pushEnabled) &&
            (identical(other.smsEnabled, smsEnabled) ||
                other.smsEnabled == smsEnabled) &&
            (identical(other.whatsappEnabled, whatsappEnabled) ||
                other.whatsappEnabled == whatsappEnabled) &&
            (identical(other.emailEnabled, emailEnabled) ||
                other.emailEnabled == emailEnabled) &&
            (identical(other.tripUpdatesEnabled, tripUpdatesEnabled) ||
                other.tripUpdatesEnabled == tripUpdatesEnabled) &&
            (identical(other.promotionsEnabled, promotionsEnabled) ||
                other.promotionsEnabled == promotionsEnabled) &&
            (identical(other.walletUpdatesEnabled, walletUpdatesEnabled) ||
                other.walletUpdatesEnabled == walletUpdatesEnabled) &&
            (identical(other.systemAlertsEnabled, systemAlertsEnabled) ||
                other.systemAlertsEnabled == systemAlertsEnabled));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      userId,
      pushEnabled,
      smsEnabled,
      whatsappEnabled,
      emailEnabled,
      tripUpdatesEnabled,
      promotionsEnabled,
      walletUpdatesEnabled,
      systemAlertsEnabled);

  /// Create a copy of NotificationPreferences
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$NotificationPreferencesImplCopyWith<_$NotificationPreferencesImpl>
      get copyWith => __$$NotificationPreferencesImplCopyWithImpl<
          _$NotificationPreferencesImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$NotificationPreferencesImplToJson(
      this,
    );
  }
}

abstract class _NotificationPreferences implements NotificationPreferences {
  const factory _NotificationPreferences(
      {required final String userId,
      final bool pushEnabled,
      final bool smsEnabled,
      final bool whatsappEnabled,
      final bool emailEnabled,
      final bool tripUpdatesEnabled,
      final bool promotionsEnabled,
      final bool walletUpdatesEnabled,
      final bool systemAlertsEnabled}) = _$NotificationPreferencesImpl;

  factory _NotificationPreferences.fromJson(Map<String, dynamic> json) =
      _$NotificationPreferencesImpl.fromJson;

  @override
  String get userId;
  @override
  bool get pushEnabled;
  @override
  bool get smsEnabled;
  @override
  bool get whatsappEnabled;
  @override
  bool get emailEnabled;
  @override
  bool get tripUpdatesEnabled;
  @override
  bool get promotionsEnabled;
  @override
  bool get walletUpdatesEnabled;
  @override
  bool get systemAlertsEnabled;

  /// Create a copy of NotificationPreferences
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$NotificationPreferencesImplCopyWith<_$NotificationPreferencesImpl>
      get copyWith => throw _privateConstructorUsedError;
}

DeviceToken _$DeviceTokenFromJson(Map<String, dynamic> json) {
  return _DeviceToken.fromJson(json);
}

/// @nodoc
mixin _$DeviceToken {
  String get userId => throw _privateConstructorUsedError;
  String get token => throw _privateConstructorUsedError;
  String get platform => throw _privateConstructorUsedError;
  String get deviceId => throw _privateConstructorUsedError;
  bool get isActive => throw _privateConstructorUsedError;
  DateTime? get registeredAt => throw _privateConstructorUsedError;

  /// Serializes this DeviceToken to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DeviceToken
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DeviceTokenCopyWith<DeviceToken> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DeviceTokenCopyWith<$Res> {
  factory $DeviceTokenCopyWith(
          DeviceToken value, $Res Function(DeviceToken) then) =
      _$DeviceTokenCopyWithImpl<$Res, DeviceToken>;
  @useResult
  $Res call(
      {String userId,
      String token,
      String platform,
      String deviceId,
      bool isActive,
      DateTime? registeredAt});
}

/// @nodoc
class _$DeviceTokenCopyWithImpl<$Res, $Val extends DeviceToken>
    implements $DeviceTokenCopyWith<$Res> {
  _$DeviceTokenCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DeviceToken
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? token = null,
    Object? platform = null,
    Object? deviceId = null,
    Object? isActive = null,
    Object? registeredAt = freezed,
  }) {
    return _then(_value.copyWith(
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      token: null == token
          ? _value.token
          : token // ignore: cast_nullable_to_non_nullable
              as String,
      platform: null == platform
          ? _value.platform
          : platform // ignore: cast_nullable_to_non_nullable
              as String,
      deviceId: null == deviceId
          ? _value.deviceId
          : deviceId // ignore: cast_nullable_to_non_nullable
              as String,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      registeredAt: freezed == registeredAt
          ? _value.registeredAt
          : registeredAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$DeviceTokenImplCopyWith<$Res>
    implements $DeviceTokenCopyWith<$Res> {
  factory _$$DeviceTokenImplCopyWith(
          _$DeviceTokenImpl value, $Res Function(_$DeviceTokenImpl) then) =
      __$$DeviceTokenImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String userId,
      String token,
      String platform,
      String deviceId,
      bool isActive,
      DateTime? registeredAt});
}

/// @nodoc
class __$$DeviceTokenImplCopyWithImpl<$Res>
    extends _$DeviceTokenCopyWithImpl<$Res, _$DeviceTokenImpl>
    implements _$$DeviceTokenImplCopyWith<$Res> {
  __$$DeviceTokenImplCopyWithImpl(
      _$DeviceTokenImpl _value, $Res Function(_$DeviceTokenImpl) _then)
      : super(_value, _then);

  /// Create a copy of DeviceToken
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? token = null,
    Object? platform = null,
    Object? deviceId = null,
    Object? isActive = null,
    Object? registeredAt = freezed,
  }) {
    return _then(_$DeviceTokenImpl(
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      token: null == token
          ? _value.token
          : token // ignore: cast_nullable_to_non_nullable
              as String,
      platform: null == platform
          ? _value.platform
          : platform // ignore: cast_nullable_to_non_nullable
              as String,
      deviceId: null == deviceId
          ? _value.deviceId
          : deviceId // ignore: cast_nullable_to_non_nullable
              as String,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      registeredAt: freezed == registeredAt
          ? _value.registeredAt
          : registeredAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$DeviceTokenImpl implements _DeviceToken {
  const _$DeviceTokenImpl(
      {required this.userId,
      required this.token,
      required this.platform,
      required this.deviceId,
      this.isActive = true,
      this.registeredAt});

  factory _$DeviceTokenImpl.fromJson(Map<String, dynamic> json) =>
      _$$DeviceTokenImplFromJson(json);

  @override
  final String userId;
  @override
  final String token;
  @override
  final String platform;
  @override
  final String deviceId;
  @override
  @JsonKey()
  final bool isActive;
  @override
  final DateTime? registeredAt;

  @override
  String toString() {
    return 'DeviceToken(userId: $userId, token: $token, platform: $platform, deviceId: $deviceId, isActive: $isActive, registeredAt: $registeredAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DeviceTokenImpl &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.token, token) || other.token == token) &&
            (identical(other.platform, platform) ||
                other.platform == platform) &&
            (identical(other.deviceId, deviceId) ||
                other.deviceId == deviceId) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.registeredAt, registeredAt) ||
                other.registeredAt == registeredAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, userId, token, platform, deviceId, isActive, registeredAt);

  /// Create a copy of DeviceToken
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DeviceTokenImplCopyWith<_$DeviceTokenImpl> get copyWith =>
      __$$DeviceTokenImplCopyWithImpl<_$DeviceTokenImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DeviceTokenImplToJson(
      this,
    );
  }
}

abstract class _DeviceToken implements DeviceToken {
  const factory _DeviceToken(
      {required final String userId,
      required final String token,
      required final String platform,
      required final String deviceId,
      final bool isActive,
      final DateTime? registeredAt}) = _$DeviceTokenImpl;

  factory _DeviceToken.fromJson(Map<String, dynamic> json) =
      _$DeviceTokenImpl.fromJson;

  @override
  String get userId;
  @override
  String get token;
  @override
  String get platform;
  @override
  String get deviceId;
  @override
  bool get isActive;
  @override
  DateTime? get registeredAt;

  /// Create a copy of DeviceToken
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DeviceTokenImplCopyWith<_$DeviceTokenImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
