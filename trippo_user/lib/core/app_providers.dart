import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trippo_shared/trippo_shared.dart';

/// Global API Service Provider
final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService();
});

/// Global Socket Service Provider
final socketServiceProvider = Provider<SocketService>((ref) {
  return SocketService();
});

/// Global GPS Tracking Service Provider
final gpsTrackingServiceProvider = Provider<GpsTrackingService>((ref) {
  return GpsTrackingService();
});

/// Global Pricing Service Provider
final pricingServiceProvider = Provider<PricingService>((ref) {
  return PricingService();
});
