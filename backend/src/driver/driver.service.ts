import { Injectable, NotFoundException, BadRequestException, ForbiddenException } from '@nestjs/common';
import { PrismaService } from '../prisma.service';
import { DriverStatus } from '@prisma/client';

/// Driver Service - Manages driver profiles, online/offline status, and location updates
/// Uses PostGIS for geospatial location storage and queries
@Injectable()
export class DriverService {
  constructor(private prisma: PrismaService) {}

  /// Create or update driver profile
  async upsertProfile(userId: string, dto: any) {
    // Verify user has DRIVER role
    const user = await this.prisma.user.findUnique({ where: { id: userId } });
    if (!user) throw new NotFoundException('User not found');
    if (user.role !== 'DRIVER') {
      throw new ForbiddenException('Only users with DRIVER role can create a driver profile');
    }

    // Upsert driver profile
    const driver = await this.prisma.driver.upsert({
      where: { userId },
      update: {
        isAvailable: dto.isAvailable ?? true,
      },
      create: {
        userId,
        isAvailable: dto.isAvailable ?? true,
      },
      include: {
        user: { select: { id: true, name: true, email: true, phone: true, profileImageUrl: true } },
        vehicle: true,
        documents: true,
      },
    });

    // Create or update vehicle if provided
    if (dto.vehicle) {
      await this.prisma.vehicle.upsert({
        where: { driverId: driver.id },
        update: {
          name: dto.vehicle.name,
          plateNumber: dto.vehicle.plateNumber,
          type: dto.vehicle.type,
          color: dto.vehicle.color,
          model: dto.vehicle.model,
          year: dto.vehicle.year,
          seats: dto.vehicle.seats,
        },
        create: {
          driverId: driver.id,
          name: dto.vehicle.name,
          plateNumber: dto.vehicle.plateNumber,
          type: dto.vehicle.type,
          color: dto.vehicle.color,
          model: dto.vehicle.model,
          year: dto.vehicle.year,
          seats: dto.vehicle.seats || 4,
        },
      });
    }

    // Create wallet for driver if not exists
    const existingWallet = await this.prisma.wallet.findFirst({ where: { driverId: driver.id } });
    if (!existingWallet) {
      await this.prisma.wallet.create({
        data: { driverId: driver.id, userId, currency: 'USD' },
      });
    }

    return this.getProfile(userId);
  }

  /// Get driver profile with vehicle and stats
  async getProfile(userId: string) {
    const driver = await this.prisma.driver.findUnique({
      where: { userId },
      include: {
        user: { select: { id: true, name: true, email: true, phone: true, profileImageUrl: true, averageRating: true } },
        vehicle: true,
        documents: { orderBy: { uploadedAt: 'desc' } },
        wallet: { select: { id: true, availableBalance: true, currency: true } },
      },
    });

    if (!driver) throw new NotFoundException('Driver profile not found');

    return {
      id: driver.id,
      userId: driver.userId,
      status: driver.status,
      averageRating: driver.averageRating,
      totalTrips: driver.totalTrips,
      completedTrips: driver.completedTrips,
      cancelledTrips: driver.cancelledTrips,
      acceptanceRate: driver.acceptanceRate,
      cancellationRate: driver.cancellationRate,
      isDocumentsVerified: driver.isDocumentsVerified,
      isAvailable: driver.isAvailable,
      lastOnlineAt: driver.lastOnlineAt,
      user: driver.user,
      vehicle: driver.vehicle,
      documents: driver.documents,
      wallet: driver.wallet,
    };
  }

