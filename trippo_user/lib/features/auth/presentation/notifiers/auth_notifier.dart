import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trippo_shared/trippo_shared.dart';
import '../../../../core/app_providers.dart';

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

/// Auth Notifier
class AuthNotifier extends StateNotifier<AuthState> {
  final Ref _ref;

  AuthNotifier(this._ref) : super(const AuthState());

  Future<void> login({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(status: AuthStatus.loading, error: null);
    
    try {
      final apiService = _ref.read(apiServiceProvider);
      final response = await apiService.post(
        ApiConstants.login,
        data: LoginRequest(
          email: email,
          password: password,
        ).toJson(),
      );
      
      final authResponse = AuthResponse.fromJson(response.data as Map<String, dynamic>);
      
      // Store tokens
      apiService.setTokens(
        accessToken: authResponse.accessToken,
        refreshToken: authResponse.refreshToken,
      );
      
      // Connect socket
      final socketService = _ref.read(socketServiceProvider);
      socketService.connect(authToken: authResponse.accessToken);
      
      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: authResponse.user,
      );
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        error: e.toString(),
      );
    }
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    state = state.copyWith(status: AuthStatus.loading, error: null);
    
    try {
      final apiService = _ref.read(apiServiceProvider);
      final response = await apiService.post(
        ApiConstants.register,
        data: RegisterRequest(
          name: name,
          email: email,
          password: password,
        ).toJson(),
      );
      
      final authResponse = AuthResponse.fromJson(response.data as Map<String, dynamic>);
      
      apiService.setTokens(
        accessToken: authResponse.accessToken,
        refreshToken: authResponse.refreshToken,
      );
      
      final socketService = _ref.read(socketServiceProvider);
      socketService.connect(authToken: authResponse.accessToken);
      
      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: authResponse.user,
      );
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        error: e.toString(),
      );
    }
  }

  Future<void> logout() async {
    final apiService = _ref.read(apiServiceProvider);
    apiService.clearTokens();
    
    final socketService = _ref.read(socketServiceProvider);
    socketService.disconnect();
    
    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  /// Check if user is already logged in on app start
  Future<void> checkAuth() async {
    // Try to refresh token or check stored credentials
    state = state.copyWith(status: AuthStatus.unauthenticated);
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
