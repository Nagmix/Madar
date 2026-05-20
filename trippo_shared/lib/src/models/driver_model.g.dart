// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'driver_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

/// Decode driver status from either uppercase (Prisma) or lowercase (expected) format
DriverStatus _decodeDriverStatus(dynamic value) {
  if (value == null) return DriverStatus.offline;
  final s = value.toString().toLowerCase();
  return switch (s) {
    'online' => DriverStatus.online,
    'busy' => DriverStatus.busy,
    'suspended' => DriverStatus.suspended,
    _ => DriverStatus.offline,
  };
}

_$DriverModelImpl _$$DriverModelImplFromJson(Map<String, dynamic> json) =>
    _$DriverModelImpl(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String?,
      countryCode: json['countryCode'] as String?,
      profileImageUrl: json['profileImageUrl'] as String?,
      vehicle: json['vehicle'] == null ? const VehicleModel(id: '', name: '', plateNumber: '', type: VehicleType.sedan, seats: 4) : VehicleModel.fromJson(json['vehicle'] as Map<String, dynamic>),
      status: _decodeDriverStatus(json['status']),
      currentLocation: json['currentLocation'] == null
          ? null
          : LocationModel.fromJson(
              json['currentLocation'] as Map<String, dynamic>),
      lastKnownLocation: json['lastKnownLocation'] == null
          ? null
          : LocationModel.fromJson(
              json['lastKnownLocation'] as Map<String, dynamic>),
      averageRating: (json['averageRating'] as num?)?.toDouble() ?? 0.0,
      totalTrips: (json['totalTrips'] as num?)?.toInt() ?? 0,
      completedTrips: (json['completedTrips'] as num?)?.toInt() ?? 0,
      cancelledTrips: (json['cancelledTrips'] as num?)?.toInt() ?? 0,
      acceptanceRate: (json['acceptanceRate'] as num?)?.toDouble() ?? 0.0,
      cancellationRate: (json['cancellationRate'] as num?)?.toDouble() ?? 0.0,
      fcmToken: json['fcmToken'] as String?,
      isEmailVerified: json['isEmailVerified'] as bool? ?? false,
      isPhoneVerified: json['isPhoneVerified'] as bool? ?? false,
      isDocumentsVerified: json['isDocumentsVerified'] as bool? ?? false,
      isBanned: json['isBanned'] as bool? ?? false,
      isActive: json['isActive'] as bool? ?? false,
      walletBalance: (json['walletBalance'] as num?)?.toDouble() ?? 0,
      totalEarnings: (json['totalEarnings'] as num?)?.toDouble() ?? 0,
      lastOnlineAt: json['lastOnlineAt'] == null
          ? null
          : DateTime.parse(json['lastOnlineAt'] as String),
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$DriverModelImplToJson(_$DriverModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'name': instance.name,
      'phone': instance.phone,
      'countryCode': instance.countryCode,
      'profileImageUrl': instance.profileImageUrl,
      'vehicle': instance.vehicle,
      'status': _$DriverStatusEnumMap[instance.status]!,
      'currentLocation': instance.currentLocation,
      'lastKnownLocation': instance.lastKnownLocation,
      'averageRating': instance.averageRating,
      'totalTrips': instance.totalTrips,
      'completedTrips': instance.completedTrips,
      'cancelledTrips': instance.cancelledTrips,
      'acceptanceRate': instance.acceptanceRate,
      'cancellationRate': instance.cancellationRate,
      'fcmToken': instance.fcmToken,
      'isEmailVerified': instance.isEmailVerified,
      'isPhoneVerified': instance.isPhoneVerified,
      'isDocumentsVerified': instance.isDocumentsVerified,
      'isBanned': instance.isBanned,
      'isActive': instance.isActive,
      'walletBalance': instance.walletBalance,
      'totalEarnings': instance.totalEarnings,
      'lastOnlineAt': instance.lastOnlineAt?.toIso8601String(),
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

const _$DriverStatusEnumMap = {
  DriverStatus.offline: 'offline',
  DriverStatus.online: 'online',
  DriverStatus.busy: 'busy',
  DriverStatus.suspended: 'suspended',
};

_$DriverDocumentImpl _$$DriverDocumentImplFromJson(Map<String, dynamic> json) =>
    _$DriverDocumentImpl(
      id: json['id'] as String,
      driverId: json['driverId'] as String,
      type: $enumDecode(_$DocumentTypeEnumMap, json['type']),
      documentUrl: json['documentUrl'] as String,
      status: $enumDecodeNullable(_$DocumentStatusEnumMap, json['status']) ??
          DocumentStatus.pending,
      rejectionReason: json['rejectionReason'] as String?,
      uploadedAt: json['uploadedAt'] == null
          ? null
          : DateTime.parse(json['uploadedAt'] as String),
      verifiedAt: json['verifiedAt'] == null
          ? null
          : DateTime.parse(json['verifiedAt'] as String),
      expiresAt: json['expiresAt'] == null
          ? null
          : DateTime.parse(json['expiresAt'] as String),
    );

Map<String, dynamic> _$$DriverDocumentImplToJson(
        _$DriverDocumentImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'driverId': instance.driverId,
      'type': _$DocumentTypeEnumMap[instance.type]!,
      'documentUrl': instance.documentUrl,
      'status': _$DocumentStatusEnumMap[instance.status]!,
      'rejectionReason': instance.rejectionReason,
      'uploadedAt': instance.uploadedAt?.toIso8601String(),
      'verifiedAt': instance.verifiedAt?.toIso8601String(),
      'expiresAt': instance.expiresAt?.toIso8601String(),
    };

const _$DocumentTypeEnumMap = {
  DocumentType.drivingLicense: 'driving_license',
  DocumentType.vehicleRegistration: 'vehicle_registration',
  DocumentType.insurance: 'insurance',
  DocumentType.nationalId: 'national_id',
  DocumentType.backgroundCheck: 'background_check',
};

const _$DocumentStatusEnumMap = {
  DocumentStatus.pending: 'pending',
  DocumentStatus.verified: 'verified',
  DocumentStatus.rejected: 'rejected',
  DocumentStatus.expired: 'expired',
};

_$DriverScoreImpl _$$DriverScoreImplFromJson(Map<String, dynamic> json) =>
    _$DriverScoreImpl(
      driverId: json['driverId'] as String,
      totalScore: (json['totalScore'] as num).toDouble(),
      proximityScore: (json['proximityScore'] as num).toDouble(),
      ratingScore: (json['ratingScore'] as num).toDouble(),
      acceptanceRateScore: (json['acceptanceRateScore'] as num).toDouble(),
      etaScore: (json['etaScore'] as num).toDouble(),
      estimatedEtaMinutes: (json['estimatedEtaMinutes'] as num).toInt(),
      distanceToPickupKm: (json['distanceToPickupKm'] as num).toDouble(),
    );

Map<String, dynamic> _$$DriverScoreImplToJson(_$DriverScoreImpl instance) =>
    <String, dynamic>{
      'driverId': instance.driverId,
      'totalScore': instance.totalScore,
      'proximityScore': instance.proximityScore,
      'ratingScore': instance.ratingScore,
      'acceptanceRateScore': instance.acceptanceRateScore,
      'etaScore': instance.etaScore,
      'estimatedEtaMinutes': instance.estimatedEtaMinutes,
      'distanceToPickupKm': instance.distanceToPickupKm,
    };
