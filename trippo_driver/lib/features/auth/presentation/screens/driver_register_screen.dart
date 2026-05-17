import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:trippo_shared/trippo_shared.dart';
import '../../../../core/network/nestjs_api_client.dart';
import '../notifiers/driver_auth_notifier.dart';

/// شاشة تسجيل سائق جديد - مدار
/// خطوات:
/// - الخطوة 1: المعلومات الشخصية (الاسم، البريد، الهاتف، كلمة المرور)
/// - الخطوة 2: معلومات المركبة (الاسم، رقم اللوحة، النوع، اللون، الموديل، السنة)
/// - الخطوة 3: رفع المستندات (رخصة القيادة، تسجيل المركبة، التأمين، الهوية)
class DriverRegisterScreen extends ConsumerStatefulWidget {
  const DriverRegisterScreen({super.key});

  @override
  ConsumerState<DriverRegisterScreen> createState() =>
      _DriverRegisterScreenState();
}

class _DriverRegisterScreenState extends ConsumerState<DriverRegisterScreen> {
  final _pageController = PageController();
  int _currentStep = 0;
  static const int _totalSteps = 3;

  // Step 1: Personal info controllers
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // Step 2: Vehicle info controllers
  final _vehicleNameController = TextEditingController();
  final _plateNumberController = TextEditingController();
  final _vehicleColorController = TextEditingController();
  final _vehicleModelController = TextEditingController();
  final _vehicleYearController = TextEditingController();
  String _vehicleType = 'sedan';

  // Step 3: Document upload
  final Map<String, DocumentStatus> _documentStatuses = {
    'driving_license': DocumentStatus.notUploaded,
    'vehicle_registration': DocumentStatus.notUploaded,
    'insurance': DocumentStatus.notUploaded,
    'national_id': DocumentStatus.notUploaded,
  };

  // Form keys for each step
  final _step1Key = GlobalKey<FormState>();
  final _step2Key = GlobalKey<FormState>();
  final _step3Key = GlobalKey<FormState>();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isUploading = false;

  static const List<String> _vehicleTypes = [
    'sedan',
    'suv',
    'van',
    'luxury',
    'motorcycle',
    'rickshaw',
    'hatchback',
  ];

