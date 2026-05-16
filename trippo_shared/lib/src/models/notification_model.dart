import 'package:freezed_annotation/freezed_annotation.dart';

part 'notification_model.freezed.dart';
part 'notification_model.g.dart';

/// Notification model - represents a notification sent to user/driver
@freezed
class NotificationModel with _$NotificationModel {
  const factory NotificationModel({
    required String id,
    required String userId,
    required String title,
    required String body,
    required NotificationType type,
    required NotificationChannel channel,
    @Default(NotificationStatus.unread) NotificationStatus status,
    Map<String, dynamic>? data,
    String? imageUrl,
    String? actionUrl,
    DateTime? readAt,
    required DateTime createdAt,
  }) = _NotificationModel;

  factory NotificationModel.fromJson(Map<String, dynamic> json) =>
      _$NotificationModelFromJson(json);
}

enum NotificationType {
  @JsonValue('trip_update')
  tripUpdate,
  @JsonValue('driver_assigned')
  driverAssigned,
  @JsonValue('driver_arriving')
  driverArriving,
  @JsonValue('driver_arrived')
  driverArrived,
  @JsonValue('trip_started')
  tripStarted,
  @JsonValue('trip_completed')
  tripCompleted,
  @JsonValue('trip_cancelled')
  tripCancelled,
  @JsonValue('payment_received')
  paymentReceived,
  @JsonValue('wallet_update')
  walletUpdate,
  @JsonValue('withdrawal_status')
  withdrawalStatus,
  @JsonValue('promotion')
  promotion,
  @JsonValue('system')
  system,
  @JsonValue('document_verification')
  documentVerification,
  @JsonValue('rating_reminder')
  ratingReminder,
}

enum NotificationChannel {
  @JsonValue('push')
  push,
  @JsonValue('sms')
  sms,
  @JsonValue('whatsapp')
  whatsapp,
  @JsonValue('email')
  email,
  @JsonValue('in_app')
  inApp,
}

enum NotificationStatus {
  @JsonValue('unread')
  unread,
  @JsonValue('read')
  read,
  @JsonValue('failed')
  failed,
}

/// Notification preferences per user
@freezed
class NotificationPreferences with _$NotificationPreferences {
  const factory NotificationPreferences({
    required String userId,
    @Default(true) bool pushEnabled,
    @Default(true) bool smsEnabled,
    @Default(false) bool whatsappEnabled,
    @Default(true) bool emailEnabled,
    @Default(true) bool tripUpdatesEnabled,
    @Default(true) bool promotionsEnabled,
    @Default(true) bool walletUpdatesEnabled,
    @Default(true) bool systemAlertsEnabled,
  }) = _NotificationPreferences;

  factory NotificationPreferences.fromJson(Map<String, dynamic> json) =>
      _$NotificationPreferencesFromJson(json);
}

/// Device token registration
@freezed
class DeviceToken with _$DeviceToken {
  const factory DeviceToken({
    required String userId,
    required String token,
    required String platform,
    required String deviceId,
    @Default(true) bool isActive,
    DateTime? registeredAt,
  }) = _DeviceToken;

  factory DeviceToken.fromJson(Map<String, dynamic> json) =>
      _$DeviceTokenFromJson(json);
}
