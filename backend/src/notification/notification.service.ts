import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma.service';
import { NotificationType, NotificationChannel, NotificationStatus } from '@prisma/client';

/// Notification Service - Manages in-app notifications and multi-channel dispatching
/// Supports FCM (push), SMS, WhatsApp, and Email channels
@Injectable()
export class NotificationService {
  constructor(private prisma: PrismaService) {}

  /// Get user notifications with pagination
  async getNotifications(userId: string, page: number = 1, pageSize: number = 20, type?: NotificationType) {
    const where = {
      userId,
      ...(type ? { type } : {}),
    };

    const [items, total] = await Promise.all([
      this.prisma.notification.findMany({
        where,
        orderBy: { createdAt: 'desc' },
        skip: (page - 1) * pageSize,
        take: pageSize,
      }),
      this.prisma.notification.count({ where }),
    ]);

    // Get unread count
    const unreadCount = await this.prisma.notification.count({
      where: { userId, status: NotificationStatus.UNREAD },
    });

    return { items, total, page, pageSize, unreadCount };
  }

  /// Register or update FCM device token
  async registerDeviceToken(userId: string, dto: any) {
    // Upsert device token (one token per device)
    const deviceToken = await this.prisma.deviceToken.upsert({
      where: {
        userId_deviceId: {
          userId,
          deviceId: dto.deviceId,
        },
      },
      update: {
        token: dto.token,
        platform: dto.platform,
        isActive: true,
      },
      create: {
        userId,
        token: dto.token,
        platform: dto.platform,
        deviceId: dto.deviceId,
        isActive: true,
      },
    });

    return deviceToken;
  }

  /// Get notification preferences for user
  async getPreferences(userId: string) {
    // Notification preferences are stored as user metadata
    // Default preferences if not set
    const user = await this.prisma.user.findUnique({ where: { id: userId } });
    if (!user) throw new NotFoundException('User not found');

    // Default notification preferences
    return {
      userId,
      channels: {
        push: true,
        sms: true,
        whatsapp: false,
        email: true,
        inApp: true,
      },
      types: {
        TRIP_UPDATE: true,
        DRIVER_ASSIGNED: true,
        DRIVER_ARRIVING: true,
        DRIVER_ARRIVED: true,
        TRIP_STARTED: true,
        TRIP_COMPLETED: true,
        TRIP_CANCELLED: true,
        PAYMENT_RECEIVED: true,
        WALLET_UPDATE: true,
        WITHDRAWAL_STATUS: true,
        PROMOTION: true,
        SYSTEM: true,
        DOCUMENT_VERIFICATION: true,
        RATING_REMINDER: true,
      },
      quietHours: {
        enabled: false,
        start: '22:00',
        end: '07:00',
      },
      language: user.preferredLanguage || 'en',
    };
  }

  /// Update notification preferences
  async updatePreferences(userId: string, dto: any) {
    // Store preferences in user metadata or a dedicated preferences table
    // For now, we return the updated preferences
    // TODO: Persist preferences in database

    return {
      userId,
      ...dto,
      updatedAt: new Date().toISOString(),
    };
  }

  // ==================== Notification Dispatch Stubs ====================

  /// Send notification via FCM (Firebase Cloud Messaging)
  /// Stub - integrate with firebase-admin SDK in production
  async sendPushNotification(userId: string, title: string, body: string, data?: any) {
    // Get user's active device tokens
    const tokens = await this.prisma.deviceToken.findMany({
      where: { userId, isActive: true },
    });

    if (tokens.length === 0) {
      console.log(`📱 No active device tokens for user ${userId}`);
      return { sent: false, reason: 'No active device tokens' };
    }

    // TODO: Send via Firebase Admin SDK
    // const messaging = getMessaging(app);
    // await messaging.sendMulticast({
    //   tokens: tokens.map(t => t.token),
    //   notification: { title, body },
    //   data: data ? Object.fromEntries(Object.entries(data).map(([k, v]) => [k, String(v)])) : undefined,
    // });

    console.log(`📱 Push notification sent to user ${userId}: "${title}" (${tokens.length} devices)`);
    return { sent: true, deviceCount: tokens.length };
  }

