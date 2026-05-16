import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trippo_shared/trippo_shared.dart';

// Screen imports
import '../../features/dispatch/presentation/screens/driver_splash_screen.dart';
import '../../features/auth/presentation/screens/driver_login_screen.dart';
import '../../features/auth/presentation/screens/driver_register_screen.dart';
import '../../features/auth/presentation/screens/driver_profile_screen.dart';
import '../../features/home/presentation/screens/driver_home_screen.dart';
import '../../features/trip/presentation/screens/active_trip_screen.dart';
import '../../features/earnings/presentation/screens/earnings_screen.dart';
import '../../features/history/presentation/screens/driver_trip_history_screen.dart';
import '../../features/wallet/presentation/screens/driver_wallet_screen.dart';

// Auth provider import
import '../../features/auth/presentation/notifiers/driver_auth_notifier.dart';

// App Theme
import '../constants/app_theme.dart';

// NestJS API Client for trip detail wrapper
import '../network/nestjs_api_client.dart';

/// Auth State Provider for GoRouter redirect logic
final driverAuthStateProvider = Provider<DriverAuthStatus>((ref) {
  final authState = ref.watch(driverAuthProvider);
  return authState.status;
});

/// GoRouter Provider - Centralized routing configuration for the Driver App
final driverRouterProvider = Provider<GoRouter>((ref) {
  final authStatus = ref.watch(driverAuthStateProvider);

  return GoRouter(
    initialLocation: '/splash',
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final isAuth = authStatus == DriverAuthStatus.authenticated;
      final isUnauth = authStatus == DriverAuthStatus.unauthenticated;
      final isInitial = authStatus == DriverAuthStatus.initial;

      final currentPath = state.matchedLocation;

      // Public routes
      final isPublicRoute = currentPath == '/splash' ||
          currentPath == '/login' ||
          currentPath == '/register';

      if (isInitial) return '/splash';

      // If not authenticated -> go to login
      if (isUnauth) {
        return isPublicRoute ? null : '/login';
      }

      // If authenticated and on public route -> home
      if (isAuth && isPublicRoute) return '/home';

      return null;
    },
    routes: [
      GoRoute(path: '/splash', name: 'splash', builder: (context, state) => const DriverSplashScreen()),
      GoRoute(path: '/login', name: 'login', builder: (context, state) => const DriverLoginScreen()),
      GoRoute(path: '/register', name: 'register', builder: (context, state) => const DriverRegisterScreen()),
      GoRoute(path: '/home', name: 'home', builder: (context, state) => const DriverHomeScreen()),
      GoRoute(
        path: '/active-trip/:tripId',
        name: 'activeTrip',
        builder: (context, state) {
          final tripId = state.pathParameters['tripId']!;
          return _ActiveTripWrapper(tripId: tripId);
        },
      ),
      GoRoute(path: '/earnings', name: 'earnings', builder: (context, state) => const DriverEarningsScreen()),
      GoRoute(path: '/wallet', name: 'wallet', builder: (context, state) => const DriverWalletScreen()),
      GoRoute(path: '/trip-history', name: 'tripHistory', builder: (context, state) => const DriverTripHistoryScreen()),
      GoRoute(path: '/profile', name: 'profile', builder: (context, state) => const DriverProfileScreen()),
      GoRoute(path: '/notifications', name: 'notifications', builder: (context, state) => const _DriverNotificationScreen()),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.explore_off, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text('Page Not Found', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text('The page "${state.matchedLocation}" does not exist.', style: const TextStyle(color: Colors.grey), textAlign: TextAlign.center),
            const SizedBox(height: 24),
            ElevatedButton(onPressed: () => context.go('/home'), child: const Text('Go Home')),
          ],
        ),
      ),
    ),
  );
});

class _ActiveTripWrapper extends ConsumerStatefulWidget {
  final String tripId;
  const _ActiveTripWrapper({required this.tripId});
  @override
  ConsumerState<_ActiveTripWrapper> createState() => _ActiveTripWrapperState();
}

class _ActiveTripWrapperState extends ConsumerState<_ActiveTripWrapper> {
  TripModel? _trip;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() { super.initState(); _loadTrip(); }

  Future<void> _loadTrip() async {
    try {
      final apiClient = NestjsApiClient();
      final trip = await apiClient.getTripDetails(widget.tripId);
      if (mounted) { setState(() { _trip = trip; _isLoading = false; }); }
    } catch (e) {
      if (mounted) { setState(() { _error = e.toString(); _isLoading = false; }); }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (_error != null || _trip == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Active Trip')),
        body: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.error_outline, size: 64, color: AppTheme.error),
          const SizedBox(height: 16),
          const Text('Failed to load trip details'),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: _loadTrip, child: const Text('Retry')),
        ])),
      );
    }
    return ActiveTripScreen(trip: _trip!);
  }
}

class _DriverNotificationScreen extends ConsumerStatefulWidget {
  const _DriverNotificationScreen();
  @override
  ConsumerState<_DriverNotificationScreen> createState() => _DriverNotificationScreenState();
}

class _DriverNotificationScreenState extends ConsumerState<_DriverNotificationScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications'), actions: [TextButton(onPressed: () {}, child: const Text('Mark all read'))]),
      body: Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.notifications_none_rounded, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text('No Notifications', style: TextStyle(color: Colors.grey[500], fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text('No new notifications', style: TextStyle(color: Colors.grey[400], fontSize: 14), textAlign: TextAlign.center),
        ]),
      ),
    );
  }
}

