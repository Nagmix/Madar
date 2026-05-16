/// App Configuration - Environment-based configuration
class AppConfig {
  AppConfig._();

  static const String appName = 'Trippo';
  static const String appVersion = '2.0.0';

  // Environment
  static const Environment environment = Environment.development;

  // API Base URL based on environment
  static String get baseUrl => switch (environment) {
    Environment.development => 'http://10.0.2.2:3000/api/v1',
    Environment.staging => 'https://staging-api.trippo.app/api/v1',
    Environment.production => 'https://api.trippo.app/api/v1',
  };

  // Socket URL based on environment
  static String get socketUrl => switch (environment) {
    Environment.development => 'http://10.0.2.2:3000',
    Environment.staging => 'https://staging-api.trippo.app',
    Environment.production => 'https://api.trippo.app',
  };

  // Google Maps API Key - should be loaded from .env in production
  static const String googleMapsApiKey = String.fromEnvironment('GOOGLE_MAPS_API_KEY');

  // Feature flags
  static const bool enableSurgePricing = true;
  static const bool enableNightPricing = true;
  static const bool enablePromoCodes = true;
  static const bool enableScheduledRides = false;
  static const bool enableMultipleStops = false;
  static const bool enableAntiFraud = true;
  static const bool enableKalmanFilter = true;
}

enum Environment {
  development,
  staging,
  production,
}
