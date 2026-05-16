import { Controller, Get, Post, Put, Body, Query, UseGuards, Req } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth, ApiResponse } from '@nestjs/swagger';
import { AuthGuard } from '@nestjs/passport';
import { NotificationService } from './notification.service';
import { NotificationType } from '@prisma/client';

// ==================== DTOs ====================

class RegisterDeviceTokenDto {
  token: string;
  platform: string; // 'ios' | 'android' | 'web'
  deviceId: string;
}

class UpdateNotificationPreferencesDto {
  channels?: {
    push?: boolean;
    sms?: boolean;
    whatsapp?: boolean;
    email?: boolean;
    inApp?: boolean;
  };
  types?: {
    TRIP_UPDATE?: boolean;
    DRIVER_ASSIGNED?: boolean;
    DRIVER_ARRIVING?: boolean;
    DRIVER_ARRIVED?: boolean;
    TRIP_STARTED?: boolean;
    TRIP_COMPLETED?: boolean;
    TRIP_CANCELLED?: boolean;
    PAYMENT_RECEIVED?: boolean;
    WALLET_UPDATE?: boolean;
    WITHDRAWAL_STATUS?: boolean;
    PROMOTION?: boolean;
    SYSTEM?: boolean;
    DOCUMENT_VERIFICATION?: boolean;
    RATING_REMINDER?: boolean;
  };
  quietHours?: {
    enabled?: boolean;
    start?: string;
    end?: string;
  };
}

class MarkReadDto {
  notificationId: string;
}

@ApiTags('notifications')
@ApiBearerAuth()
@UseGuards(AuthGuard('jwt'))
@Controller('notifications')
export class NotificationController {
  constructor(private readonly notificationService: NotificationService) {}

  @Get()
  @ApiOperation({ summary: 'Get user notifications' })
  @ApiResponse({ status: 200, description: 'Notifications retrieved' })
  async getNotifications(
    @Req() req: any,
    @Query('page') page: string = '1',
    @Query('pageSize') pageSize: string = '20',
    @Query('type') type?: NotificationType,
  ) {
    return this.notificationService.getNotifications(req.user.id, parseInt(page), parseInt(pageSize), type);
  }

  @Post('device-token')
  @ApiOperation({ summary: 'Register FCM device token' })
  @ApiResponse({ status: 201, description: 'Device token registered successfully' })
  async registerDeviceToken(@Req() req: any, @Body() dto: RegisterDeviceTokenDto) {
    return this.notificationService.registerDeviceToken(req.user.id, dto);
  }

  @Get('preferences')
  @ApiOperation({ summary: 'Get notification preferences' })
  @ApiResponse({ status: 200, description: 'Notification preferences retrieved' })
  async getPreferences(@Req() req: any) {
    return this.notificationService.getPreferences(req.user.id);
  }

  @Put('preferences')
  @ApiOperation({ summary: 'Update notification preferences' })
  @ApiResponse({ status: 200, description: 'Notification preferences updated' })
  async updatePreferences(@Req() req: any, @Body() dto: UpdateNotificationPreferencesDto) {
    return this.notificationService.updatePreferences(req.user.id, dto);
  }

  @Post(':id/read')
  @ApiOperation({ summary: 'Mark notification as read' })
  @ApiResponse({ status: 200, description: 'Notification marked as read' })
  async markAsRead(@Req() req: any, @Body() dto: MarkReadDto) {
    return this.notificationService.markAsRead(req.user.id, dto.notificationId);
  }

  @Post('read-all')
  @ApiOperation({ summary: 'Mark all notifications as read' })
  @ApiResponse({ status: 200, description: 'All notifications marked as read' })
  async markAllAsRead(@Req() req: any) {
    return this.notificationService.markAllAsRead(req.user.id);
  }
}
