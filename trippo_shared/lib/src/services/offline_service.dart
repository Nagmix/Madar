/// Offline Resilience Service - Critical for unreliable networks (Yemen, etc.)
///
/// Provides a comprehensive offline-first layer that ensures the app remains
/// functional even when network connectivity is intermittent or completely
/// unavailable. This is a **production-critical** feature for markets with
/// unreliable connectivity.
///
/// Architecture:
/// ```
///   UI / Business Logic
///         |
///         v
///   OfflineResilienceService  ◄─── Gateway for all network operations
///     ├── 1. Optimistic Update  ──► UI updates immediately
///     ├── 2. Operation Queue    ──► Stores pending operations
///     ├── 3. Local Cache        ──► Caches last-known data
///     ├── 4. Retry Engine       ──► Retries failed operations with backoff
///     ├── 5. Sync Engine        ──► Syncs queue when online
///     └── 6. Conflict Resolver  ──► Handles server-client conflicts
/// ```
///
/// Key Features:
/// - **Optimistic Updates**: UI updates immediately, operations queued for sync.
/// - **Offline Queue**: All write operations are queued and persisted locally.
/// - **Exponential Backoff Retry**: Failed operations retry with backoff.
/// - **Local Cache**: Last-known data is cached for offline access.
/// - **Connectivity Awareness**: Auto-detects online/offline transitions.
/// - **Conflict Resolution**: Server-wins strategy with local rollback.
/// - **Event Bus Integration**: Emits events for sync status changes.
///
/// Usage:
/// ```dart
/// // Execute an operation with offline support
/// await offlineService.execute(
///   operation: OfflineOperation(
///     id: 'pay_trip_123',
///     type: 'POST',
///     path: '/trips/123/pay',
///     data: {'paymentMethod': 'cash'},
///   ),
///   optimisticUpdate: () {
///     // Update UI immediately
///     state = state.copyWith(paymentStatus: PaymentStatus.completed);
///   },
///   rollback: () {
///     // Rollback if operation ultimately fails
///     state = state.copyWith(paymentStatus: PaymentStatus.pending);
///   },
/// );
/// ```
library;

import 'dart:async';
import 'dart:convert';
import 'api_service.dart';
import 'event_bus_service.dart';
import '../constants/api_constants.dart';

// ============================================================================
// Connectivity State
// ============================================================================

/// Represents the current connectivity state of the device.
enum ConnectivityState {
  /// Device has a stable internet connection.
  online,

  /// Device has an unstable/slow connection.
  unstable,

  /// Device has no internet connection.
  offline,

  /// Connectivity state is unknown.
  unknown,
}

// ============================================================================
// Offline Operation
// ============================================================================

/// Represents a single write operation that needs to be synced with the
/// NestJS backend. Operations are queued when offline and executed in
/// order when connectivity is restored.
class OfflineOperation {
  /// Unique identifier for this operation (used for deduplication).
  final String id;

  /// HTTP method: 'POST', 'PUT', 'PATCH', 'DELETE'.
  final String type;

  /// API endpoint path (e.g., '/trips/123/pay').
  final String path;

  /// Request body data.
  final Map<String, dynamic> data;

  /// When this operation was originally created.
  final DateTime createdAt;

  /// Number of retry attempts so far.
  int retryCount;

  /// Maximum number of retries before giving up.
  final int maxRetries;

  /// Priority of this operation (higher = processed first).
  final int priority;

  /// Whether this operation requires authentication.
  final bool requiresAuth;

  /// Optional correlation ID for event bus integration.
  final String? correlationId;

  /// Current status of the operation.
  OfflineOperationStatus status;

  /// Last error message, if any.
  String? lastError;

  /// When the operation was last attempted.
  DateTime? lastAttemptedAt;

  OfflineOperation({
    required this.id,
    required this.type,
    required this.path,
    required this.data,
    DateTime? createdAt,
    this.retryCount = 0,
    this.maxRetries = 5,
    this.priority = 0,
    this.requiresAuth = true,
    this.correlationId,
    this.status = OfflineOperationStatus.pending,
    this.lastError,
    this.lastAttemptedAt,
  }) : createdAt = createdAt ?? DateTime.now().toUtc();

