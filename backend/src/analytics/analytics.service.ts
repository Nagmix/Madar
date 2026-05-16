import { Injectable, Inject } from '@nestjs/common';
import { PrismaService } from '../prisma.service';
import { REDIS_CLIENT } from '../redis.module';
import { TripState, DriverStatus, VehicleType } from '@prisma/client';
import * as Redis from 'ioredis';

/// Analytics Service - Provides aggregated metrics for the admin dashboard
/// Uses Prisma for database queries with aggregation and Redis for caching
/// BullMQ job pre-computes daily analytics every night at 2 AM

interface DateRange {
  start: Date;
  end: Date;
}

interface TripFilters {
  zoneId?: string;
  vehicleType?: VehicleType;
}

@Injectable()
export class AnalyticsService {
  constructor(
    private prisma: PrismaService,
    @Inject(REDIS_CLIENT) private redis: Redis.default,
  ) {}

  // ==================== Dashboard ====================

  /// Get main dashboard stats - aggregates key metrics
  /// Cached in Redis for 5 minutes
  async getDashboardStats() {
    const cacheKey = 'analytics:dashboard';
    const cached = await this.redis.get(cacheKey);
    if (cached) return JSON.parse(cached);

    const today = this.getDateRange('today');

    const [
      totalTripsToday,
      revenueToday,
      activeDrivers,
      activeRiders,
      completedTripsToday,
      cancelledTripsToday,
      avgWaitTimeResult,
      avgTripTimeResult,
    ] = await Promise.all([
      // Total trips created today
      this.prisma.trip.count({
        where: { createdAt: { gte: today.start, lte: today.end } },
      }),

      // Revenue today (sum of totalFare for completed/paid trips)
      this.prisma.trip.aggregate({
        _sum: { totalFare: true },
        where: {
          state: { in: [TripState.TRIP_COMPLETED, TripState.PAYMENT_COMPLETED] },
          createdAt: { gte: today.start, lte: today.end },
        },
      }),

      // Currently active drivers (online or busy)
      this.prisma.driver.count({
        where: { status: { in: [DriverStatus.ONLINE, DriverStatus.BUSY] } },
      }),

      // Active riders (users with a trip in the last 24h)
      this.prisma.user.count({
        where: {
          role: 'RIDER',
          lastActiveAt: { gte: new Date(Date.now() - 24 * 60 * 60 * 1000) },
          isActive: true,
        },
      }),

      // Completed trips today
      this.prisma.trip.count({
        where: {
          state: { in: [TripState.TRIP_COMPLETED, TripState.PAYMENT_COMPLETED] },
          createdAt: { gte: today.start, lte: today.end },
        },
      }),

      // Cancelled trips today
      this.prisma.trip.count({
        where: {
          state: TripState.TRIP_CANCELLED,
          createdAt: { gte: today.start, lte: today.end },
        },
      }),

      // Average wait time (driver assigned at - created at)
      this.prisma.$queryRaw<Array<{ avg_wait_seconds: number }>>`
        SELECT COALESCE(EXTRACT(EPOCH FROM AVG("driverAssignedAt" - "createdAt")), 0)::float as avg_wait_seconds
        FROM trips
        WHERE "driverAssignedAt" IS NOT NULL
          AND "createdAt" >= ${today.start}
          AND "createdAt" <= ${today.end}
      `,

      // Average trip duration (completed at - started at)
      this.prisma.$queryRaw<Array<{ avg_trip_seconds: number }>>`
        SELECT COALESCE(EXTRACT(EPOCH FROM AVG("tripCompletedAt" - "tripStartedAt")), 0)::float as avg_trip_seconds
        FROM trips
        WHERE "tripStartedAt" IS NOT NULL
          AND "tripCompletedAt" IS NOT NULL
          AND "createdAt" >= ${today.start}
          AND "createdAt" <= ${today.end}
      `,
    ]);

    const totalTrips = totalTripsToday;
    const cancellationRate = totalTrips > 0 ? (cancelledTripsToday / totalTrips) * 100 : 0;

    const result = {
      totalTripsToday,
      revenueToday: revenueToday._sum.totalFare || 0,
      activeDrivers,
      activeRiders,
      completedTripsToday,
      cancelledTripsToday,
      cancellationRate: Math.round(cancellationRate * 100) / 100,
      avgWaitTimeSeconds: Math.round(avgWaitTimeResult[0]?.avg_wait_seconds || 0),
      avgTripTimeSeconds: Math.round(avgTripTimeResult[0]?.avg_trip_seconds || 0),
      timestamp: new Date().toISOString(),
    };

    // Cache for 5 minutes
    await this.redis.set(cacheKey, JSON.stringify(result), 'EX', 300);

    return result;
  }

  // ==================== Trip Analytics ====================