  /// Send notification via SMS
  /// Stub - integrate with Twilio or similar SMS provider
  async sendSms(userId: string, phone: string, message: string) {
    // TODO: Integrate with Twilio SMS API
    // const twilioClient = twilio(accountSid, authToken);
    // await twilioClient.messages.create({ body: message, from: twilioNumber, to: phone });

    console.log(`📩 SMS sent to ${phone}: "${message}"`);
    return { sent: true, channel: 'SMS' };
  }

  /// Send notification via WhatsApp
  /// Stub - integrate with Twilio WhatsApp API or WhatsApp Business API
  async sendWhatsApp(userId: string, phone: string, message: string, template?: string) {
    // TODO: Integrate with Twilio WhatsApp API
    // const twilioClient = twilio(accountSid, authToken);
    // await twilioClient.messages.create({
    //   body: message,
    //   from: 'whatsapp:+1234567890',
    //   to: `whatsapp:${phone}`,
    // });

    console.log(`💬 WhatsApp sent to ${phone}: "${message}"`);
    return { sent: true, channel: 'WHATSAPP' };
  }

  /// Send notification via Email
  /// Stub - integrate with SendGrid, AWS SES, or similar email provider
  async sendEmail(userId: string, email: string, subject: string, htmlBody: string) {
    // TODO: Integrate with SendGrid or AWS SES
    // await sgMail.send({ to: email, from: 'noreply@trippo.com', subject, html: htmlBody });

    console.log(`📧 Email sent to ${email}: "${subject}"`);
    return { sent: true, channel: 'EMAIL' };
  }

  // ==================== High-Level Notification Methods ====================

  /// Create an in-app notification and dispatch via preferred channels
  async notify(
    userId: string,
    type: NotificationType,
    title: string,
    body: string,
    data?: any,
    channels: NotificationChannel[] = [NotificationChannel.IN_APP, NotificationChannel.PUSH],
  ) {
    // Create in-app notification record
    const notification = await this.prisma.notification.create({
      data: {
        userId,
        title,
        body,
        type,
        channel: NotificationChannel.IN_APP,
        status: NotificationStatus.UNREAD,
        data: data || undefined,
      },
    });

    // Dispatch to other channels
    const user = await this.prisma.user.findUnique({ where: { id: userId } });
    if (!user) return notification;

    // Get user preferences
    const preferences = await this.getPreferences(userId);

    // Push notification
    if (channels.includes(NotificationChannel.PUSH) && preferences.channels.push) {
      await this.sendPushNotification(userId, title, body, data);
    }

    // SMS
    if (channels.includes(NotificationChannel.SMS) && preferences.channels.sms && user.phone) {
      await this.sendSms(userId, user.phone, body);
    }

    // WhatsApp
    if (channels.includes(NotificationChannel.WHATSAPP) && preferences.channels.whatsapp && user.phone) {
      await this.sendWhatsApp(userId, user.phone, body);
    }

    // Email
    if (channels.includes(NotificationChannel.EMAIL) && preferences.channels.email) {
      await this.sendEmail(userId, user.email, title, body);
    }

    return notification;
  }

  /// Mark notification as read
  async markAsRead(userId: string, notificationId: string) {
    const notification = await this.prisma.notification.findFirst({
      where: { id: notificationId, userId },
    });

    if (!notification) throw new NotFoundException('Notification not found');

    return this.prisma.notification.update({
      where: { id: notificationId },
      data: {
        status: NotificationStatus.READ,
        readAt: new Date(),
      },
    });
  }

  /// Mark all notifications as read
  async markAllAsRead(userId: string) {
    await this.prisma.notification.updateMany({
      where: { userId, status: NotificationStatus.UNREAD },
      data: {
        status: NotificationStatus.READ,
        readAt: new Date(),
      },
    });

    return { success: true };
  }
}