  /// Serialize to JSON for local storage persistence.
  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'path': path,
        'data': data,
        'createdAt': createdAt.toIso8601String(),
        'retryCount': retryCount,
        'maxRetries': maxRetries,
        'priority': priority,
        'requiresAuth': requiresAuth,
        'correlationId': correlationId,
        'status': status.name,
        'lastError': lastError,
        'lastAttemptedAt': lastAttemptedAt?.toIso8601String(),
      };

  /// Deserialize from JSON (local storage).
  factory OfflineOperation.fromJson(Map<String, dynamic> json) {
    return OfflineOperation(
      id: json['id'] as String,
      type: json['type'] as String,
      path: json['path'] as String,
      data: Map<String, dynamic>.from(json['data'] as Map),
      createdAt: DateTime.parse(json['createdAt'] as String),
      retryCount: json['retryCount'] as int? ?? 0,
      maxRetries: json['maxRetries'] as int? ?? 5,
      priority: json['priority'] as int? ?? 0,
      requiresAuth: json['requiresAuth'] as bool? ?? true,
      correlationId: json['correlationId'] as String?,
      status: OfflineOperationStatus.values.firstWhere(
        (s) => s.name == json['status'],
        orElse: () => OfflineOperationStatus.pending,
      ),
      lastError: json['lastError'] as String?,
      lastAttemptedAt: json['lastAttemptedAt'] != null
          ? DateTime.parse(json['lastAttemptedAt'] as String)
          : null,
    );
  }

  /// Create a copy with updated fields.
  OfflineOperation copyWith({
    int? retryCount,
    OfflineOperationStatus? status,
    String? lastError,
    DateTime? lastAttemptedAt,
  }) {
    return OfflineOperation(
      id: id,
      type: type,
      path: path,
      data: data,
      createdAt: createdAt,
      retryCount: retryCount ?? this.retryCount,
      maxRetries: maxRetries,
      priority: priority,
      requiresAuth: requiresAuth,
      correlationId: correlationId,
      status: status ?? this.status,
      lastError: lastError ?? this.lastError,
      lastAttemptedAt: lastAttemptedAt ?? this.lastAttemptedAt,
    );
  }
}

/// Status of an offline operation.
enum OfflineOperationStatus {
  /// Operation is waiting to be executed.
  pending,

  /// Operation is currently being executed.
  inProgress,

  /// Operation completed successfully.
  completed,

  /// Operation failed but will be retried.
  retrying,

  /// Operation failed permanently (max retries exceeded).
  failed,

  /// Operation was cancelled by the user.
  cancelled,
}

// ============================================================================
// Sync Status
// ============================================================================

/// Represents the current synchronization status of the offline queue.
class SyncStatus {
  final ConnectivityState connectivity;
  final int pendingOperations;
  final int completedOperations;
  final int failedOperations;
  final DateTime? lastSyncAt;
  final bool isSyncing;

  const SyncStatus({
    this.connectivity = ConnectivityState.unknown,
    this.pendingOperations = 0,
    this.completedOperations = 0,
    this.failedOperations = 0,
    this.lastSyncAt,
    this.isSyncing = false,
  });

  SyncStatus copyWith({
    ConnectivityState? connectivity,
    int? pendingOperations,
    int? completedOperations,
    int? failedOperations,
    DateTime? lastSyncAt,
    bool? isSyncing,
  }) {
    return SyncStatus(
      connectivity: connectivity ?? this.connectivity,
      pendingOperations: pendingOperations ?? this.pendingOperations,
      completedOperations: completedOperations ?? this.completedOperations,
      failedOperations: failedOperations ?? this.failedOperations,
      lastSyncAt: lastSyncAt ?? this.lastSyncAt,
      isSyncing: isSyncing ?? this.isSyncing,
    );
  }

  bool get isOnline => connectivity == ConnectivityState.online;
  bool get hasPendingWork => pendingOperations > 0;
}

// ============================================================================
// Offline Resilience Service
// ============================================================================

/// The main service that provides offline-first capabilities.
///
/// This service acts as a gateway for all network operations, ensuring they
/// are queued, retried, and synchronized properly even when the network is
/// unreliable or completely unavailable.
///
/// **Critical for Yemen** and similar markets where:
/// - Mobile data coverage is spotty
/// - WiFi is not always available
/// - Network outages are common
/// - Users may have limited data plans
class OfflineResilienceService {
  final ApiService _apiService;
  final TrippoEventBus _eventBus;

