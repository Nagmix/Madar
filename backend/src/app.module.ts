import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { ThrottlerModule } from '@nestjs/throttler';
import { BullModule } from '@nestjs/bullmq';
import { PrismaModule } from './prisma.module';
import { RedisModule } from './redis.module';

// Feature modules
import { AuthModule } from './auth/auth.module';
import { UserModule } from './user/user.module';
import { DriverModule } from './driver/driver.module';
import { TripModule } from './trip/trip.module';
import { DispatchModule } from './dispatch/dispatch.module';
import { PricingModule } from './pricing/pricing.module';
import { WalletModule } from './wallet/wallet.module';
import { NotificationModule } from './notification/notification.module';
import { GeoModule } from './geo/geo.module';
import { AnalyticsModule } from './analytics/analytics.module';
import { PromoModule } from './promo/promo.module';
import { HealthModule } from './health/health.module';

@Module({
  imports: [
    // Global configuration
    ConfigModule.forRoot({
      isGlobal: true,
      envFilePath: '.env',
    }),

    // Rate limiting
    ThrottlerModule.forRoot([{
      ttl: 60000,
      limit: 100,
    }]),

    // BullMQ for background jobs
    BullModule.forRoot({
      connection: {
        host: process.env.REDIS_HOST || 'localhost',
        port: parseInt(process.env.REDIS_PORT) || 6379,
        password: process.env.REDIS_PASSWORD || undefined,
      },
    }),

    // Database
    PrismaModule,

    // Redis cache & queue
    RedisModule,

    // Feature modules (Modular Monolith)
    AuthModule,
    UserModule,
    DriverModule,
    TripModule,
    DispatchModule,
    PricingModule,
    WalletModule,
    NotificationModule,
    GeoModule,
    AnalyticsModule,
    PromoModule,
    HealthModule,
  ],
})
export class AppModule {}
