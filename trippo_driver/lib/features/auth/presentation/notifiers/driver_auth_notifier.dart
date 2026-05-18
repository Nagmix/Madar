import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trippo_shared/trippo_shared.dart';
import '../../../../core/app_providers.dart';
import '../../../../core/network/nestjs_api_client.dart';
import '../../../../core/storage/secure_storage.dart';

/// Driver Auth Status
enum DriverAuthStatus { initial, authenticated, unauthenticated, loading }

/// Driver Auth State
class DriverAuthState {
  final DriverAuthStatus status;
  final DriverModel? driver;
  final String? error;

  const DriverAuthState({
    this.status = DriverAuthStatus.initial,
    this.driver,
    this.error,
  });

  DriverAuthState copyWith({
    DriverAuthStatus? status,
    DriverModel? driver,
    String? error,
  }) =>
      DriverAuthState(
        status: status ?? this.status,
        driver: driver ?? this.driver,
        error: error,
      );
}

/// Driver Auth Notifier
/// Manages driver authentication via NestJS Auth Module
class DriverAuthNotifier extends StateNotifier<DriverAuthState> {
  final Ref _ref;

  DriverAuthNotifier(this._ref) : super(const DriverAuthState());

  /// Extract clean error message from DioException or other errors
  String _extractError(dynamic error) {
    if (error is DioException) {
      final response = error.response;
      if (response != null && response.data != null) {
        final data = response.data;
        if (data is Map<String, dynamic>) {
          final message = data['message'] ?? data['error'];
          if (message is String) {
            return _cleanServerMessage(message);
          }
          if (message is List && message.isNotEmpty) {
            return _cleanServerMessage(message.first.toString());
          }
        }
        if (data is String) {
          return _cleanServerMessage(data);
        }
      }
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return 'Connection timed out. Please try again.';
        case DioExceptionType.connectionError:
          return 'Cannot connect to server. Please check your internet connection.';
        case DioExceptionType.badResponse:
          final statusCode = response?.statusCode;
          if (statusCode == 401) return 'Invalid email or password';
          if (statusCode == 409) return 'This email is already registered. Try logging in instead.';
          if (statusCode == 400) return 'Invalid request. Please check your input.';
          if (statusCode != null && statusCode >= 500) return 'Server error. Please try again later.';
          return 'Something went wrong. Please try again.';
        default:
          return 'Network error. Please try again.';
      }
    }
    
    final errorStr = error.toString();
    if (errorStr.contains('type') && errorStr.contains('is not a subtype')) {
      return 'Server response error. Please try again.';
    }
    
