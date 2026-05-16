/// Dispatch Scoring Service - Advanced Driver Matching Algorithm
///
/// Replaces the naive "nearest driver" approach with a multi-factor scoring
/// system that considers multiple dimensions to find the best driver for
/// each trip request.
///
/// Scoring Factors:
/// 1. **Distance** (40% weight): Geospatial proximity to pickup point.
/// 2. **ETA** (20% weight): Estimated time of arrival (traffic-aware).
/// 3. **Driver Rating** (15% weight): Historical rider satisfaction score.
/// 4. **Acceptance Rate** (10% weight): How often the driver accepts rides.
/// 5. **Cancellation Rate** (5% weight): How often the driver cancels after accepting.
/// 6. **Current Workload** (5% weight): How many trips completed recently.
/// 7. **Idle Time** (5% weight): How long the driver has been waiting.
///
/// The scoring algorithm is computed on the NestJS backend using PostGIS
/// for geospatial calculations. This Flutter-side service provides the
/// scoring formula and local computation for:
/// - Pre-filtering drivers before sending to the backend
/// - Debugging and testing
/// - Offline estimation of dispatch quality
///
/// Backend Implementation (NestJS Dispatch Module):
/// ```sql
/// SELECT driver_id,
///   (0.40 * distance_score) +
///   (0.20 * eta_score) +
///   (0.15 * rating_score) +
///   (0.10 * acceptance_score) +
///   (0.05 * cancellation_score) +
///   (0.05 * workload_score) +
///   (0.05 * idle_score) AS total_score
/// FROM (
///   SELECT d.driver_id,
///     ST_Distance(d.current_location, pickup_point) AS distance,
///     ...
///   FROM drivers d
///   WHERE ST_DWithin(d.current_location, pickup_point, 50000)
///     AND d.status = 'ONLINE'
///     AND d.vehicle_type = ANY(requested_types)
///   ORDER BY total_score DESC
///   LIMIT 5
/// ) scored_drivers;
/// ```
library;

import '../constants/app_constants.dart';

// ============================================================================
// Driver Scoring Profile
// ============================================================================

/// Complete profile of a driver used for scoring in the dispatch algorithm.
///
/// This data is fetched from the NestJS backend's PostGIS queries and
/// combined with driver statistics from the database.
class DriverScoringProfile {
  final String driverId;
  final String name;

  // Geospatial data
  final double currentLatitude;
  final double currentLongitude;
  final double distanceToPickupKm;
  final int estimatedArrivalSeconds;

  // Performance metrics
  final double averageRating;       // 0.0 - 5.0
  final double acceptanceRate;      // 0.0 - 1.0
  final double cancellationRate;    // 0.0 - 1.0
  final int totalTripsCompleted;
  final int recentTripsCount;       // Trips in last 24 hours
  final int idleTimeMinutes;        // Minutes since last trip completed

  // Vehicle info
  final String vehicleType;
  final bool isAvailable;

  const DriverScoringProfile({
    required this.driverId,
    required this.name,
    required this.currentLatitude,
    required this.currentLongitude,
    required this.distanceToPickupKm,
    required this.estimatedArrivalSeconds,
    required this.averageRating,
    required this.acceptanceRate,
    required this.cancellationRate,
    required this.totalTripsCompleted,
    required this.recentTripsCount,
    required this.idleTimeMinutes,
    required this.vehicleType,
    this.isAvailable = true,
  });
}

// ============================================================================
// Scoring Weights
// ============================================================================

/// Configurable weights for each scoring factor.
///
/// Weights must sum to 1.0. These can be adjusted via the NestJS admin
/// dashboard without requiring a Flutter app update.
class ScoringWeights {
  final double distance;
  final double eta;
  final double rating;
  final double acceptanceRate;
  final double cancellationRate;
  final double workload;
  final double idleTime;

  const ScoringWeights({
    this.distance = 0.40,
    this.eta = 0.20,
    this.rating = 0.15,
    this.acceptanceRate = 0.10,
    this.cancellationRate = 0.05,
    this.workload = 0.05,
    this.idleTime = 0.05,
  });

