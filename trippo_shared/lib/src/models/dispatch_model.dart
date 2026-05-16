import 'package:freezed_annotation/freezed_annotation.dart';
import '../constants/trip_states.dart';
import 'driver_model.dart';

part 'dispatch_model.freezed.dart';
part 'dispatch_model.g.dart';

/// Dispatch request - when a rider requests a ride
@freezed
class DispatchRequest with _$DispatchRequest {
  const factory DispatchRequest({
    required String tripId,
    required double pickupLatitude,
    required double pickupLongitude,
    required double dropoffLatitude,
    required double dropoffLongitude,
    required String vehicleType,
    required String riderId,
    @Default(1) int retryCount,
    @Default(DispatchStatus.pending) DispatchStatus status,
    DateTime? createdAt,
  }) = _DispatchRequest;

  factory DispatchRequest.fromJson(Map<String, dynamic> json) =>
      _$DispatchRequestFromJson(json);
}

enum DispatchStatus {
  @JsonValue('pending')
  pending,
  @JsonValue('searching')
  searching,
  @JsonValue('driver_notified')
  driverNotified,
  @JsonValue('driver_accepted')
  driverAccepted,
  @JsonValue('all_drivers_busy')
  allDriversBusy,
  @JsonValue('timeout')
  timeout,
  @JsonValue('cancelled')
  cancelled,
}

/// Dispatch result - outcome of dispatching to drivers
@freezed
class DispatchResult with _$DispatchResult {
  const factory DispatchResult({
    required String tripId,
    required DispatchStatus status,
    DriverModel? assignedDriver,
    DriverScore? driverScore,
    @Default([]) List<String> notifiedDriverIds,
    @Default([]) List<String> rejectedDriverIds,
    String? failureReason,
    int? searchDurationSeconds,
  }) = _DispatchResult;

  factory DispatchResult.fromJson(Map<String, dynamic> json) =>
      _$DispatchResultFromJson(json);
}

/// Driver dispatch notification (sent to driver app)
@freezed
class DriverDispatchNotification with _$DriverDispatchNotification {
  const factory DriverDispatchNotification({
    required String tripId,
    required String riderName,
    required double pickupLatitude,
    required double pickupLongitude,
    required String pickupAddress,
    required double dropoffLatitude,
    required double dropoffLongitude,
    required String dropoffAddress,
    required double estimatedFare,
    required double distanceToPickupKm,
    required int estimatedEtaMinutes,
    required String vehicleType,
    required int responseTimeoutSeconds,
  }) = _DriverDispatchNotification;

  factory DriverDispatchNotification.fromJson(Map<String, dynamic> json) =>
      _$DriverDispatchNotificationFromJson(json);
}

/// Driver response to dispatch
@freezed
class DriverDispatchResponse with _$DriverDispatchResponse {
  const factory DriverDispatchResponse({
    required String tripId,
    required String driverId,
    required DispatchResponseType responseType,
    String? reason,
  }) = _DriverDispatchResponse;

  factory DriverDispatchResponse.fromJson(Map<String, dynamic> json) =>
      _$DriverDispatchResponseFromJson(json);
}

enum DispatchResponseType {
  @JsonValue('accepted')
  accepted,
  @JsonValue('rejected')
  rejected,
  @JsonValue('timeout')
  timeout,
  @JsonValue('ignored')
  ignored,
}
