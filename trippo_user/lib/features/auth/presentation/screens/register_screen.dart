import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:trippo_shared/trippo_shared.dart';
import '../notifiers/auth_notifier.dart';

/// شاشة إنشاء حساب - مدار
class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _register() {
    if (_formKey.currentState!.validate()) {
      ref.read(authProvider.notifier).register(
            name: _nameController.text.trim(),
            email: _emailController.text.trim(),
            password: _passwordController.text,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: MadarTheme.background,
      appBar: MadarAppBar(
        title: '',
        backgroundColor: MadarTheme.background,
        showBack: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: MadarTheme.space24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // شعار مدار
                const Center(
                  child: MadarLogo(
                    size: 70,
                    showText: true,
                    color: MadarTheme.primary,
                  ),
                ),

                const SizedBox(height: MadarTheme.space24),

                // العنوان
                Text(
                  'إنشاء حساب جديد',
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                        color: MadarTheme.textPrimary,
                      ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: MadarTheme.space8),

                Text(
                  'انضم إلى مدار واستمتع برحلات مريحة',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: MadarTheme.textSecondary,
                      ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: MadarTheme.space32),

                // الاسم الكامل
                MadarTextField(
                  controller: _nameController,
                  label: 'الاسم الكامل',
                  hint: 'أدخل اسمك الكامل',
                  prefixIcon: Icons.person_outline,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'يرجى إدخال الاسم';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: MadarTheme.space16),

                // البريد الإلكتروني
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

                // رقم الهاتف (حقل إضافي لا يرسل للمصادقة)
                MadarTextField(
                  controller: _phoneController,
                  label: 'رقم الهاتف',
                  hint: 'أدخل رقم هاتفك',
                  prefixIcon: Icons.phone_outlined,
                  textDirection: TextDirection.ltr,
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'يرجى إدخال رقم الهاتف';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: MadarTheme.space16),

                // كلمة المرور
                MadarTextField(
                  controller: _passwordController,
                  label: 'كلمة المرور',
                  hint: 'أدخل كلمة مرور قوية',
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
                    if (value.length < 6) {
                      return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: MadarTheme.space32),

                // زر إنشاء الحساب
                MadarGradientButton(
                  label: 'إنشاء حساب',
                  onPressed: authState.status == AuthStatus.loading
                      ? null
                      : _register,
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

                const SizedBox(height: MadarTheme.space24),

                // تسجيل الدخول
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'لديك حساب بالفعل؟',
                      style: TextStyle(
                        color: MadarTheme.textSecondary,
                        fontFamily: MadarTheme.fontFamily,
                        fontSize: 14,
                      ),
                    ),
                    TextButton(
                      onPressed: () => context.go('/login'),
                      child: Text(
                        'تسجيل الدخول',
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