  /// Set driver online with current location
  async setOnline(userId: string, latitude: number, longitude: number) {
    const driver = await this.prisma.driver.findUnique({ where: { userId } });
    if (!driver) throw new NotFoundException('Driver profile not found');

    if (driver.status === DriverStatus.SUSPENDED) {
      throw new ForbiddenException('Driver account is suspended');
    }

    if (!driver.isDocumentsVerified) {
      throw new ForbiddenException('Documents must be verified before going online');
    }

    // Verify driver has an approved vehicle
    const vehicle = await this.prisma.vehicle.findUnique({ where: { driverId: driver.id } });
    if (!vehicle || !vehicle.isApproved) {
      throw new ForbiddenException('Vehicle must be approved before going online');
    }

    // Update driver status and location using PostGIS
    const updatedDriver = await this.prisma.driver.update({
      where: { id: driver.id },
      data: {
        status: DriverStatus.ONLINE,
        isAvailable: true,
        lastOnlineAt: new Date(),
        lastKnownLat: latitude,
        lastKnownLng: longitude,
        currentLocation: {
          // PostGIS point: ST_SetSRID(ST_MakePoint(lng, lat), 4326)::geography
          // Stored as raw SQL via Prisma unsupported type
        } as any,
      },
    });

    // Update location using raw SQL for PostGIS geography type
    await this.prisma.$executeRaw`
      UPDATE drivers
      SET "currentLocation" = ST_SetSRID(ST_MakePoint(${longitude}, ${latitude}), 4326)::geography
      WHERE id = ${driver.id}
    `;

    // TODO: Register driver in Redis for real-time tracking
    // await this.redis.geoadd('drivers:online', longitude, latitude, driver.id);

    // TODO: Notify dispatch service that driver is available
    // this.dispatchService.notifyDriverOnline(driver.id);

    return {
      id: updatedDriver.id,
      status: updatedDriver.status,
      isAvailable: updatedDriver.isAvailable,
      lastOnlineAt: updatedDriver.lastOnlineAt,
      location: { latitude, longitude },
    };
  }

  /// Set driver offline
  async setOffline(userId: string) {
    const driver = await this.prisma.driver.findUnique({ where: { userId } });
    if (!driver) throw new NotFoundException('Driver profile not found');

    if (driver.status === DriverStatus.BUSY) {
      throw new BadRequestException('Cannot go offline while on an active trip');
    }

    const updatedDriver = await this.prisma.driver.update({
      where: { id: driver.id },
      data: {
        status: DriverStatus.OFFLINE,
        isAvailable: false,
      },
    });

    // TODO: Remove driver from Redis real-time tracking
    // await this.redis.zrem('drivers:online', driver.id);

    return {
      id: updatedDriver.id,
      status: updatedDriver.status,
      isAvailable: updatedDriver.isAvailable,
    };
  }

  /// Update driver location (called frequently during tracking)
  /// Uses PostGIS for geospatial storage and supports high-frequency updates
  async updateLocation(userId: string, latitude: number, longitude: number, heading?: number, speed?: number) {
    const driver = await this.prisma.driver.findUnique({ where: { userId } });
    if (!driver) throw new NotFoundException('Driver profile not found');

    if (driver.status === DriverStatus.OFFLINE) {
      throw new BadRequestException('Cannot update location while offline');
    }

    // Update location using raw SQL for PostGIS geography type
    // This is a high-frequency operation, so we keep it lightweight
    await this.prisma.$executeRaw`
      UPDATE drivers
      SET 
        "currentLocation" = ST_SetSRID(ST_MakePoint(${longitude}, ${latitude}), 4326)::geography,
        "lastKnownLat" = ${latitude},
        "lastKnownLng" = ${longitude}
      WHERE id = ${driver.id}
    `;

    // TODO: Update Redis geospatial index for real-time dispatch
    // await this.redis.geoadd('drivers:locations', longitude, latitude, driver.id);

    // TODO: If on active trip, broadcast location to trip room via Socket.IO
    // if (driver.status === DriverStatus.BUSY) {
    //   const activeTrip = await this.prisma.trip.findFirst({
    //     where: { driverId: driver.id, state: { in: ['DRIVER_ARRIVING', 'DRIVER_ARRIVED', 'TRIP_STARTED'] } },
    //   });
    //   if (activeTrip) {
    //     this.tripGateway.broadcastDriverLocation(activeTrip.id, latitude, longitude, heading, speed);
    //   }
    // }

    // TODO: Store location trail for trip route recording
    // await this.redis.rpush(`trip:${activeTripId}:trail`, JSON.stringify({ lat, lng, heading, speed, ts: Date.now() }));

    return {
      latitude,
      longitude,
      heading,
      speed,
      timestamp: new Date().toISOString(),
    };
  }
}
