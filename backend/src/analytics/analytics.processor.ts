import { Processor, WorkerHost, OnWorkerEvent } from '@nestjs/bullmq';
import { Logger } from '@nestjs/common';
import { Job } from 'bullmq';
import { AnalyticsService } from './analytics.service';

/// BullMQ Processor for analytics jobs
/// Runs daily at 2 AM to pre-compute analytics and cache them in Redis
@Processor('analytics', {
  concurrency: 1,
  limiter: {
    max: 1,
    duration: 5000,
  },
})
export class AnalyticsProcessor extends WorkerHost {
  private readonly logger = new Logger(AnalyticsProcessor.name);

  constructor(private readonly analyticsService: AnalyticsService) {
    super();
  }

  async process(job: Job<any, any, string>): Promise<any> {
    this.logger.log(`Processing analytics job: ${job.name} (ID: ${job.id})`);

    switch (job.name) {
      case 'daily-precompute':
        return this.handleDailyPrecompute(job);

      case 'cache-warmup':
        return this.handleCacheWarmup(job);

      default:
        this.logger.warn(`Unknown job name: ${job.name}`);
        return null;
    }
  }

  /// Pre-compute daily analytics - runs every night at 2 AM
  private async handleDailyPrecompute(job: Job) {
    this.logger.log('Starting daily analytics pre-computation...');

    try {
      const result = await this.analyticsService.precomputeDailyAnalytics();
      this.logger.log(`Daily pre-computation complete for ${result.date}`);
      return result;
    } catch (error) {
      this.logger.error('Daily pre-computation failed:', error);
      throw error;
    }
  }

  /// Warm up cache - pre-populate dashboard and realtime caches
  private async handleCacheWarmup(job: Job) {
    this.logger.log('Starting cache warmup...');

    try {
      const [dashboard, realtime] = await Promise.all([
        this.analyticsService.getDashboardStats(),
        this.analyticsService.getRealtimeMetrics(),
      ]);

      this.logger.log('Cache warmup complete');
      return { dashboard, realtime };
    } catch (error) {
      this.logger.error('Cache warmup failed:', error);
      throw error;
    }
  }

  @OnWorkerEvent('completed')
  onCompleted(job: Job) {
    this.logger.log(`Analytics job completed: ${job.name} (ID: ${job.id})`);
  }

  @OnWorkerEvent('failed')
  onFailed(job: Job, error: Error) {
    this.logger.error(`Analytics job failed: ${job?.name} (ID: ${job?.id})`, error.message);
  }
}
