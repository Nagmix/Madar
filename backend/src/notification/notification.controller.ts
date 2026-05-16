import { Controller, Get, Post, Put, Body, Query, UseGuards, Req } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth, ApiResponse } from '@nestjs/swagger';
import { AuthGuard } from '@nestjs/passport';
import { IsString, IsBoolean, IsOptional, ValidateNested, IsIn } from 'class-validator';
import { Type } from 'class-transformer';
import { NotificationService } from './notification.service';
import { NotificationType } from '@prisma/client';

// ==================== DTOs ====================

class RegisterDeviceTokenDto {
  @IsString()
  token: string;

  @IsIn(['ios', 'android', 'web'])
  platform: string;

  @IsString()
  deviceId: string;
}

class NotificationChannelsDto {
  @IsOptional()
  @IsBoolean()
  push?: boolean;

  @IsOptional()
  @IsBoolean()
  sms?: boolean;

  @IsOptional()
  @IsBoolean()
  whatsapp?: boolean;

  @IsOptional()
  @IsBoolean()
  email?: boolean;

  @IsOptional()
  @IsBoolean()
  inApp?: boolean;
}

class NotificationTypesDto {
  @IsOptional()
  @IsBoolean()
  TRIP_UPDATE?: boolean;

  @IsOptional()
  @IsBoolean()
  DRIVER_ASSIGNED?: boolean;

  @IsOptional()
  @IsBoolean()
  DRIVER_ARRIVING?: boolean;

  @IsOptional()
  @IsBoolean()
  DRIVER_ARRIVED?: boolean;

  @IsOptional()
  @IsBoolean()
  TRIP_STARTED?: boolean;

  @IsOptional()
  @IsBoolean()
  TRIP_COMPLETED?: boolean;

  @IsOptional()
  @IsBoolean()
  TRIP_CANCELLED?: boolean;

  @IsOptional()
  @IsBoolean()
  PAYMENT_RECEIVED?: boolean;

  @IsOptional()
  @IsBoolean()
  WALLET_UPDATE?: boolean;

  @IsOptional()
  @IsBoolean()
  WITHDRAWAL_STATUS?: boolean;

  @IsOptional()
  @IsBoolean()
  PROMOTION?: boolean;

  @IsOptional()
  @IsBoolean()
  SYSTEM?: boolean;

  @IsOptional()
  @IsBoolean()
  DOCUMENT_VERIFICATION?: boolean;

  @IsOptional()
  @IsBoolean()
  RATING_REMINDER?: boolean;
}

class QuietHoursDto {
  @IsOptional()
  @IsBoolean()
  enabled?: boolean;

  @IsOptional()
  @IsString()
  start?: string;

  @IsOptional()
  @IsString()
  end?: string;
}

class UpdateNotificationPreferencesDto {
  @IsOptional()
  @ValidateNested()
  @Type(() => NotificationChannelsDto)
  channels?: NotificationChannelsDto;

  @IsOptional()
  @ValidateNested()
  @Type(() => NotificationTypesDto)
  types?: NotificationTypesDto;

  @IsOptional()
  @ValidateNested()
  @Type(() => QuietHoursDto)
  quietHours?: QuietHoursDto;
}

class MarkReadDto {
  @IsString()
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
