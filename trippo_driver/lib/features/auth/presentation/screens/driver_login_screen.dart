import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:trippo_shared/trippo_shared.dart';
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
      backgroundColor: MadarTheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: MadarTheme.space24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: MadarTheme.space40),

                // Logo with "سائق" badge
                Center(
                  child: Column(
                    children: [
                      MadarLogo(size: 80, showText: true, color: MadarTheme.accent),
                      const SizedBox(height: MadarTheme.space8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: MadarTheme.space20,
                          vertical: MadarTheme.space4,
                        ),
                        decoration: BoxDecoration(
                          color: MadarTheme.accent.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(MadarTheme.radiusFull),
                          border: Border.all(
                            color: MadarTheme.accent.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: const Text(
                          'سائق',
                          style: TextStyle(
                            fontFamily: MadarTheme.fontFamily,
                            color: MadarTheme.accentDark,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: MadarTheme.space32),

                // Title
                const Text(
                  'مرحباً بك!',
                  style: TextStyle(
                    fontFamily: MadarTheme.fontFamily,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: MadarTheme.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: MadarTheme.space8),
                Text(
                  'سجّل دخولك كمشرف توصيل',
                  style: TextStyle(
                    fontFamily: MadarTheme.fontFamily,
                    fontSize: 16,
                    color: MadarTheme.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: MadarTheme.space32),

                // Email field
                MadarTextField(
                  label: 'البريد الإلكتروني',
                  hint: 'أدخل بريدك الإلكتروني',
                  controller: _emailController,
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  textDirection: TextDirection.ltr,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'يرجى إدخال البريد الإلكتروني';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: MadarTheme.space16),

                // Password field
                MadarTextField(
                  label: 'كلمة المرور',
                  hint: 'أدخل كلمة المرور',
                  controller: _passwordController,
                  prefixIcon: Icons.lock_outline,
                  obscureText: _obscurePassword,
                  textDirection: TextDirection.ltr,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off : Icons.visibility,
                      color: MadarTheme.textSecondary,
                    ),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'يرجى إدخال كلمة المرور';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: MadarTheme.space32),

                // Login button
                MadarGradientButton(
                  label: 'تسجيل الدخول',
                  isLoading: authState.status == DriverAuthStatus.loading,
                  gradientColors: const [
                    MadarTheme.accent,
                    MadarTheme.accentDark,
                  ],
                  onPressed: authState.status == DriverAuthStatus.loading
                      ? null
                      : () {
                          if (_formKey.currentState!.validate()) {
                            ref.read(driverAuthProvider.notifier).login(
                                  email: _emailController.text.trim(),
                                  password: _passwordController.text,
                                );
                          }
                        },
                ),

                // Error display
                if (authState.error != null) ...[
                  const SizedBox(height: MadarTheme.space16),
                  Container(
                    padding: const EdgeInsets.all(MadarTheme.space12),
                    decoration: BoxDecoration(
                      color: MadarTheme.error.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(MadarTheme.radiusMd),
                      border: Border.all(color: MadarTheme.error.withOpacity(0.2)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: MadarTheme.error, size: 20),
                        const SizedBox(width: MadarTheme.space8),
                        Expanded(
                          child: Text(
                            authState.error!,
                            style: const TextStyle(
                              color: MadarTheme.error,
                              fontSize: 13,
                              fontFamily: MadarTheme.fontFamily,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: MadarTheme.space32),

                // Register link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'ليس لديك حساب؟',
                      style: TextStyle(
                        fontFamily: MadarTheme.fontFamily,
                        color: MadarTheme.textSecondary,
                      ),
                    ),
                    TextButton(
                      onPressed: () => context.go('/register'),
                      child: const Text(
                        'إنشاء حساب',
                        style: TextStyle(
                          fontFamily: MadarTheme.fontFamily,
                          color: MadarTheme.accent,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: MadarTheme.space24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

