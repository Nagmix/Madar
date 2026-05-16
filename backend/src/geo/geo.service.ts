import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma.service';

/// Geo Service - Geospatial operations using PostGIS
/// Handles reverse geocoding, place search, service areas, and pricing zones
/// Uses PostGIS for point-in-polygon checks and geospatial queries
@Injectable()
export class GeoService {
  constructor(private prisma: PrismaService) {}

  /// Reverse geocode coordinates to a human-readable address
  /// Proxies to Google Maps Geocoding API
  async reverseGeocode(latitude: number, longitude: number) {
    // TODO: Integrate with Google Maps Geocoding API
    // const response = await axios.get(
    //   `https://maps.googleapis.com/maps/api/geocode/json?latlng=${latitude},${longitude}&key=${process.env.GOOGLE_MAPS_API_KEY}`
    // );

    // For now, return a structured placeholder
    // In production, parse the Google Maps response

    // Use PostGIS to check which service area / zone the point falls in
    const serviceArea = await this.findServiceArea(latitude, longitude);
    const pricingZone = await this.findPricingZone(latitude, longitude);

    return {
      latitude,
      longitude,
      // Placeholder address fields (would come from Google Maps in production)
      formattedAddress: `${latitude.toFixed(4)}, ${longitude.toFixed(4)}`,
      streetNumber: null,
      streetName: null,
      city: null,
      state: null,
      country: null,
      postalCode: null,
      serviceArea: serviceArea ? {
        id: serviceArea.id,
        name: serviceArea.name,
      } : null,
      pricingZone: pricingZone ? {
        id: pricingZone.id,
        name: pricingZone.name,
        pricingMultiplier: pricingZone.pricingMultiplier,
      } : null,
    };
  }

  /// Search places using Google Places API (Autocomplete)
  /// Proxies the request to Google Places API
  async searchPlaces(query: string, latitude?: number, longitude?: number, radius?: number) {
    // TODO: Integrate with Google Places Autocomplete API
    // const response = await axios.get(
    //   `https://maps.googleapis.com/maps/api/place/autocomplete/json?input=${query}&key=${process.env.GOOGLE_MAPS_API_KEY}`
    //   + (latitude ? `&location=${latitude},${longitude}` : '')
    //   + (radius ? `&radius=${radius}` : '')
    // );

    // For now, return empty results
    return {
      query,
      predictions: [],
      // In production, would return Google Places predictions:
      // predictions: response.data.predictions.map(p => ({
      //   placeId: p.place_id,
      //   description: p.description,
      //   mainText: p.structured_formatting.main_text,
      //   secondaryText: p.structured_formatting.secondary_text,
      //   types: p.types,
      // })),
    };
  }

  /// Get all active service areas (geofences of type SERVICE_AREA)
  async getServiceAreas() {
    const serviceAreas = await this.prisma.$queryRaw`
      SELECT 
        id,
        name,
        type,
        "pricingMultiplier",
        "isActive",
        ST_AsGeoJSON(polygon::geometry) as geojson,
        ST_Area(polygon::geography) as area_sqmeters
      FROM geo_fences
      WHERE type = 'SERVICE_AREA'
        AND "isActive" = true
      ORDER BY name ASC
    `;

    return serviceAreas.map((area: any) => ({
      id: area.id,
      name: area.name,
      type: area.type,
      pricingMultiplier: area.pricingMultiplier,
      isActive: area.isActive,
      areaSquareMeters: Math.round(area.area_sqmeters),
      geojson: area.geojson ? JSON.parse(area.geojson) : null,
    }));
  }

