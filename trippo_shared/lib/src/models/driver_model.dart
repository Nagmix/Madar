import 'package:freezed_annotation/freezed_annotation.dart';
import 'location_model.dart';
import 'vehicle_model.dart';

part 'driver_model.freezed.dart';
part 'driver_model.g.dart';

/// Driver model - represents a driver in the system
@freezed
class DriverModel with _$DriverModel {
  const factory DriverModel({
    required String id,
    required String email,
    required String name,
    String? phone,
    String? countryCode,
    String? profileImageUrl,
    required VehicleModel vehicle,
    @Default(DriverStatus.offline) DriverStatus status,
    LocationModel? currentLocation,
    LocationModel? lastKnownLocation,
    @Default(0.0) double averageRating,
    @Default(0) int totalTrips,
    @Default(0) int completedTrips,
    @Default(0) int cancelledTrips,
    @Default(0.0) double acceptanceRate,
    @Default(0.0) double cancellationRate,
    String? fcmToken,
    @Default(false) bool isEmailVerified,
    @Default(false) bool isPhoneVerified,
    @Default(false) bool isDocumentsVerified,
    @Default(false) bool isBanned,
    @Default(false) bool isActive,
    @Default(0) double walletBalance,
    @Default(0) double totalEarnings,
    DateTime? lastOnlineAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _DriverModel;

  factory DriverModel.fromJson(Map<String, dynamic> json) =>
      _$DriverModelFromJson(json);
}

/// Driver status enum
enum DriverStatus {
  @JsonValue('offline')
  offline,
  @JsonValue('online')
  online,
  @JsonValue('busy')
  busy,
  @JsonValue('suspended')
  suspended,
}

/// Driver document model
@freezed
class DriverDocument with _$DriverDocument {
  const factory DriverDocument({
    required String id,
    required String driverId,
    required DocumentType type,
    required String documentUrl,
    @Default(DocumentStatus.pending) DocumentStatus status,
    String? rejectionReason,
    DateTime? uploadedAt,
    DateTime? verifiedAt,
    DateTime? expiresAt,
  }) = _DriverDocument;

  factory DriverDocument.fromJson(Map<String, dynamic> json) =>
      _$DriverDocumentFromJson(json);
}

enum DocumentType {
  @JsonValue('driving_license')
  drivingLicense,
  @JsonValue('vehicle_registration')
  vehicleRegistration,
  @JsonValue('insurance')
  insurance,
  @JsonValue('national_id')
  nationalId,
  @JsonValue('background_check')
  backgroundCheck,
}

enum DocumentStatus {
  @JsonValue('pending')
  pending,
  @JsonValue('verified')
  verified,
  @JsonValue('rejected')
  rejected,
  @JsonValue('expired')
  expired,
}

/// Driver scoring model for dispatch engine
@freezed
class DriverScore with _$DriverScore {
  const factory DriverScore({
    required String driverId,
    required double totalScore,
    required double proximityScore,
    required double ratingScore,
    required double acceptanceRateScore,
    required double etaScore,
    required int estimatedEtaMinutes,
    required double distanceToPickupKm,
  }) = _DriverScore;

  factory DriverScore.fromJson(Map<String, dynamic> json) =>
      _$DriverScoreFromJson(json);
}
