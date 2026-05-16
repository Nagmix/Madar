import { Controller, Get, Query, UseGuards } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth, ApiResponse } from '@nestjs/swagger';
import { AuthGuard } from '@nestjs/passport';
import { GeoService } from './geo.service';

@ApiTags('geo')
@ApiBearerAuth()
@UseGuards(AuthGuard('jwt'))
@Controller('geo')
export class GeoController {
  constructor(private readonly geoService: GeoService) {}

  @Get('reverse-geocode')
  @ApiOperation({ summary: 'Reverse geocode coordinates to address' })
  @ApiResponse({ status: 200, description: 'Address retrieved for coordinates' })
  async reverseGeocode(
    @Query('latitude') latitude: string,
    @Query('longitude') longitude: string,
  ) {
    return this.geoService.reverseGeocode(parseFloat(latitude), parseFloat(longitude));
  }

  @Get('places')
  @ApiOperation({ summary: 'Search places (proxy to Google Places API)' })
  @ApiResponse({ status: 200, description: 'Place predictions retrieved' })
  async searchPlaces(
    @Query('query') query: string,
    @Query('latitude') latitude?: string,
    @Query('longitude') longitude?: string,
    @Query('radius') radius?: string,
  ) {
    return this.geoService.searchPlaces(
      query,
      latitude ? parseFloat(latitude) : undefined,
      longitude ? parseFloat(longitude) : undefined,
      radius ? parseFloat(radius) : undefined,
    );
  }

  @Get('service-areas')
  @ApiOperation({ summary: 'Get all service areas' })
  @ApiResponse({ status: 200, description: 'Service areas retrieved' })
  async getServiceAreas() {
    return this.geoService.getServiceAreas();
  }

  @Get('zones')
  @ApiOperation({ summary: 'Get pricing zones' })
  @ApiResponse({ status: 200, description: 'Pricing zones retrieved' })
  async getZones() {
    return this.geoService.getZones();
  }
}
