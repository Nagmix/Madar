import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma.service';

/// Dispatch Service - Finds and assigns drivers to trips
/// Uses PostGIS for geospatial queries + Redis for real-time driver tracking
@Injectable()
export class DispatchService {
  constructor(private prisma: PrismaService) {}

  /// Find nearby available drivers using PostGIS geospatial query
  async findNearbyDrivers(lat: number, lng: number, radiusKm: number = 50, vehicleType?: string) {
    // PostGIS query: find drivers within radius, ordered by distance
    const drivers: any[] = await this.prisma.$queryRaw`
      SELECT 
        d.*,
        u.name,
        u.email,
        u.phone,
        v."name" as vehicle_name,
        v."plateNumber",
        v.type as vehicle_type,
        ST_Distance(
          d."currentLocation"::geography,
          ST_SetSRID(ST_MakePoint(${lng}, ${lat}), 4326)::geography
        ) as distance_meters,
        ST_AsText(d."currentLocation") as location_text
      FROM drivers d
      JOIN users u ON d."userId" = u.id
      JOIN vehicles v ON v."driverId" = d.id
      WHERE d.status = 'ONLINE'
        AND d."isAvailable" = true
        AND d."isDocumentsVerified" = true
        AND ST_DWithin(
          d."currentLocation"::geography,
          ST_SetSRID(ST_MakePoint(${lng}, ${lat}), 4326)::geography,
          ${radiusKm * 1000}
        )
        ${vehicleType ? PrismaService.sql`AND v.type = ${vehicleType}::"VehicleType"` : PrismaService.sql``}
      ORDER BY distance_meters ASC
      LIMIT 20
    `;

    return drivers;
  }

  /// Calculate driver score for dispatch ranking
  /// Score = proximity (40%) + rating (30%) + acceptance rate (20%) + ETA (10%)
  calculateDriverScore(driver: any, pickupLat: number, pickupLng: number): number {
    const distanceKm = (driver.distance_meters || 0) / 1000;
    
    // Proximity score: closer = higher (0-1)
    const proximityScore = Math.max(0, 1 - (distanceKm / 50));
    
    // Rating score: 5-star rating normalized (0-1)
    const ratingScore = (driver.averageRating || 0) / 5;
    
    // Acceptance rate score (0-1)
    const acceptanceScore = (driver.acceptanceRate || 0) / 100;
    
    // ETA estimation (simple: distance / avg speed 30km/h)
    const etaMinutes = (distanceKm / 30) * 60;
    const etaScore = Math.max(0, 1 - (etaMinutes / 30));
    
    // Weighted combination
    return (proximityScore * 0.4) + (ratingScore * 0.3) + (acceptanceScore * 0.2) + (etaScore * 0.1);
  }

  /// Start driver search for a trip - sends notifications to top drivers
  async startDriverSearch(tripId: string, maxRetries: number = 3) {
    const trip = await this.prisma.trip.findUnique({ where: { id: tripId } });
    if (!trip) return;

    // Find nearby drivers
    const drivers = await this.findNearbyDrivers(
      trip.pickupLat,
      trip.pickupLng,
      50,
      trip.vehicleType,
    );

    // Score and rank drivers
    const scoredDrivers = drivers
      .map((driver: any) => ({
        ...driver,
        score: this.calculateDriverScore(driver, trip.pickupLat, trip.pickupLng),
      }))
      .sort((a: any, b: any) => b.score - a.score);

    // TODO: Send notifications to top 5 drivers via Socket.IO
    // TODO: If no acceptance within timeout, try next batch
    // TODO: If all drivers busy, mark trip as all_drivers_busy

    return { tripId, candidatesFound: scoredDrivers.length, topDrivers: scoredDrivers.slice(0, 5) };
  }
}