  // Operation queue (in-memory; persisted via onQueueChanged callback)
  final List<OfflineOperation> _queue = [];

  // Local cache for offline data access
  final Map<String, _CacheEntry> _cache = {};

  // Connectivity state
  ConnectivityState _connectivity = ConnectivityState.unknown;

  // Sync status stream controller
  final _syncStatusController = StreamController<SyncStatus>.broadcast();

  // Whether a sync is currently in progress
  bool _isSyncing = false;

  // Timer for periodic sync attempts
  Timer? _syncTimer;

  // Timer for connectivity checks
  Timer? _connectivityCheckTimer;

  // Callbacks for persistence
  final Future<void> Function(List<OfflineOperation> queue)? onQueueChanged;
  final Future<void> Function(String key, String value)? onCacheChanged;
  final Future<bool> Function()? connectivityChecker;

  // Retry backoff configuration
  static const List<Duration> _retryBackoff = [
    Duration(seconds: 2),
    Duration(seconds: 5),
    Duration(seconds: 15),
    Duration(seconds: 30),
    Duration(minutes: 1),
    Duration(minutes: 5),
  ];

  /// Maximum cache age before data is considered stale.
  static const Duration maxCacheAge = Duration(hours: 24);

  /// Interval between automatic sync attempts.
  static const Duration syncInterval = Duration(seconds: 30);

  OfflineResilienceService({
    required ApiService apiService,
    required TrippoEventBus eventBus,
    this.onQueueChanged,
    this.onCacheChanged,
    this.connectivityChecker,
  })  : _apiService = apiService,
        _eventBus = eventBus {
    _startPeriodicSync();
  }

  // ==================== Streams ====================

  /// Stream of sync status updates. UI can listen to this to show
  /// sync indicators, offline banners, etc.
  Stream<SyncStatus> get syncStatusStream => _syncStatusController.stream;

  /// Current sync status.
  SyncStatus get currentSyncStatus => SyncStatus(
        connectivity: _connectivity,
        pendingOperations:
            _queue.where((o) => o.status == OfflineOperationStatus.pending).length,
        completedOperations:
            _queue.where((o) => o.status == OfflineOperationStatus.completed).length,
        failedOperations:
            _queue.where((o) => o.status == OfflineOperationStatus.failed).length,
        lastSyncAt: _lastSyncAt,
        isSyncing: _isSyncing,
      );

  DateTime? _lastSyncAt;

  /// Current connectivity state.
  ConnectivityState get connectivity => _connectivity;

  /// Whether the device is currently online.
  bool get isOnline => _connectivity == ConnectivityState.online;

  /// Number of pending operations in the queue.
  int get pendingOperationCount =>
      _queue.where((o) => o.status == OfflineOperationStatus.pending).length;

  // ==================== Connectivity Management ====================

  /// Update the connectivity state. Called by the app's connectivity
  /// monitoring service (e.g., connectivity_plus).
  void updateConnectivity(ConnectivityState state) {
    final wasOffline = _connectivity == ConnectivityState.offline;
    _connectivity = state;

    _emitSyncStatus();

    // If we just came back online, trigger an immediate sync
    if (wasOffline && state == ConnectivityState.online) {
      _eventBus.emit(
        ConnectivityRestoredEvent(
          pendingOperations: pendingOperationCount,
        ),
      );
      syncNow();
    }

    if (state == ConnectivityState.offline) {
      _eventBus.emit(ConnectivityLostEvent());
    }
  }

  /// Check connectivity by pinging the NestJS backend.
  Future<void> checkConnectivity() async {
    try {
      if (connectivityChecker != null) {
        final isOnline = await connectivityChecker!();
        updateConnectivity(
          isOnline ? ConnectivityState.online : ConnectivityState.offline,
        );
        return;
      }

      // Fallback: try to reach the health endpoint
      await _apiService.get('/health');
      updateConnectivity(ConnectivityState.online);
    } catch (_) {
      updateConnectivity(ConnectivityState.offline);
    }
  }

  // ==================== Execute Operation ====================

