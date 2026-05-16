/// App Configuration - Environment-based configuration
class AppConfig {
  AppConfig._();

  static const String appName = 'Madar';
  static const String appVersion = '2.0.0';

  // Environment
  static const Environment environment = Environment.development;

  // API Base URL based on environment
  // IMPORTANT: On real devices, use the VPS IP, not 10.0.2.2 (emulator only)
  static String get baseUrl => switch (environment) {
    Environment.development => 'http://209.74.71.33:3000/api/v1',
    Environment.staging => 'https://staging-api.madar.app/api/v1',
    Environment.production => 'https://api.madar.app/api/v1',
  };

  // Socket URL based on environment
  static String get socketUrl => switch (environment) {
    Environment.development => 'http://209.74.71.33:3000',
    Environment.staging => 'https://staging-api.madar.app',
    Environment.production => 'https://api.madar.app',
  };

  // Google Maps API Key
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