  /// Get trip analytics with period and filters
  async getTripAnalytics(period: string, filters: TripFilters) {
    const dateRange = this.getDateRange(period);
    const where = this.buildTripWhere(dateRange, filters);

    const [
      tripsByStatus,
      tripsByVehicleType,
      tripStats,
      tripsByHour,
      avgDistanceResult,
      avgDurationResult,
    ] = await Promise.all([
      // Trips by status
      this.prisma.trip.groupBy({
        by: ['state'],
        where,
        _count: { id: true },
      }),

      // Trips by vehicle type
      this.prisma.trip.groupBy({
        by: ['vehicleType'],
        where,
        _count: { id: true },
      }),

      // Total, completed, cancelled counts
      this.prisma.trip.aggregate({
        _count: { id: true },
        _sum: { totalFare: true, distanceMeters: true, durationSeconds: true },
        where,
      }),

      // Trips by hour of day (for today/week views)
      this.prisma.$queryRaw<
        Array<{ hour: number; count: bigint }>
      >`
        SELECT EXTRACT(HOUR FROM "createdAt")::int as hour, COUNT(*) as count
        FROM trips
        WHERE "createdAt" >= ${dateRange.start}
          AND "createdAt" <= ${dateRange.end}
          ${filters.vehicleType ? this.prisma.$queryRawUnsafe(`AND "vehicleType" = '${filters.vehicleType}'`) : this.prisma.$queryRawUnsafe('')}
        GROUP BY hour
        ORDER BY hour
      `,

      // Average distance
      this.prisma.trip.aggregate({
        _avg: { distanceMeters: true },
        where: { ...where, distanceMeters: { not: null } },
      }),

      // Average duration
      this.prisma.trip.aggregate({
        _avg: { durationSeconds: true },
        where: { ...where, durationSeconds: { not: null } },
      }),
    ]);

    // Build hourly distribution
    const hourlyDistribution: Record<number, number> = {};
    for (let h = 0; h < 24; h++) hourlyDistribution[h] = 0;
    tripsByHour.forEach((row) => {
      hourlyDistribution[row.hour] = Number(row.count);
    });

    const completedCount = tripsByStatus.find(
      (s) => s.state === TripState.TRIP_COMPLETED || s.state === TripState.PAYMENT_COMPLETED,
    )?._count.id || 0;
    const cancelledCount = tripsByStatus.find(
      (s) => s.state === TripState.TRIP_CANCELLED,
    )?._count.id || 0;
    const totalTrips = tripStats._count.id;

    return {
      period,
      dateRange: { start: dateRange.start, end: dateRange.end },
      totalTrips,
      completedTrips: completedCount,
      cancelledTrips: cancelledCount,
      cancellationRate: totalTrips > 0 ? Math.round((cancelledCount / totalTrips) * 10000) / 100 : 0,
      totalRevenue: tripStats._sum.totalFare || 0,
      totalDistanceMeters: tripStats._sum.distanceMeters || 0,
      totalDurationSeconds: tripStats._sum.durationSeconds || 0,
      avgDistanceMeters: Math.round(avgDistanceResult._avg.distanceMeters || 0),
      avgDurationSeconds: Math.round(avgDurationResult._avg.durationSeconds || 0),
      tripsByStatus: tripsByStatus.map((s) => ({
        status: s.state,
        count: s._count.id,
      })),
      tripsByVehicleType: tripsByVehicleType.map((v) => ({
        vehicleType: v.vehicleType,
        count: v._count.id,
      })),
      hourlyDistribution,
    };
  }

  // ==================== Revenue Analytics ====================

