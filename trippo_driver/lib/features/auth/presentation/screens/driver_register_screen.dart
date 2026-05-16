import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:trippo_shared/trippo_shared.dart';
import '../../../../core/constants/app_theme.dart';
import '../../../../core/network/nestjs_api_client.dart';
import '../notifiers/driver_auth_notifier.dart';

/// Driver Registration Screen - Multi-step registration form
///
/// Steps:
/// - Step 1: Personal info (name, email, phone, password)
/// - Step 2: Vehicle info (name, plate number, type, color, model, year)
/// - Step 3: Document upload (driving license, vehicle registration, insurance, national ID)
///
/// Features:
/// - Step indicator at top
/// - Back/Next navigation
/// - Form validation at each step
/// - Register via NestJS: POST /auth/register with role='driver'
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

    // Navigate to home on successful registration
    ref.listen<DriverAuthState>(driverAuthProvider, (prev, next) {
      if (next.status == DriverAuthStatus.authenticated) {
        context.go('/home');
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Register as Driver'),
        leading: _currentStep > 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: _goToPreviousStep,
              )
            : null,
      ),
      body: Column(
        children: [
          // Step indicator
          _buildStepIndicator(),

          // Error display
          if (authState.error != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppTheme.spacing12),
              margin: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacing24, vertical: AppTheme.spacing8),
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
                      style:
                          const TextStyle(color: AppTheme.error, fontSize: 14),
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
          horizontal: AppTheme.spacing24, vertical: AppTheme.spacing16),
      child: Column(
        children: [
          Row(
            children: List.generate(_totalSteps, (index) {
              final isCompleted = index < _currentStep;
              final isCurrent = index == _currentStep;

              return Expanded(
                child: Row(
                  children: [
                    // Step circle
                    Expanded(
                      child: Container(
                        height: 4,
                        decoration: BoxDecoration(
                          color: isCompleted || isCurrent
                              ? AppTheme.primary
                              : AppTheme.divider,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    if (index < _totalSteps - 1)
                      const SizedBox(width: 8),
                  ],
                ),
              );
            }),
          ),
          const SizedBox(height: AppTheme.spacing8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStepLabel(0, 'Personal', Icons.person),
              _buildStepLabel(1, 'Vehicle', Icons.directions_car),
              _buildStepLabel(2, 'Documents', Icons.description),
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
                  ? AppTheme.primary
                  : isCurrent
                      ? AppTheme.primary.withOpacity(0.15)
                      : Colors.grey[200],
              shape: BoxShape.circle,
            ),
            child: Center(
              child: isCompleted
                  ? const Icon(Icons.check, color: Colors.white, size: 16)
                  : Icon(icon,
                      size: 14,
                      color: isCurrent
                          ? AppTheme.primary
                          : Colors.grey[500]),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isCurrent ? FontWeight.w600 : FontWeight.normal,
              color: isCurrent
                  ? AppTheme.primary
                  : isCompleted
                      ? AppTheme.textPrimary
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
      padding: const EdgeInsets.all(AppTheme.spacing24),
      child: Form(
        key: _step1Key,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Step title
            const Text('Personal Information', style: AppTheme.heading2),
            const SizedBox(height: AppTheme.spacing8),
            Text(
              'Tell us about yourself to get started',
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
            const SizedBox(height: AppTheme.spacing32),

            // Full name
            TextFormField(
              controller: _nameController,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Full Name',
                prefixIcon: Icon(Icons.person_outlined),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your full name';
                }
                if (value.trim().length < 2) {
                  return 'Name must be at least 2 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: AppTheme.spacing16),

            // Email
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Email Address',
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

            // Phone
            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                prefixIcon: Icon(Icons.phone_outlined),
                hintText: '+1 234 567 8900',
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
            const SizedBox(height: AppTheme.spacing16),

            // Password
            TextFormField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: 'Password',
                prefixIcon: const Icon(Icons.lock_outlined),
                suffixIcon: IconButton(
                  icon: Icon(_obscurePassword
                      ? Icons.visibility_off
                      : Icons.visibility),
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a password';
                }
                if (value.length < 8) {
                  return 'Password must be at least 8 characters';
                }
                if (!value.contains(RegExp(r'[A-Z]'))) {
                  return 'Password must contain at least one uppercase letter';
                }
                if (!value.contains(RegExp(r'[0-9]'))) {
                  return 'Password must contain at least one number';
                }
                return null;
              },
            ),
            const SizedBox(height: AppTheme.spacing16),

            // Confirm Password
            TextFormField(
              controller: _confirmPasswordController,
              obscureText: _obscureConfirmPassword,
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(
                labelText: 'Confirm Password',
                prefixIcon: const Icon(Icons.lock_outlined),
                suffixIcon: IconButton(
                  icon: Icon(_obscureConfirmPassword
                      ? Icons.visibility_off
                      : Icons.visibility),
                  onPressed: () => setState(() =>
                      _obscureConfirmPassword = !_obscureConfirmPassword),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please confirm your password';
                }
                if (value != _passwordController.text) {
                  return 'Passwords do not match';
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
      padding: const EdgeInsets.all(AppTheme.spacing24),
      child: Form(
        key: _step2Key,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Step title
            const Text('Vehicle Information', style: AppTheme.heading2),
            const SizedBox(height: AppTheme.spacing8),
            Text(
              'Add your vehicle details for ride assignments',
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
            const SizedBox(height: AppTheme.spacing32),

            // Vehicle type selector
            Text(
              'Vehicle Type',
              style: AppTheme.bodyMedium
                  .copyWith(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: AppTheme.spacing8),
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
                        color: isSelected ? AppTheme.primary : Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(type.toUpperCase()),
                    ],
                  ),
                  selected: isSelected,
                  onSelected: (_) =>
                      setState(() => _vehicleType = type),
                  selectedColor: AppTheme.primary.withOpacity(0.15),
                  side: BorderSide(
                    color: isSelected ? AppTheme.primary : AppTheme.divider,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: AppTheme.spacing24),

            // Vehicle name (nickname)
            TextFormField(
              controller: _vehicleNameController,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Vehicle Nickname',
                prefixIcon: Icon(Icons.label_outlined),
                hintText: 'e.g., My White Camry',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a vehicle nickname';
                }
                return null;
              },
            ),
            const SizedBox(height: AppTheme.spacing16),

            // Vehicle make/model
            TextFormField(
              controller: _vehicleModelController,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Make & Model',
                prefixIcon: Icon(Icons.directions_car_outlined),
                hintText: 'e.g., Toyota Camry',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter make and model';
                }
                return null;
              },
            ),
            const SizedBox(height: AppTheme.spacing16),

            // Vehicle year
            TextFormField(
              controller: _vehicleYearController,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Year',
                prefixIcon: Icon(Icons.calendar_today_outlined),
                hintText: 'e.g., 2022',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter vehicle year';
                }
                final year = int.tryParse(value.trim());
                if (year == null || year < 2000 || year > DateTime.now().year + 1) {
                  return 'Please enter a valid year (2000+)';
                }
                return null;
              },
            ),
            const SizedBox(height: AppTheme.spacing16),

            // Plate number
            TextFormField(
              controller: _plateNumberController,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Plate Number',
                prefixIcon: Icon(Icons.pin_outlined),
                hintText: 'e.g., ABC 1234',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter plate number';
                }
                return null;
              },
            ),
            const SizedBox(height: AppTheme.spacing16),

            // Color
            TextFormField(
              controller: _vehicleColorController,
              textInputAction: TextInputAction.done,
              decoration: const InputDecoration(
                labelText: 'Color',
                prefixIcon: Icon(Icons.palette_outlined),
                hintText: 'e.g., White',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter vehicle color';
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
      padding: const EdgeInsets.all(AppTheme.spacing24),
      child: Form(
        key: _step3Key,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Step title
            const Text('Upload Documents', style: AppTheme.heading2),
            const SizedBox(height: AppTheme.spacing8),
            Text(
              'Upload required documents for verification',
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
            const SizedBox(height: AppTheme.spacing8),

            // Info box
            Container(
              padding: const EdgeInsets.all(AppTheme.spacing12),
              decoration: BoxDecoration(
                color: AppTheme.info.withOpacity(0.08),
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                border: Border.all(color: AppTheme.info.withOpacity(0.3)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: AppTheme.info, size: 20),
                  SizedBox(width: AppTheme.spacing8),
                  Expanded(
                    child: Text(
                      'You can upload documents later from your profile after registration. Complete registration to get started.',
                      style: TextStyle(fontSize: 12, color: AppTheme.info),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppTheme.spacing24),

            // Document upload cards
            _buildDocumentUploadCard(
              documentType: 'driving_license',
              title: 'Driving License',
              subtitle: 'Valid driving license for your vehicle type',
              icon: Icons.badge_outlined,
            ),
            const SizedBox(height: AppTheme.spacing12),

            _buildDocumentUploadCard(
              documentType: 'vehicle_registration',
              title: 'Vehicle Registration',
              subtitle: 'Current vehicle registration document',
              icon: Icons.description_outlined,
            ),
            const SizedBox(height: AppTheme.spacing12),

            _buildDocumentUploadCard(
              documentType: 'insurance',
              title: 'Insurance',
              subtitle: 'Valid vehicle insurance certificate',
              icon: Icons.shield_outlined,
            ),
            const SizedBox(height: AppTheme.spacing12),

            _buildDocumentUploadCard(
              documentType: 'national_id',
              title: 'National ID',
              subtitle: 'Government-issued identification',
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

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacing16),
        child: Row(
          children: [
            // Icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: _getDocStatusColor(status).withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              ),
              child: Icon(icon, color: _getDocStatusColor(status), size: 24),
            ),
            const SizedBox(width: AppTheme.spacing12),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTheme.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  )),
                  const SizedBox(height: 2),
                  Text(subtitle, style: AppTheme.bodySmall),
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
                    : const Icon(Icons.upload_file, color: AppTheme.primary),
                style: IconButton.styleFrom(
                  backgroundColor: AppTheme.primary.withOpacity(0.1),
                ),
              )
            else
              IconButton(
                onPressed: () => _handleDocumentUpload(documentType),
                icon: const Icon(Icons.refresh, color: AppTheme.primary, size: 20),
                style: IconButton.styleFrom(
                  backgroundColor: AppTheme.primary.withOpacity(0.05),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDocStatusBadge(DocumentStatus status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: _getDocStatusColor(status).withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        _getDocStatusLabel(status),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: _getDocStatusColor(status),
        ),
      ),
    );
  }

  Color _getDocStatusColor(DocumentStatus status) {
    return switch (status) {
      DocumentStatus.notUploaded => Colors.grey,
      DocumentStatus.uploaded => AppTheme.warning,
      DocumentStatus.verified => AppTheme.success,
      DocumentStatus.rejected => AppTheme.error,
    };
  }

  String _getDocStatusLabel(DocumentStatus status) {
    return switch (status) {
      DocumentStatus.notUploaded => 'NOT UPLOADED',
      DocumentStatus.uploaded => 'PENDING REVIEW',
      DocumentStatus.verified => 'VERIFIED',
      DocumentStatus.rejected => 'REJECTED',
    };
  }

  // ==================== Bottom Navigation ====================

  Widget _buildBottomNavigation(DriverAuthState authState) {
    final isLoading = authState.status == DriverAuthStatus.loading;

    return Container(
      padding: const EdgeInsets.all(AppTheme.spacing24),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
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
                child: OutlinedButton(
                  onPressed: _goToPreviousStep,
                  child: const Text('Back'),
                ),
              ),
            if (_currentStep > 0)
              const SizedBox(width: AppTheme.spacing16),

            // Next / Register button
            Expanded(
              flex: _currentStep == 0 ? 1 : 2,
              child: ElevatedButton(
                onPressed: isLoading ? null : _handleNextStep,
                child: isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : Text(
                        _currentStep == _totalSteps - 1
                            ? 'Register as Driver'
                            : 'Continue',
                      ),
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
    // Validate current step
    final currentFormKey = switch (_currentStep) {
      0 => _step1Key,
      1 => _step2Key,
      2 => _step3Key,
      _ => null,
    };

    if (currentFormKey != null && !currentFormKey.currentState!.validate()) {
      return;
    }

    // Step 3: Validate documents uploaded
    if (_currentStep == 2) {
      final notUploadedDocs = _documentStatuses.entries
          .where((e) => e.value == DocumentStatus.notUploaded)
          .toList();
      if (notUploadedDocs.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Please upload: ${notUploadedDocs.map((e) => e.key.replaceAll('_', ' ')).join(", ")}',
            ),
            backgroundColor: AppTheme.warning,
          ),
        );
        return;
      }
    }

    if (_currentStep < _totalSteps - 1) {
      // Go to next step
      _goToStep(_currentStep + 1);
    } else {
      // Submit registration
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
          countryCode: '+1',
        );
  }

  // ==================== Document Upload ====================

  Future<void> _handleDocumentUpload(String documentType) async {
    setState(() => _isUploading = true);

    try {
      // In production, this would use image_picker to select a file,
      // then upload to MinIO/S3, and send the URL to NestJS.
      // For now, we simulate a successful upload.
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
              '${documentType.replaceAll('_', ' ').toUpperCase()} uploaded successfully',
            ),
            backgroundColor: AppTheme.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isUploading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Upload failed: $e'),
            backgroundColor: AppTheme.error,
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
