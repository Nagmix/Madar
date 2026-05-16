import { Injectable, NotFoundException, BadRequestException, ForbiddenException } from '@nestjs/common';
import { PrismaService } from '../prisma.service';
import { TripState } from '@prisma/client';

/// Valid state transitions for Trip State Machine
const VALID_TRANSITIONS: Record<TripState, TripState[]> = {
  SEARCHING_DRIVER: [TripState.DRIVER_ASSIGNED, TripState.TRIP_CANCELLED],
  DRIVER_ASSIGNED: [TripState.DRIVER_ARRIVING, TripState.TRIP_CANCELLED],
  DRIVER_ARRIVING: [TripState.DRIVER_ARRIVED, TripState.TRIP_CANCELLED],
  DRIVER_ARRIVED: [TripState.TRIP_STARTED, TripState.TRIP_CANCELLED],
  TRIP_STARTED: [TripState.TRIP_PAUSED, TripState.TRIP_COMPLETED, TripState.TRIP_CANCELLED],
  TRIP_PAUSED: [TripState.TRIP_RESUMED, TripState.TRIP_CANCELLED],
  TRIP_RESUMED: [TripState.TRIP_PAUSED, TripState.TRIP_COMPLETED, TripState.TRIP_CANCELLED],
  TRIP_COMPLETED: [TripState.PAYMENT_PENDING],
  PAYMENT_PENDING: [TripState.PAYMENT_COMPLETED],
  PAYMENT_COMPLETED: [],
  TRIP_CANCELLED: [],
};

@Injectable()
export class TripService {
  constructor(private prisma: PrismaService) {}

  async createTrip(riderId: string, dto: any) {
    // 1. Validate pickup/dropoff locations are within service areas
    // 2. Calculate estimated fare via PricingModule
    // 3. Create trip in SEARCHING_DRIVER state
    // 4. Trigger dispatch to find driver

    const trip = await this.prisma.trip.create({
      data: {
        riderId,
        pickupLat: dto.pickupLatitude,
        pickupLng: dto.pickupLongitude,
        pickupAddress: dto.pickupAddress,
        dropoffLat: dto.dropoffLatitude,
        dropoffLng: dto.dropoffLongitude,
        dropoffAddress: dto.dropoffAddress,
        vehicleType: dto.vehicleType || 'SEDAN',
        state: TripState.SEARCHING_DRIVER,
        promoCode: dto.promoCode,
        note: dto.note,
      },
      include: { rider: { select: { id: true, name: true, phone: true } } },
    });

    // Log state change
    await this.logStateChange(trip.id, TripState.SEARCHING_DRIVER, riderId);

    // TODO: Trigger dispatch job via BullMQ
    // this.dispatchService.startDriverSearch(trip.id);

    return trip;
  }

  async acceptTrip(driverId: string, tripId: string) {
    const trip = await this.getTripOrThrow(tripId);
    
    // Validate state transition
    this.validateTransition(trip.state, TripState.DRIVER_ASSIGNED);

    const driver = await this.prisma.driver.findUnique({
      where: { userId: driverId },
      include: { vehicle: true, user: { select: { id: true, name: true, phone: true } } },
    });

    if (!driver || driver.status !== 'ONLINE') {
      throw new BadRequestException('Driver is not available');
    }

    // Update trip with driver
    const updatedTrip = await this.prisma.trip.update({
      where: { id: tripId },
      data: {
        state: TripState.DRIVER_ASSIGNED,
        driverId: driver.id,
        driverAssignedAt: new Date(),
      },
    });

    // Update driver status to BUSY
    await this.prisma.driver.update({
      where: { id: driver.id },
      data: { status: 'BUSY' },
    });

    await this.logStateChange(tripId, TripState.DRIVER_ASSIGNED, driverId);

    // TODO: Notify rider via Socket.IO and push notification
    // this.notificationService.notifyRider(trip.riderId, 'DRIVER_ASSIGNED', { trip: updatedTrip, driver });

    return updatedTrip;
  }

  async driverArrived(driverId: string, tripId: string) {
    const trip = await this.getTripOrThrow(tripId);
    this.validateTransition(trip.state, TripState.DRIVER_ARRIVED);

    const updatedTrip = await this.prisma.trip.update({
      where: { id: tripId },
      data: {
        state: TripState.DRIVER_ARRIVED,
        driverArrivedAt: new Date(),
      },
    });

    await this.logStateChange(tripId, TripState.DRIVER_ARRIVED, driverId);
    // TODO: Notify rider
    return updatedTrip;
  }

  async startTrip(driverId: string, tripId: string) {
    const trip = await this.getTripOrThrow(tripId);
    this.validateTransition(trip.state, TripState.TRIP_STARTED);

    const updatedTrip = await this.prisma.trip.update({
      where: { id: tripId },
      data: {
        state: TripState.TRIP_STARTED,
        tripStartedAt: new Date(),
      },
    });

    await this.logStateChange(tripId, TripState.TRIP_STARTED, driverId);
    return updatedTrip;
  }

