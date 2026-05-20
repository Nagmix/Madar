/// API Constants for Madar Platform
class ApiConstants {
  ApiConstants._();

  static const String baseUrl = 'http://209.74.71.33:3000/api/v1';
  static const String devBaseUrl = 'http://209.74.71.33:3000/api/v1';
  static const String devSocketUrl = 'http://209.74.71.33:3000';

  static const Duration connectionTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);
  static const Duration sendTimeout = Duration(seconds: 15);

  // Auth
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String refreshToken = '/auth/refresh';
  static const String logout = '/auth/logout';
  static const String deleteAccount = '/auth/delete-account';

  // User
  static const String userProfile = '/users/profile';
  static const String userUpdate = '/users/profile';
  static const String updateProfile = '/users/profile';

  // Driver
  static const String driverProfile = '/drivers/profile';
  static const String driverOnline = '/drivers/online';
  static const String driverOffline = '/drivers/offline';
  static const String driverLocation = '/drivers/location';
  static const String driverEarnings = '/drivers/earnings';
  static const String driverDocuments = '/drivers/documents';

  // Trip
  static const String createTrip = '/trips';
  static const String tripEstimateFare = '/trips/estimate-fare';
  static const String tripHistory = '/trips/history';
  static const String rateTrip = '/trips/{id}/rate';
  static const String tripDetails = '/trips/{id}';
  static const String cancelTrip = '/trips/{id}/cancel';
  static const String acceptTrip = '/trips/{id}/accept';
  static const String startTrip = '/trips/{id}/start';
  static const String completeTrip = '/trips/{id}/complete';

  // Dispatch
  static const String dispatchNearbyDrivers = '/dispatch/nearby-drivers';
  static const String dispatchRequest = '/dispatch/request';
  static const String requestRide = '/dispatch/request';
  static const String nearbyDrivers = '/dispatch/nearby-drivers';

  // Pricing
  static const String pricingConfig = '/pricing/config';
  static const String pricingCalculate = '/pricing/calculate';
  static const String estimateFare = '/trips/estimate-fare';
  static const String surgeStatus = '/pricing/surge';

  // Wallet
  static const String walletBalance = '/wallet/balance';
  static const String walletTransactions = '/wallet/transactions';
  static const String walletWithdraw = '/wallet/withdraw';
  static const String walletSettlements = '/wallet/settlements';

  // Notification
  static const String registerDeviceToken = '/notifications/device-token';
  static const String notificationPreferences = '/notifications/preferences';
  static const String notifications = '/notifications';

  // Promo
  static const String validatePromo = '/promo/validate';
  static const String applyPromo = '/promo/apply';
  static const String availablePromos = '/promo/available';

  // Geo
  static const String searchPlaces = '/geo/search';
  static const String serviceAreas = '/geo/service-areas';
  static const String zones = '/geo/zones';
  static const String reverseGeocode = '/geo/reverse-geocode';
  static const String geocode = '/geo/geocode';
}