  /// Validate that weights sum to 1.0 (within floating-point tolerance).
  bool get isValid => (distance + eta + rating + acceptanceRate +
      cancellationRate + workload + idleTime - 1.0).abs() < 0.01;

  /// Default weights optimized for urban ride-hailing.
  static const ScoringWeights defaults = ScoringWeights();

  /// Weights optimized for high-demand periods (prioritize proximity).
  static const ScoringWeights surgePeriod = ScoringWeights(
    distance: 0.55,
    eta: 0.25,
    rating: 0.10,
    acceptanceRate: 0.05,
    cancellationRate: 0.02,
    workload: 0.02,
    idleTime: 0.01,
  );

  /// Weights optimized for quality (prioritize rating and reliability).
  static const ScoringWeights qualityFirst = ScoringWeights(
    distance: 0.25,
    eta: 0.15,
    rating: 0.30,
    acceptanceRate: 0.15,
    cancellationRate: 0.08,
    workload: 0.04,
    idleTime: 0.03,
  );
}

// ============================================================================
// Scoring Configuration
// ============================================================================

/// Configuration for the dispatch scoring algorithm.
class ScoringConfig {
  /// Maximum search radius in kilometers.
  final double maxSearchRadiusKm;

  /// Minimum driver rating to be eligible for dispatch.
  final double minimumRating;

  /// Maximum cancellation rate to be eligible (0.0 - 1.0).
  final double maxCancellationRate;

  /// Maximum number of drivers to include in a single dispatch batch.
  final int batchSize;

  /// Number of retry attempts before giving up.
  final int maxRetries;

  /// Seconds before a dispatch request times out.
  final int dispatchTimeoutSeconds;

  /// Maximum recent trips per day (above this, workload penalty increases).
  final int maxRecentTripsPerDay;

  /// Maximum idle time in minutes to receive idle bonus.
  final int maxIdleTimeMinutes;

  /// Whether to prefer drivers with lower cancellation rates.
  final bool penalizeCancellations;

  const ScoringConfig({
    this.maxSearchRadiusKm = AppConstants.nearbyDriversRadiusKm,
    this.minimumRating = AppConstants.minimumDriverRatingToShow,
    this.maxCancellationRate = 0.3,
    this.batchSize = AppConstants.dispatchBatchSize,
    this.maxRetries = AppConstants.maxDriverSearchRetries,
    this.dispatchTimeoutSeconds = 30,
    this.maxRecentTripsPerDay = 15,
    this.maxIdleTimeMinutes = 60,
    this.penalizeCancellations = true,
  });
}

// ============================================================================
// Scoring Result
// ============================================================================

/// Result of scoring a single driver.
class DriverScore {
  final String driverId;
  final String name;
  final double distanceKm;
  final int etaSeconds;

  // Individual factor scores (0.0 - 1.0)
  final double distanceScore;
  final double etaScore;
  final double ratingScore;
  final double acceptanceScore;
  final double cancellationScore;
  final double workloadScore;
  final double idleScore;

  // Weighted total score (0.0 - 1.0, higher is better)
  final double totalScore;

  const DriverScore({
    required this.driverId,
    required this.name,
    required this.distanceKm,
    required this.etaSeconds,
    required this.distanceScore,
    required this.etaScore,
    required this.ratingScore,
    required this.acceptanceScore,
    required this.cancellationScore,
    required this.workloadScore,
    required this.idleScore,
    required this.totalScore,
  });

  /// Human-readable summary of the score.
  String get summary =>
      '$name: ${totalScore.toStringAsFixed(3)} '
      '(dist=${distanceScore.toStringAsFixed(2)} '
      'eta=${etaScore.toStringAsFixed(2)} '
      'rating=${ratingScore.toStringAsFixed(2)} '
      'accept=${acceptanceScore.toStringAsFixed(2)} '
      'cancel=${cancellationScore.toStringAsFixed(2)} '
      'work=${workloadScore.toStringAsFixed(2)} '
      'idle=${idleScore.toStringAsFixed(2)})';

  /// ETA formatted as minutes.
  String get etaMinutes => '${(etaSeconds / 60).ceil()} min';
}

// ============================================================================
// Dispatch Scoring Service
// ============================================================================