  /// Get all pricing zones (geofences with pricing multipliers)
  async getZones() {
    const zones = await this.prisma.$queryRaw`
      SELECT 
        id,
        name,
        type,
        "pricingMultiplier",
        "isActive",
        ST_AsGeoJSON(polygon::geometry) as geojson,
        ST_Area(polygon::geography) as area_sqmeters,
        ST_Centroid(polygon::geometry) as centroid
      FROM geo_fences
      WHERE type IN ('SURGE_ZONE', 'AIRPORT', 'CUSTOM')
        AND "isActive" = true
        AND "pricingMultiplier" IS NOT NULL
      ORDER BY "pricingMultiplier" DESC
    `;

    return zones.map((zone: any) => ({
      id: zone.id,
      name: zone.name,
      type: zone.type,
      pricingMultiplier: zone.pricingMultiplier,
      isActive: zone.isActive,
      areaSquareMeters: Math.round(zone.area_sqmeters),
      geojson: zone.geojson ? JSON.parse(zone.geojson) : null,
    }));
  }

  // ==================== PostGIS Helper Methods ====================

  /// Find which service area a point falls into using PostGIS point-in-polygon
  private async findServiceArea(latitude: number, longitude: number) {
    const result = await this.prisma.$queryRaw`
      SELECT id, name, type, "pricingMultiplier"
      FROM geo_fences
      WHERE type = 'SERVICE_AREA'
        AND "isActive" = true
        AND ST_Contains(
          polygon::geometry,
          ST_SetSRID(ST_MakePoint(${longitude}, ${latitude}), 4326)
        )
      LIMIT 1
    `;

    return result[0] || null;
  }

  /// Find which pricing zone a point falls into using PostGIS point-in-polygon
  private async findPricingZone(latitude: number, longitude: number) {
    const result = await this.prisma.$queryRaw`
      SELECT id, name, type, "pricingMultiplier"
      FROM geo_fences
      WHERE type IN ('SURGE_ZONE', 'AIRPORT', 'CUSTOM')
        AND "isActive" = true
        AND "pricingMultiplier" IS NOT NULL
        AND ST_Contains(
          polygon::geometry,
          ST_SetSRID(ST_MakePoint(${longitude}, ${latitude}), 4326)
        )
      ORDER BY "pricingMultiplier" DESC
      LIMIT 1
    `;

    return result[0] || null;
  }

  /// Check if a point is within any service area (used for trip validation)
  async isPointInServiceArea(latitude: number, longitude: number): Promise<boolean> {
    const result = await this.prisma.$queryRaw`
      SELECT COUNT(*) as count
      FROM geo_fences
      WHERE type = 'SERVICE_AREA'
        AND "isActive" = true
        AND ST_Contains(
          polygon::geometry,
          ST_SetSRID(ST_MakePoint(${longitude}, ${latitude}), 4326)
        )
    `;

    return Number(result[0]?.count) > 0;
  }

  /// Check if a point is within a restricted area (e.g., no-pickup zones)
  async isPointInRestrictedArea(latitude: number, longitude: number): Promise<boolean> {
    const result = await this.prisma.$queryRaw`
      SELECT COUNT(*) as count
      FROM geo_fences
      WHERE type = 'RESTRICTED'
        AND "isActive" = true
        AND ST_Contains(
          polygon::geometry,
          ST_SetSRID(ST_MakePoint(${longitude}, ${latitude}), 4326)
        )
    `;

    return Number(result[0]?.count) > 0;
  }

  /// Get the pricing multiplier for a given location
  /// Returns the highest multiplier if point falls in multiple zones
  async getPricingMultiplier(latitude: number, longitude: number): Promise<number> {
    const zone = await this.findPricingZone(latitude, longitude);
    return zone?.pricingMultiplier || 1.0;
  }

  /// Calculate distance between two points using PostGIS
  async calculateDistance(fromLat: number, fromLng: number, toLat: number, toLng: number): Promise<number> {
    const result = await this.prisma.$queryRaw`
      SELECT ST_Distance(
        ST_SetSRID(ST_MakePoint(${fromLng}, ${fromLat}), 4326)::geography,
        ST_SetSRID(ST_MakePoint(${toLng}, ${toLat}), 4326)::geography
      ) as distance_meters
    `;

    return Number(result[0]?.distance_meters) || 0;
  }
}
