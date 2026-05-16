import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trippo_shared/trippo_shared.dart';
import '../../../../core/constants/app_theme.dart';
import '../../../../core/network/nestjs_api_client.dart';

/// Notifications API Client Provider
final notificationApiProvider = Provider<NestjsApiClient>((ref) => NestjsApiClient());

/// Notifications State Provider
final notificationsProvider =
    StateNotifierProvider<NotificationsNotifier, NotificationsState>((ref) {
  return NotificationsNotifier(ref.read(notificationApiProvider));
});

/// Notifications State
class NotificationsState {
  final List<NotificationModel> notifications;
  final bool isLoading;
  final String? error;
  final bool hasMore;

  const NotificationsState({
    this.notifications = const [],
    this.isLoading = false,
    this.error,
    this.hasMore = true,
  });

  NotificationsState copyWith({
    List<NotificationModel>? notifications,
    bool? isLoading,
    String? error,
    bool? hasMore,
  }) =>
      NotificationsState(
        notifications: notifications ?? this.notifications,
        isLoading: isLoading ?? this.isLoading,
        error: error,
        hasMore: hasMore ?? this.hasMore,
      );

  int get unreadCount =>
      notifications.where((n) => n.status == NotificationStatus.unread).length;
}

/// Notifications Notifier
class NotificationsNotifier extends StateNotifier<NotificationsState> {
  final NestjsApiClient _apiClient;
  int _currentPage = 1;

  NotificationsNotifier(this._apiClient) : super(const NotificationsState());

  /// Load notifications from NestJS: GET /notifications
  Future<void> loadNotifications({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
    }

    state = state.copyWith(isLoading: true, error: null);
    try {
      final notifications =
          await _apiClient.getNotifications(page: _currentPage);

      if (mounted) {
        state = state.copyWith(
          notifications: refresh
              ? notifications
              : [...state.notifications, ...notifications],
          isLoading: false,
          hasMore: notifications.isNotEmpty,
        );
        _currentPage++;
      }
    } catch (e) {
      if (mounted) {
        state = state.copyWith(isLoading: false, error: e.toString());
      }
    }
  }

  /// Mark a single notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      await _apiClient.dio.patch('/notifications/$notificationId/read');

      final updated = state.notifications.map((n) {
        if (n.id == notificationId) {
          return n.copyWith(
            status: NotificationStatus.read,
            readAt: DateTime.now(),
          );
        }
        return n;
      }).toList();

      state = state.copyWith(notifications: updated);
    } catch (_) {}
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead() async {
    try {
      await _apiClient.dio.patch('/notifications/read-all');

      final updated = state.notifications
          .map((n) => n.copyWith(
                status: NotificationStatus.read,
                readAt: DateTime.now(),
              ))
          .toList();

      state = state.copyWith(notifications: updated);
    } catch (_) {}
  }

  /// Load more notifications (pagination)
  Future<void> loadMore() async {
    if (state.isLoading || !state.hasMore) return;
    await loadNotifications();
  }
}

