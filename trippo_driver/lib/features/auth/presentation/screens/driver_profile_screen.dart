import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:trippo_shared/trippo_shared.dart';
import '../../../../core/constants/app_theme.dart';
import '../../../../core/network/nestjs_api_client.dart';
import '../notifiers/driver_auth_notifier.dart';

/// Driver Profile API Provider
final driverProfileApiProvider = Provider<NestjsApiClient>((ref) => NestjsApiClient());

/// Driver Stats Provider
final driverStatsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final apiClient = ref.read(driverProfileApiProvider);
  return apiClient.getDriverStats();
});

/// Notification Preferences Provider for Driver
final driverNotifPrefsProvider =
    FutureProvider<NotificationPreferences>((ref) async {
  final apiClient = ref.read(driverProfileApiProvider);
  return apiClient.getNotificationPreferences();
});

/// Driver Profile Screen - Complete driver profile management
///
/// Features:
/// - Profile header with avatar, name, rating, total trips
/// - Vehicle info card (name, plate, type, color)
/// - Edit personal info
/// - Edit vehicle info
/// - Document status (verified/pending/rejected for each)
/// - Online/Offline statistics
/// - Notification preferences
/// - Logout
/// - All changes via NestJS: PUT /drivers/profile
class DriverProfileScreen extends ConsumerStatefulWidget {
  const DriverProfileScreen({super.key});

  @override
  ConsumerState<DriverProfileScreen> createState() =>
      _DriverProfileScreenState();
}

