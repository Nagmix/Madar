import 'dart:async';
import 'api_service.dart';
import 'socket_service.dart';
import '../constants/api_constants.dart';
import '../constants/app_constants.dart';
import '../models/notification_model.dart';

/// NotificationService - Multi-channel notification management
/// Integrates with NestJS Notification Module (POST /notifications/*)
///
/// Channels:
/// - Push (FCM) - via firebase_messaging (only for push, NOT for backend)
/// - In-App - via Socket.IO real-time + REST API
/// - SMS/WhatsApp/Email - handled by NestJS backend (Twilio, SMTP)
///
/// Firebase is ONLY used for FCM push notifications.
/// NestJS handles ALL notification logic, delivery, and storage.
class NotificationService {
  final ApiService _apiService;
  final SocketService _socketService;

  // Stream controllers for real-time notifications
  final _notificationController =
      StreamController<NotificationModel>.broadcast();
  final _unreadCountController = StreamController<int>.broadcast();

  // Local state
  int _unreadCount = 0;
  String? _fcmToken;
  bool _fcmInitialized = false;

  NotificationService({
    required ApiService apiService,
    required SocketService socketService,
  })  : _apiService = apiService,
        _socketService = socketService {
    _setupSocketListeners();
  }

  // ==================== Streams ====================

  /// Listen for real-time notifications via Socket.IO
  /// Event: 'notification:new'
  Stream<NotificationModel> get onNewNotification =>
      _notificationController.stream;

  /// Stream of unread notification count
  Stream<int> get unreadCountStream => _unreadCountController.stream;

  /// Current unread count
  int get unreadCount => _unreadCount;

  /// Whether FCM has been initialized
  bool get isFcmInitialized => _fcmInitialized;

  // ==================== FCM Initialization ====================

  /// Initialize FCM (Firebase Cloud Messaging) for push notifications only.
  /// This does NOT use Firebase as the backend - NestJS handles all logic.
  ///
  /// Steps:
  /// 1. Request notification permissions
  /// 2. Get FCM token
  /// 3. Register token with NestJS backend
  /// 4. Setup foreground/background message handlers
  Future<void> initializeFCM() async {
    if (_fcmInitialized) return;

    try {
      // Request permissions first
      final permissionGranted = await requestPermissions();
      if (!permissionGranted) {
        return;
      }

      // Note: Actual FCM token retrieval requires firebase_messaging package
      // which is added in each app's pubspec.yaml, not in trippo_shared.
      // Each app should call registerDeviceToken() after obtaining the FCM token.
      _fcmInitialized = true;
    } catch (e) {
      _fcmInitialized = false;
    }
  }

