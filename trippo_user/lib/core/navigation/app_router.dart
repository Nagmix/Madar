import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trippo_shared/trippo_shared.dart';
import '../constants/app_theme.dart';
import '../network/nestjs_api_client.dart';

// Screen imports
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/profile_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/home/presentation/screens/payment_screen.dart';
import '../../features/home/presentation/screens/cancel_trip_screen.dart';
import '../../features/home/presentation/screens/notification_screen.dart';
import '../../features/wallet/presentation/screens/wallet_screen.dart';
import '../../features/rating/presentation/screens/rating_screen.dart';
import '../../features/history/presentation/screens/trip_history_screen.dart';

// Auth provider import
import '../../features/auth/presentation/notifiers/auth_notifier.dart';

/// Auth State Provider for GoRouter redirect logic
///
/// Watches the authProvider to determine if user is authenticated.
/// Used by GoRouter's redirect callback to guard protected routes.
final authStateProvider = Provider<AuthStatus>((ref) {
  final authState = ref.watch(authProvider);
  return authState.status;
});

/// GoRouter Provider - Centralized routing configuration for the User App
///
/// Routes:
/// - `/splash` → SplashScreen (initial)
/// - `/login` → LoginScreen
/// - `/register` → RegisterScreen placeholder
/// - `/home` → HomeScreen (protected)
/// - `/trip-history` → TripHistoryScreen (protected)
/// - `/wallet` → WalletScreen (protected)
/// - `/profile` → ProfileScreen (protected)
/// - `/notifications` → NotificationScreen (protected)
/// - `/payment/:tripId` → PaymentScreen (protected)
/// - `/rating/:tripId` → RatingScreen (protected)
/// - `/cancel/:tripId` → CancelTripScreen (protected)
///
/// Redirect logic:
/// - If not authenticated → redirect to /login
/// - If authenticated → redirect to /home
/// - Splash screen handles initial auth check
final goRouterProvider = Provider<GoRouter>((ref) {
  final authStatus = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/splash',
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final isAuth = authStatus == AuthStatus.authenticated;
      final isUnauth = authStatus == AuthStatus.unauthenticated;
      final isInitial = authStatus == AuthStatus.initial;

      final currentPath = state.matchedLocation;

      // Public routes that don't require auth
      final isPublicRoute = currentPath == '/splash' ||
          currentPath == '/login' ||
          currentPath == '/register';

      // If still checking auth, stay on splash
      if (isInitial) {
        return '/splash';
      }

      // If not authenticated and trying to access protected route → redirect to login
      if (isUnauth && !isPublicRoute) {
        return '/login';
      }

      // If authenticated and on a public route → redirect to home
      if (isAuth && isPublicRoute && currentPath != '/splash') {
        return '/home';
      }

      // No redirect needed
      return null;
    },
    routes: [
      // ==================== Public Routes ====================

      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),

      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),

      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const _RegisterScreenPlaceholder(),
      ),

      // ==================== Protected Routes ====================

      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),

      GoRoute(
        path: '/trip-history',
        name: 'tripHistory',
        builder: (context, state) => const TripHistoryScreen(),
      ),

      GoRoute(
        path: '/wallet',
        name: 'wallet',
        builder: (context, state) => const WalletScreen(),
      ),

      GoRoute(
        path: '/profile',
        name: 'profile',
        builder: (context, state) => const ProfileScreen(),
      ),

      GoRoute(
        path: '/notifications',
        name: 'notifications',
        builder: (context, state) => const NotificationScreen(),
      ),

      GoRoute(
        path: '/payment/:tripId',
        name: 'payment',
        builder: (context, state) {
          final tripId = state.pathParameters['tripId']!;
          return PaymentScreen(tripId: tripId);
        },
      ),

      GoRoute(
        path: '/rating/:tripId',
        name: 'rating',
        builder: (context, state) {
          final tripId = state.pathParameters['tripId']!;
          // Fetch trip details and navigate to rating screen
          // For now, create a minimal TripModel for the rating screen
          return _RatingScreenWrapper(tripId: tripId);
        },
      ),

      GoRoute(
        path: '/cancel/:tripId',
        name: 'cancel',
        builder: (context, state) {
          final tripId = state.pathParameters['tripId']!;
          return CancelTripScreen(tripId: tripId);
        },
      ),
    ],

    // Error handler for unknown routes
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.explore_off, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'Page Not Found',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              'The page "${state.matchedLocation}" does not exist.',
              style: const TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go('/home'),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  );
});

/// Register Screen Placeholder
///
/// A simple placeholder for the registration screen.
/// Will be replaced with the full implementation later.
class _RegisterScreenPlaceholder extends ConsumerStatefulWidget {
  const _RegisterScreenPlaceholder();

  @override
  ConsumerState<_RegisterScreenPlaceholder> createState() =>
      _RegisterScreenPlaceholderState();
}

class _RegisterScreenPlaceholderState
    extends ConsumerState<_RegisterScreenPlaceholder> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Create Account')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Logo
            Center(
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.local_taxi,
                  size: 40,
                  color: AppTheme.primary,
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Name field
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Full Name',
                prefixIcon: Icon(Icons.person_outlined),
              ),
            ),
            const SizedBox(height: 16),

            // Email field
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.email_outlined),
              ),
            ),
            const SizedBox(height: 16),

            // Phone field
            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Phone Number (optional)',
                prefixIcon: Icon(Icons.phone_outlined),
              ),
            ),
            const SizedBox(height: 16),

            // Password field
            TextFormField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password',
                prefixIcon: Icon(Icons.lock_outlined),
              ),
            ),
            const SizedBox(height: 8),

            // Error message
            if (authState.error != null)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  authState.error!,
                  style: const TextStyle(color: Colors.red, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              ),

            const SizedBox(height: 16),

            // Register button
            ElevatedButton(
              onPressed: authState.status == AuthStatus.loading
                  ? null
                  : _handleRegister,
              child: authState.status == AuthStatus.loading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Create Account'),
            ),
            const SizedBox(height: 24),

            // Login link
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Already have an account?',
                    style: TextStyle(color: Colors.grey[600])),
                TextButton(
                  onPressed: () => context.go('/login'),
                  child: const Text('Sign In'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _handleRegister() {
    ref.read(authProvider.notifier).register(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
  }
}

/// Rating Screen Wrapper
///
/// Fetches trip details and passes them to the RatingScreen.
/// Since RatingScreen requires a TripModel, we load it first.
class _RatingScreenWrapper extends ConsumerStatefulWidget {
  final String tripId;

  const _RatingScreenWrapper({required this.tripId});

  @override
  ConsumerState<_RatingScreenWrapper> createState() =>
      _RatingScreenWrapperState();
}

class _RatingScreenWrapperState extends ConsumerState<_RatingScreenWrapper> {
  TripModel? _trip;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadTrip();
  }

  Future<void> _loadTrip() async {
    try {
      final apiClient = NestjsApiClient();
      final trip = await apiClient.getTripDetails(widget.tripId);
      if (mounted) {
        setState(() {
          _trip = trip;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null || _trip == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Rate Trip')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Failed to load trip details'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadTrip,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return RatingScreen(trip: _trip!);
  }
}

/// App Theme import for Register screen placeholder
/// (already imported at top but referenced here for clarity)
///
/// The [AppTheme] class provides consistent styling constants used
/// throughout the app, imported from core/constants/app_theme.dart.
