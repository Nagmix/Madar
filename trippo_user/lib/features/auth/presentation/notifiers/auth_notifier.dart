import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trippo_shared/trippo_shared.dart';
import '../../../../core/app_providers.dart';
import '../../../../core/network/nestjs_api_client.dart';
import '../../../../core/storage/secure_storage.dart';

// Re-export providers from app_providers
export '../../../../core/app_providers.dart';

/// Auth State
enum AuthStatus { initial, authenticated, unauthenticated, loading }

class AuthState {
  final AuthStatus status;
  final UserModel? user;
  final String? error;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.error,
  });

  AuthState copyWith({AuthStatus? status, UserModel? user, String? error}) =>
      AuthState(
        status: status ?? this.status,
        user: user ?? this.user,
        error: error,
      );
}

/// Auth Notifier - User App
class AuthNotifier extends StateNotifier<AuthState> {
  final Ref _ref;

  AuthNotifier(this._ref) : super(const AuthState());

  /// Extract clean error message from DioException or other errors
  String _extractError(dynamic error) {
    if (error is DioException) {
      final response = error.response;
      if (response != null && response.data != null) {
        final data = response.data;
        if (data is Map<String, dynamic>) {
          // Try to get the server error message
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
      // Fallback based on DioException type
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
          if (statusCode == 409) return 'This email is already registered';
          if (statusCode == 400) return 'Invalid request. Please check your input.';
          if (statusCode != null && statusCode >= 500) return 'Server error. Please try again later.';
          return 'Something went wrong. Please try again.';
        default:
          return 'Network error. Please try again.';
      }
    }
    
    // Handle type errors (JSON parsing failures)
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
    // Remove technical prefixes
    return msg
        .replaceAll('Exception: ', '')
        .replaceAll('DioException ', '')
        .replaceAll(RegExp(r'\[bad response\]:.*'), '')
        .trim();
  }

  /// Login with email/password
  Future<void> login({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(status: AuthStatus.loading, error: null);
    
    try {
      final apiClient = NestjsApiClient();
      final authResponse = await apiClient.login(
        email: email,
        password: password,
      );

      // Save tokens to secure storage for persistence
      final secureStorage = SecureStorageService.instance;
      await secureStorage.saveAuthTokens(
        accessToken: authResponse.accessToken,
        refreshToken: authResponse.refreshToken,
        expiry: DateTime.now().add(const Duration(hours: 24)),
      );
      await secureStorage.saveUserId(authResponse.user.id);
      await secureStorage.saveUserRole('user');
      await secureStorage.saveUserEmail(authResponse.user.email);
      await secureStorage.saveUserName(authResponse.user.name);

      // Set tokens on shared API service too
      final apiService = _ref.read(apiServiceProvider);
      apiService.setTokens(
        accessToken: authResponse.accessToken,
        refreshToken: authResponse.refreshToken,
      );

      // Connect socket
      try {
        final socketService = _ref.read(socketServiceProvider);
        socketService.connect(authToken: authResponse.accessToken);
      } catch (_) {}
      
      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: authResponse.user,
      );
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        error: _extractError(e),
      );
    }
  }

  /// Register new user
  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    state = state.copyWith(status: AuthStatus.loading, error: null);
    
    try {
      final apiClient = NestjsApiClient();
      final authResponse = await apiClient.register(
        name: name,
        email: email,
        password: password,
      );

      // Save tokens to secure storage
      final secureStorage = SecureStorageService.instance;
      await secureStorage.saveAuthTokens(
        accessToken: authResponse.accessToken,
        refreshToken: authResponse.refreshToken,
        expiry: DateTime.now().add(const Duration(hours: 24)),
      );
      await secureStorage.saveUserId(authResponse.user.id);
      await secureStorage.saveUserRole('user');
      await secureStorage.saveUserEmail(authResponse.user.email);
      await secureStorage.saveUserName(authResponse.user.name);

      // Set tokens on shared API service
      final apiService = _ref.read(apiServiceProvider);
      apiService.setTokens(
        accessToken: authResponse.accessToken,
        refreshToken: authResponse.refreshToken,
      );

      // Connect socket
      try {
        final socketService = _ref.read(socketServiceProvider);
        socketService.connect(authToken: authResponse.accessToken);
      } catch (_) {}
      
      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: authResponse.user,
      );
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        error: _extractError(e),
      );
    }
  }

  /// Logout
  Future<void> logout() async {
    try {
      final apiClient = NestjsApiClient();
      await apiClient.logout();
    } catch (_) {}

    final apiService = _ref.read(apiServiceProvider);
    apiService.clearTokens();
    
    try {
      final socketService = _ref.read(socketServiceProvider);
      socketService.disconnect();
    } catch (_) {}
    
    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  /// Check if user is already logged in on app start
  Future<void> checkAuth() async {
    state = state.copyWith(status: AuthStatus.loading, error: null);

    try {
      final secureStorage = SecureStorageService.instance;
      final accessToken = await secureStorage.getAccessToken();
      final isValid = await secureStorage.isTokenValid();

      if (accessToken != null && isValid) {
        try {
          final socketService = _ref.read(socketServiceProvider);
          socketService.connect(authToken: accessToken);
        } catch (_) {}

        state = state.copyWith(status: AuthStatus.authenticated);
        return;
      }

      state = const AuthState(status: AuthStatus.unauthenticated);
    } catch (e) {
      state = const AuthState(status: AuthStatus.unauthenticated);
    }
  }
}

/// Auth Provider
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref);
});

/// Is authenticated provider
final isAuthenticatedProvider = Provider<bool>((ref) {
  final authState = ref.watch(authProvider);
  return authState.status == AuthStatus.authenticated;
});

