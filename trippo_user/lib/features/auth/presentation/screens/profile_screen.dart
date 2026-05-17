import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trippo_shared/trippo_shared.dart';
import '../../../../core/constants/app_theme.dart';
import '../../../../core/network/nestjs_api_client.dart';
import '../../../auth/presentation/notifiers/auth_notifier.dart';

/// Profile API Client Provider
final profileApiProvider = Provider<NestjsApiClient>((ref) => NestjsApiClient());

/// Notification Preferences Provider
final notifPrefsProvider =
    FutureProvider<NotificationPreferences>((ref) async {
  final apiClient = ref.read(profileApiProvider);
  return apiClient.getNotificationPreferences();
});

/// User Profile Screen - Complete profile management
///
/// Features: profile editing, password change, favorite addresses,
/// notification preferences, language selection, app info, logout, delete account.
/// All changes saved via NestJS: PUT /users/profile
class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isEditing = false;
  bool _isSaving = false;
  bool _isChangingPassword = false;
  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  // Notification toggles
  bool _pushEnabled = true;
  bool _tripUpdatesEnabled = true;
  bool _promotionsEnabled = true;
  bool _walletUpdatesEnabled = true;
  bool _systemAlertsEnabled = true;

  String _selectedLanguage = 'en';

  final _languages = const [
    ('en', 'English', '🇺🇸'),
    ('ar', 'العربية', '🇸🇦'),
    ('fr', 'Français', '🇫🇷'),
    ('es', 'Español', '🇪🇸'),
    ('ur', 'اردو', '🇵🇰'),
    ('hi', 'हिन्दी', '🇮🇳'),
  ];

  // Favorite addresses
  final List<FavoriteAddress> _favoriteAddresses = [];

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
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    try {
      final apiClient = ref.read(profileApiProvider);
      final user = await apiClient.getUserProfile();
      if (mounted) {
        setState(() {
          _nameController.text = user.name;
          _phoneController.text = user.phone ?? '';
          _emailController.text = user.email;
          _selectedLanguage = user.preferredLanguage;
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
      final apiClient = ref.read(profileApiProvider);
      final updatedUser = await apiClient.updateUserProfile({
        'name': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'preferredLanguage': _selectedLanguage,
      });

      // Update notification preferences
      try {
        await apiClient.updateNotificationPreferences(NotificationPreferences(
          userId: updatedUser.id,
          pushEnabled: _pushEnabled,
          tripUpdatesEnabled: _tripUpdatesEnabled,
          promotionsEnabled: _promotionsEnabled,
          walletUpdatesEnabled: _walletUpdatesEnabled,
          systemAlertsEnabled: _systemAlertsEnabled,
        ));
      } catch (_) {}

      if (mounted) {
        setState(() {
          _isEditing = false;
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

  Future<void> _changePassword() async {
    if (_newPasswordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Passwords do not match'),
          backgroundColor: AppTheme.error,
        ),
      );
      return;
    }

    if (_newPasswordController.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password must be at least 6 characters'),
          backgroundColor: AppTheme.error,
        ),
      );
      return;
    }

    setState(() => _isChangingPassword = true);
    try {
      final apiClient = ref.read(profileApiProvider);
      await apiClient.dio.put('/users/profile', data: {
        'currentPassword': _currentPasswordController.text,
        'newPassword': _newPasswordController.text,
      });

      if (mounted) {
        setState(() => _isChangingPassword = false);
        _currentPasswordController.clear();
        _newPasswordController.clear();
        _confirmPasswordController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password changed successfully'),
            backgroundColor: AppTheme.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isChangingPassword = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to change password: $e'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    }
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account?'),
        content: const Text(
          'This action is permanent and cannot be undone. All your data, '
          'trip history, and wallet balance will be permanently deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _deleteAccount();
            },
            style: TextButton.styleFrom(foregroundColor: AppTheme.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteAccount() async {
    try {
      final apiClient = ref.read(profileApiProvider);
      await apiClient.dio.delete(ApiConstants.deleteAccount);
      ref.read(authProvider.notifier).logout();
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete account: $e'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    }
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout?'),
        content: const Text('Are you sure you want to logout?'),
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
      ref.read(authProvider.notifier).logout();
      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  void _showAddAddressSheet() {
    final addressController = TextEditingController();
    final labelController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(AppTheme.radiusXLarge)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Add Favorite Address',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: labelController,
              decoration: const InputDecoration(
                labelText: 'Label (e.g., Home, Work)',
                prefixIcon: Icon(Icons.label),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: addressController,
              decoration: const InputDecoration(
                labelText: 'Address',
                prefixIcon: Icon(Icons.location_on),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (labelController.text.isNotEmpty &&
                      addressController.text.isNotEmpty) {
                    setState(() {
                      _favoriteAddresses.add(FavoriteAddress(
                        label: labelController.text,
                        address: addressController.text,
                      ));
                    });
                    Navigator.pop(context);
                  }
                },
                child: const Text('Add Address'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final user = authState.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => setState(() => _isEditing = true),
            )
          else
            TextButton(
              onPressed: _isSaving ? null : _saveProfile,
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
            _buildProfileHeader(user),
            const SizedBox(height: AppTheme.spacing24),

            // Edit Profile Form (when editing)
            if (_isEditing) ...[
              _buildEditForm(),
              const SizedBox(height: AppTheme.spacing24),
            ],

            // Change Password Section
            _buildChangePasswordSection(),
            const SizedBox(height: AppTheme.spacing24),

            // Favorite Addresses
            _buildFavoriteAddresses(),
            const SizedBox(height: AppTheme.spacing24),

            // Notification Preferences
            _buildNotificationPreferences(),
            const SizedBox(height: AppTheme.spacing24),

            // Language Selection
            _buildLanguageSelection(),
            const SizedBox(height: AppTheme.spacing24),

            // App Info
            _buildAppInfoSection(),
            const SizedBox(height: AppTheme.spacing32),

            // Logout Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _logout,
                icon: const Icon(Icons.logout),
                label: const Text('Logout'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.error,
                  side: const BorderSide(color: AppTheme.error),
                ),
              ),
            ),
            const SizedBox(height: AppTheme.spacing12),

            // Delete Account
            SizedBox(
              width: double.infinity,
              child: TextButton.icon(
                onPressed: _showDeleteAccountDialog,
                icon: const Icon(Icons.delete_forever, color: AppTheme.error),
                label: const Text(
                  'Delete Account',
                  style: TextStyle(color: AppTheme.error),
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

  Widget _buildProfileHeader(UserModel? user) {
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
                color: AppTheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: user?.profileImageUrl != null &&
                      user!.profileImageUrl!.isNotEmpty
                  ? ClipOval(
                      child: Image.network(
                        user.profileImageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _buildAvatarFallback(user),
                      ),
                    )
                  : _buildAvatarFallback(user),
            ),
            const SizedBox(width: AppTheme.spacing16),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user?.name ?? 'User',
                    style: AppTheme.heading3,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user?.email ?? '',
                    style: AppTheme.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (user?.phone != null && user!.phone!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      user.phone!,
                      style: AppTheme.bodySmall,
                    ),
                  ],
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildInfoChip(
                          '${user?.totalRides ?? 0} rides', Icons.directions_car),
                      const SizedBox(width: 8),
                      _buildInfoChip(
                          '${user?.averageRating.toStringAsFixed(1) ?? '0.0'} ★',
                          Icons.star),
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

  Widget _buildAvatarFallback(UserModel? user) {
    return Center(
      child: Text(
        user?.name.isNotEmpty == true ? user!.name[0].toUpperCase() : '?',
        style: const TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: AppTheme.primary,
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

  // ==================== Edit Form ====================

  Widget _buildEditForm() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacing16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Edit Profile', style: AppTheme.heading3),
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

  // ==================== Change Password ====================

  Widget _buildChangePasswordSection() {
    return Card(
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: AppTheme.spacing16),
        childrenPadding: const EdgeInsets.fromLTRB(
          AppTheme.spacing16,
          0,
          AppTheme.spacing16,
          AppTheme.spacing16,
        ),
        leading: const Icon(Icons.lock_outline, color: AppTheme.primary),
        title: const Text('Change Password', style: AppTheme.bodyLarge),
        children: [
          TextField(
            controller: _currentPasswordController,
            obscureText: _obscureCurrentPassword,
            decoration: InputDecoration(
              labelText: 'Current Password',
              prefixIcon: const Icon(Icons.lock_outlined),
              suffixIcon: IconButton(
                icon: Icon(_obscureCurrentPassword
                    ? Icons.visibility_off
                    : Icons.visibility),
                onPressed: () => setState(
                    () => _obscureCurrentPassword = !_obscureCurrentPassword),
              ),
            ),
          ),
          const SizedBox(height: AppTheme.spacing12),
          TextField(
            controller: _newPasswordController,
            obscureText: _obscureNewPassword,
            decoration: InputDecoration(
              labelText: 'New Password',
              prefixIcon: const Icon(Icons.lock_outlined),
              suffixIcon: IconButton(
                icon: Icon(_obscureNewPassword
                    ? Icons.visibility_off
                    : Icons.visibility),
                onPressed: () => setState(
                    () => _obscureNewPassword = !_obscureNewPassword),
              ),
            ),
          ),
          const SizedBox(height: AppTheme.spacing12),
          TextField(
            controller: _confirmPasswordController,
            obscureText: _obscureConfirmPassword,
            decoration: InputDecoration(
              labelText: 'Confirm New Password',
              prefixIcon: const Icon(Icons.lock_outlined),
              suffixIcon: IconButton(
                icon: Icon(_obscureConfirmPassword
                    ? Icons.visibility_off
                    : Icons.visibility),
                onPressed: () => setState(() =>
                    _obscureConfirmPassword = !_obscureConfirmPassword),
              ),
            ),
          ),
          const SizedBox(height: AppTheme.spacing16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isChangingPassword ? null : _changePassword,
              child: _isChangingPassword
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child:
                          CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Change Password'),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== Favorite Addresses ====================

  Widget _buildFavoriteAddresses() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacing16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Favorite Addresses', style: AppTheme.heading3),
                IconButton(
                  icon: const Icon(Icons.add, color: AppTheme.primary),
                  onPressed: _showAddAddressSheet,
                ),
              ],
            ),
            if (_favoriteAddresses.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'No favorite addresses added yet',
                  style: AppTheme.bodySmall,
                ),
              )
            else
              ..._favoriteAddresses.map((addr) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      addr.label.toLowerCase() == 'home'
                          ? Icons.home
                          : addr.label.toLowerCase() == 'work'
                              ? Icons.work
                              : Icons.location_on,
                      color: AppTheme.primary,
                    ),
                    title: Text(addr.label,
                        style: const TextStyle(fontWeight: FontWeight.w500)),
                    subtitle: Text(addr.address,
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline, size: 20),
                      onPressed: () {
                        setState(() => _favoriteAddresses.remove(addr));
                      },
                    ),
                  )),
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
              subtitle: 'Driver assigned, arriving, trip status',
              value: _tripUpdatesEnabled,
              onChanged: (v) => setState(() => _tripUpdatesEnabled = v),
            ),
            _buildToggleTile(
              title: 'Promotions',
              subtitle: 'Discounts, promo codes, special offers',
              value: _promotionsEnabled,
              onChanged: (v) => setState(() => _promotionsEnabled = v),
            ),
            _buildToggleTile(
              title: 'Wallet Updates',
              subtitle: 'Payment received, withdrawal status',
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

  // ==================== Language Selection ====================

  Widget _buildLanguageSelection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacing16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Language', style: AppTheme.heading3),
            const SizedBox(height: AppTheme.spacing8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _languages.map((lang) {
                final isSelected = _selectedLanguage == lang.$1;
                return ChoiceChip(
                  label: Text('${lang.$3} ${lang.$2}'),
                  selected: isSelected,
                  onSelected: (_) =>
                      setState(() => _selectedLanguage = lang.$1),
                  selectedColor: AppTheme.primary.withOpacity(0.15),
                  side: BorderSide(
                    color:
                        isSelected ? AppTheme.primary : AppTheme.dividerColor,
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== App Info ====================

  Widget _buildAppInfoSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacing16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('About', style: AppTheme.heading3),
            const SizedBox(height: AppTheme.spacing8),
            _buildInfoRow('App Version', '2.0.0'),
            _buildInfoRow('Terms of Service', '', onTap: () {}),
            _buildInfoRow('Privacy Policy', '', onTap: () {}),
            _buildInfoRow('Help & Support', '', onTap: () {}),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Expanded(
              child: Text(label, style: AppTheme.bodyMedium),
            ),
            if (value.isNotEmpty)
              Text(value, style: AppTheme.bodySmall),
            if (onTap != null)
              const Icon(Icons.chevron_right,
                  size: 20, color: AppTheme.textHint),
          ],
        ),
      ),
    );
  }
}

/// Simple model for favorite addresses
class FavoriteAddress {
  final String label;
  final String address;

  const FavoriteAddress({
    required this.label,
    required this.address,
  });
}