  /// Get revenue analytics with period and filters
  async getRevenueAnalytics(period: string, filters: TripFilters) {
    const dateRange = this.getDateRange(period);
    const where = this.buildTripWhere(dateRange, filters);

    const [
      revenueAggregate,
      revenueByDay,
      commissionBreakdown,
      revenueByZone,
      revenueByVehicleType,
      revenueByPaymentStatus,
    ] = await Promise.all([
      // Total revenue aggregate
      this.prisma.trip.aggregate({
        _sum: {
          totalFare: true,
          baseFare: true,
          distanceFare: true,
          timeFare: true,
          surgeCharge: true,
          nightCharge: true,
          areaCharge: true,
          waitingCharge: true,
          cancellationFee: true,
          promoDiscount: true,
        },
        _count: { id: true },
        where,
      }),

      // Revenue by day
      this.prisma.$queryRaw<
        Array<{ date: Date; revenue: number; trips: bigint }>
      >`
        SELECT DATE("createdAt") as date,
               SUM("totalFare") as revenue,
               COUNT(*) as trips
        FROM trips
        WHERE "createdAt" >= ${dateRange.start}
          AND "createdAt" <= ${dateRange.end}
          AND state IN ('TRIP_COMPLETED', 'PAYMENT_COMPLETED')
          ${filters.vehicleType ? this.prisma.$queryRawUnsafe(`AND "vehicleType" = '${filters.vehicleType}'`) : this.prisma.$queryRawUnsafe('')}
        GROUP BY DATE("createdAt")
        ORDER BY date
      `,

      // Commission breakdown from wallet transactions
      this.prisma.walletTransaction.aggregate({
        _sum: { amount: true },
        _count: { id: true },
        where: {
          type: 'COMMISSION_DEDUCTION',
          createdAt: { gte: dateRange.start, lte: dateRange.end },
        },
      }),

      // Revenue by zone (geo fence)
      this.prisma.$queryRaw<
        Array<{ zone_id: string; zone_name: string; revenue: number; trips: bigint }>
      >`
        SELECT g.id as zone_id, g.name as zone_name,
               COALESCE(SUM(t."totalFare"), 0) as revenue,
               COUNT(t.id) as trips
        FROM geo_fences g
        LEFT JOIN trips t ON ST_Contains(
          g.polygon::geometry,
          ST_SetSRID(ST_MakePoint(t."pickupLng", t."pickupLat"), 4326)
        )
        AND t."createdAt" >= ${dateRange.start}
        AND t."createdAt" <= ${dateRange.end}
        AND t.state IN ('TRIP_COMPLETED', 'PAYMENT_COMPLETED')
        WHERE g."isActive" = true
        GROUP BY g.id, g.name
        ORDER BY revenue DESC
        LIMIT 20
      `,

      // Revenue by vehicle type
      this.prisma.trip.groupBy({
        by: ['vehicleType'],
        where: {
          ...where,
          state: { in: [TripState.TRIP_COMPLETED, TripState.PAYMENT_COMPLETED] },
        },
        _sum: { totalFare: true },
        _count: { id: true },
        _avg: { totalFare: true },
      }),

      // Revenue by payment status
      this.prisma.trip.groupBy({
        by: ['state'],
        where: {
          ...where,
          state: { in: [TripState.PAYMENT_PENDING, TripState.PAYMENT_COMPLETED, TripState.TRIP_COMPLETED] },
        },
        _sum: { totalFare: true },
        _count: { id: true },
      }),
    ]);

    return {
      period,
      dateRange: { start: dateRange.start, end: dateRange.end },
      totalRevenue: revenueAggregate._sum.totalFare || 0,
      totalTrips: revenueAggregate._count.id,
      fareBreakdown: {
        baseFare: revenueAggregate._sum.baseFare || 0,
        distanceFare: revenueAggregate._sum.distanceFare || 0,
        timeFare: revenueAggregate._sum.timeFare || 0,
        surgeCharge: revenueAggregate._sum.surgeCharge || 0,
        nightCharge: revenueAggregate._sum.nightCharge || 0,
        areaCharge: revenueAggregate._sum.areaCharge || 0,
        waitingCharge: revenueAggregate._sum.waitingCharge || 0,
        cancellationFee: revenueAggregate._sum.cancellationFee || 0,
        promoDiscount: revenueAggregate._sum.promoDiscount || 0,
      },
      totalCommission: Math.abs(commissionBreakdown._sum.amount || 0),
      commissionTransactions: commissionBreakdown._count.id,
      revenueByDay: revenueByDay.map((r) => ({
        date: r.date,
        revenue: Number(r.revenue) || 0,
        trips: Number(r.trips),
      })),
      revenueByZone: revenueByZone.map((z) => ({
        zoneId: z.zone_id,
        zoneName: z.zone_name,
        revenue: Number(z.revenue) || 0,
        trips: Number(z.trips),
      })),
      revenueByVehicleType: revenueByVehicleType.map((v) => ({
        vehicleType: v.vehicleType,
        revenue: v._sum.totalFare || 0,
        trips: v._count.id,
        avgFare: Math.round((v._avg.totalFare || 0) * 100) / 100,
      })),
      revenueByPaymentStatus: revenueByPaymentStatus.map((p) => ({
        status: p.state,
        revenue: p._sum.totalFare || 0,
        trips: p._count.id,
      })),
    };
  }

  // ==================== Driver Analytics ====================

