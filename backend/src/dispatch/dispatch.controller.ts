import { Controller, Get, Post, Query, UseGuards, Req, Body } from '@nestjs/common';
import { ApiTags, ApiBearerAuth } from '@nestjs/swagger';
import { AuthGuard } from '@nestjs/passport';
import { DispatchService } from './dispatch.service';

@ApiTags('dispatch')
@ApiBearerAuth()
@UseGuards(AuthGuard('jwt'))
@Controller('dispatch')
export class DispatchController {
  constructor(private readonly dispatchService: DispatchService) {}

  @Get('nearby-drivers')
  async getNearbyDrivers(
    @Query('latitude') lat: string,
    @Query('longitude') lng: string,
    @Query('radiusKm') radiusKm: string = '50',
    @Query('vehicleType') vehicleType?: string,
  ) {
    return this.dispatchService.findNearbyDrivers(
      parseFloat(lat),
      parseFloat(lng),
      parseFloat(radiusKm),
      vehicleType,
    );
  }

  @Post('request')
  async requestRide(@Req() req: any, @Body() dto: any) {
    return this.dispatchService.startDriverSearch(dto.tripId);
  }
}
