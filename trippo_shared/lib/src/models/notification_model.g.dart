// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$NotificationModelImpl _$$NotificationModelImplFromJson(
        Map<String, dynamic> json) =>
    _$NotificationModelImpl(
      id: json['id'] as String,
      userId: json['userId'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
      type: $enumDecode(_$NotificationTypeEnumMap, json['type']),
      channel: $enumDecode(_$NotificationChannelEnumMap, json['channel']),
      status:
          $enumDecodeNullable(_$NotificationStatusEnumMap, json['status']) ??
              NotificationStatus.unread,
      data: json['data'] as Map<String, dynamic>?,
      imageUrl: json['imageUrl'] as String?,
      actionUrl: json['actionUrl'] as String?,
      readAt: json['readAt'] == null
          ? null
          : DateTime.parse(json['readAt'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$NotificationModelImplToJson(
        _$NotificationModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'title': instance.title,
      'body': instance.body,
      'type': _$NotificationTypeEnumMap[instance.type]!,
      'channel': _$NotificationChannelEnumMap[instance.channel]!,
      'status': _$NotificationStatusEnumMap[instance.status]!,
      'data': instance.data,
      'imageUrl': instance.imageUrl,
      'actionUrl': instance.actionUrl,
      'readAt': instance.readAt?.toIso8601String(),
      'createdAt': instance.createdAt.toIso8601String(),
    };

const _$NotificationTypeEnumMap = {
  NotificationType.tripUpdate: 'trip_update',
  NotificationType.driverAssigned: 'driver_assigned',
  NotificationType.driverArriving: 'driver_arriving',
  NotificationType.driverArrived: 'driver_arrived',
  NotificationType.tripStarted: 'trip_started',
  NotificationType.tripCompleted: 'trip_completed',
  NotificationType.tripCancelled: 'trip_cancelled',
  NotificationType.paymentReceived: 'payment_received',
  NotificationType.walletUpdate: 'wallet_update',
  NotificationType.withdrawalStatus: 'withdrawal_status',
  NotificationType.promotion: 'promotion',
  NotificationType.system: 'system',
  NotificationType.documentVerification: 'document_verification',
  NotificationType.ratingReminder: 'rating_reminder',
};

const _$NotificationChannelEnumMap = {
  NotificationChannel.push: 'push',
  NotificationChannel.sms: 'sms',
  NotificationChannel.whatsapp: 'whatsapp',
  NotificationChannel.email: 'email',
  NotificationChannel.inApp: 'in_app',
};

const _$NotificationStatusEnumMap = {
  NotificationStatus.unread: 'unread',
  NotificationStatus.read: 'read',
  NotificationStatus.failed: 'failed',
};

_$NotificationPreferencesImpl _$$NotificationPreferencesImplFromJson(
        Map<String, dynamic> json) =>
    _$NotificationPreferencesImpl(
      userId: json['userId'] as String,
      pushEnabled: json['pushEnabled'] as bool? ?? true,
      smsEnabled: json['smsEnabled'] as bool? ?? true,
      whatsappEnabled: json['whatsappEnabled'] as bool? ?? false,
      emailEnabled: json['emailEnabled'] as bool? ?? true,
      tripUpdatesEnabled: json['tripUpdatesEnabled'] as bool? ?? true,
      promotionsEnabled: json['promotionsEnabled'] as bool? ?? true,
      walletUpdatesEnabled: json['walletUpdatesEnabled'] as bool? ?? true,
      systemAlertsEnabled: json['systemAlertsEnabled'] as bool? ?? true,
    );

Map<String, dynamic> _$$NotificationPreferencesImplToJson(
        _$NotificationPreferencesImpl instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'pushEnabled': instance.pushEnabled,
      'smsEnabled': instance.smsEnabled,
      'whatsappEnabled': instance.whatsappEnabled,
      'emailEnabled': instance.emailEnabled,
      'tripUpdatesEnabled': instance.tripUpdatesEnabled,
      'promotionsEnabled': instance.promotionsEnabled,
      'walletUpdatesEnabled': instance.walletUpdatesEnabled,
      'systemAlertsEnabled': instance.systemAlertsEnabled,
    };

_$DeviceTokenImpl _$$DeviceTokenImplFromJson(Map<String, dynamic> json) =>
    _$DeviceTokenImpl(
      userId: json['userId'] as String,
      token: json['token'] as String,
      platform: json['platform'] as String,
      deviceId: json['deviceId'] as String,
      isActive: json['isActive'] as bool? ?? true,
      registeredAt: json['registeredAt'] == null
          ? null
          : DateTime.parse(json['registeredAt'] as String),
    );

Map<String, dynamic> _$$DeviceTokenImplToJson(_$DeviceTokenImpl instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'token': instance.token,
      'platform': instance.platform,
      'deviceId': instance.deviceId,
      'isActive': instance.isActive,
      'registeredAt': instance.registeredAt?.toIso8601String(),
    };
