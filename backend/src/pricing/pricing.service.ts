import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma.service';
import { VehicleType } from '@prisma/client';

/// Pricing Service - Calculates fares with surge, night, area, waiting pricing
/// All pricing logic runs server-side for security and consistency
@Injectable()
export class PricingService {
  constructor(private prisma: PrismaService) {}

  /// Calculate fare for a trip
  async calculateFare(params: {
    pickupLat: number;
    pickupLng: number;
    dropoffLat: number;
    dropoffLng: number;
    vehicleType: VehicleType;
    distanceKm: number;
    durationMinutes: number;
    waitingMinutes?: number;
    promoCode?: string;
  }) {
    // 1. Get pricing config for vehicle type and zone
    const config = await this.getPricingConfig(params.vehicleType, params.pickupLat, params.pickupLng);

    // 2. Calculate base components
    const baseFare = config.baseFare;
    const distanceFare = params.distanceKm * config.perKmRate;
    const timeFare = params.durationMinutes * config.perMinuteRate;
    const subtotal = baseFare + distanceFare + timeFare;

    // 3. Check surge pricing
    const surgeMultiplier = await this.getSurgeMultiplier(params.pickupLat, params.pickupLng);
    const surgeCharge = subtotal * (surgeMultiplier - 1.0);

    // 4. Check night pricing
    const nightMultiplier = this.getNightMultiplier(config);
    const nightCharge = subtotal * (nightMultiplier - 1.0);

    // 5. Check area pricing (geofence)
    const areaMultiplier = await this.getAreaMultiplier(params.pickupLat, params.pickupLng);
    const areaCharge = subtotal * (areaMultiplier - 1.0);

    // 6. Calculate waiting charge
    const freeWaiting = config.freeWaitingMinutes;
    const chargeableWaiting = Math.max(0, (params.waitingMinutes || 0) - freeWaiting);
    const waitingCharge = chargeableWaiting * config.waitingFeePerMinute;

    // 7. Calculate promo discount
    let promoDiscount = 0;
    if (params.promoCode) {
      promoDiscount = await this.calculatePromoDiscount(params.promoCode, subtotal);
    }

    // 8. Calculate total
    const totalBeforeDiscount = subtotal + surgeCharge + nightCharge + areaCharge + waitingCharge;
    const totalFare = Math.max(config.minimumFare, totalBeforeDiscount - promoDiscount);

    return {
      baseFare,
      distanceFare,
      timeFare,
      surgeCharge: Math.round(surgeCharge * 100) / 100,
      nightCharge: Math.round(nightCharge * 100) / 100,
      areaCharge: Math.round(areaCharge * 100) / 100,
      waitingCharge: Math.round(waitingCharge * 100) / 100,
      cancellationFee: 0,
      promoDiscount: Math.round(promoDiscount * 100) / 100,
      totalFare: Math.round(totalFare * 100) / 100,
      surgeMultiplier,
      nightMultiplier,
      areaMultiplier,
      currency: config.currency,
      distanceKm: params.distanceKm,
      durationMinutes: params.durationMinutes,
      waitingMinutes: params.waitingMinutes || 0,
      vehicleType: params.vehicleType,
    };
  }

  /// Get pricing configuration for vehicle type and zone
  private async getPricingConfig(vehicleType: VehicleType, lat: number, lng: number) {
    // Check if location falls in a specific zone
    const zone = await this.prisma.$queryRaw`
      SELECT id FROM geo_fences
      WHERE type = 'SURGE_ZONE'
        AND "isActive" = true
        AND ST_Contains(
          polygon::geometry,
          ST_SetSRID(ST_MakePoint(${lng}, ${lat}), 4326)
        )
      LIMIT 1
    `;

    const zoneId = zone[0]?.id || null;

    const config = await this.prisma.pricingConfig.findFirst({
      where: { vehicleType, zoneId, isActive: true },
    });

    // Fallback to default config (no zone)
    if (!config) {
      const defaultConfig = await this.prisma.pricingConfig.findFirst({
        where: { vehicleType, zoneId: null, isActive: true },
      });
      return defaultConfig || this.getDefaultConfig(vehicleType);
    }

    return config;
  }

  /// Get surge multiplier based on demand/supply ratio in the area
  private async getSurgeMultiplier(lat: number, lng: number): Promise<number> {
    // Count active riders and available drivers in the area
    // This would use Redis for real-time counts
    // For now, return 1.0 (no surge)
    return 1.0;
  }

  /// Get night pricing multiplier
  private getNightMultiplier(config: any): number {
    const hour = new Date().getHours();
    const start = config.nightStartHour || 22;
    const end = config.nightEndHour || 6;

    if (start > end) {
      // Crosses midnight (e.g., 22:00 to 06:00)
      return (hour >= start || hour < end) ? config.nightMultiplier : 1.0;
    } else {
      return (hour >= start && hour < end) ? config.nightMultiplier : 1.0;
    }
  }

  /// Get area-based pricing multiplier from geofences
  private async getAreaMultiplier(lat: number, lng: number): Promise<number> {
    const fences = await this.prisma.$queryRaw`
      SELECT "pricingMultiplier" FROM geo_fences
      WHERE type IN ('SURGE_ZONE', 'AIRPORT', 'CUSTOM')
        AND "isActive" = true
        AND "pricingMultiplier" IS NOT NULL
        AND ST_Contains(
          polygon::geometry,
          ST_SetSRID(ST_MakePoint(${lng}, ${lat}), 4326)
        )
      ORDER BY "pricingMultiplier" DESC
      LIMIT 1
    `;

    return fences[0]?.pricingMultiplier || 1.0;
  }

  /// Calculate promo code discount
  private async calculatePromoDiscount(code: string, subtotal: number): Promise<number> {
    const promo = await this.prisma.promoCode.findUnique({ where: { code } });
    if (!promo || !promo.isActive) return 0;
    if (promo.validFrom > new Date() || promo.validTo < new Date()) return 0;
    if (promo.usageLimit && promo.usedCount >= promo.usageLimit) return 0;
    if (subtotal < promo.minFare) return 0;

    let discount = 0;
    if (promo.discountType === 'percentage') {
      discount = subtotal * (promo.discountValue / 100);
      if (promo.maxDiscount) discount = Math.min(discount, promo.maxDiscount);
    } else {
      discount = promo.discountValue;
    }

    return Math.min(discount, subtotal); // Can't discount more than subtotal
  }

  /// Default pricing configuration (fallback)
  private getDefaultConfig(vehicleType: VehicleType) {
    const multipliers: Record<string, number> = {
      MOTORCYCLE: 0.8,
      SEDAN: 1.0,
      SUV: 1.5,
      VAN: 1.8,
      LUXURY: 2.5,
    };

    const m = multipliers[vehicleType] || 1.0;

    return {
      baseFare: 5.0 * m,
      perKmRate: 1.5 * m,
      perMinuteRate: 0.25 * m,
      minimumFare: 10.0 * m,
      cancellationFee: 5.0,
      waitingFeePerMinute: 0.5,
      freeWaitingMinutes: 3,
      nightMultiplier: 1.3,
      nightStartHour: 22,
      nightEndHour: 6,
      currency: 'USD',
    };
  }
}
