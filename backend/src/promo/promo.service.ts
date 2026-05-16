import {
  Injectable,
  NotFoundException,
  BadRequestException,
  ForbiddenException,
  Inject,
} from '@nestjs/common';
import { PrismaService } from '../prisma.service';
import { REDIS_CLIENT } from '../redis.module';
import { PricingService } from '../pricing/pricing.service';

/// Promo Service - Validates, applies, and manages promotional discount codes
/// Integrates with PricingService for fare calculation and Redis for caching
///
/// Validation checks (in order):
/// 1. Code exists and is active
/// 2. Within valid date range (validFrom <= now <= validUntil)
/// 3. Global usage limit not exceeded
/// 4. Per-user usage limit not exceeded
/// 5. Minimum fare requirement met
/// 6. Vehicle type is applicable (if restricted)
/// 7. Zone is applicable (if restricted)
/// 8. First-ride-only constraint (if set)
@Injectable()
export class PromoService {
  private readonly CACHE_TTL = 300; // 5 minutes in seconds

  constructor(
    private prisma: PrismaService,
    @Inject(REDIS_CLIENT) private redis: any,
    private pricingService: PricingService,
  ) {}

  // ==================== Validate Promo Code ====================

  /// Validate a promo code and return discount preview
  /// POST /promo/validate
  async validatePromoCode(
    userId: string,
    dto: {
      code: string;
      tripId?: string;
      fareAmount?: number;
      vehicleType?: string;
      zoneId?: string;
    },
  ) {
    const normalizedCode = dto.code.trim().toUpperCase();

    // Check Redis cache first
    const cacheKey = `promo:validate:${normalizedCode}:${userId}`;
    const cached = await this.redis.get(cacheKey);
    if (cached) {
      const parsed = JSON.parse(cached);
      // Re-check fare-specific conditions if fareAmount is provided
      if (dto.fareAmount !== undefined && parsed.promoCode) {
        parsed.discountAmount = this._calculateDiscount(
          parsed.promoCode.type,
          parsed.promoCode.value,
          dto.fareAmount,
          parsed.promoCode.maxDiscount,
        );
        if (dto.fareAmount < parsed.promoCode.minFare) {
          return {
            isValid: false,
            discountAmount: 0,
            message: `Minimum fare of ${parsed.promoCode.minFare} required for this promo code`,
            errorCode: 'MIN_FARE_NOT_MET',
          };
        }
      }
      return parsed;
    }

    // 1. Find the promo code
    const promo = await this.prisma.promoCode.findUnique({
      where: { code: normalizedCode },
    });

    if (!promo) {
      const result = {
        isValid: false,
        promoCode: null,
        discountAmount: 0,
        message: 'Promo code not found',
        errorCode: 'NOT_FOUND',
      };
      await this._cacheResult(cacheKey, result, 60); // Cache negative result for 1 min
      return result;
    }

    // 2. Check if active
    if (!promo.isActive) {
      return {
        isValid: false,
        promoCode: null,
        discountAmount: 0,
        message: 'This promo code is no longer active',
        errorCode: 'INACTIVE',
      };
    }

    // 3. Check date validity
    const now = new Date();
    if (promo.validFrom > now) {
      return {
        isValid: false,
        promoCode: null,
        discountAmount: 0,
        message: 'This promo code is not yet active',
        errorCode: 'NOT_YET_ACTIVE',
      };
    }
    if (promo.validTo < now) {
      return {
        isValid: false,
        promoCode: null,
        discountAmount: 0,
        message: 'This promo code has expired',
        errorCode: 'EXPIRED',
      };
    }

    // 4. Check global usage limit
    if (promo.usageLimit && promo.usedCount >= promo.usageLimit) {
      return {
        isValid: false,
        promoCode: null,
        discountAmount: 0,
        message: 'This promo code has reached its usage limit',
        errorCode: 'USAGE_LIMIT_EXCEEDED',
      };
    }

    // 5. Check per-user usage limit
    const userUsageCount = await this._getUserPromoUsageCount(userId, promo.id);
    if (userUsageCount >= promo.perUserLimit) {
      return {
        isValid: false,
        promoCode: null,
        discountAmount: 0,
        message: 'You have already used this promo code the maximum number of times',
        errorCode: 'USER_LIMIT_EXCEEDED',
      };
    }

    // 6. Check first-ride-only constraint
    if (promo.firstRideOnly) {
      const completedTrips = await this.prisma.trip.count({
        where: {
          riderId: userId,
          state: { in: ['TRIP_COMPLETED', 'PAYMENT_COMPLETED'] },
        },
      });
      if (completedTrips > 0) {
        return {
          isValid: false,
          promoCode: null,
          discountAmount: 0,
          message: 'This promo code is only valid for your first ride',
          errorCode: 'NOT_FIRST_RIDE',
        };
      }
    }

    // 7. Check minimum fare
    if (dto.fareAmount !== undefined && dto.fareAmount < promo.minFare) {
      return {
        isValid: false,
        promoCode: null,
        discountAmount: 0,
        message: `Minimum fare of ${promo.minFare} required`,
        errorCode: 'MIN_FARE_NOT_MET',
      };
    }

    // 8. Check vehicle type applicability
    const promoMeta = await this._getPromoMetadata(promo.id);
    if (
      dto.vehicleType &&
      promoMeta?.applicableVehicleTypes?.length > 0 &&
      !promoMeta.applicableVehicleTypes.includes(dto.vehicleType)
    ) {
      return {
        isValid: false,
        promoCode: null,
        discountAmount: 0,
        message: 'This promo code is not applicable for the selected vehicle type',
        errorCode: 'VEHICLE_TYPE_NOT_APPLICABLE',
      };
    }

    // 9. Check zone applicability
    if (
      dto.zoneId &&
      promoMeta?.applicableZones?.length > 0 &&
      !promoMeta.applicableZones.includes(dto.zoneId)
    ) {
      return {
        isValid: false,
        promoCode: null,
        discountAmount: 0,
        message: 'This promo code is not applicable in your area',
        errorCode: 'ZONE_NOT_APPLICABLE',
      };
    }

    // Calculate discount preview
    const discountAmount = dto.fareAmount
      ? this._calculateDiscount(
          promo.discountType,
          promo.discountValue,
          dto.fareAmount,
          promo.maxDiscount,
        )
      : 0;

    const result = {
      isValid: true,
      promoCode: this._formatPromoCode(promo, promoMeta),
      discountAmount: Math.round(discountAmount * 100) / 100,
      message: this._getSuccessMessage(promo, discountAmount),
      errorCode: null,
    };

    // Cache valid result for 5 minutes
    await this._cacheResult(cacheKey, result, this.CACHE_TTL);

    return result;
  }

