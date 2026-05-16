import { Controller, Get, Post, Put, Body, UseGuards, Req } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth, ApiResponse } from '@nestjs/swagger';
import { AuthGuard } from '@nestjs/passport';
import { DriverService } from './driver.service';

@ApiTags('drivers')
@ApiBearerAuth()
@UseGuards(AuthGuard('jwt'))
@Controller('drivers')
export class DriverController {
  constructor(private readonly driverService: DriverService) {}

  @Post('profile')
  @ApiOperation({ summary: 'Create or update driver profile' })
  @ApiResponse({ status: 200, description: 'Driver profile created/updated successfully' })
  @ApiResponse({ status: 403, description: 'Forbidden - user does not have DRIVER role' })
  async upsertProfile(@Req() req: any, @Body() dto: UpsertDriverProfileDto) {
    return this.driverService.upsertProfile(req.user.id, dto);
  }

  @Get('profile')
  @ApiOperation({ summary: 'Get driver profile with vehicle and stats' })
  @ApiResponse({ status: 200, description: 'Driver profile retrieved' })
  @ApiResponse({ status: 404, description: 'Driver profile not found' })
  async getProfile(@Req() req: any) {
    return this.driverService.getProfile(req.user.id);
  }

  @Post('online')
  @ApiOperation({ summary: 'Set driver online with current location' })
  @ApiResponse({ status: 200, description: 'Driver is now online' })
  @ApiResponse({ status: 403, description: 'Forbidden - documents not verified or vehicle not approved' })
  async setOnline(@Req() req: any, @Body() dto: SetOnlineDto) {
    return this.driverService.setOnline(req.user.id, dto.latitude, dto.longitude);
  }

  @Post('offline')
  @ApiOperation({ summary: 'Set driver offline' })
  @ApiResponse({ status: 200, description: 'Driver is now offline' })
  @ApiResponse({ status: 400, description: 'Cannot go offline while on active trip' })
  async setOffline(@Req() req: any) {
    return this.driverService.setOffline(req.user.id);
  }

  @Post('location')
  @ApiOperation({ summary: 'Update driver location (high-frequency tracking)' })
  @ApiResponse({ status: 200, description: 'Location updated' })
  @ApiResponse({ status: 400, description: 'Cannot update location while offline' })
  async updateLocation(@Req() req: any, @Body() dto: UpdateLocationDto) {
    return this.driverService.updateLocation(
      req.user.id,
      dto.latitude,
      dto.longitude,
      dto.heading,
      dto.speed,
    );
  }
}

// ==================== DTOs ====================

class UpsertDriverProfileDto {
  isAvailable?: boolean;
  vehicle?: {
    name: string;
    plateNumber: string;
    type: string;
    color?: string;
    model?: string;
    year?: string;
    seats?: number;
  };
}

class SetOnlineDto {
  latitude: number;
  longitude: number;
}

class UpdateLocationDto {
  latitude: number;
  longitude: number;
  heading?: number;
  speed?: number;
}
