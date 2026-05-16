import { Injectable, OnModuleInit, OnModuleDestroy } from '@nestjs/common';
import { PrismaClient } from '@prisma/client';

@Injectable()
export class PrismaService extends PrismaClient implements OnModuleInit, OnModuleDestroy {
  async onModuleInit() {
    await this.$connect();
    console.log('✅ PostgreSQL + PostGIS connected via Prisma');
    
    // Enable PostGIS extension
    await this.$executeRaw`CREATE EXTENSION IF NOT EXISTS postgis;`;
    console.log('✅ PostGIS extension enabled');
  }

  async onModuleDestroy() {
    await this.$disconnect();
  }
}