  // ==================== Apply Promo Code ====================

  /// Apply a promo code to a trip
  /// POST /promo/apply
  async applyPromoCode(
    userId: string,
    dto: {
      code: string;
      tripId: string;
    },
  ) {
    const normalizedCode = dto.code.trim().toUpperCase();

    // 1. Find the trip
    const trip = await this.prisma.trip.findUnique({
      where: { id: dto.tripId },
    });

    if (!trip) {
      throw new NotFoundException('Trip not found');
    }

    // 2. Ensure user owns the trip
    if (trip.riderId !== userId) {
      throw new ForbiddenException('You can only apply promo codes to your own trips');
    }

    // 3. Ensure trip is in a valid state for promo application
    const validStates = [
      'SEARCHING_DRIVER',
      'DRIVER_ASSIGNED',
      'DRIVER_ARRIVING',
      'DRIVER_ARRIVED',
      'TRIP_STARTED',
    ];
    if (!validStates.includes(trip.state)) {
      throw new BadRequestException(
        'Cannot apply promo code to a trip that is already completed or cancelled',
      );
    }

    // 4. Check if promo already applied to this trip
    if (trip.promoCode) {
      throw new BadRequestException('A promo code has already been applied to this trip');
    }

    // 5. Re-validate the promo code (server-side final check)
    const validation = await this.validatePromoCode(userId, {
      code: normalizedCode,
      tripId: dto.tripId,
      fareAmount: trip.totalFare || 0,
      vehicleType: trip.vehicleType,
    });

    if (!validation.isValid) {
      throw new BadRequestException(validation.message || 'Promo code is no longer valid');
    }

    // 6. Calculate the actual discount based on trip fare
    const subtotal =
      trip.baseFare + trip.distanceFare + trip.timeFare +
      trip.surgeCharge + trip.nightCharge + trip.areaCharge +
      trip.waitingCharge;

    const discountAmount = this._calculateDiscount(
      validation.promoCode.type,
      validation.promoCode.value,
      subtotal,
      validation.promoCode.maxDiscount,
    );

    const clampedDiscount = Math.min(discountAmount, subtotal);

    // 7. Apply promo to trip in a transaction
    const result = await this.prisma.$transaction(async (tx) => {
      // Update trip with promo discount
      const updatedTrip = await tx.trip.update({
        where: { id: dto.tripId },
        data: {
          promoCode: normalizedCode,
          promoDiscount: clampedDiscount,
          totalFare: trip.totalFare - clampedDiscount,
        },
      });

      // Increment promo code usage count
      await tx.promoCode.update({
        where: { code: normalizedCode },
        data: { usedCount: { increment: 1 } },
      });

      // Create promo usage record for per-user tracking
      await tx.promoUsage.create({
        data: {
          promoCodeId: validation.promoCode.id,
          userId,
          tripId: dto.tripId,
          discountAmount: clampedDiscount,
        },
      });

      // Audit log
      await tx.auditLog.create({
        data: {
          action: 'PROMO_APPLIED',
          userId,
          entityType: 'TRIP',
          entityId: dto.tripId,
          metadata: {
            promoCode: normalizedCode,
            promoCodeId: validation.promoCode.id,
            discountAmount: clampedDiscount,
            previousTotalFare: trip.totalFare,
            newTotalFare: updatedTrip.totalFare,
            discountType: validation.promoCode.type,
            discountValue: validation.promoCode.value,
          },
        },
      });

      return updatedTrip;
    });

    // Invalidate caches
    await this._invalidatePromoCache(normalizedCode, userId);

    return {
      promoCodeId: validation.promoCode.id,
      tripId: dto.tripId,
      discountAmount: Math.round(clampedDiscount * 100) / 100,
      previousFare: trip.totalFare,
      newFare: result.totalFare,
      appliedAt: new Date().toISOString(),
    };
  }

