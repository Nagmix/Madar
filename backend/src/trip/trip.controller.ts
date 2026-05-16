import {
  Controller, Get, Post, Body, Param, Query, UseGuards, Req, ParseUUIDPipe, HttpStatus,
} from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { AuthGuard } from '@nestjs/passport';
import { TripService } from './trip.service';
import { TripState } from '@prisma/client';

@ApiTags('trips')
@ApiBearerAuth()
@UseGuards(AuthGuard('jwt'))
@Controller('trips')
export class TripController {
  constructor(private readonly tripService: TripService) {}

  @Post()
  @ApiOperation({ summary: 'Create a new trip request' })
  async createTrip(@Req() req: any, @Body() dto: CreateTripDto) {
    return this.tripService.createTrip(req.user.id, dto);
  }

  @Get('history')
  @ApiOperation({ summary: 'Get trip history' })
  async getTripHistory(
    @Req() req: any,
    @Query('page') page: string = '1',
    @Query('pageSize') pageSize: string = '20',
    @Query('state') state?: TripState,
  ) {
    return this.tripService.getTripHistory(req.user.id, parseInt(page), parseInt(pageSize), state);
  }

  @Get(':id')
  @ApiOperation({ summary: 'Get trip details' })
  async getTripDetails(@Req() req: any, @Param('id', ParseUUIDPipe) tripId: string) {
    return this.tripService.getTripDetails(req.user.id, tripId);
  }

  @Post(':id/cancel')
  @ApiOperation({ summary: 'Cancel a trip' })
  async cancelTrip(@Req() req: any, @Param('id', ParseUUIDPipe) tripId: string, @Body() dto: CancelTripDto) {
    return this.tripService.cancelTrip(req.user.id, tripId, dto.reason);
  }

  @Post(':id/accept')
  @ApiOperation({ summary: 'Driver accepts trip' })
  async acceptTrip(@Req() req: any, @Param('id', ParseUUIDPipe) tripId: string) {
    return this.tripService.acceptTrip(req.user.id, tripId);
  }

  @Post(':id/arrived')
  @ApiOperation({ summary: 'Driver arrived at pickup' })
  async driverArrived(@Req() req: any, @Param('id', ParseUUIDPipe) tripId: string) {
    return this.tripService.driverArrived(req.user.id, tripId);
  }

  @Post(':id/start')
  @ApiOperation({ summary: 'Start trip' })
  async startTrip(@Req() req: any, @Param('id', ParseUUIDPipe) tripId: string) {
    return this.tripService.startTrip(req.user.id, tripId);
  }

  @Post(':id/complete')
  @ApiOperation({ summary: 'Complete trip' })
  async completeTrip(@Req() req: any, @Param('id', ParseUUIDPipe) tripId: string) {
    return this.tripService.completeTrip(req.user.id, tripId);
  }

  @Post(':id/rate')
  @ApiOperation({ summary: 'Rate a trip' })
  async rateTrip(
    @Req() req: any,
    @Param('id', ParseUUIDPipe) tripId: string,
    @Body() dto: RateTripDto,
  ) {
    return this.tripService.rateTrip(req.user.id, tripId, dto.rating, dto.review, dto.tags);
  }

  @Post('estimate-fare')
  @ApiOperation({ summary: 'Estimate trip fare' })
  async estimateFare(@Body() dto: EstimateFareDto) {
    return this.tripService.estimateFare(dto);
  }
}

// DTOs
class CreateTripDto {
  pickupLatitude: number;
  pickupLongitude: number;
  pickupAddress: string;
  dropoffLatitude: number;
  dropoffLongitude: number;
  dropoffAddress: string;
  vehicleType: string;
  promoCode?: string;
  note?: string;
}

class CancelTripDto {
  reason: string;
}

class RateTripDto {
  rating: number;
  review?: string;
  tags?: string[];
}

class EstimateFareDto {
  pickupLatitude: number;
  pickupLongitude: number;
  dropoffLatitude: number;
  dropoffLongitude: number;
  vehicleType: string;
  promoCode?: string;
}
