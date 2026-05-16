import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';

// New architecture imports
import 'core/navigation/driver_router.dart';
import 'core/constants/app_theme.dart';
import 'firebase_options.dart';

/// Madar Driver App - v2.0.0
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
  // Wrap in try/catch so the app doesn't crash if Firebase is misconfigured
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    // Firebase init failed - app will still work, just without push notifications
    debugPrint('Firebase init failed (non-critical): $e');
  }

  runApp(const ProviderScope(child: MadarDriverApp()));
}

/// Main Driver App Widget
class MadarDriverApp extends ConsumerWidget {
  const MadarDriverApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(driverRouterProvider);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Madar Driver',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: router,
    );
  }
}
