import { Module, Logger } from '@nestjs/common';
import { BullModule } from '@nestjs/bullmq';
import { RedisModule } from '../redis.module';
import { AnalyticsController } from './analytics.controller';
import { AnalyticsService } from './analytics.service';
import { AnalyticsProcessor } from './analytics.processor';

/// Analytics Module - Provides aggregated metrics, dashboards, and reporting
/// Uses Prisma for DB queries, Redis for caching, BullMQ for scheduled pre-computation
@Module({
  imports: [
    // Redis module for caching
    RedisModule,
    // BullMQ queue for daily analytics pre-computation
    BullModule.registerQueue({
      name: 'analytics',
      defaultJobOptions: {
        removeOnComplete: 100,
        removeOnFail: 50,
        attempts: 3,
        backoff: {
          type: 'exponential',
          delay: 5000,
        },
      },
    }),
  ],
  controllers: [AnalyticsController],
  providers: [AnalyticsService, AnalyticsProcessor],
  exports: [AnalyticsService],
})
export class AnalyticsModule {
  private readonly logger = new Logger(AnalyticsModule.name);

  constructor() {
    this.logger.log('Analytics Module initialized');
  }
}
