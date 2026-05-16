import {
  Controller,
  Get,
  Post,
  Body,
  Query,
  UseGuards,
  Req,
  ForbiddenException,
} from '@nestjs/common';
import { ApiTags, ApiBearerAuth, ApiOperation, ApiQuery } from '@nestjs/swagger';
import { AuthGuard } from '@nestjs/passport';
import { PromoService } from './promo.service';

/// Promo Controller - Handles promo code validation, application, and admin management
///
/// Routes:
/// - POST /promo/validate  - Validate a promo code
/// - POST /promo/apply     - Apply promo code to a trip
/// - GET  /promo/available - Get available promos for user
/// - GET  /promo/admin     - Admin: list all promos
/// - POST /promo/admin     - Admin: create promo
@ApiTags('promo')
@Controller('promo')
export class PromoController {
  constructor(private readonly promoService: PromoService) {}

  // ==================== Validate Promo Code ====================

  /// Validate a promo code and return discount preview
  /// POST /promo/validate
  @Post('validate')
  @UseGuards(AuthGuard('jwt'))
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Validate a promo code' })
  async validatePromoCode(
    @Req() req: any,
    @Body() dto: {
      code: string;
      tripId?: string;
      fareAmount?: number;
      vehicleType?: string;
      zoneId?: string;
    },
  ) {
    return this.promoService.validatePromoCode(req.user.id, dto);
  }

  // ==================== Apply Promo Code ====================

  /// Apply a validated promo code to a trip
  /// POST /promo/apply
  @Post('apply')
  @UseGuards(AuthGuard('jwt'))
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Apply a promo code to a trip' })
  async applyPromoCode(
    @Req() req: any,
    @Body() dto: {
      code: string;
      tripId: string;
    },
  ) {
    return this.promoService.applyPromoCode(req.user.id, dto);
  }

  // ==================== Available Promos ====================

  /// Get available promo codes for the current user
  /// GET /promo/available
  @Get('available')
  @UseGuards(AuthGuard('jwt'))
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Get available promo codes for user' })
  async getAvailablePromos(@Req() req: any) {
    return this.promoService.getAvailablePromos(req.user.id);
  }

  // ==================== Admin: List Promos ====================

  /// Admin: Get all promo codes with pagination
  /// GET /promo/admin
  @Get('admin')
  @UseGuards(AuthGuard('jwt'))
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Admin: List all promo codes' })
  @ApiQuery({ name: 'page', required: false, type: Number })
  @ApiQuery({ name: 'pageSize', required: false, type: Number })
  @ApiQuery({ name: 'isActive', required: false, type: Boolean })
  async adminListPromos(
    @Req() req: any,
    @Query('page') page?: string,
    @Query('pageSize') pageSize?: string,
    @Query('isActive') isActive?: string,
  ) {
    // Role check - only admins can access
    if (req.user.role !== 'ADMIN') {
      throw new ForbiddenException('Insufficient permissions');
    }

    return this.promoService.adminListPromos(
      page ? parseInt(page) : 1,
      pageSize ? parseInt(pageSize) : 20,
      isActive !== undefined ? isActive === 'true' : undefined,
    );
  }

  // ==================== Admin: Create Promo ====================

  /// Admin: Create a new promo code
  /// POST /promo/admin
  @Post('admin')
  @UseGuards(AuthGuard('jwt'))
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Admin: Create a new promo code' })
  async adminCreatePromo(
    @Req() req: any,
    @Body() dto: {
      code: string;
      description: string;
      discountType: string;
      discountValue: number;
      maxDiscount?: number;
      minFare?: number;
      usageLimit?: number;
      perUserLimit?: number;
      validFrom: string;
      validTo: string;
      firstRideOnly?: boolean;
      applicableVehicleTypes?: string[];
      applicableZones?: string[];
    },
  ) {
    // Role check - only admins can access
    if (req.user.role !== 'ADMIN') {
      throw new ForbiddenException('Insufficient permissions');
    }

    return this.promoService.adminCreatePromo(dto);
  }
}
