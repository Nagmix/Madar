import { Module } from '@nestjs/common';
import { PromoService } from './promo.service';
import { PromoController } from './promo.controller';
import { PricingModule } from '../pricing/pricing.module';

/// Promo Module - Promotional discount code management
///
/// Integrates with:
/// - PricingModule (for fare calculations)
/// - PrismaService (database - promo_codes, promo_usages, promo_metadata tables)
/// - RedisModule (caching - promo validation results cached for 5 min)
///
/// Routes:
/// - POST /promo/validate  - Validate a promo code
/// - POST /promo/apply     - Apply promo code to a trip
/// - GET  /promo/available - Get available promos for user
/// - GET  /promo/admin     - Admin: list all promos
/// - POST /promo/admin     - Admin: create promo
@Module({
  imports: [PricingModule],
  controllers: [PromoController],
  providers: [PromoService],
  exports: [PromoService],
})
export class PromoModule {}