/// Service for computing driver scores for the dispatch algorithm.
///
/// While the NestJS backend is the authoritative scorer (it has access to
/// PostGIS and real-time data), this Flutter-side service provides:
///
/// 1. **Local scoring** for debugging and testing.
/// 2. **Score explanation** for the driver app to show why they received
///    or didn't receive a dispatch.
/// 3. **Pre-filtering** to reduce the data sent over the network.
/// 4. **Offline estimation** when the backend is unreachable.
class DispatchScoringService {
  ScoringWeights _weights;
  ScoringConfig _config;

  DispatchScoringService({
    ScoringWeights weights = ScoringWeights.defaults,
    ScoringConfig config = const ScoringConfig(),
  })  : _weights = weights,
        _config = config;

  /// Current scoring weights.
  ScoringWeights get weights => _weights;

  /// Current scoring configuration.
  ScoringConfig get config => _config;

  /// Update scoring weights (e.g., from backend configuration).
  void updateWeights(ScoringWeights newWeights) {
    if (newWeights.isValid) {
      _weights = newWeights;
    }
  }

  /// Update scoring configuration.
  void updateConfig(ScoringConfig newConfig) {
    _config = newConfig;
  }

  // ==================== Scoring Engine ====================

  /// Score a list of drivers and return them sorted by total score
  /// (highest first).
  ///
  /// [drivers] — List of candidate driver profiles.
  /// [pickupLatitude] / [pickupLongitude] — Pickup location coordinates.
  /// [limit] — Maximum number of scored drivers to return.
  List<DriverScore> scoreDrivers({
    required List<DriverScoringProfile> drivers,
    required double pickupLatitude,
    required double pickupLongitude,
    int? limit,
  }) {
    // Filter eligible drivers
    final eligibleDrivers = drivers.where(_isEligible).toList();

    // Score each driver
    final scoredDrivers = eligibleDrivers.map((driver) {
      return _scoreDriver(driver);
    }).toList();

    // Sort by total score (descending)
    scoredDrivers.sort((a, b) => b.totalScore.compareTo(a.totalScore));

    // Return top N drivers
    final maxResults = limit ?? _config.batchSize;
    return scoredDrivers.take(maxResults).toList();
  }

  /// Score a single driver and return the detailed score breakdown.
  DriverScore _scoreDriver(DriverScoringProfile driver) {
    // Calculate individual factor scores (0.0 - 1.0)
    final distanceScore = _calculateDistanceScore(driver.distanceToPickupKm);
    final etaScore = _calculateEtaScore(driver.estimatedArrivalSeconds);
    final ratingScore = _calculateRatingScore(driver.averageRating);
    final acceptanceScore =
        _calculateAcceptanceScore(driver.acceptanceRate);
    final cancellationScore =
        _calculateCancellationScore(driver.cancellationRate);
    final workloadScore =
        _calculateWorkloadScore(driver.recentTripsCount);
    final idleScore = _calculateIdleScore(driver.idleTimeMinutes);

    // Compute weighted total score
    final totalScore = (distanceScore * _weights.distance) +
        (etaScore * _weights.eta) +
        (ratingScore * _weights.rating) +
        (acceptanceScore * _weights.acceptanceRate) +
        (cancellationScore * _weights.cancellationRate) +
        (workloadScore * _weights.workload) +
        (idleScore * _weights.idleTime);

    return DriverScore(
      driverId: driver.driverId,
      name: driver.name,
      distanceKm: driver.distanceToPickupKm,
      etaSeconds: driver.estimatedArrivalSeconds,
      distanceScore: distanceScore,
      etaScore: etaScore,
      ratingScore: ratingScore,
      acceptanceScore: acceptanceScore,
      cancellationScore: cancellationScore,
      workloadScore: workloadScore,
      idleScore: idleScore,
      totalScore: totalScore,
    );
  }

  // ==================== Eligibility Check ====================