  /// Get driver analytics for a given period
  async getDriverAnalytics(period: string) {
    const dateRange = this.getDateRange(period);

    const [
      driverStats,
      topDriversByEarnings,
      topDriversByRating,
      topDriversByTrips,
      ratingDistribution,
      onlineHoursResult,
    ] = await Promise.all([
      // Overall driver stats
      this.prisma.driver.aggregate({
        _count: { id: true },
        _avg: {
          averageRating: true,
          acceptanceRate: true,
          cancellationRate: true,
        },
        _sum: { totalTrips: true, completedTrips: true, cancelledTrips: true },
        where: { isDocumentsVerified: true },
      }),

      // Top 10 drivers by earnings (via wallet)
      this.prisma.$queryRaw<
        Array<{
          driver_id: string;
          user_name: string;
          total_earnings: number;
          trip_count: bigint;
          avg_rating: number;
        }>
      >`
        SELECT d.id as driver_id, u.name as user_name,
               COALESCE(w."totalEarnings", 0) as total_earnings,
               d."totalTrips" as trip_count,
               d."averageRating" as avg_rating
        FROM drivers d
        JOIN users u ON d."userId" = u.id
        LEFT JOIN wallets w ON w."driverId" = d.id
        WHERE d."isDocumentsVerified" = true
        ORDER BY w."totalEarnings" DESC NULLS LAST
        LIMIT 10
      `,

      // Top 10 drivers by rating (min 20 trips)
      this.prisma.driver.findMany({
        where: {
          isDocumentsVerified: true,
          totalTrips: { gte: 20 },
        },
        orderBy: { averageRating: 'desc' },
        take: 10,
        include: {
          user: { select: { name: true } },
        },
      }),

      // Top 10 drivers by completed trips
      this.prisma.driver.findMany({
        where: { isDocumentsVerified: true },
        orderBy: { completedTrips: 'desc' },
        take: 10,
        include: {
          user: { select: { name: true } },
        },
      }),

      // Rating distribution
      this.prisma.$queryRaw<
        Array<{ rating_bucket: string; count: bigint }>
      >`
        SELECT
          CASE
            WHEN "averageRating" >= 4.5 THEN '4.5-5.0'
            WHEN "averageRating" >= 4.0 THEN '4.0-4.4'
            WHEN "averageRating" >= 3.5 THEN '3.5-3.9'
            WHEN "averageRating" >= 3.0 THEN '3.0-3.4'
            WHEN "averageRating" > 0 THEN '0.1-2.9'
            ELSE 'unrated'
          END as rating_bucket,
          COUNT(*) as count
        FROM drivers
        WHERE "isDocumentsVerified" = true
        GROUP BY rating_bucket
        ORDER BY rating_bucket DESC
      `,

      // Average online hours per day (drivers who went online in the period)
      this.prisma.$queryRaw<
        Array<{ avg_online_hours: number }>
      >`
        SELECT COALESCE(AVG(
          EXTRACT(EPOCH FROM (
            COALESCE("updatedAt", NOW()) - COALESCE("lastOnlineAt", "updatedAt"))
          ) / 3600
        ), 0)::float as avg_online_hours
        FROM drivers
        WHERE "lastOnlineAt" >= ${dateRange.start}
      `,
    ]);

    return {
      period,
      dateRange: { start: dateRange.start, end: dateRange.end },
      totalVerifiedDrivers: driverStats._count.id,
      avgRating: Math.round((driverStats._avg.averageRating || 0) * 100) / 100,
      avgAcceptanceRate: Math.round((driverStats._avg.acceptanceRate || 0) * 100) / 100,
      avgCancellationRate: Math.round((driverStats._avg.cancellationRate || 0) * 100) / 100,
      totalTripsCompleted: driverStats._sum.completedTrips || 0,
      totalTripsCancelled: driverStats._sum.cancelledTrips || 0,
      avgOnlineHours: Math.round((onlineHoursResult[0]?.avg_online_hours || 0) * 100) / 100,
      topDriversByEarnings: topDriversByEarnings.map((d) => ({
        driverId: d.driver_id,
        name: d.user_name,
        totalEarnings: Number(d.total_earnings) || 0,
        tripCount: Number(d.trip_count),
        avgRating: Math.round((Number(d.avg_rating) || 0) * 100) / 100,
      })),
      topDriversByRating: topDriversByRating.map((d) => ({
        driverId: d.id,
        name: d.user.name,
        averageRating: d.averageRating,
        totalTrips: d.totalTrips,
        acceptanceRate: d.acceptanceRate,
      })),
      topDriversByTrips: topDriversByTrips.map((d) => ({
        driverId: d.id,
        name: d.user.name,
        completedTrips: d.completedTrips,
        averageRating: d.averageRating,
      })),
      ratingDistribution: ratingDistribution.map((r) => ({
        bucket: r.rating_bucket,
        count: Number(r.count),
      })),
    };
  }

  // ==================== User Analytics ====================