  // ==================== Available Promos ====================

  /// Get available promo codes for the current user
  /// GET /promo/available
  async getAvailablePromos(userId: string) {
    const now = new Date();

    // Check cache
    const cacheKey = `promo:available:${userId}`;
    const cached = await this.redis.get(cacheKey);
    if (cached) {
      return JSON.parse(cached);
    }

    // Find active promos within valid date range
    const promos = await this.prisma.promoCode.findMany({
      where: {
        isActive: true,
        validFrom: { lte: now },
        validTo: { gte: now },
      },
      orderBy: { createdAt: 'desc' },
    });

    // Filter based on user eligibility
    const eligiblePromos = [];
    for (const promo of promos) {
      // Check global usage limit
      if (promo.usageLimit && promo.usedCount >= promo.usageLimit) {
        continue;
      }

      // Check per-user limit
      const userUsageCount = await this._getUserPromoUsageCount(userId, promo.id);
      if (userUsageCount >= promo.perUserLimit) {
        continue;
      }

      // Check first-ride-only constraint
      if (promo.firstRideOnly) {
        const completedTrips = await this.prisma.trip.count({
          where: {
            riderId: userId,
            state: { in: ['TRIP_COMPLETED', 'PAYMENT_COMPLETED'] },
          },
        });
        if (completedTrips > 0) continue;
      }

      const promoMeta = await this._getPromoMetadata(promo.id);
      eligiblePromos.push(this._formatPromoCode(promo, promoMeta));
    }

    // Cache for 2 minutes
    await this._cacheResult(cacheKey, { items: eligiblePromos }, 120);

    return { items: eligiblePromos };
  }

  // ==================== Admin: List All Promos ====================

  /// Admin: Get all promo codes with pagination
  /// GET /promo/admin
  async adminListPromos(page: number = 1, pageSize: number = 20, isActive?: boolean) {
    const where = {
      ...(isActive !== undefined ? { isActive } : {}),
    };

    const [items, total] = await Promise.all([
      this.prisma.promoCode.findMany({
        where,
        orderBy: { createdAt: 'desc' },
        skip: (page - 1) * pageSize,
        take: pageSize,
      }),
      this.prisma.promoCode.count({ where }),
    ]);

    // Enrich with metadata
    const enrichedItems = await Promise.all(
      items.map(async (promo) => {
        const meta = await this._getPromoMetadata(promo.id);
        return this._formatPromoCode(promo, meta);
      }),
    );

    return { items: enrichedItems, total, page, pageSize };
  }

  // ==================== Admin: Create Promo ====================

