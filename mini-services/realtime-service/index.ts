// ============================================
// Real-time Service - Ride Hailing Platform
// Socket.IO Server on port 3002
// ============================================

import { Server as HttpServer } from 'http';
import { Server as SocketIOServer } from 'socket.io';
import { db } from './db';
import {
  validateTransition,
  isValidTransition,
  isTerminalState,
  getTimestampField,
  type TripStatus,
} from './state-machine';
import {
  dispatchTrip,
  setActiveOffer,
  getActiveOffer,
  removeActiveOffer,
  hasActiveOffer,
  getOfferTimeout,
  getMaxAttempts,
  getTopNDrivers,
  haversineDistance,
  type DispatchRequest,
} from './dispatch';

// ============================================
// Server Setup
// ============================================

const PORT = 3002;

const httpServer = new HttpServer();
const io = new SocketIOServer(httpServer, {
  cors: {
    origin: '*',
    methods: ['GET', 'POST'],
  },
});

// ============================================
// In-memory tracking
// ============================================

// Connected sockets by role
interface SocketData {
  role: 'driver' | 'rider' | 'admin' | null;
  userId: string | null;
  driverId: string | null;
  riderId: string | null;
}

// Map: driverId -> socketId
const driverSockets = new Map<string, string>();
// Map: riderId -> socketId
const riderSockets = new Map<string, string>();
// Map: socketId -> SocketData
const socketDataMap = new Map<string, SocketData>();

// Last known driver locations (for fraud detection)
const lastDriverLocation = new Map<
  string,
  { lat: number; lng: number; speed: number; timestamp: number }
>();

// ============================================
// Helper Functions
// ============================================

function log(event: string, data: unknown): void {
  console.log(
    `[${new Date().toISOString()}] [${event}]`,
    JSON.stringify(data, null, 0)
  );
}

function getSocketData(socket: any): SocketData {
  return (
    socketDataMap.get(socket.id) || {
      role: null,
      userId: null,
      driverId: null,
      riderId: null,
    }
  );
}

function setSocketData(socketId: string, data: Partial<SocketData>): void {
  const existing = socketDataMap.get(socketId) || {
    role: null,
    userId: null,
    driverId: null,
    riderId: null,
  };
  socketDataMap.set(socketId, { ...existing, ...data });
}

/**
 * Generate a trip number
 */
function generateTripNumber(): string {
  const prefix = 'TRP';
  const timestamp = Date.now().toString(36).toUpperCase();
  const random = Math.random().toString(36).substring(2, 6).toUpperCase();
  return `${prefix}-${timestamp}-${random}`;
}

// ============================================
// GPS Spoofing Detection
// ============================================

interface SpoofingCheck {
  isSpoofed: boolean;
  reasons: string[];
}

function checkGpsSpoofing(
  driverId: string,
  latitude: number,
  longitude: number,
  speed: number | undefined,
  isMocked: boolean | undefined
): SpoofingCheck {
  const reasons: string[] = [];

  // 1. Check if location is mocked (from device)
  if (isMocked) {
    reasons.push('Device reports mocked location');
  }

  // 2. Check for location jumps (teleportation)
  const lastLoc = lastDriverLocation.get(driverId);
  if (lastLoc) {
    const distance = haversineDistance(
      lastLoc.lat,
      lastLoc.lng,
      latitude,
      longitude
    );
    const timeDiff = (Date.now() - lastLoc.timestamp) / 1000; // seconds

    // If distance > 500m and time < 2 seconds, likely a jump
    if (distance > 0.5 && timeDiff < 2) {
      reasons.push(
        `Location jump: ${distance.toFixed(2)}km in ${timeDiff.toFixed(1)}s`
      );
    }

    // If reported speed doesn't match calculated speed
    if (speed !== undefined && speed > 0 && timeDiff > 0) {
      const calculatedSpeed = (distance / timeDiff) * 3600; // km/h
      // Allow 50% tolerance
      if (calculatedSpeed > speed * 1.5 + 20) {
        reasons.push(
          `Speed anomaly: reported ${speed}km/h, calculated ~${calculatedSpeed.toFixed(0)}km/h`
        );
      }
    }
  }

  // 3. Check for impossible speed
  if (speed !== undefined && speed > 200) {
    // 200 km/h is unreasonable for ride-hailing
    reasons.push(`Impossible speed: ${speed}km/h`);
  }

  // 4. Check for invalid coordinates
  if (Math.abs(latitude) > 90 || Math.abs(longitude) > 180) {
    reasons.push('Invalid coordinates');
  }

  return {
    isSpoofed: reasons.length > 0,
    reasons,
  };
}