  /// Get user analytics for a given period
  async getUserAnalytics(period: string) {
    const dateRange = this.getDateRange(period);

    const [
      newRegistrations,
      newRegistrationsByRole,
      dauResult,
      mauResult,
      activeRidersInPeriod,
      retentionResult,
      avgTripsPerUserResult,
      registrationTrend,
    ] = await Promise.all([
      // New registrations in period
      this.prisma.user.count({
        where: {
          createdAt: { gte: dateRange.start, lte: dateRange.end },
          isActive: true,
        },
      }),

      // New registrations by role
      this.prisma.user.groupBy({
        by: ['role'],
        where: {
          createdAt: { gte: dateRange.start, lte: dateRange.end },
          isActive: true,
        },
        _count: { id: true },
      }),

      // DAU - Daily Active Users (users active in last 24h)
      this.prisma.user.count({
        where: {
          lastActiveAt: { gte: new Date(Date.now() - 24 * 60 * 60 * 1000) },
          isActive: true,
          isBanned: false,
        },
      }),

      // MAU - Monthly Active Users (users active in last 30 days)
      this.prisma.user.count({
        where: {
          lastActiveAt: { gte: new Date(Date.now() - 30 * 24 * 60 * 60 * 1000) },
          isActive: true,
          isBanned: false,
        },
      }),

      // Active riders (with at least 1 trip in period)
      this.prisma.$queryRaw<
        Array<{ active_riders: bigint }>
      >`
        SELECT COUNT(DISTINCT "riderId") as active_riders
        FROM trips
        WHERE "createdAt" >= ${dateRange.start}
          AND "createdAt" <= ${dateRange.end}
      `,

      // Retention: users who registered 30+ days ago and were active in last 7 days
      this.prisma.$queryRaw<
        Array<{ retained: bigint; cohort: bigint }>
      >`
        SELECT
          COUNT(CASE WHEN u."lastActiveAt" >= NOW() - INTERVAL '7 days' THEN 1 END) as retained,
          COUNT(*) as cohort
        FROM users u
        WHERE u."createdAt" <= NOW() - INTERVAL '30 days'
          AND u."isActive" = true
          AND u."isBanned" = false
      `,

      // Average trips per active rider
      this.prisma.$queryRaw<
        Array<{ avg_trips: number }>
      >`
        SELECT COALESCE(AVG(trip_count), 0)::float as avg_trips
        FROM (
          SELECT "riderId", COUNT(*) as trip_count
          FROM trips
          WHERE "createdAt" >= ${dateRange.start}
            AND "createdAt" <= ${dateRange.end}
          GROUP BY "riderId"
        ) sub
      `,

      // Registration trend by day
      this.prisma.$queryRaw<
        Array<{ date: Date; count: bigint }>
      >`
        SELECT DATE("createdAt") as date, COUNT(*) as count
        FROM users
        WHERE "createdAt" >= ${dateRange.start}
          AND "createdAt" <= ${dateRange.end}
          AND "isActive" = true
        GROUP BY DATE("createdAt")
        ORDER BY date
      `,
    ]);

    const retentionRate =
      Number(retentionResult[0]?.cohort || 0) > 0
        ? (Number(retentionResult[0]?.retained || 0) / Number(retentionResult[0]?.cohort)) * 100
        : 0;

    return {
      period,
      dateRange: { start: dateRange.start, end: dateRange.end },
      newRegistrations,
      newRegistrationsByRole: newRegistrationsByRole.map((r) => ({
        role: r.role,
        count: r._count.id,
      })),
      dau: dauResult,
      mau: mauResult,
      activeRiders: Number(activeRidersInPeriod[0]?.active_riders || 0),
      retentionRate30d: Math.round(retentionRate * 100) / 100,
      avgTripsPerActiveRider: Math.round((avgTripsPerUserResult[0]?.avg_trips || 0) * 100) / 100,
      registrationTrend: registrationTrend.map((r) => ({
        date: r.date,
        count: Number(r.count),
      })),
    };
  }

  // ==================== Surge Analytics ====================

