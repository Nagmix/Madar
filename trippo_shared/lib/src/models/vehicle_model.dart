import 'package:freezed_annotation/freezed_annotation.dart';

part 'vehicle_model.freezed.dart';
part 'vehicle_model.g.dart';

/// Vehicle model - represents a driver's vehicle
@freezed
class VehicleModel with _$VehicleModel {
  const factory VehicleModel({
    required String id,
    required String name,
    required String plateNumber,
    required VehicleType type,
    required int seats,
    String? color,
    String? model,
    String? year,
    String? imageUrl,
    @Default(false) bool isApproved,
  }) = _VehicleModel;

  factory VehicleModel.fromJson(Map<String, dynamic> json) =>
      _$VehicleModelFromJson(json);
}

/// Vehicle type enum with display info
enum VehicleType {
  @JsonValue('motorcycle')
  motorcycle(
    displayName: 'Motorcycle',
    icon: '🏍️',
    baseMultiplier: 0.8,
    seats: 1,
  ),
  @JsonValue('sedan')
  sedan(
    displayName: 'Sedan',
    icon: '🚗',
    baseMultiplier: 1.0,
    seats: 4,
  ),
  @JsonValue('suv')
  suv(
    displayName: 'SUV',
    icon: '🚙',
    baseMultiplier: 1.5,
    seats: 6,
  ),
  @JsonValue('van')
  van(
    displayName: 'Van',
    icon: '🚐',
    baseMultiplier: 1.8,
    seats: 8,
  ),
  @JsonValue('luxury')
  luxury(
    displayName: 'Luxury',
    icon: '✨',
    baseMultiplier: 2.5,
    seats: 4,
  );

  const VehicleType({
    required this.displayName,
    required this.icon,
    required this.baseMultiplier,
    required this.seats,
  });

  final String displayName;
  final String icon;
  final double baseMultiplier;
  final int seats;

  static VehicleType fromString(String value) {
    return VehicleType.values.firstWhere(
      (type) => type.name == value.toLowerCase(),
      orElse: () => VehicleType.sedan,
    );
  }
}

/// Vehicle type info for selection UI
@freezed
class VehicleTypeInfo with _$VehicleTypeInfo {
  const factory VehicleTypeInfo({
    required VehicleType type,
    required String displayName,
    required String description,
    required double baseFare,
    required double perKmRate,
    required double perMinuteRate,
    required double minimumFare,
    required int estimatedArrivalMinutes,
    required String iconAsset,
  }) = _VehicleTypeInfo;

  factory VehicleTypeInfo.fromJson(Map<String, dynamic> json) =>
      _$VehicleTypeInfoFromJson(json);
}
