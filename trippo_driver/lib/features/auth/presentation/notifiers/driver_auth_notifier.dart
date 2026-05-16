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
      String errorMsg = e.toString();
      // Clean up error message for display
      if (errorMsg.contains('Invalid credentials')) {
        errorMsg = 'Invalid email or password';
      } else if (errorMsg.contains('SocketException') || errorMsg.contains('Connection refused')) {
        errorMsg = 'Cannot connect to server. Please check your internet connection.';
      }
      state = state.copyWith(
        status: DriverAuthStatus.unauthenticated,
        error: errorMsg,
      );
    }
  }

  /// Register new driver - POST /auth/register (with role: 'driver')
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
      String errorMsg = e.toString();
      if (errorMsg.contains('Email already registered')) {
        errorMsg = 'This email is already registered. Try logging in instead.';
      } else if (errorMsg.contains('SocketException') || errorMsg.contains('Connection refused')) {
        errorMsg = 'Cannot connect to server. Please check your internet connection.';
      }
      state = state.copyWith(
        status: DriverAuthStatus.unauthenticated,
        error: errorMsg,
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
        // Token exists and is valid, consider authenticated
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

/// Is driver authenticated provider
final isDriverAuthenticatedProvider = Provider<bool>((ref) {
  final authState = ref.watch(driverAuthProvider);
  return authState.status == DriverAuthStatus.authenticated;
});

/// Current driver provider
final currentDriverProvider = Provider<DriverModel?>((ref) {
  final authState = ref.watch(driverAuthProvider);
  return authState.driver;
});