  /// Get surge pricing analytics
  async getSurgeAnalytics(period: string, zoneId?: string) {
    const dateRange = this.getDateRange(period);

    const zoneFilter = zoneId
      ? this.prisma.$queryRawUnsafe(`AND g.id = '${zoneId}'`)
      : this.prisma.$queryRawUnsafe('');

    const [
      surgeTrips,
      surgeRevenueImpact,
      surgeByHour,
      surgeByZone,
      surgeMultiplierDistribution,
    ] = await Promise.all([
      // Trips with surge
      this.prisma.trip.aggregate({
        _count: { id: true },
        _sum: { surgeCharge: true },
        where: {
          surgeMultiplier: { gt: 1 },
          createdAt: { gte: dateRange.start, lte: dateRange.end },
          ...(zoneId ? {} : {}),
        },
      }),

      // Revenue impact of surge
      this.prisma.$queryRaw<
        Array<{
          total_with_surge: number;
          total_without_surge: number;
          surge_revenue: number;
        }>
      >`
        SELECT
          COALESCE(SUM("totalFare"), 0) as total_with_surge,
          COALESCE(SUM("totalFare" - "surgeCharge"), 0) as total_without_surge,
          COALESCE(SUM("surgeCharge"), 0) as surge_revenue
        FROM trips
        WHERE "createdAt" >= ${dateRange.start}
          AND "createdAt" <= ${dateRange.end}
          AND state IN ('TRIP_COMPLETED', 'PAYMENT_COMPLETED')
          AND "surgeMultiplier" > 1
      `,

      // Surge by hour of day
      this.prisma.$queryRaw<
        Array<{ hour: number; avg_multiplier: number; trip_count: bigint }>
      >`
        SELECT EXTRACT(HOUR FROM "createdAt")::int as hour,
               AVG("surgeMultiplier")::float as avg_multiplier,
               COUNT(*) as trip_count
        FROM trips
        WHERE "createdAt" >= ${dateRange.start}
          AND "createdAt" <= ${dateRange.end}
          AND "surgeMultiplier" > 1
        GROUP BY hour
        ORDER BY hour
      `,

      // Surge by zone
      this.prisma.$queryRaw<
        Array<{
          zone_id: string;
          zone_name: string;
          avg_multiplier: number;
          trip_count: bigint;
          total_surge_revenue: number;
        }>
      >`
        SELECT g.id as zone_id, g.name as zone_name,
               AVG(t."surgeMultiplier")::float as avg_multiplier,
               COUNT(t.id) as trip_count,
               COALESCE(SUM(t."surgeCharge"), 0) as total_surge_revenue
        FROM geo_fences g
        JOIN trips t ON ST_Contains(
          g.polygon::geometry,
          ST_SetSRID(ST_MakePoint(t."pickupLng", t."pickupLat"), 4326)
        )
        AND t."createdAt" >= ${dateRange.start}
        AND t."createdAt" <= ${dateRange.end}
        AND t."surgeMultiplier" > 1
        WHERE g."isActive" = true
          AND g.type = 'SURGE_ZONE'
          ${zoneFilter}
        GROUP BY g.id, g.name
        ORDER BY total_surge_revenue DESC
        LIMIT 20
      `,

      // Surge multiplier distribution
      this.prisma.$queryRaw<
        Array<{ multiplier_range: string; count: bigint }>
      >`
        SELECT
          CASE
            WHEN "surgeMultiplier" <= 1.2 THEN '1.0-1.2x'
            WHEN "surgeMultiplier" <= 1.5 THEN '1.2-1.5x'
            WHEN "surgeMultiplier" <= 2.0 THEN '1.5-2.0x'
            WHEN "surgeMultiplier" <= 3.0 THEN '2.0-3.0x'
            ELSE '3.0x+'
          END as multiplier_range,
          COUNT(*) as count
        FROM trips
        WHERE "createdAt" >= ${dateRange.start}
          AND "createdAt" <= ${dateRange.end}
          AND "surgeMultiplier" > 1
        GROUP BY multiplier_range
        ORDER BY multiplier_range
      `,
    ]);

    // Build demand pattern: hourly distribution of all trips vs surge trips
    const demandPattern: Record<number, { total: number; surge: number }> = {};
    for (let h = 0; h < 24; h++) demandPattern[h] = { total: 0, surge: 0 };

    surgeByHour.forEach((row) => {
      demandPattern[row.hour].surge = Number(row.trip_count);
    });

    // Get total trips by hour for demand comparison
    const allTripsByHour = await this.prisma.$queryRaw<
      Array<{ hour: number; count: bigint }>
    >`
      SELECT EXTRACT(HOUR FROM "createdAt")::int as hour, COUNT(*) as count
      FROM trips
      WHERE "createdAt" >= ${dateRange.start}
        AND "createdAt" <= ${dateRange.end}
      GROUP BY hour
      ORDER BY hour
    `;
    allTripsByHour.forEach((row) => {
      demandPattern[row.hour].total = Number(row.count);
    });

    return {
      period,
      dateRange: { start: dateRange.start, end: dateRange.end },
      surgeTrips: surgeTrips._count.id,
      surgeRevenue: surgeTrips._sum.surgeCharge || 0,
      revenueImpact: {
        totalWithSurge: Number(surgeRevenueImpact[0]?.total_with_surge || 0),
        totalWithoutSurge: Number(surgeRevenueImpact[0]?.total_without_surge || 0),
        surgeRevenue: Number(surgeRevenueImpact[0]?.surge_revenue || 0),
      },
      demandPattern,
      surgeByHour: surgeByHour.map((h) => ({
        hour: h.hour,
        avgMultiplier: Math.round(h.avg_multiplier * 100) / 100,
        tripCount: Number(h.trip_count),
      })),
      surgeByZone: surgeByZone.map((z) => ({
        zoneId: z.zone_id,
        zoneName: z.zone_name,
        avgMultiplier: Math.round(z.avg_multiplier * 100) / 100,
        tripCount: Number(z.trip_count),
        totalSurgeRevenue: Number(z.total_surge_revenue),
      })),
      multiplierDistribution: surgeMultiplierDistribution.map((m) => ({
        range: m.multiplier_range,
        count: Number(m.count),
      })),
    };
  }

  // ==================== Realtime Metrics ====================

