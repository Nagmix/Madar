// ============================================
// Dispatch Engine - Smart Driver Matching
// ============================================

import { db } from './db';

// -------------------------------------------
// Types
// -------------------------------------------

export interface DriverCandidate {
  id: string;
  name: string;
  rating: number;
  acceptanceRate: number;
  totalTrips: number;
  vehicleType: string;
  latitude: number;
  longitude: number;
  distanceToPickup: number; // km
  lastTripEndedAt: Date | null;
  score: number;
}

export interface DispatchRequest {
  tripId: string;
  pickupLat: number;
  pickupLng: number;
  vehicleTypeRequested: string;
  radiusKm?: number;
}

export interface DispatchResult {
  matchedDrivers: DriverCandidate[];
  radiusUsed: number;
  attempt: number;
}

// -------------------------------------------
// Haversine Distance Formula
// -------------------------------------------

/**
 * Calculate the distance between two geo points using the Haversine formula.
 * Returns distance in kilometers.
 */
export function haversineDistance(
  lat1: number,
  lng1: number,
  lat2: number,
  lng2: number
): number {
  const R = 6371; // Earth radius in km
  const dLat = toRad(lat2 - lat1);
  const dLng = toRad(lng2 - lng1);
  const a =
    Math.sin(dLat / 2) * Math.sin(dLat / 2) +
    Math.cos(toRad(lat1)) *
      Math.cos(toRad(lat2)) *
      Math.sin(dLng / 2) *
      Math.sin(dLng / 2);
  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
  return R * c;
}

function toRad(deg: number): number {
  return (deg * Math.PI) / 180;
}

// -------------------------------------------
// Scoring Algorithm
// -------------------------------------------

/**
 * Score a driver candidate based on multiple factors.
 * Higher score = better match.
 * Max score = 100.
 *
 * Weights:
 *  - Distance:    40 points (closer is better)
 *  - Acceptance:  25 points (higher acceptance rate is better)
 *  - Rating:      15 points (higher rating is better)
 *  - Vehicle:     10 points (exact type match)
 *  - Wait time:   10 points (drivers waiting longer get priority)
 */
export function scoreDriver(
  driver: DriverCandidate,
  maxDistance: number
): number {
  let score = 0;

  // 1. Distance score (0-40): closer drivers get higher scores
  // Linear decay from 40 (0km) to 0 (maxDistance)
  const distanceScore = Math.max(0, 40 * (1 - driver.distanceToPickup / maxDistance));
  score += distanceScore;

  // 2. Acceptance rate score (0-25)
  const acceptanceScore = driver.acceptanceRate * 25;
  score += acceptanceScore;

  // 3. Rating score (0-15): rating is 0-5, normalize to 0-15
  const ratingScore = (driver.rating / 5) * 15;
  score += ratingScore;

  // 4. Vehicle type match (0 or 10)
  const vehicleMatch = driver.vehicleType === driver.vehicleType ? 10 : 0;
  // We check against the requested type stored on the candidate
  // Actually we need the requested type - we'll set it later
  score += vehicleMatch;

  // 5. Wait time score (0-10): prefer drivers who have been waiting longer
  if (driver.lastTripEndedAt) {
    const minutesSinceLastTrip =
      (Date.now() - new Date(driver.lastTripEndedAt).getTime()) / (1000 * 60);
    // Max out at 60 minutes of waiting
    const waitScore = Math.min(10, (minutesSinceLastTrip / 60) * 10);
    score += waitScore;
  } else {
    // Driver has never completed a trip - give medium priority
    score += 5;
  }

  return Math.round(score * 100) / 100;
}

/**
 * Score a driver with the requested vehicle type context.
 */
export function scoreDriverWithContext(
  driver: Omit<DriverCandidate, 'score' | 'vehicleType'> & { vehicleType: string },
  requestedVehicleType: string,
  maxDistance: number
): DriverCandidate {
  let score = 0;

  // 1. Distance score (0-40)
  const distanceScore = Math.max(0, 40 * (1 - driver.distanceToPickup / maxDistance));
  score += distanceScore;

  // 2. Acceptance rate score (0-25)
  const acceptanceScore = driver.acceptanceRate * 25;
  score += acceptanceScore;

  // 3. Rating score (0-15)
  const ratingScore = (driver.rating / 5) * 15;
  score += ratingScore;

  // 4. Vehicle type match (0 or 10)
  const vehicleMatch = driver.vehicleType === requestedVehicleType ? 10 : 0;
  score += vehicleMatch;

  // 5. Wait time score (0-10)
  if (driver.lastTripEndedAt) {
    const minutesSinceLastTrip =
      (Date.now() - new Date(driver.lastTripEndedAt).getTime()) / (1000 * 60);
    const waitScore = Math.min(10, (minutesSinceLastTrip / 60) * 10);
    score += waitScore;
  } else {
    score += 5;
  }

  return {
    ...driver,
    score: Math.round(score * 100) / 100,
  };
}

// -------------------------------------------
// Find Nearby Drivers
// -------------------------------------------

/**
 * Find all online drivers within a given radius of the pickup location.
 * Uses the latest DriverLocation for each driver.
 */
