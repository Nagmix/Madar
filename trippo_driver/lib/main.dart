import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';

// New architecture imports
import 'core/navigation/driver_router.dart';
import 'core/constants/app_theme.dart';
import 'firebase_options.dart';

/// Trippo Driver App - v2.0.0
/// 
/// Architecture: Flutter + Riverpod + NestJS Backend
/// - Backend: NestJS (NOT Firebase/Firestore for core logic)
/// - Auth: JWT via NestJS Auth Module
/// - Realtime: Socket.IO + Redis (NOT Firebase Realtime DB)
/// - Database: PostgreSQL + PostGIS (NOT Firestore)
/// - Queue: BullMQ + Redis
/// - GPS Tracking: Kalman Filter + Anomaly Detection
/// - Firebase: ONLY for FCM push notifications
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase ONLY for FCM push notifications
  // All core backend operations go through NestJS API
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const ProviderScope(child: TrippoDriverApp()));
}

/// Main Driver App Widget
class TrippoDriverApp extends ConsumerWidget {
  const TrippoDriverApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(driverRouterProvider);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Trippo Driver',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: router,
    );
  }
}