  /// Get realtime metrics - cached for 30 seconds
  async getRealtimeMetrics() {
    const cacheKey = 'analytics:realtime';
    const cached = await this.redis.get(cacheKey);
    if (cached) return JSON.parse(cached);

    const now = new Date();
    const fiveMinAgo = new Date(now.getTime() - 5 * 60 * 1000);

    const [
      activeTrips,
      onlineDrivers,
      pendingRequests,
      avgEtaResult,
      driversByStatus,
      recentCompletedTrips,
      requestsLast5Min,
    ] = await Promise.all([
      // Active trips (in progress)
      this.prisma.trip.count({
        where: {
          state: {
            in: [
              TripState.SEARCHING_DRIVER,
              TripState.DRIVER_ASSIGNED,
              TripState.DRIVER_ARRIVING,
              TripState.DRIVER_ARRIVED,
              TripState.TRIP_STARTED,
            ],
          },
        },
      }),

      // Online drivers
      this.prisma.driver.count({
        where: { status: DriverStatus.ONLINE },
      }),

      // Pending trip requests (searching for driver)
      this.prisma.trip.count({
        where: { state: TripState.SEARCHING_DRIVER },
      }),

      // Average ETA (time from trip creation to driver assigned in last hour)
      this.prisma.$queryRaw<
        Array<{ avg_eta_seconds: number }>
      >`
        SELECT COALESCE(EXTRACT(EPOCH FROM AVG("driverAssignedAt" - "createdAt")), 0)::float as avg_eta_seconds
        FROM trips
        WHERE "driverAssignedAt" IS NOT NULL
          AND "createdAt" >= NOW() - INTERVAL '1 hour'
      `,

      // Drivers by status
      this.prisma.driver.groupBy({
        by: ['status'],
        _count: { id: true },
      }),

      // Trips completed in last hour
      this.prisma.trip.count({
        where: {
          state: { in: [TripState.TRIP_COMPLETED, TripState.PAYMENT_COMPLETED] },
          tripCompletedAt: { gte: new Date(now.getTime() - 60 * 60 * 1000) },
        },
      }),

      // Trip requests in last 5 minutes (for requests/min rate)
      this.prisma.trip.count({
        where: {
          createdAt: { gte: fiveMinAgo },
        },
      }),
    ]);

    const requestsPerMinute = Math.round((requestsLast5Min / 5) * 100) / 100;

    const result = {
      activeTrips,
      onlineDrivers,
      busyDrivers: driversByStatus.find((d) => d.status === DriverStatus.BUSY)?._count.id || 0,
      offlineDrivers: driversByStatus.find((d) => d.status === DriverStatus.OFFLINE)?._count.id || 0,
      pendingRequests,
      averageEtaSeconds: Math.round(avgEtaResult[0]?.avg_eta_seconds || 0),
      tripsCompletedLastHour: recentCompletedTrips,
      requestsPerMinute,
      driversByStatus: driversByStatus.map((d) => ({
        status: d.status,
        count: d._count.id,
      })),
      timestamp: now.toISOString(),
    };

    // Cache for 30 seconds
    await this.redis.set(cacheKey, JSON.stringify(result), 'EX', 30);

    return result;
  }

  // ==================== Daily Pre-computation ====================

  /// Pre-compute daily analytics (called by BullMQ scheduled job at 2 AM)
  async precomputeDailyAnalytics() {
    const yesterday = new Date();
    yesterday.setHours(0, 0, 0, 0);
    const dayEnd = new Date(yesterday);
    dayEnd.setDate(dayEnd.getDate() + 1);

    const dateStr = yesterday.toISOString().split('T')[0];

    // Compute key metrics for yesterday
    const [tripCount, revenue, completedTrips, cancelledTrips, newUsers, newDrivers] =
      await Promise.all([
        this.prisma.trip.count({
          where: { createdAt: { gte: yesterday, lt: dayEnd } },
        }),
        this.prisma.trip.aggregate({
          _sum: { totalFare: true },
          where: {
            state: { in: [TripState.TRIP_COMPLETED, TripState.PAYMENT_COMPLETED] },
            createdAt: { gte: yesterday, lt: dayEnd },
          },
        }),
        this.prisma.trip.count({
          where: {
            state: { in: [TripState.TRIP_COMPLETED, TripState.PAYMENT_COMPLETED] },
            createdAt: { gte: yesterday, lt: dayEnd },
          },
        }),
        this.prisma.trip.count({
          where: {
            state: TripState.TRIP_CANCELLED,
            createdAt: { gte: yesterday, lt: dayEnd },
          },
        }),
        this.prisma.user.count({
          where: { createdAt: { gte: yesterday, lt: dayEnd }, isActive: true },
        }),
        this.prisma.driver.count({
          where: {
            isDocumentsVerified: true,
            createdAt: { gte: yesterday, lt: dayEnd },
          },
        }),
      ]);

    const dailySummary = {
      date: dateStr,
      totalTrips: tripCount,
      completedTrips,
      cancelledTrips,
      revenue: revenue._sum.totalFare || 0,
      newUsers,
      newDrivers,
      computedAt: new Date().toISOString(),
    };

    // Store in Redis with 7 day TTL for quick access
    const key = `analytics:daily:${dateStr}`;
    await this.redis.set(key, JSON.stringify(dailySummary), 'EX', 7 * 24 * 60 * 60);

    // Invalidate dashboard cache so it recomputes
    await this.redis.del('analytics:dashboard');

    return dailySummary;
  }

  // ==================== CSV Export ====================

