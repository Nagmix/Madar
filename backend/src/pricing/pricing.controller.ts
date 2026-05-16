import { Controller, Get, Post, Query, UseGuards } from '@nestjs/common';
import { ApiTags, ApiBearerAuth } from '@nestjs/swagger';
import { AuthGuard } from '@nestjs/passport';
import { PricingService } from './pricing.service';

@ApiTags('pricing')
@Controller('pricing')
export class PricingController {
  constructor(private readonly pricingService: PricingService) {}

  @Get('config')
  @UseGuards(AuthGuard('jwt'))
  @ApiBearerAuth()
  async getPricingConfig(
    @Query('vehicleType') vehicleType: string,
    @Query('zoneId') zoneId?: string,
  ) {
    // Return pricing configuration
    return { vehicleType, zoneId, message: 'Pricing config endpoint' };
  }

  @Post('calculate')
  @UseGuards(AuthGuard('jwt'))
  @ApiBearerAuth()
  async calculateFare(@Body() dto: any) {
    return this.pricingService.calculateFare({
      pickupLat: dto.pickupLatitude,
      pickupLng: dto.pickupLongitude,
      dropoffLat: dto.dropoffLatitude,
      dropoffLng: dto.dropoffLongitude,
      vehicleType: dto.vehicleType,
      distanceKm: dto.distanceKm || 0,
      durationMinutes: dto.durationMinutes || 0,
      waitingMinutes: dto.waitingMinutes,
      promoCode: dto.promoCode,
    });
  }

  @Get('surge')
  @UseGuards(AuthGuard('jwt'))
  @ApiBearerAuth()
  async getSurgeStatus(@Query('zoneId') zoneId?: string) {
    return { isActive: false, currentMultiplier: 1.0, reason: 'Normal pricing', zoneId };
  }
}
