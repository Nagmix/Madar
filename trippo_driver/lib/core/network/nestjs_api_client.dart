import 'package:dio/dio.dart';
import 'package:trippo_shared/trippo_shared.dart';
import '../storage/secure_storage.dart';
import '../constants/app_config.dart';

/// NestJS API Client - Complete integration layer with NestJS backend for Driver App
/// 
/// This replaces ALL Firebase/Firestore direct calls with proper
/// NestJS REST API calls. Firebase is ONLY used for push notifications (FCM).
///
/// Driver-specific endpoints beyond User App:
/// - POST /drivers/documents - Upload driver documents
/// - GET /drivers/stats - Get driver statistics
/// - POST /dispatch/:id/accept - Accept dispatch trip
/// - POST /dispatch/:id/reject - Reject dispatch trip
/// - POST /trips/:id/arrived - Driver arrived at pickup
/// - POST /trips/:id/pause - Pause trip
/// - POST /trips/:id/resume - Resume trip
///
/// NestJS Backend Architecture:
/// - Auth Module: JWT authentication (login, register, refresh, OTP)
/// - Trip Module: Trip CRUD, state machine transitions
/// - Driver Module: Driver profile, location, status management
/// - Dispatch Module: Driver search, scoring, assignment
/// - Pricing Module: Fare calculation, surge pricing, promo codes
/// - Wallet Module: Balance, transactions, withdrawals, settlements
/// - Notification Module: Push, SMS, WhatsApp, Email, In-app
/// - Geo Module: PostGIS queries, geofences, zones, service areas
class NestjsApiClient {
  late final Dio _dio;
  final SecureStorageService _secureStorage = SecureStorageService.instance;

  NestjsApiClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.baseUrl,
        connectTimeout: ApiConstants.connectionTimeout,
        receiveTimeout: ApiConstants.receiveTimeout,
        sendTimeout: ApiConstants.sendTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-App-Version': AppConfig.appVersion,
          'X-Platform': 'flutter',
        },
      ),
    );

    _dio.interceptors.addAll([
      _AuthInterceptor(_dio, _secureStorage),
      _RefreshTokenInterceptor(_dio, _secureStorage),
      _LoggingInterceptor(),
      _ErrorMappingInterceptor(),
    ]);
  }

  Dio get dio => _dio;

  // ==================== AUTH ====================

  /// Login with email/password - NestJS Auth Module
  /// POST /auth/login
  Future<AuthResponse> login({
    required String email,
    required String password,
    String? fcmToken,
  }) async {
    final response = await _dio.post(
      ApiConstants.login,
      data: {
        'email': email,
        'password': password,
        'fcmToken': fcmToken,
      },
    );
    final authResponse = AuthResponse.fromJson(response.data);
    await _saveAuthTokens(authResponse);
    return authResponse;
  }

  /// Register new driver - NestJS Auth Module
  /// POST /auth/register
  Future<AuthResponse> register({
    required String name,
    required String email,
    required String password,
    String? phone,
    String? countryCode,
    String? fcmToken,
  }) async {
    final response = await _dio.post(
      ApiConstants.register,
      data: {
        'name': name,
        'email': email,
        'password': password,
        'phone': phone,
        'countryCode': countryCode,
        'fcmToken': fcmToken,
        'role': 'DRIVER',
      },
    );
    final authResponse = AuthResponse.fromJson(response.data);
    await _saveAuthTokens(authResponse);
    return authResponse;
  }

  /// Login with phone OTP - NestJS Auth Module
  /// POST /auth/phone/send-otp
  Future<void> sendPhoneOtp({required String phone, required String countryCode}) async {
    await _dio.post('/auth/phone/send-otp', data: {
      'phone': phone,
      'countryCode': countryCode,
    });
  }

  /// Verify phone OTP - NestJS Auth Module
  /// POST /auth/phone/verify-otp
  Future<AuthResponse> verifyPhoneOtp({
    required String phone,
    required String otp,
    String? fcmToken,
  }) async {
    final response = await _dio.post('/auth/phone/verify-otp', data: {
      'phone': phone,
      'otp': otp,
      'fcmToken': fcmToken,
    });
    final authResponse = AuthResponse.fromJson(response.data);
    await _saveAuthTokens(authResponse);
    return authResponse;
  }

  /// Refresh JWT token - NestJS Auth Module
  /// POST /auth/refresh
  Future<void> refreshToken() async {
    final refreshToken = await _secureStorage.getRefreshToken();
    if (refreshToken == null) throw Exception('No refresh token');
    
    final response = await _dio.post(
      ApiConstants.refreshToken,
      data: {'refreshToken': refreshToken},
    );
    
    final newAccessToken = response.data['accessToken'] as String;
    final newRefreshToken = response.data['refreshToken'] as String;
    final expiresIn = response.data['expiresIn'] as int? ?? 3600;
    
    await _secureStorage.saveAuthTokens(
      accessToken: newAccessToken,
      refreshToken: newRefreshToken,
      expiry: DateTime.now().add(Duration(seconds: expiresIn)),
    );
  }

  /// Logout - NestJS Auth Module
  /// POST /auth/logout
  Future<void> logout() async {
    try {
      await _dio.post(ApiConstants.logout);
    } finally {
      await _secureStorage.clearAuthData();
    }
  }

  // ==================== DRIVER ====================

  /// Get driver profile - NestJS Driver Module
  /// GET /drivers/profile
  /// The API returns { id, userId, status, user: {...}, vehicle: {...} }
  /// But DriverModel expects { id, email, name, vehicle, ... } at top level
  /// So we flatten the response before parsing.
  Future<DriverModel> getDriverProfile() async {
    final response = await _dio.get(ApiConstants.driverProfile);
    final data = _flattenDriverResponse(response.data);
    return DriverModel.fromJson(data);
  }

  /// Flatten the nested API response to match DriverModel format
  /// API: { id, userId, status, user: {name, email, phone, profileImageUrl, ...}, vehicle, ... }
  /// Model: { id, email, name, phone, profileImageUrl, vehicle, ... }
  static Map<String, dynamic> _flattenDriverResponse(Map<String, dynamic> apiData) {
    final user = apiData['user'] as Map<String, dynamic>?;
    final vehicle = apiData['vehicle'];
    
    return {
      'id': apiData['id'] ?? apiData['userId'] ?? '',
      'email': user?['email'] ?? apiData['email'] ?? '',
      'name': user?['name'] ?? apiData['name'] ?? '',
      'phone': user?['phone'] ?? apiData['phone'],
      'countryCode': user?['countryCode'] ?? apiData['countryCode'],
      'profileImageUrl': user?['profileImageUrl'] ?? apiData['profileImageUrl'],
      'vehicle': vehicle ?? {'id': '', 'name': '', 'plateNumber': '', 'type': 'sedan', 'seats': 4},
      'status': _mapDriverStatus(apiData['status']),
      'currentLocation': apiData['currentLocation'],
      'lastKnownLocation': apiData['lastKnownLocation'],
      'averageRating': (apiData['averageRating'] as num?)?.toDouble() ?? (user?['averageRating'] as num?)?.toDouble() ?? 0.0,
      'totalTrips': (apiData['totalTrips'] as num?)?.toInt() ?? 0,
      'completedTrips': (apiData['completedTrips'] as num?)?.toInt() ?? 0,
      'cancelledTrips': (apiData['cancelledTrips'] as num?)?.toInt() ?? 0,
      'acceptanceRate': (apiData['acceptanceRate'] as num?)?.toDouble() ?? 0.0,
      'cancellationRate': (apiData['cancellationRate'] as num?)?.toDouble() ?? 0.0,
      'isEmailVerified': apiData['isEmailVerified'] as bool? ?? user?['isEmailVerified'] as bool? ?? false,
      'isPhoneVerified': apiData['isPhoneVerified'] as bool? ?? user?['isPhoneVerified'] as bool? ?? false,
      'isDocumentsVerified': apiData['isDocumentsVerified'] as bool? ?? false,
      'isBanned': apiData['isBanned'] as bool? ?? user?['isBanned'] as bool? ?? false,
      'isActive': apiData['isActive'] as bool? ?? user?['isActive'] as bool? ?? false,
      'walletBalance': (apiData['walletBalance'] as num?)?.toDouble() ?? 0.0,
      'totalEarnings': (apiData['totalEarnings'] as num?)?.toDouble() ?? 0.0,
      'lastOnlineAt': apiData['lastOnlineAt'],
      'createdAt': apiData['createdAt'],
      'updatedAt': apiData['updatedAt'],
    };
  }
  
  /// Map driver status from API (uppercase) to model format (lowercase)
  static String _mapDriverStatus(dynamic status) {
    if (status == null) return 'offline';
    final s = status.toString().toLowerCase();
    // API may return OFFLINE, ONLINE, BUSY, SUSPENDED (Prisma enum)
    // Model expects: offline, online, busy, suspended
    return s;
  }

  /// Set driver online - NestJS Driver Module
  /// POST /drivers/online
  Future<void> setDriverOnline({
    required double latitude,
    required double longitude,
    double? heading,
    double? accuracy,
  }) async {
    await _dio.post(ApiConstants.driverOnline, data: {
      'latitude': latitude,
      'longitude': longitude,
      'heading': heading,
      'accuracy': accuracy,
    });
  }

  /// Set driver offline - NestJS Driver Module
  /// POST /drivers/offline
  Future<void> setDriverOffline() async {
    await _dio.post(ApiConstants.driverOffline);
  }

  /// Update driver location - NestJS Driver Module (via Redis + Socket.IO)
  /// POST /drivers/location
  Future<void> updateDriverLocation({
    required double latitude,
    required double longitude,
    double? heading,
    double? speed,
    double? accuracy,
  }) async {
    await _dio.post(ApiConstants.driverLocation, data: {
      'latitude': latitude,
      'longitude': longitude,
      'heading': heading,
      'speed': speed,
      'accuracy': accuracy,
    });
  }

  /// Update driver documents - NestJS Driver Module
  /// POST /drivers/documents
  Future<void> uploadDriverDocument({
    required String documentType,
    required String documentUrl,
    DateTime? expiresAt,
  }) async {
    await _dio.post(ApiConstants.driverDocuments, data: {
      'documentType': documentType,
      'documentUrl': documentUrl,
      'expiresAt': expiresAt?.toIso8601String(),
    });
  }

  /// Get driver statistics - NestJS Driver Module
  /// GET /drivers/stats
  Future<Map<String, dynamic>> getDriverStats({
    String? period,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final response = await _dio.get(
      '/drivers/stats',
      queryParameters: {
        'period': period,
        'startDate': startDate?.toIso8601String(),
        'endDate': endDate?.toIso8601String(),
      },
    );
    return response.data as Map<String, dynamic>;
  }

  /// Get driver earnings - NestJS Driver Module
  /// GET /drivers/earnings
  Future<Map<String, dynamic>> getDriverEarnings({
    String? period,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final response = await _dio.get(
      ApiConstants.driverEarnings,
      queryParameters: {
        'period': period,
        'startDate': startDate?.toIso8601String(),
        'endDate': endDate?.toIso8601String(),
      },
    );
    return response.data as Map<String, dynamic>;
  }

  // ==================== TRIP ====================

  /// Get trip details - NestJS Trip Module
  /// GET /trips/:id
  Future<TripModel> getTripDetails(String tripId) async {
    final response = await _dio.get(
      ApiConstants.tripDetails.replaceAll('{id}', tripId),
    );
    return TripModel.fromJson(response.data);
  }

  /// Accept trip (driver) - NestJS Trip Module
  /// POST /trips/:id/accept
  Future<TripModel> acceptTrip(String tripId) async {
    final response = await _dio.post(
      ApiConstants.acceptTrip.replaceAll('{id}', tripId),
    );
    return TripModel.fromJson(response.data);
  }

  /// Cancel trip - NestJS Trip Module
  /// POST /trips/:id/cancel
  Future<TripModel> cancelTrip({
    required String tripId,
    required String reason,
  }) async {
    final response = await _dio.post(
      ApiConstants.cancelTrip.replaceAll('{id}', tripId),
      data: {'reason': reason},
    );
    return TripModel.fromJson(response.data);
  }

  /// Start trip (driver) - NestJS Trip Module
  /// POST /trips/:id/start
  Future<TripModel> startTrip(String tripId) async {
    final response = await _dio.post(
      ApiConstants.startTrip.replaceAll('{id}', tripId),
    );
    return TripModel.fromJson(response.data);
  }

  /// Complete trip (driver) - NestJS Trip Module
  /// POST /trips/:id/complete
  Future<TripModel> completeTrip(String tripId) async {
    final response = await _dio.post(
      ApiConstants.completeTrip.replaceAll('{id}', tripId),
    );
    return TripModel.fromJson(response.data);
  }

  /// Driver arrived at pickup - NestJS Trip Module
  /// POST /trips/:id/arrived
  Future<TripModel> arrivedAtPickup(String tripId) async {
    final response = await _dio.post(
      '/trips/$tripId/arrived',
    );
    return TripModel.fromJson(response.data);
  }

  /// Pause trip - NestJS Trip Module
  /// POST /trips/:id/pause
  Future<TripModel> pauseTrip(String tripId, {String? reason}) async {
    final response = await _dio.post(
      '/trips/$tripId/pause',
      data: {'reason': reason},
    );
    return TripModel.fromJson(response.data);
  }

  /// Resume trip - NestJS Trip Module
  /// POST /trips/:id/resume
  Future<TripModel> resumeTrip(String tripId) async {
    final response = await _dio.post(
      '/trips/$tripId/resume',
    );
    return TripModel.fromJson(response.data);
  }

  /// Get trip history - NestJS Trip Module
  /// GET /trips/history
  Future<List<TripSummary>> getTripHistory({
    int page = 1,
    int pageSize = 20,
    String? status,
  }) async {
    final response = await _dio.get(
      ApiConstants.tripHistory,
      queryParameters: {
        'page': page,
        'pageSize': pageSize,
        'status': status,
      },
    );
    final items = response.data['items'] as List<dynamic>;
    return items.map((e) => TripSummary.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// Rate trip - NestJS Trip Module
  /// POST /trips/:id/rate
  Future<void> rateTrip({
    required String tripId,
    required double rating,
    String? review,
    List<String>? tags,
  }) async {
    await _dio.post(
      ApiConstants.rateTrip.replaceAll('{id}', tripId),
      data: {
        'rating': rating,
        'review': review,
        'tags': tags,
      },
    );
  }

  // ==================== DISPATCH ====================

  /// Accept dispatch trip - NestJS Dispatch Module
  /// POST /dispatch/:id/accept
  Future<void> acceptDispatch(String dispatchId) async {
    await _dio.post('/dispatch/$dispatchId/accept');
  }

  /// Reject dispatch trip - NestJS Dispatch Module
  /// POST /dispatch/:id/reject
  Future<void> rejectDispatch(String dispatchId, {String? reason}) async {
    await _dio.post('/dispatch/$dispatchId/reject', data: {
      'reason': reason,
    });
  }

  // ==================== PRICING ====================

  /// Estimate fare - NestJS Pricing Module
  /// POST /trips/estimate-fare
  Future<FareEstimateResponse> estimateFare(FareEstimateRequest request) async {
    final response = await _dio.post(
      ApiConstants.estimateFare,
      data: request.toJson(),
    );
    return FareEstimateResponse.fromJson(response.data);
  }

  /// Get pricing config - NestJS Pricing Module
  /// GET /pricing/config
  Future<PricingConfig> getPricingConfig({String? vehicleType, String? zoneId}) async {
    final response = await _dio.get(
      ApiConstants.pricingConfig,
      queryParameters: {'vehicleType': vehicleType, 'zoneId': zoneId},
    );
    return PricingConfig.fromJson(response.data);
  }

  /// Get surge status - NestJS Pricing Module
  /// GET /pricing/surge
  Future<SurgeStatus> getSurgeStatus({String? zoneId}) async {
    final response = await _dio.get(
      ApiConstants.surgeStatus,
      queryParameters: {'zoneId': zoneId},
    );
    return SurgeStatus.fromJson(response.data);
  }

  // ==================== WALLET ====================

  /// Get wallet balance - NestJS Wallet Module
  /// GET /wallet/balance
  Future<WalletModel> getWalletBalance() async {
    final response = await _dio.get(ApiConstants.walletBalance);
    return WalletModel.fromJson(response.data);
  }

  /// Get wallet transactions - NestJS Wallet Module
  /// GET /wallet/transactions
  Future<List<WalletTransaction>> getWalletTransactions({
    int page = 1,
    int pageSize = 20,
    String? type,
  }) async {
    final response = await _dio.get(
      ApiConstants.walletTransactions,
      queryParameters: {'page': page, 'pageSize': pageSize, 'type': type},
    );
    final items = response.data['items'] as List<dynamic>;
    return items.map((e) => WalletTransaction.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// Request withdrawal - NestJS Wallet Module
  /// POST /wallet/withdraw
  Future<WithdrawalRequest> requestWithdrawal({
    required double amount,
    required String method,
    required String accountDetails,
  }) async {
    final response = await _dio.post(
      ApiConstants.walletWithdraw,
      data: {'amount': amount, 'method': method, 'accountDetails': accountDetails},
    );
    return WithdrawalRequest.fromJson(response.data);
  }

  /// Get settlements - NestJS Wallet Module
  /// GET /wallet/settlements
  Future<List<Settlement>> getSettlements({int page = 1}) async {
    final response = await _dio.get(
      ApiConstants.walletSettlements,
      queryParameters: {'page': page},
    );
    final items = response.data['items'] as List<dynamic>;
    return items.map((e) => Settlement.fromJson(e as Map<String, dynamic>)).toList();
  }

  // ==================== GEO ====================

  /// Reverse geocode - NestJS Geo Module (PostGIS)
  /// GET /geo/reverse-geocode
  Future<LocationModel> reverseGeocode({
    required double latitude,
    required double longitude,
  }) async {
    final response = await _dio.get(
      ApiConstants.reverseGeocode,
      queryParameters: {'latitude': latitude, 'longitude': longitude},
    );
    return LocationModel.fromJson(response.data);
  }

  /// Search places - NestJS Geo Module (proxies Google Places)
  /// GET /geo/places
  Future<List<LocationModel>> searchPlaces({
    required String query,
    required double latitude,
    required double longitude,
    String? country,
  }) async {
    final response = await _dio.get(
      ApiConstants.searchPlaces,
      queryParameters: {
        'query': query,
        'latitude': latitude,
        'longitude': longitude,
        'country': country,
      },
    );
    final items = response.data as List<dynamic>;
    return items.map((e) => LocationModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// Get service areas - NestJS Geo Module (PostGIS)
  /// GET /geo/service-areas
  Future<List<GeoFence>> getServiceAreas() async {
    final response = await _dio.get(ApiConstants.serviceAreas);
    final items = response.data as List<dynamic>;
    return items.map((e) => GeoFence.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// Get zones - NestJS Geo Module (PostGIS)
  /// GET /geo/zones
  Future<List<GeoFence>> getZones() async {
    final response = await _dio.get(ApiConstants.zones);
    final items = response.data as List<dynamic>;
    return items.map((e) => GeoFence.fromJson(e as Map<String, dynamic>)).toList();
  }

  // ==================== NOTIFICATIONS ====================

  /// Get notifications - NestJS Notification Module
  /// GET /notifications
  Future<List<NotificationModel>> getNotifications({int page = 1}) async {
    final response = await _dio.get(
      ApiConstants.notifications,
      queryParameters: {'page': page},
    );
    final items = response.data['items'] as List<dynamic>;
    return items.map((e) => NotificationModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// Register device token - NestJS Notification Module
  /// POST /notifications/device-token
  Future<void> registerDeviceToken({
    required String token,
    required String platform,
  }) async {
    await _dio.post(ApiConstants.registerDeviceToken, data: {
      'token': token,
      'platform': platform,
    });
  }

  /// Get notification preferences - NestJS Notification Module
  /// GET /notifications/preferences
  Future<NotificationPreferences> getNotificationPreferences() async {
    final response = await _dio.get(ApiConstants.notificationPreferences);
    return NotificationPreferences.fromJson(response.data);
  }

  /// Update notification preferences - NestJS Notification Module
  /// PUT /notifications/preferences
  Future<void> updateNotificationPreferences(NotificationPreferences preferences) async {
    await _dio.put(ApiConstants.notificationPreferences, data: preferences.toJson());
  }

  // ==================== HELPERS ====================

  Future<void> _saveAuthTokens(AuthResponse authResponse) async {
    await _secureStorage.saveAuthTokens(
      accessToken: authResponse.accessToken,
      refreshToken: authResponse.refreshToken,
      expiry: DateTime.now().add(const Duration(hours: 24)),
    );
    await _secureStorage.saveUserId(authResponse.user.id);
    await _secureStorage.saveUserRole('driver');
    await _secureStorage.saveUserEmail(authResponse.user.email);
    await _secureStorage.saveUserName(authResponse.user.name);
  }
}

// ==================== Validation Error ====================

/// Validation error from NestJS backend
/// Maps to NestJS validation pipe error format
class ValidationError {
  final String message;
  final Map<String, String> fieldErrors;

  const ValidationError({required this.message, this.fieldErrors = const {}});

  @override
  String toString() => 'ValidationError: $message';
}

// ==================== Auth Interceptor ====================

/// Automatically adds JWT token from NestJS to all requests
class _AuthInterceptor extends Interceptor {
  final Dio _dio;
  final SecureStorageService _secureStorage;

  _AuthInterceptor(this._dio, this._secureStorage);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    // Skip auth endpoints that don't need tokens
    final noAuthPaths = ['/auth/login', '/auth/register', '/auth/phone/send-otp', '/auth/phone/verify-otp'];
    if (noAuthPaths.any((path) => options.path.contains(path))) {
      handler.next(options);
      return;
    }

    final token = await _secureStorage.getAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }
}

// ==================== Refresh Token Interceptor ====================

/// Automatically refreshes expired JWT tokens from NestJS
class _RefreshTokenInterceptor extends Interceptor {
  final Dio _dio;
  final SecureStorageService _secureStorage;
  bool _isRefreshing = false;

  _RefreshTokenInterceptor(this._dio, this._secureStorage);

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401 && !_isRefreshing) {
      _isRefreshing = true;
      try {
        final refreshToken = await _secureStorage.getRefreshToken();
        if (refreshToken == null) {
          _isRefreshing = false;
          handler.next(err);
          return;
        }

        // Call NestJS refresh endpoint
        final response = await _dio.post(
          ApiConstants.refreshToken,
          data: {'refreshToken': refreshToken},
          options: Options(headers: {'Authorization': ''}),
        );

        final newAccessToken = response.data['accessToken'] as String;
        final newRefreshToken = response.data['refreshToken'] as String;
        final expiresIn = response.data['expiresIn'] as int? ?? 3600;

        await _secureStorage.saveAuthTokens(
          accessToken: newAccessToken,
          refreshToken: newRefreshToken,
          expiry: DateTime.now().add(Duration(seconds: expiresIn)),
        );

        // Retry the original request
        err.requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';
        final retryResponse = await _dio.fetch(err.requestOptions);
        _isRefreshing = false;
        handler.resolve(retryResponse);
      } catch (refreshError) {
        _isRefreshing = false;
        await _secureStorage.clearAuthData();
        handler.next(err);
      }
    } else {
      handler.next(err);
    }
  }
}

// ==================== Logging Interceptor ====================

class _LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Log to Sentry/Datadog in production
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    handler.next(err);
  }
}

// ==================== Error Mapping Interceptor ====================

/// Maps NestJS error responses to app-level exceptions
/// NestJS returns errors in format: { statusCode, message, error }
/// IMPORTANT: NestJS validation pipe returns 'message' as List<String>, not String
/// This was causing: type 'List<dynamic>' is not a subtype of type 'String?' in type cast
class _ErrorMappingInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.data is Map<String, dynamic>) {
      final data = err.response!.data as Map<String, dynamic>;
      
      // Safely extract message - NestJS can return message as String OR List<String>
      final rawMessage = data['message'];
      String message;
      if (rawMessage is String) {
        message = rawMessage;
      } else if (rawMessage is List) {
        message = rawMessage.join('; ');
      } else {
        message = 'An error occurred';
      }
      
      final statusCode = data['statusCode'] as int? ?? err.response?.statusCode;
      
      // NestJS validation errors format
      if (statusCode == 422 && data['errors'] != null) {
        final fieldErrors = <String, String>{};
        final errors = data['errors'] as List<dynamic>;
        for (final error in errors) {
          if (error is Map<String, dynamic>) {
            final field = error['field'] as String? ?? 'unknown';
            final msg = error['message'] as String? ?? 'Invalid value';
            fieldErrors[field] = msg;
          }
        }
        handler.next(DioException(
          requestOptions: err.requestOptions,
          response: err.response,
          type: DioExceptionType.badResponse,
          error: ValidationError(message: message, fieldErrors: fieldErrors),
        ));
        return;
      }
    }
    handler.next(err);
  }
}
