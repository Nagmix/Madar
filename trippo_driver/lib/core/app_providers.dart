import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trippo_shared/trippo_shared.dart';
import 'network/nestjs_api_client.dart';

/// Global NestJS API Client Provider - Driver-specific client
/// with driver endpoints (dispatch accept/reject, arrived, pause, resume)
final nestjsApiClientProvider = Provider<NestjsApiClient>((ref) {
  return NestjsApiClient();
});

/// Global Socket Service Provider - Driver socket connection
/// Handles dispatch notifications, trip updates, and driver location streaming
final driverSocketServiceProvider = Provider<SocketService>((ref) {
  return SocketService();
});

/// Global GPS Tracking Service Provider - Driver location tracking
/// Professional GPS tracking with Kalman filtering and anti-spoofing
final gpsTrackingServiceProvider = Provider<GpsTrackingService>((ref) {
  return GpsTrackingService();
});

/// Global Pricing Service Provider - Client-side fare estimation
/// Works with server-side pricing for verification
final pricingServiceProvider = Provider<PricingService>((ref) {
  return PricingService();
});