  static const Map<String, String> _vehicleTypeLabels = {
    'sedan': 'سيدان',
    'suv': 'دفع رباعي',
    'van': 'فان',
    'luxury': 'فاخر',
    'motorcycle': 'دراجة',
    'rickshaw': 'ريكشا',
    'hatchback': 'هاتشباك',
  };

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _vehicleNameController.dispose();
    _plateNumberController.dispose();
    _vehicleColorController.dispose();
    _vehicleModelController.dispose();
    _vehicleYearController.dispose();
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
      appBar: AppBar(
        backgroundColor: MadarTheme.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        title: const Text(
          'إنشاء حساب سائق جديد',
          style: TextStyle(
            fontFamily: MadarTheme.fontFamily,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        leading: _currentStep > 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: _goToPreviousStep,
              )
            : IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => context.go('/login'),
              ),
      ),
      body: Column(
        children: [
          // Step indicator
          _buildStepIndicator(),

          // Error display
          if (authState.error != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(MadarTheme.space12),
              margin: const EdgeInsets.symmetric(
                horizontal: MadarTheme.space24,
                vertical: MadarTheme.space8,
              ),
              decoration: BoxDecoration(
                color: MadarTheme.error.withOpacity(0.08),
                borderRadius: BorderRadius.circular(MadarTheme.radiusMd),
                border: Border.all(color: MadarTheme.error.withOpacity(0.3)),
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
                        fontSize: 14,
                        fontFamily: MadarTheme.fontFamily,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Step content
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildStep1PersonalInfo(),
                _buildStep2VehicleInfo(),
                _buildStep3Documents(),
              ],
            ),
          ),

          // Bottom navigation buttons
          _buildBottomNavigation(authState),
        ],
      ),
    );
  }

  // ==================== Step Indicator ====================

  Widget _buildStepIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: MadarTheme.space24,
        vertical: MadarTheme.space16,
      ),
      child: Column(
        children: [
          Row(
            children: List.generate(_totalSteps, (index) {
              final isCompleted = index < _currentStep;
              final isCurrent = index == _currentStep;

              return Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 4,
                        decoration: BoxDecoration(
                          color: isCompleted || isCurrent
                              ? MadarTheme.accent
                              : MadarTheme.textHint.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    if (index < _totalSteps - 1) const SizedBox(width: 8),
                  ],
                ),
              );
            }),
          ),
          const SizedBox(height: MadarTheme.space8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStepLabel(0, 'الشخصية', Icons.person),
              _buildStepLabel(1, 'المركبة', Icons.directions_car),
              _buildStepLabel(2, 'المستندات', Icons.description),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStepLabel(int step, String label, IconData icon) {
    final isCompleted = step < _currentStep;
    final isCurrent = step == _currentStep;

    return GestureDetector(
      onTap: isCompleted ? () => _goToStep(step) : null,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: isCompleted
                  ? MadarTheme.accent
                  : isCurrent
                      ? MadarTheme.accent.withOpacity(0.15)
                      : Colors.grey[200],
              shape: BoxShape.circle,
            ),
            child: Center(
              child: isCompleted
                  ? const Icon(Icons.check, color: Colors.white, size: 16)
                  : Icon(
                      icon,
                      size: 14,
                      color: isCurrent ? MadarTheme.accent : Colors.grey[500],
                    ),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontFamily: MadarTheme.fontFamily,
              fontSize: 12,
              fontWeight: isCurrent ? FontWeight.w600 : FontWeight.normal,
              color: isCurrent
                  ? MadarTheme.accent
                  : isCompleted
                      ? MadarTheme.textPrimary
                      : Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  // ==================== Step 1: Personal Info ====================

  Widget _buildStep1PersonalInfo() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(MadarTheme.space24),
      child: Form(
        key: _step1Key,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'المعلومات الشخصية',
              style: TextStyle(
                fontFamily: MadarTheme.fontFamily,
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: MadarTheme.textPrimary,
              ),
            ),
            const SizedBox(height: MadarTheme.space8),
            Text(
              'أخبرنا عنك للبدء',
              style: TextStyle(
                fontFamily: MadarTheme.fontFamily,
                color: MadarTheme.textSecondary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: MadarTheme.space32),

            // Full name
            MadarTextField(
              label: 'الاسم الكامل',
              hint: 'أدخل اسمك الكامل',
              controller: _nameController,
              prefixIcon: Icons.person_outlined,
              textDirection: TextDirection.rtl,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'يرجى إدخال الاسم الكامل';
                }
                if (value.trim().length < 2) {
                  return 'يجب أن يكون الاسم حرفين على الأقل';
                }
                return null;
              },
            ),
            const SizedBox(height: MadarTheme.space16),

            // Email
            MadarTextField(
              label: 'البريد الإلكتروني',
              hint: 'أدخل بريدك الإلكتروني',
              controller: _emailController,
              prefixIcon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              textDirection: TextDirection.ltr,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'يرجى إدخال البريد الإلكتروني';
                }
                if (!value.contains('@') || !value.contains('.')) {
                  return 'يرجى إدخال بريد إلكتروني صالح';
                }
                return null;
              },
            ),
            const SizedBox(height: MadarTheme.space16),

            // Phone
            MadarTextField(
              label: 'رقم الهاتف',
              hint: '+966 5XX XXX XXXX',
              controller: _phoneController,
              prefixIcon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
              textDirection: TextDirection.ltr,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'يرجى إدخال رقم الهاتف';
                }
                if (value.trim().length < 8) {
                  return 'يرجى إدخال رقم هاتف صالح';
                }
                return null;
              },
            ),
            const SizedBox(height: MadarTheme.space16),

            // Password
            MadarTextField(
              label: 'كلمة المرور',
              hint: 'أدخل كلمة مرور قوية',
              controller: _passwordController,
              prefixIcon: Icons.lock_outlined,
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
                if (value.length < 8) {
                  return 'يجب أن تكون 8 أحرف على الأقل';
                }
                return null;
              },
            ),
            const SizedBox(height: MadarTheme.space16),

            // Confirm Password
            MadarTextField(
              label: 'تأكيد كلمة المرور',
              hint: 'أعد إدخال كلمة المرور',
              controller: _confirmPasswordController,
              prefixIcon: Icons.lock_outlined,
              obscureText: _obscureConfirmPassword,
              textDirection: TextDirection.ltr,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                  color: MadarTheme.textSecondary,
                ),
                onPressed: () => setState(
                    () => _obscureConfirmPassword = !_obscureConfirmPassword),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'يرجى تأكيد كلمة المرور';
                }
                if (value != _passwordController.text) {
                  return 'كلمات المرور غير متطابقة';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  // ==================== Step 2: Vehicle Info ====================

  Widget _buildStep2VehicleInfo() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(MadarTheme.space24),
      child: Form(
        key: _step2Key,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'معلومات المركبة',
              style: TextStyle(
                fontFamily: MadarTheme.fontFamily,
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: MadarTheme.textPrimary,
              ),
            ),
            const SizedBox(height: MadarTheme.space8),
            Text(
              'أضف تفاصيل مركبتك لاستلام الرحلات',
              style: TextStyle(
                fontFamily: MadarTheme.fontFamily,
                color: MadarTheme.textSecondary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: MadarTheme.space32),

            // Vehicle type selector
            Text(
              'نوع المركبة',
              style: TextStyle(
                fontFamily: MadarTheme.fontFamily,
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: MadarTheme.textSecondary,
              ),
            ),
            const SizedBox(height: MadarTheme.space8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _vehicleTypes.map((type) {
                final isSelected = _vehicleType == type;
                return ChoiceChip(
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _getVehicleIcon(type),
                        size: 16,
                        color: isSelected ? MadarTheme.accent : Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _vehicleTypeLabels[type] ?? type,
                        style: TextStyle(
                          fontFamily: MadarTheme.fontFamily,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  selected: isSelected,
                  onSelected: (_) => setState(() => _vehicleType = type),
                  selectedColor: MadarTheme.accent.withOpacity(0.15),
                  side: BorderSide(
                    color: isSelected ? MadarTheme.accent : MadarTheme.textHint.withOpacity(0.3),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: MadarTheme.space24),

            // Vehicle name (nickname)
            MadarTextField(
              label: 'اسم المركبة',
              hint: 'مثال: الكامري البيضاء',
              controller: _vehicleNameController,
              prefixIcon: Icons.label_outlined,
              textDirection: TextDirection.rtl,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'يرجى إدخال اسم المركبة';
                }
                return null;
              },
            ),
            const SizedBox(height: MadarTheme.space16),

            // Vehicle make/model
            MadarTextField(
              label: 'الطراز والموديل',
              hint: 'مثال: تويوتا كامري',
              controller: _vehicleModelController,
              prefixIcon: Icons.directions_car_outlined,
              textDirection: TextDirection.rtl,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'يرجى إدخال الطراز والموديل';
                }
                return null;
              },
            ),
            const SizedBox(height: MadarTheme.space16),

            // Vehicle year
            MadarTextField(
              label: 'سنة الصنع',
              hint: 'مثال: 2022',
              controller: _vehicleYearController,
              prefixIcon: Icons.calendar_today_outlined,
              keyboardType: TextInputType.number,
              textDirection: TextDirection.ltr,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'يرجى إدخال سنة الصنع';
                }
                final year = int.tryParse(value.trim());
                if (year == null || year < 2000 || year > DateTime.now().year + 1) {
                  return 'يرجى إدخال سنة صالحة (2000+)';
                }
                return null;
              },
            ),
            const SizedBox(height: MadarTheme.space16),

            // Plate number
            MadarTextField(
              label: 'رقم اللوحة',
              hint: 'مثال: أ ب ج 1234',
              controller: _plateNumberController,
              prefixIcon: Icons.pin_outlined,
              textDirection: TextDirection.rtl,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'يرجى إدخال رقم اللوحة';
                }
                return null;
              },
            ),
            const SizedBox(height: MadarTheme.space16),

            // Color
            MadarTextField(
              label: 'اللون',
              hint: 'مثال: أبيض',
              controller: _vehicleColorController,
              prefixIcon: Icons.palette_outlined,
              textDirection: TextDirection.rtl,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'يرجى إدخال لون المركبة';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  // ==================== Step 3: Documents ====================

  Widget _buildStep3Documents() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(MadarTheme.space24),
      child: Form(
        key: _step3Key,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'رفع المستندات',
              style: TextStyle(
                fontFamily: MadarTheme.fontFamily,
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: MadarTheme.textPrimary,
              ),
            ),
            const SizedBox(height: MadarTheme.space8),
            Text(
              'ارفع المستندات المطلوبة للتحقق',
              style: TextStyle(
                fontFamily: MadarTheme.fontFamily,
                color: MadarTheme.textSecondary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: MadarTheme.space8),

            // Info box
            Container(
              padding: const EdgeInsets.all(MadarTheme.space12),
              decoration: BoxDecoration(
                color: MadarTheme.primary.withOpacity(0.06),
                borderRadius: BorderRadius.circular(MadarTheme.radiusMd),
                border: Border.all(color: MadarTheme.primary.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: MadarTheme.primary, size: 20),
                  const SizedBox(width: MadarTheme.space8),
                  Expanded(
                    child: Text(
                      'يمكنك رفع المستندات لاحقاً من ملفك الشخصي بعد التسجيل. أكمل التسجيل للبدء.',
                      style: TextStyle(
                        fontFamily: MadarTheme.fontFamily,
                        fontSize: 12,
                        color: MadarTheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: MadarTheme.space24),

            // Document upload cards
            _buildDocumentUploadCard(
              documentType: 'driving_license',
              title: 'رخصة القيادة',
              subtitle: 'رخصة قيادة صالحة لنوع مركبتك',
              icon: Icons.badge_outlined,
            ),
            const SizedBox(height: MadarTheme.space12),

            _buildDocumentUploadCard(
              documentType: 'vehicle_registration',
              title: 'استمارة المركبة',
              subtitle: 'وثيقة تسجيل المركبة الحالية',
              icon: Icons.description_outlined,
            ),
            const SizedBox(height: MadarTheme.space12),

            _buildDocumentUploadCard(
              documentType: 'insurance',
              title: 'التأمين',
              subtitle: 'شهادة تأمين المركبة السارية',
              icon: Icons.shield_outlined,
            ),
            const SizedBox(height: MadarTheme.space12),

            _buildDocumentUploadCard(
              documentType: 'national_id',
              title: 'الهوية الوطنية',
              subtitle: 'وثيقة هوية صادرة عن الجهة المختصة',
              icon: Icons.credit_card_outlined,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentUploadCard({
    required String documentType,
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    final status = _documentStatuses[documentType] ?? DocumentStatus.notUploaded;

    return MadarCard(
      padding: const EdgeInsets.all(MadarTheme.space16),
      child: Row(
        children: [
          // Icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: _getDocStatusColor(status).withOpacity(0.1),
              borderRadius: BorderRadius.circular(MadarTheme.radiusMd),
            ),
            child: Icon(icon, color: _getDocStatusColor(status), size: 24),
          ),
          const SizedBox(width: MadarTheme.space12),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: MadarTheme.fontFamily,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: MadarTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontFamily: MadarTheme.fontFamily,
                    fontSize: 12,
                    color: MadarTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                _buildDocStatusBadge(status),
              ],
            ),
          ),

          // Upload/re-upload button
          if (status == DocumentStatus.notUploaded)
            IconButton(
              onPressed: _isUploading
                  ? null
                  : () => _handleDocumentUpload(documentType),
              icon: _isUploading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.upload_file, color: MadarTheme.accent),
              style: IconButton.styleFrom(
                backgroundColor: MadarTheme.accent.withOpacity(0.1),
              ),
            )
          else
            IconButton(
              onPressed: () => _handleDocumentUpload(documentType),
              icon: const Icon(Icons.refresh, color: MadarTheme.accent, size: 20),
              style: IconButton.styleFrom(
                backgroundColor: MadarTheme.accent.withOpacity(0.05),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDocStatusBadge(DocumentStatus status) {
    final color = _getDocStatusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        _getDocStatusLabel(status),
        style: TextStyle(
          fontFamily: MadarTheme.fontFamily,
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Color _getDocStatusColor(DocumentStatus status) {
    return switch (status) {
      DocumentStatus.notUploaded => MadarTheme.textHint,
      DocumentStatus.uploaded => MadarTheme.warning,
      DocumentStatus.verified => MadarTheme.success,
      DocumentStatus.rejected => MadarTheme.error,
    };
  }

  String _getDocStatusLabel(DocumentStatus status) {
    return switch (status) {
      DocumentStatus.notUploaded => 'لم يُرفع',
      DocumentStatus.uploaded => 'قيد المراجعة',
      DocumentStatus.verified => 'تم التحقق',
      DocumentStatus.rejected => 'مرفوض',
    };
  }

  // ==================== Bottom Navigation ====================

  Widget _buildBottomNavigation(DriverAuthState authState) {
    final isLoading = authState.status == DriverAuthStatus.loading;

    return Container(
      padding: const EdgeInsets.all(MadarTheme.space24),
      decoration: BoxDecoration(
        color: MadarTheme.surface,
        boxShadow: [
          MadarTheme.shadow(
            color: Colors.black.withOpacity(0.05),
            blur: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // Back button
            if (_currentStep > 0)
              Expanded(
                child: MadarButton(
                  label: 'رجوع',
                  isOutlined: true,
                  color: MadarTheme.textSecondary,
                  onPressed: _goToPreviousStep,
                ),
              ),
            if (_currentStep > 0) const SizedBox(width: MadarTheme.space16),

            // Next / Register button
            Expanded(
              flex: _currentStep == 0 ? 1 : 2,
              child: MadarGradientButton(
                label: _currentStep == _totalSteps - 1 ? 'إنشاء حساب' : 'التالي',
                isLoading: isLoading,
                gradientColors: const [MadarTheme.accent, MadarTheme.accentDark],
                onPressed: isLoading ? null : _handleNextStep,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== Navigation ====================

  void _goToStep(int step) {
    setState(() => _currentStep = step);
    _pageController.animateToPage(
      step,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _goToPreviousStep() {
    if (_currentStep > 0) {
      _goToStep(_currentStep - 1);
    }
  }

  void _handleNextStep() {
    final currentFormKey = switch (_currentStep) {
      0 => _step1Key,
      1 => _step2Key,
      2 => _step3Key,
      _ => null,
    };

    if (currentFormKey != null && !currentFormKey.currentState!.validate()) {
      return;
    }

    if (_currentStep == 2) {
      final notUploadedDocs = _documentStatuses.entries
          .where((e) => e.value == DocumentStatus.notUploaded)
          .toList();
      if (notUploadedDocs.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'يمكنك رفع المستندات لاحقاً. جارٍ المتابعة...',
              style: TextStyle(fontFamily: MadarTheme.fontFamily),
            ),
            backgroundColor: MadarTheme.primary,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }

    if (_currentStep < _totalSteps - 1) {
      _goToStep(_currentStep + 1);
    } else {
      _handleRegister();
    }
  }

  // ==================== Registration ====================

  void _handleRegister() {
    ref.read(driverAuthProvider.notifier).register(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
          phone: _phoneController.text.trim(),
          countryCode: '+966',
        );
  }

  // ==================== Document Upload ====================

  Future<void> _handleDocumentUpload(String documentType) async {
    setState(() => _isUploading = true);

    try {
      final apiClient = NestjsApiClient();
      await apiClient.uploadDriverDocument(
        documentType: documentType,
        documentUrl:
            'https://storage.example.com/documents/$documentType/${DateTime.now().millisecondsSinceEpoch}.jpg',
      );

      if (mounted) {
        setState(() {
          _documentStatuses[documentType] = DocumentStatus.uploaded;
          _isUploading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'تم رفع المستند بنجاح',
              style: const TextStyle(fontFamily: MadarTheme.fontFamily),
            ),
            backgroundColor: MadarTheme.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isUploading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'فشل الرفع: $e',
              style: const TextStyle(fontFamily: MadarTheme.fontFamily),
            ),
            backgroundColor: MadarTheme.error,
          ),
        );
      }
    }
  }

  // ==================== Helpers ====================

  IconData _getVehicleIcon(String type) {
    return switch (type) {
      'sedan' => Icons.directions_car,
      'suv' => Icons.airport_shuttle,
      'van' => Icons.airport_shuttle,
      'luxury' => Icons.local_taxi,
      'motorcycle' => Icons.motorcycle,
      'rickshaw' => Icons.pedal_bike,
      'hatchback' => Icons.directions_car,
      _ => Icons.directions_car,
    };
  }
}

/// Document upload status
enum DocumentStatus {
  notUploaded,
  uploaded,
  verified,
  rejected,
}

