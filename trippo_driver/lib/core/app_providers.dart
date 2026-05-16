import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:trippo_shared/trippo_shared.dart';
import 'network/nestjs_api_client.dart';

part 'app_providers.g.dart';

/// Global NestJS API Client Provider - Driver-specific client
/// with driver endpoints (dispatch accept/reject, arrived, pause, resume)
@Riverpod(keepAlive: true)
NestjsApiClient nestjsApiClient(NestjsApiClientRef ref) {
  return NestjsApiClient();
}

/// Global Socket Service Provider - Driver socket connection
/// Handles dispatch notifications, trip updates, and driver location streaming
@Riverpod(keepAlive: true)
SocketService driverSocketService(DriverSocketServiceRef ref) {
  return SocketService();
}

/// Global GPS Tracking Service Provider - Driver location tracking
/// Professional GPS tracking with Kalman filtering and anti-spoofing
@Riverpod(keepAlive: true)
GpsTrackingService gpsTrackingService(GpsTrackingServiceRef ref) {
  return GpsTrackingService();
}

/// Global Pricing Service Provider - Client-side fare estimation
/// Works with server-side pricing for verification
@Riverpod(keepAlive: true)
PricingService pricingService(PricingServiceRef ref) {
  return PricingService();
}