export async function findNearbyDrivers(
  pickupLat: number,
  pickupLng: number,
  radiusKm: number,
  requestedVehicleType: string
): Promise<DriverCandidate[]> {
  // Get all online drivers with their latest location and vehicle info
  const onlineDrivers = await db.driver.findMany({
    where: {
      isOnline: true,
      status: 'ONLINE',
    },
    include: {
      driverLocations: {
        orderBy: { createdAt: 'desc' },
        take: 1,
      },
      vehicle: true,
    },
  });

  const candidates: DriverCandidate[] = [];

  for (const driver of onlineDrivers) {
    const latestLocation = driver.driverLocations[0];
    if (!latestLocation) continue;

    // Skip mocked GPS locations
    if (latestLocation.isMocked) continue;

    const distance = haversineDistance(
      pickupLat,
      pickupLng,
      latestLocation.latitude,
      latestLocation.longitude
    );

    // Filter by radius
    if (distance > radiusKm) continue;

    // Get the last completed trip time for wait-time scoring
    const lastCompletedTrip = await db.trip.findFirst({
      where: {
        driverId: driver.id,
        status: { in: ['TRIP_COMPLETED', 'PAYMENT_COMPLETED'] },
      },
      orderBy: { tripCompletedAt: 'desc' },
      select: { tripCompletedAt: true },
    });

    const candidateData = {
      id: driver.id,
      name: driver.name,
      rating: driver.rating,
      acceptanceRate: driver.acceptanceRate,
      totalTrips: driver.totalTrips,
      vehicleType: driver.vehicle?.type || 'SEDAN',
      latitude: latestLocation.latitude,
      longitude: latestLocation.longitude,
      distanceToPickup: distance,
      lastTripEndedAt: lastCompletedTrip?.tripCompletedAt || null,
    };

    const scored = scoreDriverWithContext(
      candidateData,
      requestedVehicleType,
      radiusKm
    );

    candidates.push(scored);
  }

  // Sort by score descending
  candidates.sort((a, b) => b.score - a.score);

  return candidates;
}

// -------------------------------------------
// Dispatch Algorithm
// -------------------------------------------

const DEFAULT_RADIUS_KM = 5;
const EXPAND_RADIUS_KM = 10;
const MAX_RADIUS_KM = 30;
const MAX_ATTEMPTS = 3;
const TOP_N_DRIVERS = 3;
const OFFER_TIMEOUT_MS = 30_000; // 30 seconds

/**
 * Run the dispatch algorithm for a trip request.
 * Returns the top N drivers to offer the trip to.
 */
export async function dispatchTrip(
  request: DispatchRequest
): Promise<DispatchResult> {
  const {
    tripId,
    pickupLat,
    pickupLng,
    vehicleTypeRequested,
    radiusKm = DEFAULT_RADIUS_KM,
  } = request;

  let attempt = 1;
  let currentRadius = radiusKm;

  while (attempt <= MAX_ATTEMPTS) {
    console.log(
      `[Dispatch] Attempt ${attempt} for trip ${tripId}, radius: ${currentRadius}km`
    );

    const candidates = await findNearbyDrivers(
      pickupLat,
      pickupLng,
      currentRadius,
      vehicleTypeRequested
    );

    if (candidates.length > 0) {
      // Take top N drivers
      const matchedDrivers = candidates.slice(0, TOP_N_DRIVERS);
      console.log(
        `[Dispatch] Found ${candidates.length} candidates, offering to top ${matchedDrivers.length} drivers`
      );
      return {
        matchedDrivers,
        radiusUsed: currentRadius,
        attempt,
      };
    }

    // No drivers found, expand radius
    attempt++;
    currentRadius = Math.min(currentRadius + EXPAND_RADIUS_KM, MAX_RADIUS_KM);
  }

  // No drivers found after all attempts
  console.log(
    `[Dispatch] No drivers found for trip ${tripId} after ${MAX_ATTEMPTS} attempts`
  );
  return {
    matchedDrivers: [],
    radiusUsed: currentRadius,
    attempt,
  };
}

// -------------------------------------------
// Offer Management
// -------------------------------------------

// Track active dispatch offers: tripId -> { driverIds, timeout, attempt }
interface ActiveOffer {
  tripId: string;
  driverIds: string[];
  timeout: ReturnType<typeof setTimeout>;
  attempt: number;
  vehicleTypeRequested: string;
  pickupLat: number;
  pickupLng: number;
}

const activeOffers = new Map<string, ActiveOffer>();

/**
 * Get the offer timeout duration in ms
 */
export function getOfferTimeout(): number {
  return OFFER_TIMEOUT_MS;
}

/**
 * Get maximum dispatch attempts
 */
export function getMaxAttempts(): number {
  return MAX_ATTEMPTS;
}

/**
 * Get number of top drivers to offer to simultaneously
 */
export function getTopNDrivers(): number {
  return TOP_N_DRIVERS;
}

/**
 * Store an active dispatch offer
 */
export function setActiveOffer(
  tripId: string,
  offer: ActiveOffer
): void {
  // Clear existing offer if any
  if (activeOffers.has(tripId)) {
    clearTimeout(activeOffers.get(tripId)!.timeout);
  }
  activeOffers.set(tripId, offer);
}

/**
 * Get an active dispatch offer
 */
export function getActiveOffer(tripId: string): ActiveOffer | undefined {
  return activeOffers.get(tripId);
}

/**
 * Remove an active dispatch offer
 */
export function removeActiveOffer(tripId: string): ActiveOffer | undefined {
  const offer = activeOffers.get(tripId);
  if (offer) {
    clearTimeout(offer.timeout);
    activeOffers.delete(tripId);
  }
  return offer;
}

/**
 * Check if a trip has an active dispatch offer
 */
export function hasActiveOffer(tripId: string): boolean {
  return activeOffers.has(tripId);
}
