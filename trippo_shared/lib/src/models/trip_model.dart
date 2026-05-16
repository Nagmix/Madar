import 'package:freezed_annotation/freezed_annotation.dart';
import '../constants/trip_states.dart';
import 'location_model.dart';
import 'user_model.dart';
import 'driver_model.dart';
import 'pricing_model.dart';

part 'trip_model.freezed.dart';
part 'trip_model.g.dart';

/// Trip model - the core entity representing a ride
@freezed
class TripModel with _$TripModel {
  const factory TripModel({
    required String id,
    required String riderId,
    required LocationModel pickupLocation,
    required LocationModel dropoffLocation,
    @Default(TripState.searchingDriver) TripState state,
    String? driverId,
    DriverModel? driver,
    UserModel? rider,
    @Default([]) List<TripStateLog> stateLog,
    RouteInfo? routeInfo,
    FareBreakdown? fareBreakdown,
    @Default(0) int estimatedDurationMinutes,
    @Default(0.0) double estimatedDistanceKm,
    String? cancellationReason,
    CancelledBy? cancelledBy,
    @Default(0.0) double riderRating,
    @Default(0.0) double driverRating,
    String? riderReview,
    String? driverReview,
    @Default('') String vehicleType,
    DateTime? driverAssignedAt,
    DateTime? driverArrivedAt,
    DateTime? tripStartedAt,
    DateTime? tripCompletedAt,
    DateTime? cancelledAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _TripModel;

  factory TripModel.fromJson(Map<String, dynamic> json) =>
      _$TripModelFromJson(json);
}

/// Trip state log entry - tracks state transitions
@freezed
class TripStateLog with _$TripStateLog {
  const factory TripStateLog({
    required TripState state,
    required DateTime timestamp,
    String? changedBy,
    String? reason,
    Map<String, dynamic>? metadata,
  }) = _TripStateLog;

  factory TripStateLog.fromJson(Map<String, dynamic> json) =>
      _$TripStateLogFromJson(json);
}

/// Who cancelled the trip
enum CancelledBy {
  @JsonValue('rider')
  rider,
  @JsonValue('driver')
  driver,
  @JsonValue('system')
  system,
  @JsonValue('timeout')
  timeout,
}

/// Create trip request
@freezed
class CreateTripRequest with _$CreateTripRequest {
  const factory CreateTripRequest({
    required double pickupLatitude,
    required double pickupLongitude,
    required String pickupAddress,
    required double dropoffLatitude,
    required double dropoffLongitude,
    required String dropoffAddress,
    required String vehicleType,
    String? promoCode,
    String? note,
    @Default(false) bool scheduleForLater,
    DateTime? scheduledAt,
  }) = _CreateTripRequest;

  factory CreateTripRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateTripRequestFromJson(json);
}

/// Trip rating request
@freezed
class TripRatingRequest with _$TripRatingRequest {
  const factory TripRatingRequest({
    required double rating,
    String? review,
    List<String>? tags,
  }) = _TripRatingRequest;

  factory TripRatingRequest.fromJson(Map<String, dynamic> json) =>
      _$TripRatingRequestFromJson(json);
}

/// Trip summary for history lists
@freezed
class TripSummary with _$TripSummary {
  const factory TripSummary({
    required String id,
    required String pickupAddress,
    required String dropoffAddress,
    required TripState state,
    required double fare,
    required DateTime createdAt,
    String? driverName,
    String? vehicleType,
    double? rating,
  }) = _TripSummary;

  factory TripSummary.fromJson(Map<String, dynamic> json) =>
      _$TripSummaryFromJson(json);
}