/// Notification Screen - In-app notifications
///
/// Features: notification list, unread/read distinction,
/// mark all as read, pull to refresh, empty state, type-based icons.
/// Notifications fetched via NestJS: GET /notifications
class NotificationScreen extends ConsumerWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifState = ref.watch(notificationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          if (notifState.unreadCount > 0)
            TextButton(
              onPressed: () =>
                  ref.read(notificationsProvider.notifier).markAllAsRead(),
              child: const Text('Mark all read'),
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref
            .read(notificationsProvider.notifier)
            .loadNotifications(refresh: true),
        color: AppTheme.primary,
        child: _buildBody(context, ref, notifState),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    WidgetRef ref,
    NotificationsState state,
  ) {
    if (state.isLoading && state.notifications.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null && state.notifications.isEmpty) {
      return _buildErrorState(context, ref, state.error!);
    }

    if (state.notifications.isEmpty) {
      return _buildEmptyState(context);
    }

    return ListView.separated(
      padding: const EdgeInsets.all(AppTheme.spacing16),
      itemCount: state.notifications.length + (state.hasMore ? 1 : 0),
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        if (index >= state.notifications.length) {
          // Load more trigger
          Future.microtask(() =>
              ref.read(notificationsProvider.notifier).loadMore());
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        return _buildNotificationCard(
            context, ref, state.notifications[index]);
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(
          height: MediaQuery.of(
                  NavigationService.navigatorKey.currentContext ?? context)
              .size
              .height *
              0.6,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.notifications_none_rounded,
                    size: 80, color: Colors.grey[300]),
                const SizedBox(height: 16),
                Text(
                  'No Notifications',
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'You\'re all caught up! Notifications will appear here.',
                  style: TextStyle(color: Colors.grey[400], fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState(
      BuildContext context, WidgetRef ref, String error) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.6,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline,
                    size: 64, color: AppTheme.error),
                const SizedBox(height: 16),
                const Text(
                  'Failed to load notifications',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Text(error,
                    style: AppTheme.bodySmall, textAlign: TextAlign.center),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => ref
                      .read(notificationsProvider.notifier)
                      .loadNotifications(refresh: true),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNotificationCard(
    BuildContext context,
    WidgetRef ref,
    NotificationModel notification,
  ) {
    final isUnread = notification.status == NotificationStatus.unread;

    return Dismissible(
      key: ValueKey(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppTheme.error.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        ),
        child: const Icon(Icons.delete, color: AppTheme.error),
      ),
      onDismissed: (_) {
        // Delete notification via API
        ref.read(notificationApiProvider).dio.delete('/notifications/${notification.id}');
      },
      child: Card(
        color: isUnread ? AppTheme.primary.withOpacity(0.03) : AppTheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          side: isUnread
              ? const BorderSide(color: AppTheme.primary, width: 1)
              : BorderSide.none,
        ),
        child: InkWell(
          onTap: () => _handleNotificationTap(context, ref, notification),
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.spacing16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Type icon
                _buildTypeIcon(notification.type),
                const SizedBox(width: AppTheme.spacing12),
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              notification.title,
                              style: AppTheme.bodyMedium.copyWith(
                                fontWeight: isUnread
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (isUnread)
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: AppTheme.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        notification.body,
                        style: AppTheme.bodySmall,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _formatTimestamp(notification.createdAt),
                        style: AppTheme.caption,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTypeIcon(NotificationType type) {
    final config = _getTypeConfig(type);
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: config.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
      ),
      child: Icon(config.icon, color: config.color, size: 20),
    );
  }

  _NotificationTypeConfig _getTypeConfig(NotificationType type) {
    return switch (type) {
      NotificationType.tripUpdate => _NotificationTypeConfig(
          icon: Icons.directions_car,
          color: AppTheme.info,
        ),
      NotificationType.driverAssigned => _NotificationTypeConfig(
          icon: Icons.person_pin,
          color: AppTheme.primary,
        ),
      NotificationType.driverArriving => _NotificationTypeConfig(
          icon: Icons.navigation,
          color: AppTheme.primary,
        ),
      NotificationType.driverArrived => _NotificationTypeConfig(
          icon: Icons.location_on,
          color: AppTheme.primary,
        ),
      NotificationType.tripStarted => _NotificationTypeConfig(
          icon: Icons.play_circle_fill,
          color: AppTheme.primary,
        ),
      NotificationType.tripCompleted => _NotificationTypeConfig(
          icon: Icons.check_circle,
          color: AppTheme.success,
        ),
      NotificationType.tripCancelled => _NotificationTypeConfig(
          icon: Icons.cancel,
          color: AppTheme.error,
        ),
      NotificationType.paymentReceived => _NotificationTypeConfig(
          icon: Icons.payment,
          color: AppTheme.success,
        ),
      NotificationType.walletUpdate => _NotificationTypeConfig(
          icon: Icons.account_balance_wallet,
          color: AppTheme.accent,
        ),
      NotificationType.withdrawalStatus => _NotificationTypeConfig(
          icon: Icons.account_balance,
          color: AppTheme.accent,
        ),
      NotificationType.promotion => _NotificationTypeConfig(
          icon: Icons.local_offer,
          color: AppTheme.warning,
        ),
      NotificationType.system => _NotificationTypeConfig(
          icon: Icons.info,
          color: AppTheme.info,
        ),
      NotificationType.documentVerification => _NotificationTypeConfig(
          icon: Icons.verified,
          color: AppTheme.info,
        ),
      NotificationType.ratingReminder => _NotificationTypeConfig(
          icon: Icons.star,
          color: Colors.amber,
        ),
    };
  }

  void _handleNotificationTap(
    BuildContext context,
    WidgetRef ref,
    NotificationModel notification,
  ) {
    // Mark as read
    if (notification.status == NotificationStatus.unread) {
      ref.read(notificationsProvider.notifier).markAsRead(notification.id);
    }

    // Navigate based on notification type and data
    final data = notification.data;
    if (data == null) return;

    switch (notification.type) {
      case NotificationType.tripUpdate:
      case NotificationType.driverAssigned:
      case NotificationType.driverArriving:
      case NotificationType.driverArrived:
      case NotificationType.tripStarted:
      case NotificationType.tripCompleted:
      case NotificationType.tripCancelled:
        if (data.containsKey('tripId')) {
          // Navigate to trip detail
          // context.go('/trip/${data['tripId']}');
        }
        break;
      case NotificationType.paymentReceived:
      case NotificationType.walletUpdate:
      case NotificationType.withdrawalStatus:
        // Navigate to wallet
        // context.go('/wallet');
        break;
      case NotificationType.promotion:
        // Show promotion details
        break;
      case NotificationType.system:
        // Show system announcement
        break;
      default:
        break;
    }
  }

  String _formatTimestamp(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }
}

/// Helper class for notification type visual config
class _NotificationTypeConfig {
  final IconData icon;
  final Color color;

  const _NotificationTypeConfig({
    required this.icon,
    required this.color,
  });
}

/// Simple navigation service for context-free navigation
class NavigationService {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();
}