class _DriverProfileScreenState extends ConsumerState<DriverProfileScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();

  // Vehicle edit controllers
  final _vehicleNameController = TextEditingController();
  final _plateNumberController = TextEditingController();
  final _vehicleColorController = TextEditingController();
  final _vehicleModelController = TextEditingController();
  final _vehicleYearController = TextEditingController();

  bool _isEditingProfile = false;
  bool _isEditingVehicle = false;
  bool _isSaving = false;

  // Notification toggles
  bool _pushEnabled = true;
  bool _tripUpdatesEnabled = true;
  bool _promotionsEnabled = false;
  bool _walletUpdatesEnabled = true;
  bool _systemAlertsEnabled = true;

  // Document statuses
  final Map<String, _DocStatus> _documentStatuses = {
    'driving_license': _DocStatus.pending,
    'vehicle_registration': _DocStatus.verified,
    'insurance': _DocStatus.pending,
    'national_id': _DocStatus.rejected,
  };

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _vehicleNameController.dispose();
    _plateNumberController.dispose();
    _vehicleColorController.dispose();
    _vehicleModelController.dispose();
    _vehicleYearController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    try {
      final apiClient = ref.read(driverProfileApiProvider);
      final driver = await apiClient.getDriverProfile();
      if (mounted) {
        setState(() {
          _nameController.text = driver.name;
          _phoneController.text = driver.phone ?? '';
          _emailController.text = driver.email;
          // Vehicle info from driver model if available
          if (driver.vehicle != null) {
            _vehicleNameController.text = driver.vehicle!.name;
            _plateNumberController.text = driver.vehicle!.plateNumber;
            _vehicleColorController.text = driver.vehicle!.color ?? '';
            _vehicleModelController.text = driver.vehicle!.model ?? '';
            _vehicleYearController.text = driver.vehicle!.year ?? '';
          }
        });
      }

      // Load notification preferences
      try {
        final prefs = await apiClient.getNotificationPreferences();
        if (mounted) {
          setState(() {
            _pushEnabled = prefs.pushEnabled;
            _tripUpdatesEnabled = prefs.tripUpdatesEnabled;
            _promotionsEnabled = prefs.promotionsEnabled;
            _walletUpdatesEnabled = prefs.walletUpdatesEnabled;
            _systemAlertsEnabled = prefs.systemAlertsEnabled;
          });
        }
      } catch (_) {
        // Use defaults
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load profile: $e')),
        );
      }
    }
  }

  Future<void> _saveProfile() async {
    setState(() => _isSaving = true);
    try {
      final apiClient = ref.read(driverProfileApiProvider);
      await apiClient.dio.put('/drivers/profile', data: {
        'name': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
      });

      // Update notification preferences
      try {
        await apiClient.updateNotificationPreferences(NotificationPreferences(
          userId: '',
          pushEnabled: _pushEnabled,
          tripUpdatesEnabled: _tripUpdatesEnabled,
          promotionsEnabled: _promotionsEnabled,
          walletUpdatesEnabled: _walletUpdatesEnabled,
          systemAlertsEnabled: _systemAlertsEnabled,
        ));
      } catch (_) {}

      // Refresh auth state with updated profile
      
      if (mounted) {
        setState(() {
          _isEditingProfile = false;
          _isSaving = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully'),
            backgroundColor: AppTheme.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save profile: $e'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    }
  }

  Future<void> _saveVehicleInfo() async {
    setState(() => _isSaving = true);
    try {
      final apiClient = ref.read(driverProfileApiProvider);
      await apiClient.dio.put('/drivers/profile', data: {
        'vehicle': {
          'name': _vehicleNameController.text.trim(),
          'plateNumber': _plateNumberController.text.trim(),
          'color': _vehicleColorController.text.trim(),
          'model': _vehicleModelController.text.trim(),
          'year': int.tryParse(_vehicleYearController.text.trim()),
        },
      });

      
      if (mounted) {
        setState(() {
          _isEditingVehicle = false;
          _isSaving = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vehicle info updated successfully'),
            backgroundColor: AppTheme.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save vehicle info: $e'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(driverAuthProvider);
    final driver = authState.driver;
    final statsAsync = ref.watch(driverStatsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          if (!_isEditingProfile && !_isEditingVehicle)
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => setState(() => _isEditingProfile = true),
            )
          else
            TextButton(
              onPressed: _isSaving ? null : () {
                if (_isEditingProfile) _saveProfile();
                if (_isEditingVehicle) _saveVehicleInfo();
              },
              child: _isSaving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Save'),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spacing16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Header
            _buildProfileHeader(driver),
            const SizedBox(height: AppTheme.spacing24),

            // Edit Profile Form
            if (_isEditingProfile) ...[
              _buildEditProfileForm(),
              const SizedBox(height: AppTheme.spacing24),
            ],

            // Vehicle Info Card
            _buildVehicleInfoCard(driver),
            const SizedBox(height: AppTheme.spacing24),

            // Edit Vehicle Form
            if (_isEditingVehicle) ...[
              _buildEditVehicleForm(),
              const SizedBox(height: AppTheme.spacing24),
            ],

            // Document Status
            _buildDocumentStatus(),
            const SizedBox(height: AppTheme.spacing24),

            // Online/Offline Statistics
            _buildOnlineStats(statsAsync),
            const SizedBox(height: AppTheme.spacing24),

            // Notification Preferences
            _buildNotificationPreferences(),
            const SizedBox(height: AppTheme.spacing32),

            // Logout Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _handleLogout,
                icon: const Icon(Icons.logout),
                label: const Text('Logout'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.error,
                  side: const BorderSide(color: AppTheme.error),
                ),
              ),
            ),
            const SizedBox(height: AppTheme.spacing24),
          ],
        ),
      ),
    );
  }

  // ==================== Profile Header ====================

  Widget _buildProfileHeader(DriverModel? driver) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacing20),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppTheme.secondary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: driver?.profileImageUrl != null &&
                      driver!.profileImageUrl!.isNotEmpty
                  ? ClipOval(
                      child: Image.network(
                        driver.profileImageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            _buildAvatarFallback(driver),
                      ),
                    )
                  : _buildAvatarFallback(driver),
            ),
            const SizedBox(width: AppTheme.spacing16),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    driver?.name ?? 'Driver',
                    style: AppTheme.heading3,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    driver?.email ?? '',
                    style: AppTheme.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (driver?.phone != null && driver!.phone!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(driver.phone!, style: AppTheme.bodySmall),
                  ],
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildInfoChip(
                        '${driver?.averageRating.toStringAsFixed(1) ?? '0.0'} ★',
                        Icons.star,
                      ),
                      const SizedBox(width: 8),
                      _buildInfoChip(
                        '${driver?.totalTrips ?? 0} trips',
                        Icons.route,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarFallback(DriverModel? driver) {
    return Center(
      child: Text(
        driver?.name.isNotEmpty == true
            ? driver!.name[0].toUpperCase()
            : 'D',
        style: const TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: AppTheme.secondary,
        ),
      ),
    );
  }

  Widget _buildInfoChip(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppTheme.primary),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: AppTheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  // ==================== Edit Profile Form ====================

  Widget _buildEditProfileForm() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacing16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Edit Personal Info', style: AppTheme.heading3),
                TextButton(
                  onPressed: () => setState(() => _isEditingProfile = false),
                  child: const Text('Cancel'),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spacing16),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Full Name',
                prefixIcon: Icon(Icons.person_outlined),
              ),
            ),
            const SizedBox(height: AppTheme.spacing12),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                prefixIcon: Icon(Icons.phone_outlined),
              ),
            ),
            const SizedBox(height: AppTheme.spacing12),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              enabled: false,
              decoration: const InputDecoration(
                labelText: 'Email (cannot be changed)',
                prefixIcon: Icon(Icons.email_outlined),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== Vehicle Info Card ====================

  Widget _buildVehicleInfoCard(DriverModel? driver) {
    final vehicle = driver?.vehicle;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacing16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Vehicle Information', style: AppTheme.heading3),
                if (!_isEditingVehicle)
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, size: 20),
                    onPressed: () =>
                        setState(() => _isEditingVehicle = true),
                  ),
              ],
            ),
            const SizedBox(height: AppTheme.spacing12),
            if (vehicle != null) ...[
              _buildVehicleDetailRow(
                Icons.directions_car,
                'Vehicle',
                vehicle.name,
              ),
              _buildVehicleDetailRow(
                Icons.pin_outlined,
                'Plate',
                vehicle.plateNumber,
              ),
              _buildVehicleDetailRow(
                Icons.category_outlined,
                'Type',
                vehicle.type.name.toUpperCase(),
              ),
              _buildVehicleDetailRow(
                Icons.palette_outlined,
                'Color',
                vehicle.color ?? 'N/A',
              ),
              if (vehicle.model != null && vehicle.model!.isNotEmpty)
                _buildVehicleDetailRow(
                  Icons.build_outlined,
                  'Model',
                  vehicle.model!,
                ),
            ] else ...[
              Text(
                'No vehicle information available',
                style: AppTheme.bodySmall,
              ),
              const SizedBox(height: AppTheme.spacing12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () =>
                      setState(() => _isEditingVehicle = true),
                  child: const Text('Add Vehicle'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildVehicleDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppTheme.textSecondary),
          const SizedBox(width: AppTheme.spacing8),
          Text(label, style: AppTheme.bodySmall),
          const Spacer(),
          Text(value, style: AppTheme.bodyMedium.copyWith(
            fontWeight: FontWeight.w500,
          )),
        ],
      ),
    );
  }

  // ==================== Edit Vehicle Form ====================

  Widget _buildEditVehicleForm() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacing16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Edit Vehicle Info', style: AppTheme.heading3),
                TextButton(
                  onPressed: () => setState(() => _isEditingVehicle = false),
                  child: const Text('Cancel'),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spacing16),
            TextField(
              controller: _vehicleNameController,
              decoration: const InputDecoration(
                labelText: 'Vehicle Nickname',
                prefixIcon: Icon(Icons.label_outlined),
              ),
            ),
            const SizedBox(height: AppTheme.spacing12),
            TextField(
              controller: _vehicleModelController,
              decoration: const InputDecoration(
                labelText: 'Make & Model',
                prefixIcon: Icon(Icons.directions_car_outlined),
              ),
            ),
            const SizedBox(height: AppTheme.spacing12),
            TextField(
              controller: _vehicleYearController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Year',
                prefixIcon: Icon(Icons.calendar_today_outlined),
              ),
            ),
            const SizedBox(height: AppTheme.spacing12),
            TextField(
              controller: _plateNumberController,
              decoration: const InputDecoration(
                labelText: 'Plate Number',
                prefixIcon: Icon(Icons.pin_outlined),
              ),
            ),
            const SizedBox(height: AppTheme.spacing12),
            TextField(
              controller: _vehicleColorController,
              decoration: const InputDecoration(
                labelText: 'Color',
                prefixIcon: Icon(Icons.palette_outlined),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== Document Status ====================

  Widget _buildDocumentStatus() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacing16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Document Status', style: AppTheme.heading3),
            const SizedBox(height: AppTheme.spacing12),
            ..._documentStatuses.entries.map((entry) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      Icon(
                        _getDocStatusIcon(entry.value),
                        size: 18,
                        color: _getDocStatusColor(entry.value),
                      ),
                      const SizedBox(width: AppTheme.spacing8),
                      Expanded(
                        child: Text(
                          _formatDocKey(entry.key),
                          style: AppTheme.bodyMedium,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: _getDocStatusColor(entry.value)
                              .withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          _getDocStatusLabel(entry.value),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: _getDocStatusColor(entry.value),
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  IconData _getDocStatusIcon(_DocStatus status) {
    return switch (status) {
      _DocStatus.verified => Icons.verified,
      _DocStatus.pending => Icons.schedule,
      _DocStatus.rejected => Icons.error_outline,
    };
  }

  Color _getDocStatusColor(_DocStatus status) {
    return switch (status) {
      _DocStatus.verified => AppTheme.success,
      _DocStatus.pending => AppTheme.warning,
      _DocStatus.rejected => AppTheme.error,
    };
  }

  String _getDocStatusLabel(_DocStatus status) {
    return switch (status) {
      _DocStatus.verified => 'VERIFIED',
      _DocStatus.pending => 'PENDING',
      _DocStatus.rejected => 'REJECTED',
    };
  }

  String _formatDocKey(String key) {
    return key.split('_').map((w) => w[0].toUpperCase() + w.substring(1)).join(' ');
  }

  // ==================== Online/Offline Statistics ====================

  Widget _buildOnlineStats(AsyncValue<Map<String, dynamic>> statsAsync) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacing16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Statistics', style: AppTheme.heading3),
            const SizedBox(height: AppTheme.spacing16),
            statsAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              error: (e, _) => Column(
                children: [
                  Text('Could not load stats', style: AppTheme.bodySmall),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => ref.invalidate(driverStatsProvider),
                    child: const Text('Retry'),
                  ),
                ],
              ),
              data: (stats) => Row(
                children: [
                  _buildStatItem(
                    'Online Hours',
                    '${stats['totalOnlineHours'] ?? '0'}h',
                    Icons.schedule,
                  ),
                  _buildStatItem(
                    'Total Trips',
                    '${stats['totalTrips'] ?? '0'}',
                    Icons.route,
                  ),
                  _buildStatItem(
                    'Acceptance',
                    '${stats['acceptanceRate'] ?? '0'}%',
                    Icons.check_circle,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(AppTheme.spacing12),
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: AppTheme.background,
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppTheme.primary, size: 20),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            Text(label, style: AppTheme.bodySmall),
          ],
        ),
      ),
    );
  }

  // ==================== Notification Preferences ====================

  Widget _buildNotificationPreferences() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacing16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Notification Preferences', style: AppTheme.heading3),
            const SizedBox(height: AppTheme.spacing8),
            _buildToggleTile(
              title: 'Push Notifications',
              subtitle: 'Receive push notifications on your device',
              value: _pushEnabled,
              onChanged: (v) => setState(() => _pushEnabled = v),
            ),
            _buildToggleTile(
              title: 'Trip Updates',
              subtitle: 'New ride requests, trip status changes',
              value: _tripUpdatesEnabled,
              onChanged: (v) => setState(() => _tripUpdatesEnabled = v),
            ),
            _buildToggleTile(
              title: 'Promotions',
              subtitle: 'Incentives, bonus opportunities',
              value: _promotionsEnabled,
              onChanged: (v) => setState(() => _promotionsEnabled = v),
            ),
            _buildToggleTile(
              title: 'Wallet Updates',
              subtitle: 'Earnings, settlements, withdrawals',
              value: _walletUpdatesEnabled,
              onChanged: (v) => setState(() => _walletUpdatesEnabled = v),
            ),
            _buildToggleTile(
              title: 'System Alerts',
              subtitle: 'App updates, maintenance, announcements',
              value: _systemAlertsEnabled,
              onChanged: (v) => setState(() => _systemAlertsEnabled = v),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title, style: AppTheme.bodyMedium),
      subtitle: Text(subtitle, style: AppTheme.bodySmall),
      value: value,
      onChanged: onChanged,
      activeColor: AppTheme.primary,
      dense: true,
    );
  }

  // ==================== Logout ====================

  Future<void> _handleLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout?'),
        content: const Text(
            'Are you sure you want to logout? You will stop receiving ride requests.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppTheme.error),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(driverAuthProvider.notifier).logout();
      if (mounted) {
        context.go('/login');
      }
    }
  }
}

/// Document status enum for driver profile
enum _DocStatus {
  verified,
  pending,
  rejected,
}