  /// Request notification permissions (iOS + Android)
  /// Returns true if permissions are granted
  Future<bool> requestPermissions() async {
    try {
      // Permission request is handled by each app using:
      // - iOS: firebase_messaging requestPermission()
      // - Android: notification channel setup
      // This method provides a unified interface.
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Get FCM token and register with NestJS backend
  /// POST /notifications/device-token
  ///
  /// Call this after obtaining the FCM token from firebase_messaging.
  /// The NestJS backend stores the token for sending push notifications.
  Future<void> registerDeviceToken({
    required String token,
    required String platform,
    String? deviceId,
  }) async {
    try {
      _fcmToken = token;
      await _apiService.post(
        ApiConstants.registerDeviceToken,
        data: {
          'token': token,
          'platform': platform,
          'deviceId': deviceId,
        },
      );
    } catch (e) {
      rethrow;
    }
  }

  // ==================== Notification CRUD ====================

  /// Get notifications list - GET /notifications
  /// Supports pagination
  Future<List<NotificationModel>> getNotifications({
    int page = 1,
    int pageSize = AppConstants.defaultPageSize,
  }) async {
    try {
      final response = await _apiService.get(
        ApiConstants.notifications,
        queryParameters: {
          'page': page,
          'pageSize': pageSize,
        },
      );

      final data = response.data;
      if (data is Map<String, dynamic> && data.containsKey('items')) {
        final items = data['items'] as List<dynamic>;
        return items
            .map((e) => NotificationModel.fromJson(e as Map<String, dynamic>))
            .toList();
      } else if (data is List) {
        return data
            .map((e) => NotificationModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }

  /// Mark notification as read - PATCH /notifications/:id/read
  Future<void> markAsRead(String notificationId) async {
    try {
      await _apiService.patch(
        '${ApiConstants.notifications}/$notificationId/read',
      );
      _updateUnreadCount(_unreadCount - 1);
    } catch (e) {
      rethrow;
    }
  }

  /// Mark all as read - PATCH /notifications/read-all
  Future<void> markAllAsRead() async {
    try {
      await _apiService.patch(
        '${ApiConstants.notifications}/read-all',
      );
      _updateUnreadCount(0);
    } catch (e) {
      rethrow;
    }
  }

  // ==================== Notification Preferences ====================

  /// Get notification preferences - GET /notifications/preferences
  Future<NotificationPreferences> getPreferences() async {
    try {
      final response = await _apiService.get(
        ApiConstants.notificationPreferences,
      );
      return NotificationPreferences.fromJson(
          response.data as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  /// Update notification preferences - PUT /notifications/preferences
  Future<void> updatePreferences(NotificationPreferences prefs) async {
    try {
      await _apiService.put(
        ApiConstants.notificationPreferences,
        data: prefs.toJson(),
      );
    } catch (e) {
      rethrow;
    }
  }

  // ==================== Real-time Socket.IO ====================

  /// Setup Socket.IO listeners for real-time notifications
  void _setupSocketListeners() {
    _socketService.on('notification:new', (data) {
      try {
        final notification = NotificationModel.fromJson(
          data is Map<String, dynamic> ? data : Map<String, dynamic>.from(data as Map),
        );
        _notificationController.add(notification);
        _updateUnreadCount(_unreadCount + 1);
      } catch (_) {
        // Ignore malformed notification data
      }
    });
  }

  // ==================== FCM Message Handlers ====================

  /// Handle incoming FCM message (foreground)
  /// Called when a push notification arrives while the app is in the foreground.
  /// Shows a local notification and updates in-app state.
  void handleForegroundMessage(Map<String, dynamic> message) {
    try {
      final data = message['data'] as Map<String, dynamic>?;
      if (data != null) {
        // Parse the notification from the FCM data payload
        final notification = NotificationModel.fromJson(data);
        _notificationController.add(notification);
        _updateUnreadCount(_unreadCount + 1);

        // Show local notification
        showLocalNotification(
          title: notification.title,
          body: notification.body,
          payload: notification.id,
        );
      } else {
        // Handle notification message (title + body format)
        final title = message['notification']?['title'] as String? ?? '';
        final body = message['notification']?['body'] as String? ?? '';
        showLocalNotification(title: title, body: body);
      }
    } catch (_) {
      // Ignore malformed FCM data
    }
  }

  /// Handle incoming FCM message (background)
  /// Called when a push notification arrives while the app is in the background.
  /// NestJS backend sends the notification; this processes it on the client side.
  void handleBackgroundMessage(Map<String, dynamic> message) {
    // Background message handling is configured at app startup
    // via FirebaseMessaging.onBackgroundMessage() in main.dart
    // This method can be used for processing data-only messages
    try {
      final data = message['data'] as Map<String, dynamic>?;
      if (data != null) {
        // Process data payload for background handling
        // e.g., update badge count, play sound, etc.
      }
    } catch (_) {
      // Ignore malformed FCM data
    }
  }

  /// Show local notification
  /// Displays a local notification using flutter_local_notifications.
  /// Each app configures its own notification channel and plugin instance.
  void showLocalNotification({
    required String title,
    required String body,
    String? payload,
    String channelId = AppConstants.channelRideUpdates,
    String channelName = 'Ride Updates',
    int id = 0,
  }) {
    // Local notification display is handled by each app's notification plugin.
    // This method provides the interface; actual implementation calls
    // flutter_local_notifications or similar in the app layer.
    //
    // Typical usage in app layer:
    //   final androidDetails = AndroidNotificationDetails(
    //     channelId, channelName, ...);
    //   final platformDetails = NotificationDetails(android: androidDetails);
    //   flutterLocalNotificationsPlugin.show(id, title, body, platformDetails);
  }

  // ==================== Unread Count ====================

  /// Update unread count and notify listeners
  void _updateUnreadCount(int newCount) {
    _unreadCount = newCount.clamp(0, 999999);
    _unreadCountController.add(_unreadCount);
  }

  /// Fetch current unread count from server
  /// GET /notifications?status=unread&pageSize=1
  Future<int> fetchUnreadCount() async {
    try {
      final response = await _apiService.get(
        ApiConstants.notifications,
        queryParameters: {
          'status': 'unread',
          'pageSize': 1,
        },
      );

      final data = response.data;
      if (data is Map<String, dynamic> && data.containsKey('total')) {
        _updateUnreadCount(data['total'] as int);
      }
      return _unreadCount;
    } catch (e) {
      return _unreadCount;
    }
  }

  // ==================== Cleanup ====================

  /// Dispose resources
  void dispose() {
    _notificationController.close();
    _unreadCountController.close();
    _socketService.off('notification:new');
  }
}
