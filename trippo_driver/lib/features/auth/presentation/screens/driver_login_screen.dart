import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:trippo_shared/trippo_shared.dart';
import '../../../../core/constants/app_theme.dart';
import '../../../../core/network/nestjs_api_client.dart';
import '../notifiers/driver_auth_notifier.dart';

/// Driver Login Screen - Professional login for Trippo Driver
///
/// Features:
/// - Trippo Driver branding (distinct from user app)
/// - Email/password login with validation
/// - Phone OTP login option
/// - "Don't have an account? Register as Driver" link
/// - Loading state during API call
/// - Error display
/// - All auth via NestJS: POST /auth/login
class DriverLoginScreen extends ConsumerStatefulWidget {
  const DriverLoginScreen({super.key});

  @override
  ConsumerState<DriverLoginScreen> createState() => _DriverLoginScreenState();
}

class _DriverLoginScreenState extends ConsumerState<DriverLoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _otpFormKey = GlobalKey<FormState>();

  bool _obscurePassword = true;
  bool _isPhoneLogin = false;
  bool _otpSent = false;
  bool _isSendingOtp = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(driverAuthProvider);

    // Navigate to home on successful auth
    ref.listen<DriverAuthState>(driverAuthProvider, (prev, next) {
      if (next.status == DriverAuthStatus.authenticated) {
        context.go('/home');
      }
    });

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppTheme.spacing24),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: _isPhoneLogin
                ? _buildPhoneLoginForm(authState)
                : _buildEmailLoginForm(authState),
          ),
        ),
      ),
    );
  }

  // ==================== Email Login Form ====================

  Widget _buildEmailLoginForm(DriverAuthState authState) {
    return Form(
      key: _formKey,
      child: Column(
        key: const ValueKey('email_login'),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 48),

          // Trippo Driver Branding
          _buildDriverBranding(),

          const SizedBox(height: 48),

          // Welcome text
          const Text(
            'Welcome, Driver!',
            style: AppTheme.heading1,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppTheme.spacing8),
          Text(
            'Sign in to start earning',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 40),

          // Email field
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              labelText: 'Email',
              prefixIcon: Icon(Icons.email_outlined),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter your email';
              }
              if (!value.contains('@') || !value.contains('.')) {
                return 'Please enter a valid email';
              }
              return null;
            },
          ),

          const SizedBox(height: AppTheme.spacing16),

          // Password field
          TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            textInputAction: TextInputAction.done,
            decoration: InputDecoration(
              labelText: 'Password',
              prefixIcon: const Icon(Icons.lock_outlined),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: () {
                  setState(() => _obscurePassword = !_obscurePassword);
                },
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your password';
              }
              if (value.length < 6) {
                return 'Password must be at least 6 characters';
              }
              return null;
            },
            onFieldSubmitted: (_) => _handleEmailLogin(),
          ),

          const SizedBox(height: AppTheme.spacing8),

          // Forgot password
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: _handleForgotPassword,
              child: const Text('Forgot password?'),
            ),
          ),

          const SizedBox(height: AppTheme.spacing16),

          // Error message
          if (authState.error != null)
            Container(
              padding: const EdgeInsets.all(AppTheme.spacing12),
              margin: const EdgeInsets.only(bottom: AppTheme.spacing16),
              decoration: BoxDecoration(
                color: AppTheme.error.withOpacity(0.08),
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                border: Border.all(color: AppTheme.error.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline,
                      color: AppTheme.error, size: 20),
                  const SizedBox(width: AppTheme.spacing8),
                  Expanded(
                    child: Text(
                      authState.error!,
                      style: const TextStyle(
                          color: AppTheme.error, fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),

          // Login button
          ElevatedButton(
            onPressed: authState.status == DriverAuthStatus.loading
                ? null
                : _handleEmailLogin,
            child: authState.status == DriverAuthStatus.loading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  )
                : const Text('Sign In'),
          ),

          const SizedBox(height: AppTheme.spacing24),

          // Divider
          _buildDivider('OR'),

          const SizedBox(height: AppTheme.spacing24),

          // Phone OTP login
          OutlinedButton.icon(
            onPressed: () {
              setState(() => _isPhoneLogin = true);
            },
            icon: const Icon(Icons.phone_android),
            label: const Text('Continue with Phone OTP'),
          ),

          const SizedBox(height: 48),

          // Register link
          _buildRegisterLink(),
        ],
      ),
    );
  }

  // ==================== Phone OTP Login Form ====================

  Widget _buildPhoneLoginForm(DriverAuthState authState) {
    return Form(
      key: _otpFormKey,
      child: Column(
        key: const ValueKey('phone_login'),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 48),

          // Trippo Driver Branding
          _buildDriverBranding(),

          const SizedBox(height: 48),

          // Phone login header
          const Text(
            'Phone Login',
            style: AppTheme.heading1,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppTheme.spacing8),
          Text(
            _otpSent
                ? 'Enter the OTP sent to your phone'
                : 'We\'ll send you a verification code',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 40),

          // Phone field
          TextFormField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            enabled: !_otpSent,
            decoration: InputDecoration(
              labelText: 'Phone Number',
              prefixIcon: const Icon(Icons.phone_outlined),
              hintText: '+1 234 567 8900',
              suffixIcon: _otpSent
                  ? const Icon(Icons.check_circle, color: AppTheme.success)
                  : null,
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter your phone number';
              }
              if (value.trim().length < 8) {
                return 'Please enter a valid phone number';
              }
              return null;
            },
          ),

          // OTP field (shown after OTP sent)
          if (_otpSent) ...[
            const SizedBox(height: AppTheme.spacing16),
            TextFormField(
              controller: _otpController,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                letterSpacing: 8,
              ),
              decoration: const InputDecoration(
                labelText: 'Verification Code',
                hintText: '------',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter the verification code';
                }
                if (value.trim().length < 4) {
                  return 'Please enter a valid code';
                }
                return null;
              },
            ),
          ],

          const SizedBox(height: AppTheme.spacing24),

          // Error message
          if (authState.error != null)
            Container(
              padding: const EdgeInsets.all(AppTheme.spacing12),
              margin: const EdgeInsets.only(bottom: AppTheme.spacing16),
              decoration: BoxDecoration(
                color: AppTheme.error.withOpacity(0.08),
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                border: Border.all(color: AppTheme.error.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline,
                      color: AppTheme.error, size: 20),
                  const SizedBox(width: AppTheme.spacing8),
                  Expanded(
                    child: Text(
                      authState.error!,
                      style: const TextStyle(
                          color: AppTheme.error, fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),

          // Send OTP / Verify OTP button
          if (!_otpSent)
            ElevatedButton(
              onPressed: _isSendingOtp ? null : _handleSendOtp,
              child: _isSendingOtp
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Send Verification Code'),
            )
          else
            ElevatedButton(
              onPressed: authState.status == DriverAuthStatus.loading
                  ? null
                  : _handleVerifyOtp,
              child: authState.status == DriverAuthStatus.loading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Verify & Sign In'),
            ),

          if (_otpSent) ...[
            const SizedBox(height: AppTheme.spacing16),
            TextButton(
              onPressed: _isSendingOtp ? null : _handleResendOtp,
              child: const Text('Resend Code'),
            ),
          ],

          const SizedBox(height: AppTheme.spacing24),

          // Back to email login
          TextButton.icon(
            onPressed: () {
              setState(() {
                _isPhoneLogin = false;
                _otpSent = false;
              });
            },
            icon: const Icon(Icons.arrow_back, size: 18),
            label: const Text('Sign in with email instead'),
          ),

          const SizedBox(height: AppTheme.spacing24),

          // Register link
          _buildRegisterLink(),
        ],
      ),
    );
  }

  // ==================== Shared Widgets ====================

  Widget _buildDriverBranding() {
    return Column(
      children: [
        // Driver-specific logo
        Container(
          width: 96,
          height: 96,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppTheme.secondary, AppTheme.secondaryLight],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppTheme.secondary.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(
            Icons.drive_eta,
            size: 48,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: AppTheme.spacing16),
        const Text(
          'TRIPPO',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            letterSpacing: 4,
            color: AppTheme.secondary,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: AppTheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text(
            'DRIVER',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              letterSpacing: 3,
              color: AppTheme.primary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDivider(String text) {
    return Row(
      children: [
        const Expanded(child: Divider()),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(text, style: TextStyle(color: Colors.grey[500])),
        ),
        const Expanded(child: Divider()),
      ],
    );
  }

  Widget _buildRegisterLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("Don't have an account?",
            style: TextStyle(color: Colors.grey[600])),
        TextButton(
          onPressed: () => context.go('/register'),
          child: const Text(
            'Register as Driver',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  // ==================== Handlers ====================

  void _handleEmailLogin() {
    if (!_formKey.currentState!.validate()) return;

    ref.read(driverAuthProvider.notifier).login(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
  }

  Future<void> _handleSendOtp() async {
    if (!_otpFormKey.currentState!.validate()) return;

    setState(() => _isSendingOtp = true);
    try {
      final apiClient = NestjsApiClient();
      await apiClient.sendPhoneOtp(
        phone: _phoneController.text.trim(),
        countryCode: '+1',
      );
      if (mounted) {
        setState(() {
          _otpSent = true;
          _isSendingOtp = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Verification code sent!'),
            backgroundColor: AppTheme.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSendingOtp = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send OTP: $e'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    }
  }

  void _handleVerifyOtp() {
    if (!_otpFormKey.currentState!.validate()) return;

    final apiClient = NestjsApiClient();
    apiClient.verifyPhoneOtp(
      phone: _phoneController.text.trim(),
      otp: _otpController.text.trim(),
    ).then((authResponse) {
      // Auth tokens are already saved by the API client
      // Now fetch driver profile and update auth state
      ref.read(driverAuthProvider.notifier).checkAuth();
    }).catchError((e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Verification failed: $e'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    });
  }

  Future<void> _handleResendOtp() async {
    setState(() => _isSendingOtp = true);
    try {
      final apiClient = NestjsApiClient();
      await apiClient.sendPhoneOtp(
        phone: _phoneController.text.trim(),
        countryCode: '+1',
      );
      if (mounted) {
        setState(() => _isSendingOtp = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Code resent!'),
            backgroundColor: AppTheme.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSendingOtp = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to resend: $e'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    }
  }

  void _handleForgotPassword() {
    // TODO: Navigate to forgot password screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Password reset coming soon')),
    );
  }
}