  /// Check if a driver is eligible for dispatch.
  bool _isEligible(DriverScoringProfile driver) {
    // Must be available
    if (!driver.isAvailable) return false;

    // Must be within search radius
    if (driver.distanceToPickupKm > _config.maxSearchRadiusKm) return false;

    // Must have minimum rating
    if (driver.averageRating < _config.minimumRating) return false;

    // Must not have excessive cancellation rate
    if (_config.penalizeCancellations &&
        driver.cancellationRate > _config.maxCancellationRate) {
      return false;
    }

    // Must have completed at least some trips (unless new driver grace period)
    // For new drivers (< 5 trips), we give them a chance with a lower bar
    if (driver.totalTripsCompleted >= 5 &&
        driver.acceptanceRate < 0.3) {
      return false; // Very low acceptance rate for experienced drivers
    }

    return true;
  }

  // ==================== Individual Score Calculations ====================

  /// Distance score: Closer drivers get higher scores.
  /// Score decreases linearly from 1.0 (0 km) to 0.0 (maxSearchRadiusKm).
  ///
  /// Formula: 1.0 - (distanceKm / maxSearchRadiusKm)
  ///
  /// Examples (50 km radius):
  /// - 0 km  → 1.00
  /// - 5 km  → 0.90
  /// - 10 km → 0.80
  /// - 25 km → 0.50
  /// - 50 km → 0.00
  double _calculateDistanceScore(double distanceKm) {
    if (distanceKm <= 0) return 1.0;
    if (distanceKm >= _config.maxSearchRadiusKm) return 0.0;
    return 1.0 - (distanceKm / _config.maxSearchRadiusKm);
  }

  /// ETA score: Shorter estimated arrival times get higher scores.
  /// Score decreases as ETA increases.
  ///
  /// Formula: max(0, 1.0 - (etaSeconds / maxEtaSeconds))
  /// maxEtaSeconds is based on max radius at average city speed (~30 km/h).
  ///
  /// Examples (6000s = 100 min max):
  /// - 60s   (1 min)  → 0.99
  /// - 300s  (5 min)  → 0.95
  /// - 600s  (10 min) → 0.90
  /// - 1800s (30 min) → 0.70
  /// - 3600s (60 min) → 0.40
  double _calculateEtaScore(int etaSeconds) {
    // Estimate max ETA based on search radius at 20 km/h average speed
    final maxEtaSeconds = (_config.maxSearchRadiusKm / 20.0) * 3600;
    if (etaSeconds <= 0) return 1.0;
    if (etaSeconds >= maxEtaSeconds) return 0.0;
    return 1.0 - (etaSeconds / maxEtaSeconds);
  }

  /// Rating score: Higher-rated drivers get higher scores.
  /// Uses a quadratic curve to strongly favor highly-rated drivers.
  ///
  /// Formula: (rating / 5.0) ^ 1.5
  ///
  /// Examples:
  /// - 5.0 → 1.00
  /// - 4.8 → 0.94
  /// - 4.5 → 0.85
  /// - 4.0 → 0.72
  /// - 3.5 → 0.59
  /// - 3.0 → 0.46
  double _calculateRatingScore(double rating) {
    final normalizedRating = (rating / 5.0).clamp(0.0, 1.0);
    // Use power of 1.5 to give more weight to higher ratings
    return _pow(normalizedRating, 1.5);
  }

  /// Acceptance rate score: Drivers who accept more rides get higher scores.
  ///
  /// Formula: acceptanceRate (linear)
  ///
  /// Examples:
  /// - 1.0 (100%) → 1.00
  /// - 0.8 (80%)  → 0.80
  /// - 0.5 (50%)  → 0.50
  double _calculateAcceptanceScore(double acceptanceRate) {
    return acceptanceRate.clamp(0.0, 1.0);
  }

  /// Cancellation rate score: Drivers who cancel less get higher scores.
  /// This is inverted — low cancellation rate = high score.
  ///
  /// Formula: 1.0 - cancellationRate
  ///
  /// Examples:
  /// - 0%   → 1.00
  /// - 5%   → 0.95
  /// - 10%  → 0.90
  /// - 20%  → 0.80
  /// - 30%  → 0.70
  double _calculateCancellationScore(double cancellationRate) {
    return (1.0 - cancellationRate).clamp(0.0, 1.0);
  }