  /// Export trip data as CSV for a given date range
  async exportTripsCsv(period: string, filters: TripFilters): Promise<string> {
    const dateRange = this.getDateRange(period);
    const where = this.buildTripWhere(dateRange, filters);

    const trips = await this.prisma.trip.findMany({
      where,
      orderBy: { createdAt: 'desc' },
      include: {
        rider: { select: { name: true, email: true } },
        driver: { select: { user: { select: { name: true } } } },
      },
    });

    const headers = [
      'Trip ID',
      'Rider',
      'Driver',
      'Status',
      'Vehicle Type',
      'Pickup Address',
      'Dropoff Address',
      'Distance (m)',
      'Duration (s)',
      'Base Fare',
      'Surge Charge',
      'Total Fare',
      'Currency',
      'Surge Multiplier',
      'Rider Rating',
      'Driver Rating',
      'Created At',
      'Completed At',
    ];

    const rows = trips.map((t) =>
      [
        t.id,
        t.rider?.name || '',
        t.driver?.user?.name || 'N/A',
        t.state,
        t.vehicleType,
        `"${t.pickupAddress.replace(/"/g, '""')}"`,
        `"${t.dropoffAddress.replace(/"/g, '""')}"`,
        t.distanceMeters || 0,
        t.durationSeconds || 0,
        t.baseFare,
        t.surgeCharge,
        t.totalFare,
        t.currency,
        t.surgeMultiplier,
        t.riderRating,
        t.driverRating,
        t.createdAt.toISOString(),
        t.tripCompletedAt?.toISOString() || '',
      ].join(','),
    );

    return [headers.join(','), ...rows].join('\n');
  }

  /// Export revenue data as CSV
  async exportRevenueCsv(period: string, filters: TripFilters): Promise<string> {
    const dateRange = this.getDateRange(period);
    const where = this.buildTripWhere(dateRange, {
      ...filters,
    });

    const transactions = await this.prisma.walletTransaction.findMany({
      where: {
        createdAt: { gte: dateRange.start, lte: dateRange.end },
        type: { in: ['TRIP_EARNING', 'COMMISSION_DEDUCTION', 'INCENTIVE_BONUS'] },
      },
      orderBy: { createdAt: 'desc' },
      take: 10000,
    });

    const headers = [
      'Transaction ID',
      'Wallet ID',
      'Driver ID',
      'Type',
      'Amount',
      'Balance After',
      'Currency',
      'Description',
      'Trip ID',
      'Status',
      'Created At',
    ];

    const rows = transactions.map((t) =>
      [
        t.id,
        t.walletId,
        t.driverId,
        t.type,
        t.amount,
        t.balanceAfter,
        t.currency,
        `"${t.description.replace(/"/g, '""')}"`,
        t.tripId || '',
        t.status,
        t.createdAt.toISOString(),
      ].join(','),
    );

    return [headers.join(','), ...rows].join('\n');
  }

  // ==================== Helper Methods ====================

  /// Build the where clause for trip queries from date range and filters
  private buildTripWhere(dateRange: DateRange, filters: TripFilters) {
    const where: any = {
      createdAt: { gte: dateRange.start, lte: dateRange.end },
    };

    if (filters.vehicleType) {
      where.vehicleType = filters.vehicleType;
    }

    // Zone filtering requires a subquery with PostGIS
    // For zone filter, we'd need raw SQL. For now, we return the base where
    // and handle zone in the specific query methods that use $queryRaw

    return where;
  }

  /// Get date range from period string
  private getDateRange(period: string): DateRange {
    const now = new Date();
    const end = new Date(now);

    let start: Date;

    switch (period) {
      case 'today':
        start = new Date(now);
        start.setHours(0, 0, 0, 0);
        break;

      case 'yesterday':
        start = new Date(now);
        start.setDate(start.getDate() - 1);
        start.setHours(0, 0, 0, 0);
        end.setDate(end.getDate() - 1);
        end.setHours(23, 59, 59, 999);
        break;

      case 'week':
        start = new Date(now);
        start.setDate(start.getDate() - 7);
        start.setHours(0, 0, 0, 0);
        break;

      case 'month':
        start = new Date(now);
        start.setDate(1);
        start.setHours(0, 0, 0, 0);
        break;

      case 'last_month':
        start = new Date(now.getFullYear(), now.getMonth() - 1, 1);
        end.setDate(0); // Last day of previous month
        end.setHours(23, 59, 59, 999);
        break;

      case 'quarter':
        start = new Date(now);
        start.setDate(start.getDate() - 90);
        start.setHours(0, 0, 0, 0);
        break;

      case 'year':
        start = new Date(now.getFullYear(), 0, 1);
        start.setHours(0, 0, 0, 0);
        break;

      default:
        // Try ISO date range format: "2024-01-01,2024-01-31"
        if (period.includes(',')) {
          const [from, to] = period.split(',');
          start = new Date(from);
          end.setTime(new Date(to).getTime());
          end.setHours(23, 59, 59, 999);
        } else {
          // Default to today
          start = new Date(now);
          start.setHours(0, 0, 0, 0);
        }
    }

    return { start, end };
  }
}
