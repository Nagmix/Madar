/// ثوابت التطبيق - منصة مدار
/// App Constants for Madar Platform
class AppConstants {
  AppConstants._();

  static const String appName = 'مدار';
  static const String appNameEn = 'Madar';
  static const String appSlogan = 'نقلك الذكي';
  
  // Pagination
  static const int defaultPageSize = 20;
  
  // Map defaults
  static const double defaultLatitude = 15.3694;
  static const double defaultLongitude = 44.1910;
  static const double defaultZoom = 14.0;
  
  // Trip
  static const int searchDriverTimeoutSeconds = 30;
  static const int maxRetryAttempts = 3;
  static const double minimumFare = 600.0;
  static const int maxTripsPerHour = 6;
  static const int maxCancellationPerDay = 5;
  
  // GPS & Location
  static const int gpsUpdateIntervalMs = 5000;
  static const int gpsUpdateIntervalActiveMs = 2000;
  static const double gpsMinAccuracyMeters = 50.0;
  static const double gpsMaxSpeedKmh = 200.0;
  static const double maxReasonableSpeedKmh = 180.0;
  
  // Dispatch
  static const double nearbyDriversRadiusKm = 5.0;
  static const double minimumDriverRatingToShow = 3.5;
  static const int dispatchBatchSize = 10;
  static const int maxDriverSearchRetries = 3;
  
  // Rating
  static const double defaultRating = 5.0;
  static const int ratingDisplayDecimals = 1;
  
  // Pricing defaults - Updated per user requirements
  static const double defaultBaseFare = 500.0;        // سعر الافتتاح
  static const double defaultPerKmRate = 200.0;        // 200 ريال يمني لكل كم
  static const double defaultPerMinuteRate = 25.0;
  static const double defaultMinimumFare = 600.0;
  static const double defaultCancellationFee = 200.0;
  static const double defaultWaitingFeePerMinute = 30.0;
  static const double driverCommissionRate = 0.20;
  static const double driverIncentiveBonusRate = 0.05;
  
  // Vehicle type multipliers
  static const Map<String, double> vehicleTypeMultipliers = {
    'sedan': 1.0,
    'suv': 1.3,
    'van': 1.5,
    'luxury': 2.0,
    'economy': 0.8,
  };
  
  // Night pricing
  static const int nightStartHour = 22;
  static const int nightEndHour = 6;
  
  // Surge multipliers
  static const double surgeMultiplierLow = 1.2;
  static const double surgeMultiplierMedium = 1.5;
  static const double surgeMultiplierHigh = 2.0;
  static const double surgeMultiplierExtreme = 3.0;
  
  // Wallet
  static const double minimumWithdrawalAmount = 1000.0;
  static const double maximumWithdrawalAmount = 100000.0;
  
  // Notification channels
  static const String channelRideUpdates = 'ride_updates';
}