  /// Execute an operation with offline resilience.
  ///
  /// If the device is online, the operation is executed immediately.
  /// If the device is offline, the operation is queued and will be
  /// executed when connectivity is restored.
  ///
  /// [optimisticUpdate] is called immediately (before the network request)
  /// to update the UI with the expected result.
  ///
  /// [rollback] is called if the operation ultimately fails (after all
  /// retries are exhausted) to revert the optimistic update.
  ///
  /// Returns `true` if the operation was executed immediately and
  /// succeeded, `false` if it was queued for later execution.
  Future<bool> execute({
    required OfflineOperation operation,
    VoidCallback? optimisticUpdate,
    VoidCallback? rollback,
  }) async {
    // Apply optimistic update immediately
    optimisticUpdate?.call();

    if (_connectivity == ConnectivityState.online) {
      // Try to execute immediately
      try {
        await _executeOperation(operation);
        operation = operation.copyWith(status: OfflineOperationStatus.completed);
        _completedOperations.add(operation);
        _lastSyncAt = DateTime.now().toUtc();
        _emitSyncStatus();
        return true;
      } catch (e) {
        // Online but failed — queue for retry
        operation = operation.copyWith(
          status: OfflineOperationStatus.retrying,
          retryCount: operation.retryCount + 1,
          lastError: e.toString(),
          lastAttemptedAt: DateTime.now().toUtc(),
        );

        if (operation.retryCount >= operation.maxRetries) {
          operation = operation.copyWith(status: OfflineOperationStatus.failed);
          rollback?.call();
        }

        _addToQueue(operation, rollback: rollback);
        _emitSyncStatus();
        return false;
      }
    }

    // Offline — queue the operation
    _addToQueue(operation, rollback: rollback);
    _emitSyncStatus();
    return false;
  }

