import '../constants/app_constants.dart';
import '../models/pricing_model.dart';

/// Pricing Service - Client-side fare calculation and estimation
/// Works in conjunction with server-side pricing for verification
class PricingService {
  /// Calculate fare estimate based on distance, duration, and vehicle type
  /// This is a client-side estimation; the server calculates the final fare
  FareBreakdown calculateFareEstimate({
    required double distanceKm,
    required int durationMinutes,
    required String vehicleType,
    double baseFare = AppConstants.defaultBaseFare,
    double perKmRate = AppConstants.defaultPerKmRate,
    double perMinuteRate = AppConstants.defaultPerMinuteRate,
    double minimumFare = AppConstants.defaultMinimumFare,
    double surgeMultiplier = 1.0,
    double nightMultiplier = 1.0,
    double areaMultiplier = 1.0,
    int waitingMinutes = 0,
    double waitingFeePerMinute = AppConstants.defaultWaitingFeePerMinute,
    int freeWaitingMinutes = 3,
    double promoDiscount = 0.0,
    String currency = 'USD',
  }) {
    // 1. Get vehicle type multiplier
    final vehicleMultiplier = AppConstants.vehicleTypeMultipliers[vehicleType] ?? 1.0;

    // 2. Calculate base components
    final adjustedBaseFare = baseFare * vehicleMultiplier;
    final distanceFare = distanceKm * perKmRate * vehicleMultiplier;
    final timeFare = durationMinutes * perMinuteRate * vehicleMultiplier;

    // 3. Calculate subtotal before multipliers
    final subtotal = adjustedBaseFare + distanceFare + timeFare;

    // 4. Apply surge pricing
    final surgeCharge = subtotal * (surgeMultiplier - 1.0);

    // 5. Apply night pricing
    final nightCharge = subtotal * (nightMultiplier - 1.0);

    // 6. Apply area pricing
    final areaCharge = subtotal * (areaMultiplier - 1.0);

    // 7. Calculate waiting charges
    final chargeableWaitingMinutes = waitingMinutes > freeWaitingMinutes
        ? waitingMinutes - freeWaitingMinutes
        : 0;
    final waitingCharge = chargeableWaitingMinutes * waitingFeePerMinute;

    // 8. Calculate total before discount
    final totalBeforeDiscount = subtotal + surgeCharge + nightCharge + areaCharge + waitingCharge;

    // 9. Apply promo discount
    final finalTotal = (totalBeforeDiscount - promoDiscount).clamp(minimumFare, double.infinity);

    return FareBreakdown(
      baseFare: adjustedBaseFare,
      distanceFare: distanceFare,
      timeFare: timeFare,
      totalFare: finalTotal,
      surgeCharge: surgeCharge,
      nightCharge: nightCharge,
      areaCharge: areaCharge,
      waitingCharge: waitingCharge,
      cancellationFee: 0.0,
      promoDiscount: promoDiscount,
      surgeMultiplier: surgeMultiplier,
      nightMultiplier: nightMultiplier,
      areaMultiplier: areaMultiplier,
      currency: currency,
      distanceKm: distanceKm,
      durationMinutes: durationMinutes,
      waitingMinutes: waitingMinutes,
      vehicleType: vehicleType,
    );
  }

  /// Check if current time falls within night pricing hours
  bool isNightPricingActive({
    DateTime? currentTime,
    int nightStartHour = AppConstants.nightStartHour,
    int nightEndHour = AppConstants.nightEndHour,
  }) {
    final hour = (currentTime ?? DateTime.now()).hour;
    if (nightStartHour > nightEndHour) {
      // e.g., 22:00 to 06:00 - crosses midnight
      return hour >= nightStartHour || hour < nightEndHour;
    } else {
      return hour >= nightStartHour && hour < nightEndHour;
    }
  }

  /// Calculate surge multiplier based on demand/supply ratio
  double calculateSurgeMultiplier({
    required int activeRiders,
    required int availableDrivers,
  }) {
    if (availableDrivers == 0) return AppConstants.surgeMultiplierExtreme;
    
    final ratio = activeRiders / availableDrivers;
    
    if (ratio >= 5.0) {
      return AppConstants.surgeMultiplierExtreme;
    } else if (ratio >= 3.0) {
      return AppConstants.surgeMultiplierHigh;
    } else if (ratio >= 2.0) {
      return AppConstants.surgeMultiplierMedium;
    } else if (ratio >= 1.5) {
      return AppConstants.surgeMultiplierLow;
    }
    
    return 1.0; // No surge
  }

  /// Calculate cancellation fee based on trip state and timing
  double calculateCancellationFee({
    required String tripState,
    required DateTime tripCreatedAt,
    required double estimatedFare,
  }) {
    final minutesSinceCreation = DateTime.now().difference(tripCreatedAt).inMinutes;
    
    // Free cancellation within first 2 minutes
    if (minutesSinceCreation <= 2) return 0.0;
    
    // If driver already assigned and arriving
    if (tripState == 'DRIVER_ARRIVING' || tripState == 'DRIVER_ARRIVED') {
      return (estimatedFare * 0.3).clamp(
        AppConstants.defaultCancellationFee,
        estimatedFare * 0.5,
      );
    }
    
    // After driver assigned but before arriving
    if (tripState == 'DRIVER_ASSIGNED') {
      return AppConstants.defaultCancellationFee * 0.5;
    }
    
    return 0.0;
  }

  /// Format fare amount with currency symbol
  String formatFare(double amount, {String currency = 'USD'}) {
    final symbols = {
      'USD': '\$',
      'SAR': 'ر.س',
      'AED': 'د.إ',
      'PKR': '₨',
      'EUR': '€',
      'GBP': '£',
    };
    final symbol = symbols[currency] ?? currency;
    return '$symbol ${amount.toStringAsFixed(2)}';
  }
}