  /// Admin: Create a new promo code
  /// POST /promo/admin
  async adminCreatePromo(dto: {
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
  }) {
    const normalizedCode = dto.code.trim().toUpperCase();

    // Check if code already exists
    const existing = await this.prisma.promoCode.findUnique({
      where: { code: normalizedCode },
    });
    if (existing) {
      throw new BadRequestException('A promo code with this code already exists');
    }

    // Validate discount type
    if (!['percentage', 'fixed'].includes(dto.discountType)) {
      throw new BadRequestException('Discount type must be "percentage" or "fixed"');
    }

    // Validate percentage value
    if (dto.discountType === 'percentage' && (dto.discountValue <= 0 || dto.discountValue > 100)) {
      throw new BadRequestException('Percentage discount must be between 0 and 100');
    }

    // Validate fixed value
    if (dto.discountType === 'fixed' && dto.discountValue <= 0) {
      throw new BadRequestException('Fixed discount must be greater than 0');
    }

    // Validate dates
    const validFrom = new Date(dto.validFrom);
    const validTo = new Date(dto.validTo);
    if (validFrom >= validTo) {
      throw new BadRequestException('validFrom must be before validTo');
    }

    // Create the promo code
    const promo = await this.prisma.promoCode.create({
      data: {
        code: normalizedCode,
        description: dto.description,
        discountType: dto.discountType,
        discountValue: dto.discountValue,
        maxDiscount: dto.maxDiscount,
        minFare: dto.minFare || 0,
        usageLimit: dto.usageLimit,
        perUserLimit: dto.perUserLimit || 1,
        validFrom,
        validTo,
        firstRideOnly: dto.firstRideOnly || false,
      },
    });

    // Store vehicle types and zones as metadata if provided
    if (dto.applicableVehicleTypes?.length || dto.applicableZones?.length) {
      await this.prisma.promoMetadata.create({
        data: {
          promoCodeId: promo.id,
          applicableVehicleTypes: dto.applicableVehicleTypes || [],
          applicableZones: dto.applicableZones || [],
        },
      });
    }

    // Invalidate available promos cache
    await this._invalidateAvailablePromosCache();

    return this._formatPromoCode(promo, {
      applicableVehicleTypes: dto.applicableVehicleTypes || [],
      applicableZones: dto.applicableZones || [],
    });
  }

  // ==================== Private Helpers ====================

  /// Calculate discount amount based on type
  private _calculateDiscount(
    discountType: string,
    discountValue: number,
    fareAmount: number,
    maxDiscount?: number | null,
  ): number {
    let discount = 0;

    if (discountType === 'percentage') {
      discount = fareAmount * (discountValue / 100);
      if (maxDiscount) {
        discount = Math.min(discount, maxDiscount);
      }
    } else {
      // Fixed discount
      discount = discountValue;
    }

    // Cannot discount more than the fare
    return Math.min(discount, fareAmount);
  }

  /// Get user's usage count for a specific promo code
  private async _getUserPromoUsageCount(userId: string, promoCodeId: string): Promise<number> {
    const count = await this.prisma.promoUsage.count({
      where: {
        userId,
        promoCodeId,
      },
    });
    return count;
  }

  /// Get promo metadata (vehicle types, zones)
  private async _getPromoMetadata(promoCodeId: string): Promise<{
    applicableVehicleTypes: string[];
    applicableZones: string[];
  } | null> {
    const metadata = await this.prisma.promoMetadata.findUnique({
      where: { promoCodeId },
    });

    if (!metadata) return null;

    return {
      applicableVehicleTypes: (metadata.applicableVehicleTypes as string[]) || [],
      applicableZones: (metadata.applicableZones as string[]) || [],
    };
  }

  /// Format promo code for API response
  private _formatPromoCode(
    promo: any,
    meta?: { applicableVehicleTypes: string[]; applicableZones: string[] } | null,
  ) {
    return {
      id: promo.id,
      code: promo.code,
      description: promo.description,
      type: promo.discountType,
      value: promo.discountValue,
      minFare: promo.minFare,
      maxDiscount: promo.maxDiscount,
      usageLimit: promo.usageLimit,
      usedCount: promo.usedCount,
      validFrom: promo.validFrom,
      validUntil: promo.validTo,
      isActive: promo.isActive,
      applicableVehicleTypes: meta?.applicableVehicleTypes || [],
      applicableZones: meta?.applicableZones || [],
      firstRideOnly: promo.firstRideOnly || false,
      maxPerUser: promo.perUserLimit || 1,
    };
  }

  /// Generate success message for valid promo
  private _getSuccessMessage(promo: any, discountAmount: number): string {
    if (promo.discountType === 'percentage') {
      const maxMsg = promo.maxDiscount
        ? ` (up to ${promo.maxDiscount})`
        : '';
      return `${promo.discountValue}% off${maxMsg} - You save ${discountAmount.toFixed(2)}`;
    }
    return `${promo.discountValue} off - You save ${discountAmount.toFixed(2)}`;
  }

  /// Cache a validation result in Redis
  private async _cacheResult(key: string, data: any, ttlSeconds: number): Promise<void> {
    try {
      await this.redis.setex(key, ttlSeconds, JSON.stringify(data));
    } catch {
      // Redis failure should not block promo operations
    }
  }

  /// Invalidate promo validation cache for a specific code+user
  private async _invalidatePromoCache(code: string, userId: string): Promise<void> {
    try {
      const key = `promo:validate:${code}:${userId}`;
      await this.redis.del(key);
    } catch {
      // Ignore Redis errors
    }
  }

  /// Invalidate all available promos caches
  private async _invalidateAvailablePromosCache(): Promise<void> {
    try {
      await this.redis.del('promo:available:*');
    } catch {
      // Ignore Redis errors
    }
  }
}
