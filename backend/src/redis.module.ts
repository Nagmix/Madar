import { Module } from '@nestjs/common';
import * as Redis from 'ioredis';

export const REDIS_CLIENT = 'REDIS_CLIENT';

@Module({
  providers: [
    {
      provide: REDIS_CLIENT,
      useFactory: () => {
        const redis = new Redis.default({
          host: process.env.REDIS_HOST || 'localhost',
          port: parseInt(process.env.REDIS_PORT) || 6379,
          password: process.env.REDIS_PASSWORD,
          retryStrategy: (times) => Math.min(times * 200, 5000),
        });
        redis.on('connect', () => console.log('✅ Redis connected'));
        redis.on('error', (err) => console.error('❌ Redis error:', err));
        return redis;
      },
    },
  ],
  exports: [REDIS_CLIENT],
})
export class RedisModule {}
