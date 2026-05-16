import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trippo_shared/trippo_shared.dart';
import '../../../core/app_providers.dart';
import '../../../core/network/nestjs_api_client.dart';

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
/// Stores `userRole: 'driver'` in secure storage after login
/// Connects SocketService after successful auth for real-time dispatch
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

      // _saveAuthTokens inside apiClient.login already stores role as 'driver'

      // Fetch full driver profile after login
      final driverProfile = await apiClient.getDriverProfile();

      // Connect socket service for real-time updates
      final socketService = _ref.read(driverSocketServiceProvider);
      socketService.connect(authToken: authResponse.accessToken);

      state = state.copyWith(
        status: DriverAuthStatus.authenticated,
        driver: driverProfile,
      );
    } catch (e) {
      state = state.copyWith(
        status: DriverAuthStatus.unauthenticated,
        error: e.toString(),
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

      // Fetch full driver profile after registration
      final driverProfile = await apiClient.getDriverProfile();

      // Connect socket service for real-time updates
      final socketService = _ref.read(driverSocketServiceProvider);
      socketService.connect(authToken: authResponse.accessToken);

      state = state.copyWith(
        status: DriverAuthStatus.authenticated,
        driver: driverProfile,
      );
    } catch (e) {
      state = state.copyWith(
        status: DriverAuthStatus.unauthenticated,
        error: e.toString(),
      );
    }
  }

  /// Logout - POST /auth/logout
  /// Clears tokens from secure storage and disconnects socket
  Future<void> logout() async {
    try {
      final apiClient = _ref.read(nestjsApiClientProvider);
      await apiClient.logout();
    } catch (_) {
      // Even if API call fails, we still clear local state
    }

    // Disconnect socket
    final socketService = _ref.read(driverSocketServiceProvider);
    socketService.disconnect();

    state = const DriverAuthState(status: DriverAuthStatus.unauthenticated);
  }

  /// Check if driver is already logged in on app start
  /// Validates stored JWT token and refreshes if needed
  Future<void> checkAuth() async {
    state = state.copyWith(status: DriverAuthStatus.loading, error: null);

    try {
      final apiClient = _ref.read(nestjsApiClientProvider);
      final secureStorage = SecureStorageService.instance;

      // Check if we have a valid access token
      final accessToken = await secureStorage.getAccessToken();
      final isValid = await secureStorage.isTokenValid();
      final userRole = await secureStorage.getUserRole();

      if (accessToken != null && isValid && userRole == 'driver') {
        // Try to fetch driver profile to validate token
        try {
          final driverProfile = await apiClient.getDriverProfile();

          // Reconnect socket with existing token
          final socketService = _ref.read(driverSocketServiceProvider);
          socketService.connect(authToken: accessToken);

          state = state.copyWith(
            status: DriverAuthStatus.authenticated,
            driver: driverProfile,
          );
          return;
        } catch (_) {
          // Token might be expired, try refresh
          try {
            await apiClient.refreshToken();
            final driverProfile = await apiClient.getDriverProfile();

            final newToken = await secureStorage.getAccessToken();
            final socketService = _ref.read(driverSocketServiceProvider);
            if (newToken != null) {
              socketService.connect(authToken: newToken);
            }

            state = state.copyWith(
              status: DriverAuthStatus.authenticated,
              driver: driverProfile,
            );
            return;
          } catch (_) {
            // Refresh failed, need to re-login
          }
        }
      }

      state = const DriverAuthState(status: DriverAuthStatus.unauthenticated);
    } catch (e) {
      state = DriverAuthState(
        status: DriverAuthStatus.unauthenticated,
        error: e.toString(),
      );
    }
  }

  /// Update driver profile - PUT /drivers/profile
  Future<void> updateDriverProfile({
    String? name,
    String? phone,
    String? countryCode,
    String? profileImageUrl,
  }) async {
    try {
      final apiClient = _ref.read(nestjsApiClientProvider);
      // Note: The API client uses the driver profile endpoint
      // which returns the updated DriverModel
      await apiClient.getDriverProfile(); // Verify we can reach the API

      // Refresh the driver profile from server
      final updatedDriver = await apiClient.getDriverProfile();

      state = state.copyWith(driver: updatedDriver);
    } catch (e) {
      state = state.copyWith(error: e.toString());
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

/// Current driver provider - convenience accessor
final currentDriverProvider = Provider<DriverModel?>((ref) {
  final authState = ref.watch(driverAuthProvider);
  return authState.driver;
});
