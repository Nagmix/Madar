import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:trippo_shared/trippo_shared.dart';
import '../../../../core/constants/app_theme.dart';
import '../notifiers/driver_auth_notifier.dart';

/// شاشة تسجيل دخول السائق - مدار
class DriverLoginScreen extends ConsumerStatefulWidget {
  const DriverLoginScreen({super.key});

  @override
  ConsumerState<DriverLoginScreen> createState() => _DriverLoginScreenState();
}

class _DriverLoginScreenState extends ConsumerState<DriverLoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(driverAuthProvider);

    ref.listen<DriverAuthState>(driverAuthProvider, (prev, next) {
      if (next.status == DriverAuthStatus.authenticated) {
        context.go('/home');
      }
    });

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),

                // شعار مدار
                Center(
                  child: Container(
                    width: 80, height: 80,
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Icon(Icons.local_taxi, size: 40, color: AppTheme.primary),
                  ),
                ),

                const SizedBox(height: 24),

                // عنوان مدار سائق
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF6D00).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'مدار سائق',
                    style: TextStyle(color: Color(0xFFFF6D00), fontWeight: FontWeight.w700, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ),

                const SizedBox(height: 32),

                const Text('مرحباً بك!', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: AppTheme.textPrimary), textAlign: TextAlign.center),
                const SizedBox(height: 8),
                Text('سجّل دخولك كمشرف توصيل', style: TextStyle(fontSize: 16, color: Colors.grey[500]), textAlign: TextAlign.center),

                const SizedBox(height: 40),

                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  textDirection: TextDirection.ltr,
                  decoration: const InputDecoration(labelText: 'البريد الإلكتروني', prefixIcon: Icon(Icons.email_outlined)),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'يرجى إدخال البريد الإلكتروني';
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  textDirection: TextDirection.ltr,
                  decoration: InputDecoration(
                    labelText: 'كلمة المرور',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility), onPressed: () => setState(() => _obscurePassword = !_obscurePassword)),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'يرجى إدخال كلمة المرور';
                    return null;
                  },
                ),

                const SizedBox(height: 32),

                ElevatedButton(
                  onPressed: authState.status == DriverAuthStatus.loading ? null : () {
                    if (_formKey.currentState!.validate()) {
                      ref.read(driverAuthProvider.notifier).login(email: _emailController.text.trim(), password: _passwordController.text);
                    }
                  },
                  child: authState.status == DriverAuthStatus.loading
                      ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)))
                      : const Text('تسجيل الدخول'),
                ),

                if (authState.error != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: AppTheme.error.withOpacity(0.1), borderRadius: BorderRadius.circular(AppTheme.radiusMedium)),
                    child: Row(children: [
                      const Icon(Icons.error_outline, color: AppTheme.error, size: 20),
                      const SizedBox(width: 8),
                      Expanded(child: Text(authState.error!, style: const TextStyle(color: AppTheme.error, fontSize: 13))),
                    ]),
                  ),
                ],

                const SizedBox(height: 32),

                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text('ليس لديك حساب؟', style: TextStyle(color: Colors.grey[600])),
                  TextButton(
                    onPressed: () => context.go('/register'),
                    child: const Text('سجّل كسائق', style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w700)),
                  ),
                ]),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
