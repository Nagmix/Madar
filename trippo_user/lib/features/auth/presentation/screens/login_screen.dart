import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:trippo_shared/trippo_shared.dart';
import '../notifiers/auth_notifier.dart';

/// شاشة تسجيل الدخول - مدار
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
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

  void _login() {
    if (_formKey.currentState!.validate()) {
      ref.read(authProvider.notifier).login(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    ref.listen<AuthState>(authProvider, (prev, next) {
      if (next.status == AuthStatus.authenticated) {
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

                // شعار مدار
                const Center(
                  child: MadarLogo(
                    size: 80,
                    showText: true,
                    color: MadarTheme.primary,
                  ),
                ),

                const SizedBox(height: MadarTheme.space40),

                // عنوان الترحيب
                Text(
                  'مرحباً بعودتك!',
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                        color: MadarTheme.textPrimary,
                      ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: MadarTheme.space8),

                Text(
                  'سجّل دخولك للمتابعة',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: MadarTheme.textSecondary,
                      ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: MadarTheme.space40),

                // حقل البريد الإلكتروني
                MadarTextField(
                  controller: _emailController,
                  label: 'البريد الإلكتروني',
                  hint: 'أدخل بريدك الإلكتروني',
                  prefixIcon: Icons.email_outlined,
                  textDirection: TextDirection.ltr,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'يرجى إدخال البريد الإلكتروني';
                    }
                    if (!value.contains('@')) return 'البريد الإلكتروني غير صالح';
                    return null;
                  },
                ),

                const SizedBox(height: MadarTheme.space16),

                // حقل كلمة المرور
                MadarTextField(
                  controller: _passwordController,
                  label: 'كلمة المرور',
                  hint: 'أدخل كلمة المرور',
                  prefixIcon: Icons.lock_outline,
                  obscureText: _obscurePassword,
                  textDirection: TextDirection.ltr,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: MadarTheme.textSecondary,
                      size: 22,
                    ),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'يرجى إدخال كلمة المرور';
                    }
                    if (value.length < 6) return 'كلمة المرور قصيرة جداً';
                    return null;
                  },
                ),

                const SizedBox(height: MadarTheme.space8),

                // نسيت كلمة المرور
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    onPressed: () {},
                    child: Text(
                      'نسيت كلمة المرور؟',
                      style: TextStyle(
                        color: MadarTheme.primary,
                        fontFamily: MadarTheme.fontFamily,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: MadarTheme.space16),

                // زر تسجيل الدخول
                MadarGradientButton(
                  label: 'تسجيل الدخول',
                  onPressed: authState.status == AuthStatus.loading
                      ? null
                      : _login,
                  isLoading: authState.status == AuthStatus.loading,
                  gradientColors: const [
                    MadarTheme.primary,
                    MadarTheme.primaryDark,
                  ],
                ),

                // رسالة الخطأ
                if (authState.error != null) ...[
                  const SizedBox(height: MadarTheme.space16),
                  Container(
                    padding: const EdgeInsets.all(MadarTheme.space12),
                    decoration: BoxDecoration(
                      color: MadarTheme.error.withOpacity(0.08),
                      borderRadius:
                          BorderRadius.circular(MadarTheme.radiusMd),
                      border: Border.all(
                        color: MadarTheme.error.withOpacity(0.2),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline,
                            color: MadarTheme.error, size: 20),
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

                const SizedBox(height: MadarTheme.space40),

                // إنشاء حساب جديد
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'ليس لديك حساب؟',
                      style: TextStyle(
                        color: MadarTheme.textSecondary,
                        fontFamily: MadarTheme.fontFamily,
                        fontSize: 14,
                      ),
                    ),
                    TextButton(
                      onPressed: () => context.go('/register'),
                      child: Text(
                        'إنشاء حساب',
                        style: TextStyle(
                          color: MadarTheme.primary,
                          fontWeight: FontWeight.w700,
                          fontFamily: MadarTheme.fontFamily,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