  /// Execute a read operation with offline cache support.
  ///
  /// If the device is online, the data is fetched from the server and
  /// cached locally. If offline, the cached data is returned (if available
  /// and not stale).
  ///
  /// Returns the cached data if offline, or the fresh data if online.
  Future<T?> executeWithCache<T>({
    required String cacheKey,
    required Future<T> Function() fetch,
    Duration? maxAge,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    // Check cache first
    final cached = _cache[cacheKey];
    final age = cached != null ? DateTime.now().difference(cached.cachedAt) : null;
    final isCacheValid = age != null && age <= (maxAge ?? maxCacheAge);

    if (_connectivity != ConnectivityState.online && isCacheValid) {
      // Offline but cache is valid — return cached data
      if (fromJson != null && cached!.data is Map<String, dynamic>) {
        return fromJson(cached.data as Map<String, dynamic>) as T;
      }
      return cached!.data as T;
    }

    if (_connectivity == ConnectivityState.online) {
      try {
        // Online — fetch fresh data
        final data = await fetch();

        // Cache the result
        _cacheData(cacheKey, data);

        return data;
      } catch (e) {
        // Online fetch failed — fall back to cache if available
        if (isCacheValid) {
          if (fromJson != null && cached!.data is Map<String, dynamic>) {
            return fromJson(cached.data as Map<String, dynamic>) as T;
          }
          return cached!.data as T;
        }
        rethrow;
      }
    }

    // Offline and no valid cache
    if (isCacheValid) {
      if (fromJson != null && cached!.data is Map<String, dynamic>) {
        return fromJson(cached.data as Map<String, dynamic>) as T;
      }
      return cached!.data as T;
    }

    return null;
  }

  // ==================== Queue Management ====================

  /// Add an operation to the offline queue.
  void _addToQueue(OfflineOperation operation, {VoidCallback? rollback}) {
    // Check for duplicate operations (same ID)
    final existingIndex = _queue.indexWhere((o) => o.id == operation.id);
    if (existingIndex >= 0) {
      _queue[existingIndex] = operation;
    } else {
      // Insert in priority order (higher priority first)
      int insertIndex = _queue.length;
      for (int i = 0; i < _queue.length; i++) {
        if (_queue[i].priority < operation.priority) {
          insertIndex = i;
          break;
        }
      }
      _queue.insert(insertIndex, operation);
    }

    // Store rollback callback
    if (rollback != null) {
      _rollbacks[operation.id] = rollback;
    }

    _persistQueue();
  }

  /// Remove an operation from the queue.
  void removeOperation(String operationId) {
    _queue.removeWhere((o) => o.id == operationId);
    _rollbacks.remove(operationId);
    _persistQueue();
    _emitSyncStatus();
  }

  /// Cancel a pending operation.
  void cancelOperation(String operationId) {
    final index = _queue.indexWhere((o) => o.id == operationId);
    if (index >= 0) {
      _queue[index] = _queue[index].copyWith(
        status: OfflineOperationStatus.cancelled,
      );
      _persistQueue();
      _emitSyncStatus();
    }
  }

  /// Clear all completed and failed operations from the queue.
  void clearCompletedOperations() {
    _queue.removeWhere((o) =>
        o.status == OfflineOperationStatus.completed ||
        o.status == OfflineOperationStatus.failed ||
        o.status == OfflineOperationStatus.cancelled);
    _persistQueue();
    _emitSyncStatus();
  }

  /// Get all pending operations.
  List<OfflineOperation> get pendingOperations =>
      _queue.where((o) => o.status == OfflineOperationStatus.pending).toList();

  /// Get all operations (for debugging / admin).
  List<OfflineOperation> get allOperations => List.unmodifiable(_queue);

  // ==================== Sync Engine ====================

  /// Trigger an immediate sync of all pending operations.
  ///
  /// This is called automatically when connectivity is restored,
  /// but can also be called manually (e.g., pull-to-refresh).
  Future<void> syncNow() async {
    if (_isSyncing) return;
    if (_connectivity != ConnectivityState.online) return;

    _isSyncing = true;
    _emitSyncStatus();

    try {
      // Sort queue by priority (descending) and then by creation time (ascending)
      final pendingOps = _queue
          .where((o) =>
              o.status == OfflineOperationStatus.pending ||
              o.status == OfflineOperationStatus.retrying)
          .toList()
        ..sort((a, b) {
          final priorityCompare = b.priority.compareTo(a.priority);
          if (priorityCompare != 0) return priorityCompare;
          return a.createdAt.compareTo(b.createdAt);
        });

      for (final operation in pendingOps) {
        try {
          await _executeOperation(operation);

          // Mark as completed
          final index = _queue.indexWhere((o) => o.id == operation.id);
          if (index >= 0) {
            _queue[index] = _queue[index].copyWith(
              status: OfflineOperationStatus.completed,
            );
          }

          _completedOperations.add(operation);
        } catch (e) {
          // Update retry count and status
          final newRetryCount = operation.retryCount + 1;
          final index = _queue.indexWhere((o) => o.id == operation.id);

          if (newRetryCount >= operation.maxRetries) {
            if (index >= 0) {
              _queue[index] = _queue[index].copyWith(
                status: OfflineOperationStatus.failed,
                retryCount: newRetryCount,
                lastError: e.toString(),
                lastAttemptedAt: DateTime.now().toUtc(),
              );
            }

            // Execute rollback if available
            _rollbacks[operation.id]?.call();
            _rollbacks.remove(operation.id);
          } else {
            if (index >= 0) {
              _queue[index] = _queue[index].copyWith(
                status: OfflineOperationStatus.retrying,
                retryCount: newRetryCount,
                lastError: e.toString(),
                lastAttemptedAt: DateTime.now().toUtc(),
              );
            }

            // Wait for backoff before next retry
            final backoff = _getBackoff(newRetryCount);
            await Future.delayed(backoff);
          }
        }
      }

      _lastSyncAt = DateTime.now().toUtc();
      _persistQueue();
    } finally {
      _isSyncing = false;
      _emitSyncStatus();
    }
  }

  // ==================== Cache Management ====================

  /// Cache data locally for offline access.
  void _cacheData<T>(String key, T data) {
    _cache[key] = _CacheEntry(
      data: data,
      cachedAt: DateTime.now().toUtc(),
    );

    // Persist to local storage if callback is provided
    onCacheChanged?.call(key, jsonEncode(data));
  }

  /// Get cached data for a key.
  T? getCachedData<T>(String key) {
    final entry = _cache[key];
    if (entry == null) return null;
    return entry.data as T?;
  }

  /// Invalidate cached data for a key.
  void invalidateCache(String key) {
    _cache.remove(key);
  }

  /// Invalidate all cached data.
  void invalidateAllCache() {
    _cache.clear();
  }

  /// Load cached data from local storage (called on app startup).
  void loadCacheFromStorage(Map<String, String> storedCache) {
    for (final entry in storedCache.entries) {
      try {
        final decoded = jsonDecode(entry.value);
        _cache[entry.key] = _CacheEntry(
          data: decoded,
          cachedAt: DateTime.now().toUtc(), // Assume recent if just loaded
        );
      } catch (_) {
        // Ignore malformed cache entries
      }
    }
  }

  /// Load operation queue from local storage (called on app startup).
  void loadQueueFromStorage(List<Map<String, dynamic>> storedQueue) {
    _queue.clear();
    for (final json in storedQueue) {
      try {
        final operation = OfflineOperation.fromJson(json);
        // Only load pending/retrying operations
        if (operation.status == OfflineOperationStatus.pending ||
            operation.status == OfflineOperationStatus.retrying) {
          _queue.add(operation);
        }
      } catch (_) {
        // Ignore malformed queue entries
      }
    }
    _emitSyncStatus();
  }

  // ==================== Private Helpers ====================

  /// Execute a single operation against the NestJS backend.
  Future<void> _executeOperation(OfflineOperation operation) async {
    switch (operation.type.toUpperCase()) {
      case 'POST':
        await _apiService.post(operation.path, data: operation.data);
        break;
      case 'PUT':
        await _apiService.put(operation.path, data: operation.data);
        break;
      case 'PATCH':
        await _apiService.patch(operation.path, data: operation.data);
        break;
      case 'DELETE':
        await _apiService.delete(operation.path, data: operation.data);
        break;
      default:
        throw UnsupportedError('Unsupported operation type: ${operation.type}');
    }
  }

  /// Get the backoff duration for a given retry attempt.
  Duration _getBackoff(int retryCount) {
    final index = (retryCount - 1).clamp(0, _retryBackoff.length - 1);
    return _retryBackoff[index];
  }

  /// Persist the queue to local storage.
  Future<void> _persistQueue() async {
    if (onQueueChanged != null) {
      await onQueueChanged!(List.from(_queue));
    }
  }

  /// Emit the current sync status to all listeners.
  void _emitSyncStatus() {
    if (!_syncStatusController.isClosed) {
      _syncStatusController.add(currentSyncStatus);
    }
  }

  /// Start periodic sync attempts.
  void _startPeriodicSync() {
    _syncTimer?.cancel();
    _syncTimer = Timer.periodic(syncInterval, (_) {
      if (_connectivity == ConnectivityState.online && !_isSyncing && _queue.any(
        (o) => o.status == OfflineOperationStatus.pending || o.status == OfflineOperationStatus.retrying,
      )) {
        syncNow();
      }
    });

    // Periodic connectivity check
    _connectivityCheckTimer?.cancel();
    _connectivityCheckTimer = Timer.periodic(
      const Duration(seconds: 15),
      (_) => checkConnectivity(),
    );
  }

  // Rollback callbacks for failed operations
  final Map<String, VoidCallback> _rollbacks = {};

  // Completed operations (for recent history)
  final List<OfflineOperation> _completedOperations = [];

  // ==================== Cleanup ====================

  /// Dispose the service and release all resources.
  void dispose() {
    _syncTimer?.cancel();
    _connectivityCheckTimer?.cancel();
    _syncStatusController.close();
    _queue.clear();
    _cache.clear();
    _rollbacks.clear();
    _completedOperations.clear();
  }
}

// ============================================================================
// Connectivity Domain Events
// ============================================================================

/// Emitted when connectivity is restored after being offline.
class ConnectivityRestoredEvent extends DomainEvent {
  final int pendingOperations;

  ConnectivityRestoredEvent({required this.pendingOperations});

  @override
  Map<String, dynamic> toJson() => {
        'type': 'ConnectivityRestored',
        'eventId': eventId,
        'timestamp': timestamp.toIso8601String(),
        'pendingOperations': pendingOperations,
      };
}

/// Emitted when connectivity is lost.
class ConnectivityLostEvent extends DomainEvent {
  ConnectivityLostEvent();

  @override
  Map<String, dynamic> toJson() => {
        'type': 'ConnectivityLost',
        'eventId': eventId,
        'timestamp': timestamp.toIso8601String(),
      };
}

// ============================================================================
// Cache Entry
// ============================================================================

class _CacheEntry {
  final dynamic data;
  final DateTime cachedAt;

  _CacheEntry({required this.data, required this.cachedAt});

  bool get isStale => DateTime.now().difference(cachedAt) >
      OfflineResilienceService.maxCacheAge;
}

// ============================================================================
// Type Alias
// ============================================================================

typedef VoidCallback = void Function();
