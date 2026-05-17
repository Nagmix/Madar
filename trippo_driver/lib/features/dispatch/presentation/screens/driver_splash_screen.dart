import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_theme.dart';
import '../../../auth/presentation/notifiers/driver_auth_notifier.dart';

class DriverSplashScreen extends ConsumerStatefulWidget {
  const DriverSplashScreen({super.key});

  @override
  ConsumerState<DriverSplashScreen> createState() => _DriverSplashScreenState();
}

class _DriverSplashScreenState extends ConsumerState<DriverSplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;

  @override
  void initState() {
    super.initState();
    _logoController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
    _logoScale = Tween<double>(begin: 0.5, end: 1.0).animate(CurvedAnimation(parent: _logoController, curve: Curves.elasticOut));
    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _logoController, curve: Curves.easeOut));
    _logoController.forward();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    ref.read(driverAuthProvider.notifier).checkAuth();
  }

  @override
  void dispose() {
    _logoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<DriverAuthState>(driverAuthProvider, (prev, next) {
      if (next.status == DriverAuthStatus.authenticated) {
        context.go('/home');
      } else if (next.status == DriverAuthStatus.unauthenticated) {
        context.go('/login');
      }
    });

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topRight, end: Alignment.bottomLeft, colors: [Color(0xFFFF6D00), Color(0xFFE65100), Color(0xFFBF360C)]),
        ),
        child: SafeArea(
          child: Center(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              FadeTransition(
                opacity: _logoOpacity,
                child: ScaleTransition(
                  scale: _logoScale,
                  child: Container(
                    width: 120, height: 120,
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(32), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 20, offset: const Offset(0, 10))]),
                    child: const Center(child: Icon(Icons.local_taxi, size: 60, color: Color(0xFFFF6D00))),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              const Text('مدار', style: TextStyle(color: Colors.white, fontSize: 42, fontWeight: FontWeight.w800, letterSpacing: 2)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
                child: const Text('سائق', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
              ),
              const SizedBox(height: 40),
              CircularProgressIndicator(strokeWidth: 3, valueColor: AlwaysStoppedAnimation<Color>(Colors.white.withOpacity(0.8))),
            ]),
          ),
        ),
      ),
    );
  }
}