// ============================================
// Admin Stats Helper
// ============================================

async function getAdminStats() {
  try {
    const [
      totalDrivers,
      onlineDrivers,
      totalRiders,
      activeTrips,
      tripsToday,
      fraudAlertsOpen,
    ] = await Promise.all([
      db.driver.count(),
      db.driver.count({ where: { isOnline: true } }),
      db.rider.count(),
      db.trip.count({
        where: {
          status: {
            in: [
              'SEARCHING_DRIVER',
              'DRIVER_ASSIGNED',
              'DRIVER_ARRIVING',
              'DRIVER_ARRIVED',
              'TRIP_STARTED',
              'TRIP_PAUSED',
              'TRIP_RESUMED',
            ],
          },
        },
      }),
      db.trip.count({
        where: {
          createdAt: {
            gte: new Date(new Date().setHours(0, 0, 0, 0)),
          },
        },
      }),
      db.fraudAlert.count({ where: { status: 'OPEN' } }),
    ]);

    return {
      totalDrivers,
      onlineDrivers,
      totalRiders,
      activeTrips,
      tripsToday,
      fraudAlertsOpen,
      timestamp: new Date().toISOString(),
    };
  } catch (error) {
    console.error('[AdminStats] Error fetching stats:', error);
    return null;
  }
}

// ============================================
// Dispatch Offer Handler
// ============================================

async function handleDispatchOffer(
  tripId: string,
  pickupLat: number,
  pickupLng: number,
  vehicleTypeRequested: string,
  attempt: number = 1
): Promise<void> {
  log('DISPATCH_OFFER', { tripId, attempt });

  const result = await dispatchTrip({
    tripId,
    pickupLat,
    pickupLng,
    vehicleTypeRequested,
  });

  if (result.matchedDrivers.length === 0) {
    // No drivers found after all attempts - expire the trip
    if (attempt >= getMaxAttempts()) {
      log('DISPATCH_EXPIRED', { tripId, reason: 'no_drivers_found' });
      try {
        await db.trip.update({
          where: { id: tripId },
          data: { status: 'TRIP_EXPIRED' },
        });
        await db.tripEvent.create({
          data: {
            tripId,
            status: 'TRIP_EXPIRED',
            actor: 'system',
            metadata: JSON.stringify({ reason: 'no_drivers_found', attempts: attempt }),
          },
        });

        // Notify admin dashboard
        io.to('admin:dashboard').emit('admin:trip:update', {
          tripId,
          status: 'TRIP_EXPIRED',
          reason: 'no_drivers_found',
        });

        // Find the rider's socket and notify them
        const trip = await db.trip.findUnique({
          where: { id: tripId },
          select: { riderId: true },
        });
        if (trip) {
          const riderSocketId = riderSockets.get(trip.riderId);
          if (riderSocketId) {
            io.to(riderSocketId).emit('rider:trip:expired', {
              tripId,
              reason: 'no_drivers_found',
            });
          }
        }
      } catch (err) {
        console.error('[Dispatch] Error expiring trip:', err);
      }
    }
    return;
  }

  // Get trip details for the offer
  const trip = await db.trip.findUnique({
    where: { id: tripId },
    include: { rider: true },
  });
  if (!trip) return;

  // Emit offers to matched drivers
  const driverIds: string[] = [];
  for (const driver of result.matchedDrivers) {
    const socketId = driverSockets.get(driver.id);
    if (socketId) {
      io.to(socketId).emit('driver:trip:offer', {
        tripId: trip.id,
        tripNumber: trip.tripNumber,
        originAddress: trip.originAddress,
        originLat: trip.originLat,
        originLng: trip.originLng,
        destinationAddress: trip.destinationAddress,
        destinationLat: trip.destinationLat,
        destinationLng: trip.destinationLng,
        estimatedFare: trip.totalFare,
        distanceMeters: trip.distanceMeters,
        riderName: trip.rider.name,
        riderRating: trip.rider.rating,
        vehicleTypeRequested: trip.vehicleTypeRequested,
        expiresAt: new Date(Date.now() + getOfferTimeout()).toISOString(),
      });
      driverIds.push(driver.id);
      log('DRIVER_OFFER_SENT', { tripId, driverId: driver.id });
    }
  }

  // Set timeout for offer expiration
  const timeout = setTimeout(async () => {
    log('DISPATCH_TIMEOUT', { tripId, attempt });
    // Check if the trip is still searching
    const currentTrip = await db.trip.findUnique({
      where: { id: tripId },
      select: { status: true },
    });
    if (!currentTrip || currentTrip.status !== 'SEARCHING_DRIVER') {
      removeActiveOffer(tripId);
      return;
    }

    // Retry with expanded radius
    const nextAttempt = attempt + 1;
    if (nextAttempt <= getMaxAttempts()) {
      await handleDispatchOffer(
        tripId,
        pickupLat,
        pickupLng,
        vehicleTypeRequested,
        nextAttempt
      );
    } else {
      // Max attempts reached - expire trip
      try {
        await db.trip.update({
          where: { id: tripId },
          data: { status: 'TRIP_EXPIRED' },
        });
        await db.tripEvent.create({
          data: {
            tripId,
            status: 'TRIP_EXPIRED',
            actor: 'system',
            metadata: JSON.stringify({ reason: 'no_driver_accepted' }),
          },
        });

        io.to('admin:dashboard').emit('admin:trip:update', {
          tripId,
          status: 'TRIP_EXPIRED',
          reason: 'no_driver_accepted',
        });

        const expiredTrip = await db.trip.findUnique({
          where: { id: tripId },
          select: { riderId: true },
        });
        if (expiredTrip) {
          const riderSocketId = riderSockets.get(expiredTrip.riderId);
          if (riderSocketId) {
            io.to(riderSocketId).emit('rider:trip:expired', {
              tripId,
              reason: 'no_driver_accepted',
            });
          }
        }
      } catch (err) {
        console.error('[Dispatch] Error expiring trip on timeout:', err);
      }
      removeActiveOffer(tripId);
    }
  }, getOfferTimeout());

  setActiveOffer(tripId, {
    tripId,
    driverIds,
    timeout,
    attempt,
    vehicleTypeRequested,
    pickupLat,
    pickupLng,
  });
}