    return _cleanServerMessage(errorStr);
  }
  
  String _cleanServerMessage(String msg) {
    if (msg.contains('Invalid credentials')) return 'Invalid email or password';
    if (msg.contains('Email already registered')) return 'This email is already registered. Try logging in instead.';
    if (msg.contains('SocketException') || msg.contains('Connection refused')) return 'Cannot connect to server. Please check your internet connection.';
    if (msg.contains('connection error') || msg.contains('Software caused connection abort')) return 'Network error. Please check your internet connection and try again.';
    if (msg.contains('timeout')) return 'Connection timed out. Please try again.';
    return msg
        .replaceAll('Exception: ', '')
        .replaceAll('DioException ', '')
        .replaceAll(RegExp(r'\[bad response\]:.*'), '')
        .trim();
  }

  /// Login with email/password - POST /auth/login
  Future<void> login({
    required String email,
    required String password,
    String? fcmToken,
  }) async {
    state = state.copyWith(status: DriverAuthStatus.loading, error: null);

    try {
      final apiClient = _ref.read(nestjsApiClientProvider);
      final authResponse = await apiClient.login(
        email: email,
        password: password,
        fcmToken: fcmToken,
      );

      // Save auth tokens
      final secureStorage = SecureStorageService.instance;
      await secureStorage.saveAuthTokens(
        accessToken: authResponse.accessToken,
        refreshToken: authResponse.refreshToken,
        expiry: DateTime.now().add(const Duration(hours: 24)),
      );
      await secureStorage.saveUserId(authResponse.user.id);
      await secureStorage.saveUserRole('driver');
      await secureStorage.saveUserEmail(authResponse.user.email);
      await secureStorage.saveUserName(authResponse.user.name);

      // Connect socket service for real-time updates
      try {
        final socketService = _ref.read(driverSocketServiceProvider);
        socketService.connect(authToken: authResponse.accessToken);
      } catch (_) {}

      state = state.copyWith(
        status: DriverAuthStatus.authenticated,
      );
    } catch (e) {
      state = state.copyWith(
        status: DriverAuthStatus.unauthenticated,
        error: _extractError(e),
      );
    }
  }

  /// Register new driver - POST /auth/register (with role: 'DRIVER')
  Future<void> register({
    required String name,
    required String email,
    required String password,
    String? phone,
    String? countryCode,
    String? fcmToken,
  }) async {
    state = state.copyWith(status: DriverAuthStatus.loading, error: null);

    try {
      final apiClient = _ref.read(nestjsApiClientProvider);
      final authResponse = await apiClient.register(
        name: name,
        email: email,
        password: password,
        phone: phone,
        countryCode: countryCode,
        fcmToken: fcmToken,
      );

      // Save auth tokens
      final secureStorage = SecureStorageService.instance;
      await secureStorage.saveAuthTokens(
        accessToken: authResponse.accessToken,
        refreshToken: authResponse.refreshToken,
        expiry: DateTime.now().add(const Duration(hours: 24)),
      );
      await secureStorage.saveUserId(authResponse.user.id);
      await secureStorage.saveUserRole('driver');
      await secureStorage.saveUserEmail(authResponse.user.email);
      await secureStorage.saveUserName(authResponse.user.name);

      // Connect socket service
      try {
        final socketService = _ref.read(driverSocketServiceProvider);
        socketService.connect(authToken: authResponse.accessToken);
      } catch (_) {}

      state = state.copyWith(
        status: DriverAuthStatus.authenticated,
      );
    } catch (e) {
      state = state.copyWith(
        status: DriverAuthStatus.unauthenticated,
        error: _extractError(e),
      );
    }
  }

  /// Logout
  Future<void> logout() async {
    try {
      final apiClient = _ref.read(nestjsApiClientProvider);
      await apiClient.logout();
    } catch (_) {}

    try {
      final socketService = _ref.read(driverSocketServiceProvider);
      socketService.disconnect();
    } catch (_) {}

    state = const DriverAuthState(status: DriverAuthStatus.unauthenticated);
  }

  /// Check if driver is already logged in on app start
  Future<void> checkAuth() async {
    state = state.copyWith(status: DriverAuthStatus.loading, error: null);

    try {
      final secureStorage = SecureStorageService.instance;
      final accessToken = await secureStorage.getAccessToken();
      final isValid = await secureStorage.isTokenValid();

      if (accessToken != null && isValid) {
        try {
          final socketService = _ref.read(driverSocketServiceProvider);
          socketService.connect(authToken: accessToken);
        } catch (_) {}

        state = state.copyWith(status: DriverAuthStatus.authenticated);
        return;
      }

      state = const DriverAuthState(status: DriverAuthStatus.unauthenticated);
    } catch (e) {
      state = const DriverAuthState(status: DriverAuthStatus.unauthenticated);
    }
  }
}

/// Driver Auth Provider
final driverAuthProvider =
    StateNotifierProvider<DriverAuthNotifier, DriverAuthState>((ref) {
  return DriverAuthNotifier(ref);
});


/// Current Driver Provider - selects current driver from auth state
/// Used by dispatch and trip notifiers to get the current driver ID
final currentDriverProvider = Provider<DriverModel?>((ref) {
  final authState = ref.watch(driverAuthProvider);
  return authState.driver;
});
