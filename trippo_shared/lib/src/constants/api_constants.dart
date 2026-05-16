/// API Constants for Trippo Platform
library;

class ApiConstants {
  ApiConstants._();

  // Base URLs - these should be configured per environment
  static const String devBaseUrl = 'http://10.0.2.2:3000/api/v1';
  static const String stagingBaseUrl = 'https://staging-api.trippo.app/api/v1';
  static const String prodBaseUrl = 'https://api.trippo.app/api/v1';

  // Socket URLs
  static const String devSocketUrl = 'http://10.0.2.2:3000';
  static const String stagingSocketUrl = 'https://staging-api.trippo.app';
  static const String prodSocketUrl = 'https://api.trippo.app';

  // API Endpoints - Auth
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String refreshToken = '/auth/refresh';
  static const String forgotPassword = '/auth/forgot-password';
  static const String verifyOtp = '/auth/verify-otp';
  static const String resetPassword = '/auth/reset-password';
  static const String logout = '/auth/logout';

  // API Endpoints - User
  static const String userProfile = '/users/profile';
  static const String updateProfile = '/users/profile';
  static const String deleteAccount = '/users/account';

  // API Endpoints - Driver
  static const String driverProfile = '/drivers/profile';
  static const String driverOnline = '/drivers/online';
  static const String driverOffline = '/drivers/offline';
  static const String driverLocation = '/drivers/location';
  static const String driverDocuments = '/drivers/documents';
  static const String driverEarnings = '/drivers/earnings';

  // API Endpoints - Trip
  static const String createTrip = '/trips';
  static const String tripDetails = '/trips/{id}';
  static const String cancelTrip = '/trips/{id}/cancel';
  static const String acceptTrip = '/trips/{id}/accept';
  static const String startTrip = '/trips/{id}/start';
  static const String completeTrip = '/trips/{id}/complete';
  static const String tripHistory = '/trips/history';
  static const String rateTrip = '/trips/{id}/rate';
  static const String estimateFare = '/trips/estimate-fare';

  // API Endpoints - Dispatch
  static const String nearbyDrivers = '/dispatch/nearby-drivers';
  static const String requestRide = '/dispatch/request';

  // API Endpoints - Pricing
  static const String pricingConfig = '/pricing/config';
  static const String calculateFare = '/pricing/calculate';
  static const String surgeStatus = '/pricing/surge';

  // API Endpoints - Promo
  static const String validatePromo = '/pricing/promo/validate';
  static const String applyPromo = '/pricing/promo/apply';
  static const String availablePromos = '/pricing/promo/available';

  // API Endpoints - Wallet
  static const String walletBalance = '/wallet/balance';
  static const String walletTransactions = '/wallet/transactions';
  static const String walletWithdraw = '/wallet/withdraw';
  static const String walletSettlements = '/wallet/settlements';

  // API Endpoints - Notifications
  static const String notifications = '/notifications';
  static const String notificationPreferences = '/notifications/preferences';
  static const String registerDeviceToken = '/notifications/device-token';

  // API Endpoints - Geo
  static const String geocode = '/geo/geocode';
  static const String reverseGeocode = '/geo/reverse-geocode';
  static const String serviceAreas = '/geo/service-areas';
  static const String zones = '/geo/zones';
  static const String searchPlaces = '/geo/places';

  // Google Maps API (used until backend proxy is ready)
  static const String googleMapsBase = 'https://maps.googleapis.com/maps/api';
  static const String googleDirections = '/directions/json';
  static const String googlePlacesAutocomplete = '/place/autocomplete/json';
  static const String googlePlaceDetails = '/place/details/json';
  static const String googleGeocode = '/geocode/json';

  // Timeout durations
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 10);

  // Driver search timeout
  static const Duration driverSearchTimeout = Duration(seconds: 60);
  static const Duration driverResponseTimeout = Duration(seconds: 30);
}