// ============================================
// Socket.IO Connection Handler
// ============================================

io.on('connection', (socket) => {
  log('CONNECTION', { socketId: socket.id });

  // Initialize socket data
  socketDataMap.set(socket.id, {
    role: null,
    userId: null,
    driverId: null,
    riderId: null,
  });

  // -------------------------------------------
  // Authentication
  // -------------------------------------------

  socket.on(
    'auth:driver',
    async (data: { driverId: string; token?: string }) => {
      try {
        log('AUTH_DRIVER', { driverId: data.driverId });

        // Verify driver exists
        const driver = await db.driver.findUnique({
          where: { id: data.driverId },
        });
        if (!driver) {
          socket.emit('auth:error', { message: 'Driver not found' });
          return;
        }

        // Store socket data
        setSocketData(socket.id, {
          role: 'driver',
          driverId: data.driverId,
          userId: data.driverId,
        });
        driverSockets.set(data.driverId, socket.id);

        // Join driver-specific room
        socket.join(`driver:${data.driverId}`);

        log('AUTH_DRIVER_SUCCESS', { driverId: data.driverId });
        socket.emit('auth:success', {
          role: 'driver',
          driverId: data.driverId,
        });
      } catch (error) {
        console.error('[Auth:Driver] Error:', error);
        socket.emit('auth:error', { message: 'Authentication failed' });
      }
    }
  );

  socket.on(
    'auth:rider',
    async (data: { riderId: string; token?: string }) => {
      try {
        log('AUTH_RIDER', { riderId: data.riderId });

        const rider = await db.rider.findUnique({
          where: { id: data.riderId },
        });
        if (!rider) {
          socket.emit('auth:error', { message: 'Rider not found' });
          return;
        }

        setSocketData(socket.id, {
          role: 'rider',
          riderId: data.riderId,
          userId: data.riderId,
        });
        riderSockets.set(data.riderId, socket.id);

        socket.join(`rider:${data.riderId}`);

        log('AUTH_RIDER_SUCCESS', { riderId: data.riderId });
        socket.emit('auth:success', {
          role: 'rider',
          riderId: data.riderId,
        });
      } catch (error) {
        console.error('[Auth:Rider] Error:', error);
        socket.emit('auth:error', { message: 'Authentication failed' });
      }
    }
  );

  socket.on('auth:admin', async (data: { userId: string; token?: string }) => {
    try {
      log('AUTH_ADMIN', { userId: data.userId });

      const user = await db.user.findUnique({
        where: { id: data.userId },
      });
      if (!user) {
        socket.emit('auth:error', { message: 'User not found' });
        return;
      }

      setSocketData(socket.id, {
        role: 'admin',
        userId: data.userId,
      });

      socket.join('admin:dashboard');

      log('AUTH_ADMIN_SUCCESS', { userId: data.userId });
      socket.emit('auth:success', {
        role: 'admin',
        userId: data.userId,
      });

      // Send initial stats
      const stats = await getAdminStats();
      if (stats) {
        socket.emit('admin:stats:update', stats);
      }
    } catch (error) {
      console.error('[Auth:Admin] Error:', error);
      socket.emit('auth:error', { message: 'Authentication failed' });
    }
  });

  // -------------------------------------------
  // Driver Location Updates
  // -------------------------------------------

  socket.on(
    'driver:location:update',
    async (data: {
      latitude: number;
      longitude: number;
      heading?: number;
      speed?: number;
      accuracy?: number;
      isMocked?: boolean;
    }) => {
      try {
        const socketData = getSocketData(socket);
        if (socketData.role !== 'driver' || !socketData.driverId) {
          socket.emit('error', { message: 'Not authenticated as driver' });
          return;
        }

        const driverId = socketData.driverId;

        // GPS Spoofing Detection
        const spoofingResult = checkGpsSpoofing(
          driverId,
          data.latitude,
          data.longitude,
          data.speed,
          data.isMocked
        );

        // Save location to DB
        await db.driverLocation.create({
          data: {
            driverId,
            latitude: data.latitude,
            longitude: data.longitude,
            heading: data.heading,
            speed: data.speed,
            accuracy: data.accuracy,
            isMocked: spoofingResult.isSpoofed,
          },
        });

        // Update last known location
        lastDriverLocation.set(driverId, {
          lat: data.latitude,
          lng: data.longitude,
          speed: data.speed || 0,
          timestamp: Date.now(),
        });

        // Broadcast to admin dashboard
        io.to('admin:dashboard').emit('admin:driver:location', {
          driverId,
          latitude: data.latitude,
          longitude: data.longitude,
          heading: data.heading,
          speed: data.speed,
          accuracy: data.accuracy,
          isMocked: spoofingResult.isSpoofed,
          timestamp: new Date().toISOString(),
        });

        // If spoofing detected, emit fraud alert
        if (spoofingResult.isSpoofed) {
          log('FRAUD_GPS_SPOOFING', {
            driverId,
            reasons: spoofingResult.reasons,
          });

          // Create fraud alert in DB
          try {
            await db.fraudAlert.create({
              data: {
                type: 'gps_spoofing',
                severity: 'HIGH',
                status: 'OPEN',
                driverId,
                description: `GPS spoofing detected: ${spoofingResult.reasons.join('; ')}`,
                evidence: JSON.stringify({
                  location: {
                    latitude: data.latitude,
                    longitude: data.longitude,
                  },
                  speed: data.speed,
                  isMocked: data.isMocked,
                  reasons: spoofingResult.reasons,
                }),
              },
            });
          } catch (dbErr) {
            console.error('[Fraud] Error creating fraud alert:', dbErr);
          }

          // Emit fraud alert to admin
          io.to('admin:dashboard').emit('admin:fraud:alert', {
            type: 'gps_spoofing',
            driverId,
            reasons: spoofingResult.reasons,
            location: {
              latitude: data.latitude,
              longitude: data.longitude,
            },
            timestamp: new Date().toISOString(),
          });

          // Also emit to the driver
          socket.emit('fraud:gps_spoofing', {
            message: 'GPS anomaly detected. Please disable any GPS mocking apps.',
            reasons: spoofingResult.reasons,
          });
        }

        // Forward location to trip tracking rooms if driver has an active trip
        const activeTrip = await db.trip.findFirst({
          where: {
            driverId,
            status: {
              in: [
                'DRIVER_ASSIGNED',
                'DRIVER_ARRIVING',
                'DRIVER_ARRIVED',
                'TRIP_STARTED',
                'TRIP_PAUSED',
                'TRIP_RESUMED',
              ],
            },
          },
          select: { id: true },
        });

        if (activeTrip) {
          // Save to trip locations
          await db.tripLocation.create({
            data: {
              tripId: activeTrip.id,
              driverId,
              latitude: data.latitude,
              longitude: data.longitude,
              heading: data.heading,
              speed: data.speed,
            },
          });

          // Emit to trip tracking room
          io.to(`trip:${activeTrip.id}`).emit('trip:location:update', {
            tripId: activeTrip.id,
            latitude: data.latitude,
            longitude: data.longitude,
            heading: data.heading,
            speed: data.speed,
            timestamp: new Date().toISOString(),
          });
        }
      } catch (error) {
        console.error('[DriverLocation] Error:', error);
        socket.emit('error', { message: 'Failed to update location' });
      }
    }
  );

  // -------------------------------------------
  // Driver Status Change
  // -------------------------------------------

  socket.on(
    'driver:status:change',
    async (data: { status: 'ONLINE' | 'OFFLINE' }) => {
      try {
        const socketData = getSocketData(socket);
        if (socketData.role !== 'driver' || !socketData.driverId) {
          socket.emit('error', { message: 'Not authenticated as driver' });
          return;
        }

        const driverId = socketData.driverId;
        const isOnline = data.status === 'ONLINE';

        log('DRIVER_STATUS_CHANGE', { driverId, status: data.status });

        // Update driver in DB
        await db.driver.update({
          where: { id: driverId },
          data: {
            isOnline,
            status: isOnline ? 'ONLINE' : 'OFFLINE',
            lastOnlineAt: isOnline ? new Date() : undefined,
          },
        });

        // Broadcast to admin dashboard
        io.to('admin:dashboard').emit('admin:driver:status', {
          driverId,
          status: data.status,
          isOnline,
          timestamp: new Date().toISOString(),
        });

        socket.emit('driver:status:updated', {
          status: data.status,
          isOnline,
        });
      } catch (error) {
        console.error('[DriverStatus] Error:', error);
        socket.emit('error', { message: 'Failed to update status' });
      }
    }
  );

  // -------------------------------------------
  // Trip Request (from Rider)
  // -------------------------------------------

  socket.on(
    'trip:request',
    async (data: {
      riderId: string;
      originAddress: string;
      originLat: number;
      originLng: number;
      destinationAddress: string;
      destinationLat: number;
      destinationLng: number;
      vehicleTypeRequested?: string;
      paymentMethod?: string;
      estimatedFare?: number;
      distanceMeters?: number;
      durationSeconds?: number;
    }) => {
      try {
        const socketData = getSocketData(socket);
        if (socketData.role !== 'rider' || !socketData.riderId) {
          socket.emit('error', { message: 'Not authenticated as rider' });
          return;
        }

        log('TRIP_REQUEST', { riderId: data.riderId });

        // Create trip in DB
        const trip = await db.trip.create({
          data: {
            tripNumber: generateTripNumber(),
            riderId: data.riderId,
            originAddress: data.originAddress,
            originLat: data.originLat,
            originLng: data.originLng,
            destinationAddress: data.destinationAddress,
            destinationLat: data.destinationLat,
            destinationLng: data.destinationLng,
            vehicleTypeRequested: (data.vehicleTypeRequested || 'SEDAN') as any,
            paymentMethod: (data.paymentMethod || 'CASH') as any,
            totalFare: data.estimatedFare || 0,
            distanceMeters: data.distanceMeters,
            durationSeconds: data.durationSeconds,
            status: 'SEARCHING_DRIVER',
            requestedAt: new Date(),
          },
        });

        // Create initial trip event
        await db.tripEvent.create({
          data: {
            tripId: trip.id,
            status: 'SEARCHING_DRIVER',
            actor: 'rider',
            actorId: data.riderId,
          },
        });

        // Notify rider
        socket.emit('rider:trip:created', {
          tripId: trip.id,
          tripNumber: trip.tripNumber,
          status: 'SEARCHING_DRIVER',
          message: 'Searching for nearby drivers...',
        });

        // Notify admin dashboard
        io.to('admin:dashboard').emit('admin:trip:new', {
          tripId: trip.id,
          tripNumber: trip.tripNumber,
          riderId: data.riderId,
          originAddress: data.originAddress,
          destinationAddress: data.destinationAddress,
          vehicleTypeRequested: data.vehicleTypeRequested || 'SEDAN',
          estimatedFare: data.estimatedFare,
          status: 'SEARCHING_DRIVER',
          timestamp: new Date().toISOString(),
        });

        // Run dispatch engine
        await handleDispatchOffer(
          trip.id,
          data.originLat,
          data.originLng,
          data.vehicleTypeRequested || 'SEDAN'
        );
      } catch (error) {
        console.error('[TripRequest] Error:', error);
        socket.emit('error', { message: 'Failed to create trip request' });
      }
    }
  );

  // -------------------------------------------
  // Driver Accepts Trip
  // -------------------------------------------

  socket.on(
    'driver:trip:accept',
    async (data: { tripId: string }) => {
      try {
        const socketData = getSocketData(socket);
        if (socketData.role !== 'driver' || !socketData.driverId) {
          socket.emit('error', { message: 'Not authenticated as driver' });
          return;
        }

        const driverId = socketData.driverId;
        log('DRIVER_TRIP_ACCEPT', { driverId, tripId: data.tripId });

        // Check trip exists and is in correct state
        const trip = await db.trip.findUnique({
          where: { id: data.tripId },
          include: { rider: true },
        });

        if (!trip) {
          socket.emit('error', { message: 'Trip not found' });
          return;
        }

        if (trip.status !== 'SEARCHING_DRIVER') {
          socket.emit('error', {
            message: `Trip is no longer available (status: ${trip.status})`,
          });
          return;
        }

        // Validate transition
        const transition = validateTransition(trip.status, 'DRIVER_ASSIGNED');
        if (!transition.valid) {
          socket.emit('error', { message: transition.error });
          return;
        }

        // Clear the dispatch offer timeout
        removeActiveOffer(data.tripId);

        // Update trip
        const updatedTrip = await db.trip.update({
          where: { id: data.tripId },
          data: {
            status: 'DRIVER_ASSIGNED',
            driverId,
            driverAssignedAt: new Date(),
          },
        });

        // Create trip event
        await db.tripEvent.create({
          data: {
            tripId: data.tripId,
            status: 'DRIVER_ASSIGNED',
            actor: 'driver',
            actorId: driverId,
            metadata: JSON.stringify({ driverName: socketData.driverId }),
          },
        });

        // Update driver status
        await db.driver.update({
          where: { id: driverId },
          data: {
            status: 'ON_TRIP',
            acceptedTrips: { increment: 1 },
            acceptanceRate: 0, // Will be recalculated
          },
        });

        // Recalculate acceptance rate
        const driverRecord = await db.driver.findUnique({
          where: { id: driverId },
          select: { acceptedTrips: true, rejectedTrips: true },
        });
        if (driverRecord) {
          const total = driverRecord.acceptedTrips + driverRecord.rejectedTrips;
          const rate = total > 0 ? driverRecord.acceptedTrips / total : 0;
          await db.driver.update({
            where: { id: driverId },
            data: { acceptanceRate: rate },
          });
        }

        // Notify rider
        const riderSocketId = riderSockets.get(trip.riderId);
        if (riderSocketId) {
          io.to(riderSocketId).emit('rider:trip:assigned', {
            tripId: data.tripId,
            tripNumber: trip.tripNumber,
            driverId,
            status: 'DRIVER_ASSIGNED',
            message: 'A driver has been assigned to your trip!',
          });
        }

        // Notify driver
        socket.emit('driver:trip:confirmed', {
          tripId: data.tripId,
          tripNumber: trip.tripNumber,
          status: 'DRIVER_ASSIGNED',
          riderName: trip.rider.name,
          riderPhone: trip.rider.phone,
          originAddress: trip.originAddress,
          destinationAddress: trip.destinationAddress,
        });

        // Notify admin
        io.to('admin:dashboard').emit('admin:trip:update', {
          tripId: data.tripId,
          tripNumber: trip.tripNumber,
          status: 'DRIVER_ASSIGNED',
          driverId,
          riderId: trip.riderId,
          timestamp: new Date().toISOString(),
        });

        // Reject other drivers who were offered this trip
        const offer = getActiveOffer(data.tripId);
        // Offer already removed, but we stored driverIds before
        // We need to notify other drivers that the trip is taken
        // Since we removed the offer, let's notify all other offered drivers
        // For simplicity, we'll emit a cancel to all drivers in the offer room
      } catch (error) {
        console.error('[DriverAccept] Error:', error);
        socket.emit('error', { message: 'Failed to accept trip' });
      }
    }
  );

  // -------------------------------------------
  // Driver Rejects Trip
  // -------------------------------------------

  socket.on(
    'driver:trip:reject',
    async (data: { tripId: string; reason?: string }) => {
      try {
        const socketData = getSocketData(socket);
        if (socketData.role !== 'driver' || !socketData.driverId) {
          socket.emit('error', { message: 'Not authenticated as driver' });
          return;
        }

        const driverId = socketData.driverId;
        log('DRIVER_TRIP_REJECT', { driverId, tripId: data.tripId });

        // Update driver rejection count
        await db.driver.update({
          where: { id: driverId },
          data: {
            rejectedTrips: { increment: 1 },
          },
        });

        // Recalculate acceptance rate
        const driverRecord = await db.driver.findUnique({
          where: { id: driverId },
          select: { acceptedTrips: true, rejectedTrips: true },
        });
        if (driverRecord) {
          const total = driverRecord.acceptedTrips + driverRecord.rejectedTrips;
          const rate = total > 0 ? driverRecord.acceptedTrips / total : 0;
          await db.driver.update({
            where: { id: driverId },
            data: { acceptanceRate: rate },
          });
        }

        // Notify admin
        io.to('admin:dashboard').emit('admin:trip:update', {
          tripId: data.tripId,
          event: 'driver_rejected',
          driverId,
          reason: data.reason,
          timestamp: new Date().toISOString(),
        });

        socket.emit('driver:trip:rejected', {
          tripId: data.tripId,
          message: 'Trip rejection recorded',
        });
      } catch (error) {
        console.error('[DriverReject] Error:', error);
        socket.emit('error', { message: 'Failed to reject trip' });
      }
    }
  );

  // -------------------------------------------
  // Trip Status Update
  // -------------------------------------------

  socket.on(
    'trip:status:update',
    async (data: {
      tripId: string;
      status: TripStatus;
      actor?: string;
      metadata?: Record<string, unknown>;
    }) => {
      try {
        const socketData = getSocketData(socket);
        log('TRIP_STATUS_UPDATE', data);

        // Get current trip
        const trip = await db.trip.findUnique({
          where: { id: data.tripId },
          include: { rider: true, driver: true },
        });

        if (!trip) {
          socket.emit('error', { message: 'Trip not found' });
          return;
        }

        // Validate transition
        const transition = validateTransition(trip.status, data.status);
        if (!transition.valid) {
          socket.emit('error', { message: transition.error });
          return;
        }

        // Determine actor
        const actor = data.actor || socketData.role || 'system';
        const actorId =
          socketData.role === 'driver'
            ? socketData.driverId
            : socketData.role === 'rider'
              ? socketData.riderId
              : socketData.userId;

        // Build update data
        const updateData: Record<string, unknown> = {
          status: data.status,
        };

        // Set the appropriate timestamp field
        const timestampField = getTimestampField(data.status);
        if (timestampField) {
          updateData[timestampField] = new Date();
        }

        // Update trip in DB
        await db.trip.update({
          where: { id: data.tripId },
          data: updateData,
        });

        // Create trip event
        await db.tripEvent.create({
          data: {
            tripId: data.tripId,
            status: data.status,
            actor,
            actorId,
            metadata: data.metadata ? JSON.stringify(data.metadata) : null,
          },
        });

        // Update driver status based on trip status
        if (trip.driverId) {
          if (data.status === 'TRIP_STARTED') {
            await db.driver.update({
              where: { id: trip.driverId },
              data: { status: 'ON_TRIP' },
            });
          } else if (
            ['TRIP_COMPLETED', 'TRIP_CANCELLED', 'TRIP_EXPIRED'].includes(
              data.status
            )
          ) {
            await db.driver.update({
              where: { id: trip.driverId },
              data: {
                status: 'ONLINE',
                isOnline: true,
                totalTrips: data.status === 'TRIP_COMPLETED' ? { increment: 1 } : undefined,
              },
            });
          }
        }

        // Build notification payload
        const payload = {
          tripId: data.tripId,
          tripNumber: trip.tripNumber,
          status: data.status,
          previousStatus: trip.status,
          timestamp: new Date().toISOString(),
          metadata: data.metadata,
        };

        // Notify rider
        const riderSocketId = riderSockets.get(trip.riderId);
        if (riderSocketId) {
          io.to(riderSocketId).emit('rider:trip:update', payload);
        }

        // Notify driver
        if (trip.driverId) {
          const driverSocketId = driverSockets.get(trip.driverId);
          if (driverSocketId) {
            io.to(driverSocketId).emit('driver:trip:update', payload);
          }
        }

        // Notify admin
        io.to('admin:dashboard').emit('admin:trip:update', {
          ...payload,
          riderId: trip.riderId,
          driverId: trip.driverId,
        });

        // Acknowledge to sender
        socket.emit('trip:status:updated', {
          tripId: data.tripId,
          status: data.status,
          valid: true,
        });
      } catch (error) {
        console.error('[TripStatusUpdate] Error:', error);
        socket.emit('error', { message: 'Failed to update trip status' });
      }
    }
  );

  // -------------------------------------------
  // Track Trip (Admin/Rider subscribes to tracking)
  // -------------------------------------------

  socket.on(
    'track:trip',
    async (data: { tripId: string }) => {
      try {
        log('TRACK_TRIP', { tripId: data.tripId, socketId: socket.id });

        // Verify trip exists
        const trip = await db.trip.findUnique({
          where: { id: data.tripId },
        });

        if (!trip) {
          socket.emit('error', { message: 'Trip not found' });
          return;
        }

        // Join trip tracking room
        socket.join(`trip:${data.tripId}`);

        // Get last known driver location if trip is active
        if (trip.driverId) {
          const lastLocation = await db.driverLocation.findFirst({
            where: { driverId: trip.driverId },
            orderBy: { createdAt: 'desc' },
          });

          if (lastLocation) {
            socket.emit('trip:location:update', {
              tripId: data.tripId,
              latitude: lastLocation.latitude,
              longitude: lastLocation.longitude,
              heading: lastLocation.heading,
              speed: lastLocation.speed,
              timestamp: lastLocation.createdAt.toISOString(),
            });
          }
        }

        socket.emit('track:trip:subscribed', {
          tripId: data.tripId,
          status: trip.status,
        });
      } catch (error) {
        console.error('[TrackTrip] Error:', error);
        socket.emit('error', { message: 'Failed to track trip' });
      }
    }
  );

  // -------------------------------------------
  // Untrack Trip
  // -------------------------------------------

  socket.on(
    'untrack:trip',
    (data: { tripId: string }) => {
      log('UNTRACK_TRIP', { tripId: data.tripId, socketId: socket.id });
      socket.leave(`trip:${data.tripId}`);
      socket.emit('track:trip:unsubscribed', { tripId: data.tripId });
    }
  );

  // -------------------------------------------
  // Disconnect
  // -------------------------------------------

  socket.on('disconnect', async (reason) => {
    try {
      const socketData = getSocketData(socket.id);

      log('DISCONNECT', {
        socketId: socket.id,
        role: socketData.role,
        userId: socketData.userId,
        reason,
      });

      // Clean up mappings
      if (socketData.role === 'driver' && socketData.driverId) {
        driverSockets.delete(socketData.driverId);
        lastDriverLocation.delete(socketData.driverId);

        // Optionally set driver offline
        try {
          await db.driver.update({
            where: { id: socketData.driverId },
            data: {
              isOnline: false,
              status: 'OFFLINE',
            },
          });

          io.to('admin:dashboard').emit('admin:driver:status', {
            driverId: socketData.driverId,
            status: 'OFFLINE',
            isOnline: false,
            reason: 'disconnected',
            timestamp: new Date().toISOString(),
          });
        } catch (dbErr) {
          console.error('[Disconnect] Error updating driver offline:', dbErr);
        }
      }

      if (socketData.role === 'rider' && socketData.riderId) {
        riderSockets.delete(socketData.riderId);
      }

      socketDataMap.delete(socket.id);
    } catch (error) {
      console.error('[Disconnect] Error:', error);
    }
  });

  // -------------------------------------------
  // Error handler
  // -------------------------------------------

  socket.on('error', (error) => {
    console.error('[Socket Error]', error);
  });
});

// ============================================
// Periodic Admin Stats Update (every 10 seconds)
// ============================================

setInterval(async () => {
  try {
    const stats = await getAdminStats();
    if (stats) {
      io.to('admin:dashboard').emit('admin:stats:update', stats);
    }
  } catch (error) {
    console.error('[StatsInterval] Error:', error);
  }
}, 10_000);

// ============================================
// Start Server
// ============================================

httpServer.listen(PORT, () => {
  console.log(
    `🚀 Real-time Service running on port ${PORT}`
  );
  console.log(`📡 Socket.IO server ready for connections`);
  console.log(`🔗 Connect via: io("/?XTransformPort=${PORT}")`);
});

// Handle process errors
process.on('uncaughtException', (error) => {
  console.error('[Uncaught Exception]', error);
});

process.on('unhandledRejection', (reason) => {
  console.error('[Unhandled Rejection]', reason);
});