  async completeTrip(driverId: string, tripId: string) {
    const trip = await this.getTripOrThrow(tripId);
    this.validateTransition(trip.state, TripState.TRIP_COMPLETED);

    // Calculate final fare
    // const fare = await this.pricingService.calculateFinalFare(trip);

    const updatedTrip = await this.prisma.trip.update({
      where: { id: tripId },
      data: {
        state: TripState.TRIP_COMPLETED,
        tripCompletedAt: new Date(),
        // totalFare: fare.totalFare,
      },
    });

    // Update driver status back to ONLINE
    await this.prisma.driver.update({
      where: { id: trip.driverId! },
      data: { status: 'ONLINE' },
    });

    // Update trip counts
    await this.prisma.user.update({
      where: { id: trip.riderId },
      data: { totalRides: { increment: 1 } },
    });
    await this.prisma.driver.update({
      where: { id: trip.driverId! },
      data: { totalTrips: { increment: 1 }, completedTrips: { increment: 1 } },
    });

    await this.logStateChange(tripId, TripState.TRIP_COMPLETED, driverId);

    // TODO: Process payment, create wallet transaction
    return updatedTrip;
  }

  async cancelTrip(userId: string, tripId: string, reason: string) {
    const trip = await this.getTripOrThrow(tripId);
    this.validateTransition(trip.state, TripState.TRIP_CANCELLED);

    // Determine who cancelled
    const driver = await this.prisma.driver.findUnique({ where: { userId } });
    const cancelledBy = driver ? 'DRIVER' : 'RIDER';

    const updatedTrip = await this.prisma.trip.update({
      where: { id: tripId },
      data: {
        state: TripState.TRIP_CANCELLED,
        cancelledBy: cancelledBy as any,
        cancellationReason: reason,
        cancelledAt: new Date(),
      },
    });

    // Update driver status back to ONLINE if was assigned
    if (trip.driverId) {
      await this.prisma.driver.update({
        where: { id: trip.driverId },
        data: { status: 'ONLINE', cancelledTrips: { increment: 1 } },
      });
    }

    // Update rider cancellations
    if (cancelledBy === 'RIDER') {
      await this.prisma.user.update({
        where: { id: userId },
        data: { cancellations: { increment: 1 } },
      });
    }

    await this.logStateChange(tripId, TripState.TRIP_CANCELLED, userId, reason);
    return updatedTrip;
  }

  async rateTrip(userId: string, tripId: string, rating: number, review?: string, tags?: string[]) {
    const trip = await this.getTripOrThrow(tripId);
    
    if (trip.state !== TripState.PAYMENT_COMPLETED && trip.state !== TripState.TRIP_COMPLETED) {
      throw new BadRequestException('Cannot rate a trip that is not completed');
    }

    const driver = await this.prisma.driver.findUnique({ where: { userId } });
    
    if (driver) {
      return this.prisma.trip.update({
        where: { id: tripId },
        data: { driverRating: rating, driverReview: review },
      });
    } else {
      return this.prisma.trip.update({
        where: { id: tripId },
        data: { riderRating: rating, riderReview: review },
      });
    }
  }

  async getTripHistory(userId: string, page: number, pageSize: number, state?: TripState) {
    const driver = await this.prisma.driver.findUnique({ where: { userId } });
    
    const where = {
      ...(driver ? { driverId: driver.id } : { riderId: userId }),
      ...(state ? { state } : {}),
    };

    const [items, total] = await Promise.all([
      this.prisma.trip.findMany({
        where,
        orderBy: { createdAt: 'desc' },
        skip: (page - 1) * pageSize,
        take: pageSize,
        include: {
          rider: { select: { name: true } },
          driver: { select: { user: { select: { name: true } } } },
        },
      }),
      this.prisma.trip.count({ where }),
    ]);

    return { items, total, page, pageSize };
  }

  async getTripDetails(userId: string, tripId: string) {
    const trip = await this.prisma.trip.findUnique({
      where: { id: tripId },
      include: {
        rider: { select: { id: true, name: true, phone: true } },
        driver: { select: { id: true, user: { select: { id: true, name: true, phone: true } }, vehicle: true, averageRating: true } },
        stateLog: { orderBy: { timestamp: 'asc' } },
      },
    });

    if (!trip) throw new NotFoundException('Trip not found');
    return trip;
  }

  async estimateFare(dto: any) {
    // Calculate distance and duration using Google Maps or PostGIS
    // Apply pricing config
    // Apply surge/night/area multipliers
    // Return fare breakdown
    return {
      fareBreakdown: {
        baseFare: 5.0,
        distanceFare: 10.0,
        timeFare: 3.0,
        surgeCharge: 0,
        nightCharge: 0,
        areaCharge: 0,
        waitingCharge: 0,
        promoDiscount: 0,
        totalFare: 18.0,
      },
      estimatedDurationMinutes: 15,
      estimatedDistanceKm: 8.5,
      isSurgeActive: false,
      surgeMultiplier: 1.0,
      currency: 'USD',
    };
  }

  // ==================== Helpers ====================

  private async getTripOrThrow(tripId: string) {
    const trip = await this.prisma.trip.findUnique({ where: { id: tripId } });
    if (!trip) throw new NotFoundException('Trip not found');
    return trip;
  }

  private validateTransition(from: TripState, to: TripState) {
    const allowed = VALID_TRANSITIONS[from] || [];
    if (!allowed.includes(to)) {
      throw new BadRequestException(`Invalid state transition: ${from} → ${to}`);
    }
  }

  private async logStateChange(tripId: string, state: TripState, changedBy: string, reason?: string) {
    await this.prisma.tripStateLog.create({
      data: { tripId, state, changedBy, reason },
    });
  }
}
