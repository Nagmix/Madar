import 'package:freezed_annotation/freezed_annotation.dart';

part 'location_model.freezed.dart';
part 'location_model.g.dart';

/// Represents a geographic location with address information
@freezed
class LocationModel with _$LocationModel {
  const factory LocationModel({
    required double latitude,
    required double longitude,
    String? address,
    String? name,
    String? placeId,
    double? accuracy,
    double? heading,
    double? speed,
    DateTime? timestamp,
  }) = _LocationModel;

  factory LocationModel.fromJson(Map<String, dynamic> json) =>
      _$LocationModelFromJson(json);
}

/// Represents a geographic bounding box for map camera
@freezed
class GeoBounds with _$GeoBounds {
  const factory GeoBounds({
    required double northeastLat,
    required double northeastLng,
    required double southwestLat,
    required double southwestLng,
  }) = _GeoBounds;

  factory GeoBounds.fromJson(Map<String, dynamic> json) =>
      _$GeoBoundsFromJson(json);
}

/// Represents a geo-fence zone
@freezed
class GeoFence with _$GeoFence {
  const factory GeoFence({
    required String id,
    required String name,
    required List<LocationModel> polygon,
    required GeoFenceType type,
    double? pricingMultiplier,
    bool? isActive,
  }) = _GeoFence;

  factory GeoFence.fromJson(Map<String, dynamic> json) =>
      _$GeoFenceFromJson(json);
}

enum GeoFenceType {
  @JsonValue('service_area')
  serviceArea,
  @JsonValue('restricted')
  restricted,
  @JsonValue('surge_zone')
  surgeZone,
  @JsonValue('airport')
  airport,
  @JsonValue('custom')
  custom,
}

/// Route information between two points
@freezed
class RouteInfo with _$RouteInfo {
  const factory RouteInfo({
    required LocationModel origin,
    required LocationModel destination,
    required int distanceMeters,
    required int durationSeconds,
    required String encodedPolyline,
    String? distanceText,
    String? durationText,
    List<RouteStep>? steps,
  }) = _RouteInfo;

  factory RouteInfo.fromJson(Map<String, dynamic> json) =>
      _$RouteInfoFromJson(json);
}

/// A single step in a route
@freezed
class RouteStep with _$RouteStep {
  const factory RouteStep({
    required String instruction,
    required int distanceMeters,
    required int durationSeconds,
    required LocationModel startLocation,
    required LocationModel endLocation,
    String? maneuver,
  }) = _RouteStep;

  factory RouteStep.fromJson(Map<String, dynamic> json) =>
      _$RouteStepFromJson(json);
}
