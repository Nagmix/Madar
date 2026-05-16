import {
  Controller,
  Get,
  Query,
  UseGuards,
  Res,
  HttpStatus,
} from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth, ApiQuery, ApiResponse } from '@nestjs/swagger';
import { AuthGuard } from '@nestjs/passport';
import { Response } from 'express';
import { AnalyticsService } from './analytics.service';
import { RolesGuard } from '../auth/guards/roles.guard';
import { SetMetadata } from '@nestjs/common';
import { VehicleType } from '@prisma/client';

/// Custom @Roles decorator for role-based access control
/// Sets metadata that RolesGuard reads to enforce admin-only access
export const Roles = (...roles: string[]) => SetMetadata('roles', roles);

@ApiTags('analytics')
@ApiBearerAuth()
@UseGuards(AuthGuard('jwt'), RolesGuard)
@Roles('admin')
@Controller('analytics')
export class AnalyticsController {
  constructor(private readonly analyticsService: AnalyticsService) {}

  // ==================== Dashboard ====================

  @Get('dashboard')
  @ApiOperation({ summary: 'Get main dashboard stats (admin only)' })
  @ApiResponse({ status: 200, description: 'Dashboard metrics retrieved successfully' })
  @ApiResponse({ status: 403, description: 'Insufficient permissions' })
  async getDashboardStats() {
    return this.analyticsService.getDashboardStats();
  }

  // ==================== Trip Analytics ====================

  @Get('trips')
  @ApiOperation({ summary: 'Get trip analytics with filters' })
  @ApiQuery({ name: 'period', required: false, description: 'Time period: today, week, month, quarter, year, or date range (2024-01-01,2024-01-31)', example: 'week' })
  @ApiQuery({ name: 'vehicleType', required: false, enum: ['MOTORCYCLE', 'SEDAN', 'SUV', 'VAN', 'LUXURY'], description: 'Filter by vehicle type' })
  @ApiQuery({ name: 'zoneId', required: false, description: 'Filter by geo fence zone ID' })
  @ApiResponse({ status: 200, description: 'Trip analytics retrieved successfully' })
  async getTripAnalytics(
    @Query('period') period: string = 'today',
    @Query('vehicleType') vehicleType?: VehicleType,
    @Query('zoneId') zoneId?: string,
  ) {
    return this.analyticsService.getTripAnalytics(period, { vehicleType, zoneId });
  }

  // ==================== Revenue Analytics ====================

  @Get('revenue')
  @ApiOperation({ summary: 'Get revenue analytics' })
  @ApiQuery({ name: 'period', required: false, description: 'Time period: today, week, month, quarter, year, or date range', example: 'month' })
  @ApiQuery({ name: 'vehicleType', required: false, enum: ['MOTORCYCLE', 'SEDAN', 'SUV', 'VAN', 'LUXURY'], description: 'Filter by vehicle type' })
  @ApiQuery({ name: 'zoneId', required: false, description: 'Filter by geo fence zone ID' })
  @ApiQuery({ name: 'export', required: false, description: 'Set to "csv" to export as CSV' })
  @ApiResponse({ status: 200, description: 'Revenue analytics retrieved successfully' })
  async getRevenueAnalytics(
    @Query('period') period: string = 'month',
    @Query('vehicleType') vehicleType?: VehicleType,
    @Query('zoneId') zoneId?: string,
    @Query('export') exportFormat?: string,
    @Res() res?: Response,
  ) {
    if (exportFormat === 'csv') {
      const csv = await this.analyticsService.exportRevenueCsv(period, { vehicleType, zoneId });
      res!.setHeader('Content-Type', 'text/csv');
      res!.setHeader('Content-Disposition', `attachment; filename=revenue-${period}-${new Date().toISOString().split('T')[0]}.csv`);
      return res!.status(HttpStatus.OK).send(csv);
    }

    return this.analyticsService.getRevenueAnalytics(period, { vehicleType, zoneId });
  }

  // ==================== Driver Analytics ====================

  @Get('drivers')
  @ApiOperation({ summary: 'Get driver analytics' })
  @ApiQuery({ name: 'period', required: false, description: 'Time period: today, week, month, quarter, year', example: 'month' })
  @ApiResponse({ status: 200, description: 'Driver analytics retrieved successfully' })
  async getDriverAnalytics(
    @Query('period') period: string = 'month',
  ) {
    return this.analyticsService.getDriverAnalytics(period);
  }

  // ==================== User Analytics ====================

  @Get('users')
  @ApiOperation({ summary: 'Get user analytics' })
  @ApiQuery({ name: 'period', required: false, description: 'Time period: today, week, month, quarter, year', example: 'month' })
  @ApiResponse({ status: 200, description: 'User analytics retrieved successfully' })
  async getUserAnalytics(
    @Query('period') period: string = 'month',
  ) {
    return this.analyticsService.getUserAnalytics(period);
  }

  // ==================== Surge Analytics ====================

  @Get('surge')
  @ApiOperation({ summary: 'Get surge pricing analytics' })
  @ApiQuery({ name: 'period', required: false, description: 'Time period: today, week, month', example: 'week' })
  @ApiQuery({ name: 'zoneId', required: false, description: 'Filter by specific surge zone ID' })
  @ApiResponse({ status: 200, description: 'Surge analytics retrieved successfully' })
  async getSurgeAnalytics(
    @Query('period') period: string = 'week',
    @Query('zoneId') zoneId?: string,
  ) {
    return this.analyticsService.getSurgeAnalytics(period, zoneId);
  }

  // ==================== Realtime Metrics ====================

  @Get('realtime')
  @ApiOperation({ summary: 'Get realtime platform metrics' })
  @ApiResponse({ status: 200, description: 'Realtime metrics retrieved successfully' })
  async getRealtimeMetrics() {
    return this.analyticsService.getRealtimeMetrics();
  }

  // ==================== CSV Export ====================

  @Get('export/trips')
  @ApiOperation({ summary: 'Export trip data as CSV' })
  @ApiQuery({ name: 'period', required: false, description: 'Time period', example: 'month' })
  @ApiQuery({ name: 'vehicleType', required: false, enum: ['MOTORCYCLE', 'SEDAN', 'SUV', 'VAN', 'LUXURY'] })
  @ApiQuery({ name: 'zoneId', required: false, description: 'Filter by zone ID' })
  @ApiResponse({ status: 200, description: 'CSV file download' })
  async exportTripsCsv(
    @Query('period') period: string = 'month',
    @Query('vehicleType') vehicleType?: VehicleType,
    @Query('zoneId') zoneId?: string,
    @Res() res?: Response,
  ) {
    const csv = await this.analyticsService.exportTripsCsv(period, { vehicleType, zoneId });
    res.setHeader('Content-Type', 'text/csv');
    res.setHeader('Content-Disposition', `attachment; filename=trips-${period}-${new Date().toISOString().split('T')[0]}.csv`);
    return res.status(HttpStatus.OK).send(csv);
  }
}