  /// Workload score: Drivers who haven't been overworked get slightly
  /// higher scores. This prevents dispatching to drivers who are
  /// already doing many trips.
  ///
  /// Formula: max(0, 1.0 - (recentTrips / maxRecentTrips))
  ///
  /// Examples (maxRecentTripsPerDay = 15):
  /// - 0 trips  → 1.00
  /// - 5 trips  → 0.67
  /// - 10 trips → 0.33
  /// - 15 trips → 0.00
  double _calculateWorkloadScore(int recentTripsCount) {
    if (recentTripsCount <= 0) return 1.0;
    if (recentTripsCount >= _config.maxRecentTripsPerDay) return 0.0;
    return 1.0 -
        (recentTripsCount / _config.maxRecentTripsPerDay);
  }

  /// Idle time score: Drivers who have been waiting longer get slightly
  /// higher scores. This ensures fair distribution of rides.
  ///
  /// Formula: min(1.0, idleMinutes / maxIdleTimeMinutes)
  ///
  /// Examples (maxIdleTimeMinutes = 60):
  /// - 0 min  → 0.00 (just completed a ride)
  /// - 15 min → 0.25
  /// - 30 min → 0.50
  /// - 60 min → 1.00
  /// - 90 min → 1.00 (capped)
  double _calculateIdleScore(int idleMinutes) {
    if (idleMinutes <= 0) return 0.0;
    return (idleMinutes / _config.maxIdleTimeMinutes).clamp(0.0, 1.0);
  }

  // ==================== Utility ====================

  /// Custom power function (avoid dart:math dependency for simple cases).
  double _pow(double base, double exponent) {
    // Use exponential/logarithm identity: base^exp = e^(exp * ln(base))
    if (base <= 0) return 0.0;
    if (base == 1.0) return 1.0;

    // Simple approximation for common cases
    if (exponent == 1.5) {
      return base * _sqrt(base);
    }
    if (exponent == 2.0) {
      return base * base;
    }

    // For other exponents, use simple iterative approximation
    double result = 1.0;
    for (int i = 0; i < exponent.toInt(); i++) {
      result *= base;
    }
    return result;
  }

  /// Simple square root approximation.
  double _sqrt(double value) {
    if (value <= 0) return 0.0;
    double x = value;
    double y = 1.0;
    double epsilon = 0.000001;
    while (x - y > epsilon) {
      x = (x + y) / 2;
      y = value / x;
    }
    return x;
  }

  // ==================== Score Explanation ====================

  /// Generate a human-readable explanation of why a driver received
  /// their score. Useful for the driver app to show performance insights.
  String getScoreExplanation(DriverScore score) {
    final buffer = StringBuffer();
    buffer.writeln('Dispatch Score: ${(score.totalScore * 100).toStringAsFixed(1)}%');
    buffer.writeln('');
    buffer.writeln('Score Breakdown:');
    buffer.writeln(
        '  Distance (${score.distanceKm.toStringAsFixed(1)} km): '
        '${(score.distanceScore * 100).toStringAsFixed(0)}% × ${(_weights.distance * 100).toStringAsFixed(0)}% weight');
    buffer.writeln(
        '  ETA (${score.etaMinutes}): '
        '${(score.etaScore * 100).toStringAsFixed(0)}% × ${(_weights.eta * 100).toStringAsFixed(0)}% weight');
    buffer.writeln(
        '  Rating: '
        '${(score.ratingScore * 100).toStringAsFixed(0)}% × ${(_weights.rating * 100).toStringAsFixed(0)}% weight');
    buffer.writeln(
        '  Acceptance: '
        '${(score.acceptanceScore * 100).toStringAsFixed(0)}% × ${(_weights.acceptanceRate * 100).toStringAsFixed(0)}% weight');
    buffer.writeln(
        '  Cancellation: '
        '${(score.cancellationScore * 100).toStringAsFixed(0)}% × ${(_weights.cancellationRate * 100).toStringAsFixed(0)}% weight');
    buffer.writeln(
        '  Workload: '
        '${(score.workloadScore * 100).toStringAsFixed(0)}% × ${(_weights.workload * 100).toStringAsFixed(0)}% weight');
    buffer.writeln(
        '  Idle Time: '
        '${(score.idleScore * 100).toStringAsFixed(0)}% × ${(_weights.idleTime * 100).toStringAsFixed(0)}% weight');

    return buffer.toString();
  }
}
