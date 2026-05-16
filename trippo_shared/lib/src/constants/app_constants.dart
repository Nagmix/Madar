/// App Constants for Trippo Platform
library;

class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'Trippo';
  static const String appNameAr = 'تريبو';
  static const String appVersion = '2.0.0';

  // Map defaults
  static const double defaultLatitude = 24.7136; // Riyadh
  static const double defaultLongitude = 46.6753;
  static const double defaultZoom = 14.0;
  static const double pickupRadiusMeters = 500.0;
  static const double nearbyDriversRadiusKm = 50.0;
  static const double driverArrivalThresholdMeters = 50.0;

  // GPS Tracking
  static const int gpsUpdateIntervalMs = 3000; // 3 seconds
  static const int gpsUpdateIntervalActiveMs = 1000; // 1 second during trip
  static const double gpsMinAccuracyMeters = 50.0;
  static const double gpsMaxSpeedKmh = 200.0; // Anti-spoofing

  // Dispatch
  static const int maxDriverSearchRetries = 3;
  static const int dispatchBatchSize = 5; // Send to 5 drivers at a time
  static const Duration dispatchRetryDelay = Duration(seconds: 10);

  // Pricing defaults
  static const double defaultBaseFare = 5.0;
  static const double defaultPerKmRate = 1.5;
  static const double defaultPerMinuteRate = 0.25;
  static const double defaultMinimumFare = 10.0;
  static const double defaultCancellationFee = 5.0;
  static const double defaultWaitingFeePerMinute = 0.5;
  static const double defaultWaitingFreeMinutes = 3.0;

  // Surge pricing
  static const double surgeMultiplierLow = 1.2;
  static const double surgeMultiplierMedium = 1.5;
  static const double surgeMultiplierHigh = 2.0;
  static const double surgeMultiplierExtreme = 3.0;

  // Night pricing
  static const int nightStartHour = 22; // 10 PM
  static const int nightEndHour = 6; // 6 AM
  static const double nightMultiplier = 1.3;

  // Vehicle types
  static const String vehicleTypeSedan = 'sedan';
  static const String vehicleTypeSuv = 'suv';
  static const String vehicleTypeMotorcycle = 'motorcycle';
  static const String vehicleTypeVan = 'van';
  static const String vehicleTypeLuxury = 'luxury';

  // Vehicle type multipliers for pricing
  static const Map<String, double> vehicleTypeMultipliers = {
    vehicleTypeMotorcycle: 0.8,
    vehicleTypeSedan: 1.0,
    vehicleTypeSuv: 1.5,
    vehicleTypeVan: 1.8,
    vehicleTypeLuxury: 2.5,
  };

  // Wallet
  static const double minimumWithdrawalAmount = 50.0;
  static const double maximumWithdrawalAmount = 5000.0;
  static const double driverCommissionRate = 0.20; // 20% commission
  static const double driverIncentiveBonusRate = 0.05; // 5% bonus on high ratings

  // Rating
  static const double minimumRating = 1.0;
  static const double maximumRating = 5.0;
  static const double minimumDriverRatingToShow = 4.0;

  // Anti-fraud
  static const int maxTripsPerHour = 6;
  static const int maxCancellationPerDay = 5;
  static const double maxReasonableSpeedKmh = 200.0;
  static const double minTripDistanceMeters = 100.0;

  // Notification channels
  static const String channelRideUpdates = 'ride_updates';
  static const String channelPromotions = 'promotions';
  static const String channelWallet = 'wallet_updates';
  static const String channelSystem = 'system';

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
}
