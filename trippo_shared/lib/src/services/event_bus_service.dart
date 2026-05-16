/// Event Bus Service - Event-Driven Architecture for Trippo Platform
///
/// Implements a lightweight, type-safe event bus that enables loose coupling
/// between modules. Every significant domain action emits an event that other
/// modules can subscribe to — this is the foundation for scalability.
///
/// Architecture:
/// ```
///   Module A (Producer)          Event Bus          Module B (Consumer)
///   ┌──────────────┐     ┌──────────────────┐     ┌──────────────┐
///   │ trip.created  │────►│  EventBus        │────►│ notification  │
///   │ driver.loc    │────►│  ┌────────────┐  │────►│ dispatch      │
///   │ payment.done  │────►│  │ StreamCtrl │  │────►│ analytics     │
///   │ wallet.tx     │────►│  └────────────┘  │────►│ anti-fraud    │
///   └──────────────┘     └──────────────────┘     └──────────────┘
/// ```
///
/// Domain Events:
/// - TripCreated, DriverAssigned, TripStarted, TripCompleted
/// - DriverLocationUpdated, DriverOnline, DriverOffline
/// - PaymentCompleted, WalletTransactionCreated
/// - DispatchRequested, DispatchAccepted, DispatchRejected
/// - GpsAnomalyDetected, FraudDetected
/// - UserRated
///
/// Usage:
/// ```dart
/// // Subscribe to events
/// eventBus.on<TripCreatedEvent>().listen((event) {
///   print('New trip: ${event.tripId}');
/// });
///
/// // Emit events
/// eventBus.emit(TripCreatedEvent(tripId: '123', riderId: '456'));
/// ```
library;

import 'dart:async';

// ============================================================================
// Domain Events
// ============================================================================

/// Base class for all domain events in the Trippo platform.
///
/// Every event carries:
/// - [eventId]: A unique identifier for idempotency and deduplication.
/// - [timestamp]: When the event occurred (UTC).
/// - [correlationId]: Optional ID linking related events (e.g., a trip's
///   lifecycle events all share the same correlationId = tripId).
abstract class DomainEvent {
  final String eventId;
  final DateTime timestamp;
  final String? correlationId;

  DomainEvent({
    String? eventId,
    DateTime? timestamp,
    this.correlationId,
  })  : eventId = eventId ?? _generateId(),
        timestamp = timestamp ?? DateTime.now().toUtc();

  /// Generate a simple unique ID
  static String _generateId() {
    return '${DateTime.now().millisecondsSinceEpoch}-${_counter++}';
  }

  static int _counter = 0;

  /// Serialize the event to a JSON-compatible map for logging and transmission.
  Map<String, dynamic> toJson();
}

// ============================================================================
// Trip Domain Events
// ============================================================================

/// Emitted when a rider requests a new trip.
class TripCreatedEvent extends DomainEvent {
  final String tripId;
  final String riderId;
  final double pickupLat;
  final double pickupLng;
  final double dropoffLat;
  final double dropoffLng;
  final String vehicleType;

  TripCreatedEvent({
    required this.tripId,
    required this.riderId,
    required this.pickupLat,
    required this.pickupLng,
    required this.dropoffLat,
    required this.dropoffLng,
    required this.vehicleType,
    String? correlationId,
  }) : super(correlationId: correlationId ?? tripId);

  @override
  Map<String, dynamic> toJson() => {
        'type': 'TripCreated',
        'eventId': eventId,
        'timestamp': timestamp.toIso8601String(),
        'correlationId': correlationId,
        'tripId': tripId,
        'riderId': riderId,
        'pickupLat': pickupLat,
        'pickupLng': pickupLng,
        'dropoffLat': dropoffLat,
        'dropoffLng': dropoffLng,
        'vehicleType': vehicleType,
      };
}

/// Emitted when a driver is assigned to a trip.
class DriverAssignedEvent extends DomainEvent {
  final String tripId;
  final String driverId;
  final String riderId;
  final double driverLat;
  final double driverLng;
  final int estimatedArrivalMinutes;

  DriverAssignedEvent({
    required this.tripId,
    required this.driverId,
    required this.riderId,
    required this.driverLat,
    required this.driverLng,
    required this.estimatedArrivalMinutes,
    String? correlationId,
  }) : super(correlationId: correlationId ?? tripId);

  @override
  Map<String, dynamic> toJson() => {
        'type': 'DriverAssigned',
        'eventId': eventId,
        'timestamp': timestamp.toIso8601String(),
        'correlationId': correlationId,
        'tripId': tripId,
        'driverId': driverId,
        'riderId': riderId,
        'driverLat': driverLat,
        'driverLng': driverLng,
        'estimatedArrivalMinutes': estimatedArrivalMinutes,
      };
}

/// Emitted when the driver arrives at the pickup location.
class DriverArrivedEvent extends DomainEvent {
  final String tripId;
  final String driverId;

  DriverArrivedEvent({
    required this.tripId,
    required this.driverId,
    String? correlationId,
  }) : super(correlationId: correlationId ?? tripId);

  @override
  Map<String, dynamic> toJson() => {
        'type': 'DriverArrived',
        'eventId': eventId,
        'timestamp': timestamp.toIso8601String(),
        'correlationId': correlationId,
        'tripId': tripId,
        'driverId': driverId,
      };
}

/// Emitted when the trip starts (driver picks up the rider).
class TripStartedEvent extends DomainEvent {
  final String tripId;
  final String driverId;
  final String riderId;
  final double startLat;
  final double startLng;

  TripStartedEvent({
    required this.tripId,
    required this.driverId,
    required this.riderId,
    required this.startLat,
    required this.startLng,
    String? correlationId,
  }) : super(correlationId: correlationId ?? tripId);

  @override
  Map<String, dynamic> toJson() => {
        'type': 'TripStarted',
        'eventId': eventId,
        'timestamp': timestamp.toIso8601String(),
        'correlationId': correlationId,
        'tripId': tripId,
        'driverId': driverId,
        'riderId': riderId,
        'startLat': startLat,
        'startLng': startLng,
      };
}

/// Emitted when the trip is completed (driver drops off the rider).
class TripCompletedEvent extends DomainEvent {
  final String tripId;
  final String driverId;
  final String riderId;
  final double endLat;
  final double endLng;
  final double totalDistanceKm;
  final int durationMinutes;
  final double totalFare;

  TripCompletedEvent({
    required this.tripId,
    required this.driverId,
    required this.riderId,
    required this.endLat,
    required this.endLng,
    required this.totalDistanceKm,
    required this.durationMinutes,
    required this.totalFare,
    String? correlationId,
  }) : super(correlationId: correlationId ?? tripId);

  @override
  Map<String, dynamic> toJson() => {
        'type': 'TripCompleted',
        'eventId': eventId,
        'timestamp': timestamp.toIso8601String(),
        'correlationId': correlationId,
        'tripId': tripId,
        'driverId': driverId,
        'riderId': riderId,
        'endLat': endLat,
        'endLng': endLng,
        'totalDistanceKm': totalDistanceKm,
        'durationMinutes': durationMinutes,
        'totalFare': totalFare,
      };
}

/// Emitted when a trip is cancelled by rider or driver.
class TripCancelledEvent extends DomainEvent {
  final String tripId;
  final String cancelledBy; // 'rider' or 'driver'
  final String reason;
  final String? tripStateAtCancellation;

  TripCancelledEvent({
    required this.tripId,
    required this.cancelledBy,
    required this.reason,
    this.tripStateAtCancellation,
    String? correlationId,
  }) : super(correlationId: correlationId ?? tripId);

  @override
  Map<String, dynamic> toJson() => {
        'type': 'TripCancelled',
        'eventId': eventId,
        'timestamp': timestamp.toIso8601String(),
        'correlationId': correlationId,
        'tripId': tripId,
        'cancelledBy': cancelledBy,
        'reason': reason,
        'tripStateAtCancellation': tripStateAtCancellation,
      };
}

// ============================================================================
// Driver Domain Events
// ============================================================================

/// Emitted when a driver goes online and becomes available for dispatch.
class DriverOnlineEvent extends DomainEvent {
  final String driverId;
  final double latitude;
  final double longitude;

  DriverOnlineEvent({
    required this.driverId,
    required this.latitude,
    required this.longitude,
  }) : super(correlationId: driverId);

  @override
  Map<String, dynamic> toJson() => {
        'type': 'DriverOnline',
        'eventId': eventId,
        'timestamp': timestamp.toIso8601String(),
        'correlationId': correlationId,
        'driverId': driverId,
        'latitude': latitude,
        'longitude': longitude,
      };
}

/// Emitted when a driver goes offline.
class DriverOfflineEvent extends DomainEvent {
  final String driverId;
  final String reason; // 'manual', 'timeout', 'low_battery'

  DriverOfflineEvent({
    required this.driverId,
    required this.reason,
  }) : super(correlationId: driverId);

  @override
  Map<String, dynamic> toJson() => {
        'type': 'DriverOffline',
        'eventId': eventId,
        'timestamp': timestamp.toIso8601String(),
        'correlationId': correlationId,
        'driverId': driverId,
        'reason': reason,
      };
}

/// Emitted when a driver's location is updated during a trip or while online.
class DriverLocationUpdatedEvent extends DomainEvent {
  final String driverId;
  final String? tripId;
  final double latitude;
  final double longitude;
  final double heading;
  final double speed;
  final double accuracy;
  final bool isFlagged;

  DriverLocationUpdatedEvent({
    required this.driverId,
    this.tripId,
    required this.latitude,
    required this.longitude,
    required this.heading,
    required this.speed,
    required this.accuracy,
    this.isFlagged = false,
    String? correlationId,
  }) : super(correlationId: correlationId ?? tripId ?? driverId);

  @override
  Map<String, dynamic> toJson() => {
        'type': 'DriverLocationUpdated',
        'eventId': eventId,
        'timestamp': timestamp.toIso8601String(),
        'correlationId': correlationId,
        'driverId': driverId,
        'tripId': tripId,
        'latitude': latitude,
        'longitude': longitude,
        'heading': heading,
        'speed': speed,
        'accuracy': accuracy,
        'isFlagged': isFlagged,
      };
}

// ============================================================================
// Payment & Wallet Domain Events
// ============================================================================

/// Emitted when a payment is completed for a trip.
class PaymentCompletedEvent extends DomainEvent {
  final String tripId;
  final String riderId;
  final String driverId;
  final double amount;
  final String paymentMethod; // 'cash', 'card', 'wallet'
  final double driverEarnings;
  final double platformCommission;

  PaymentCompletedEvent({
    required this.tripId,
    required this.riderId,
    required this.driverId,
    required this.amount,
    required this.paymentMethod,
    required this.driverEarnings,
    required this.platformCommission,
    String? correlationId,
  }) : super(correlationId: correlationId ?? tripId);

  @override
  Map<String, dynamic> toJson() => {
        'type': 'PaymentCompleted',
        'eventId': eventId,
        'timestamp': timestamp.toIso8601String(),
        'correlationId': correlationId,
        'tripId': tripId,
        'riderId': riderId,
        'driverId': driverId,
        'amount': amount,
        'paymentMethod': paymentMethod,
        'driverEarnings': driverEarnings,
        'platformCommission': platformCommission,
      };
}

/// Emitted when a wallet transaction is created (earning, withdrawal, etc.).
class WalletTransactionEvent extends DomainEvent {
  final String walletId;
  final String userId;
  final String transactionType; // 'trip_earning', 'withdrawal', 'incentive', etc.
  final double amount;
  final double balanceAfter;

  WalletTransactionEvent({
    required this.walletId,
    required this.userId,
    required this.transactionType,
    required this.amount,
    required this.balanceAfter,
    String? correlationId,
  }) : super(correlationId: correlationId);

  @override
  Map<String, dynamic> toJson() => {
        'type': 'WalletTransaction',
        'eventId': eventId,
        'timestamp': timestamp.toIso8601String(),
        'correlationId': correlationId,
        'walletId': walletId,
        'userId': userId,
        'transactionType': transactionType,
        'amount': amount,
        'balanceAfter': balanceAfter,
      };
}

// ============================================================================
// Dispatch Domain Events
// ============================================================================

/// Emitted when a dispatch request is sent to drivers.
class DispatchRequestedEvent extends DomainEvent {
  final String tripId;
  final String riderId;
  final List<String> targetDriverIds;
  final int searchRadiusKm;

  DispatchRequestedEvent({
    required this.tripId,
    required this.riderId,
    required this.targetDriverIds,
    required this.searchRadiusKm,
    String? correlationId,
  }) : super(correlationId: correlationId ?? tripId);

  @override
  Map<String, dynamic> toJson() => {
        'type': 'DispatchRequested',
        'eventId': eventId,
        'timestamp': timestamp.toIso8601String(),
        'correlationId': correlationId,
        'tripId': tripId,
        'riderId': riderId,
        'targetDriverIds': targetDriverIds,
        'searchRadiusKm': searchRadiusKm,
      };
}

/// Emitted when a driver accepts a dispatch.
class DispatchAcceptedEvent extends DomainEvent {
  final String tripId;
  final String driverId;
  final int responseTimeMs;

  DispatchAcceptedEvent({
    required this.tripId,
    required this.driverId,
    required this.responseTimeMs,
    String? correlationId,
  }) : super(correlationId: correlationId ?? tripId);

  @override
  Map<String, dynamic> toJson() => {
        'type': 'DispatchAccepted',
        'eventId': eventId,
        'timestamp': timestamp.toIso8601String(),
        'correlationId': correlationId,
        'tripId': tripId,
        'driverId': driverId,
        'responseTimeMs': responseTimeMs,
      };
}

/// Emitted when a driver rejects a dispatch.
class DispatchRejectedEvent extends DomainEvent {
  final String tripId;
  final String driverId;
  final String? reason;

  DispatchRejectedEvent({
    required this.tripId,
    required this.driverId,
    this.reason,
    String? correlationId,
  }) : super(correlationId: correlationId ?? tripId);

  @override
  Map<String, dynamic> toJson() => {
        'type': 'DispatchRejected',
        'eventId': eventId,
        'timestamp': timestamp.toIso8601String(),
        'correlationId': correlationId,
        'tripId': tripId,
        'driverId': driverId,
        'reason': reason,
      };
}

// ============================================================================
// Security & Anti-Fraud Domain Events
// ============================================================================

/// Emitted when a GPS anomaly is detected.
class GpsAnomalyDetectedEvent extends DomainEvent {
  final String? driverId;
  final String? tripId;
  final String anomalyType; // 'speed', 'jump', 'mock', 'accuracy'
  final double value;
  final double threshold;
  final String severity; // 'low', 'medium', 'high'

  GpsAnomalyDetectedEvent({
    this.driverId,
    this.tripId,
    required this.anomalyType,
    required this.value,
    required this.threshold,
    required this.severity,
    String? correlationId,
  }) : super(correlationId: correlationId);

  @override
  Map<String, dynamic> toJson() => {
        'type': 'GpsAnomalyDetected',
        'eventId': eventId,
        'timestamp': timestamp.toIso8601String(),
        'correlationId': correlationId,
        'driverId': driverId,
        'tripId': tripId,
        'anomalyType': anomalyType,
        'value': value,
        'threshold': threshold,
        'severity': severity,
      };
}

/// Emitted when fraud is detected.
class FraudDetectedEvent extends DomainEvent {
  final String userId;
  final String fraudType; // 'fake_account', 'gps_spoofing', 'payment_fraud', 'fake_trip'
  final String severity;
  final Map<String, dynamic> evidence;

  FraudDetectedEvent({
    required this.userId,
    required this.fraudType,
    required this.severity,
    required this.evidence,
    String? correlationId,
  }) : super(correlationId: correlationId);

  @override
  Map<String, dynamic> toJson() => {
        'type': 'FraudDetected',
        'eventId': eventId,
        'timestamp': timestamp.toIso8601String(),
        'correlationId': correlationId,
        'userId': userId,
        'fraudType': fraudType,
        'severity': severity,
        'evidence': evidence,
      };
}

/// Emitted when a rider rates a driver after a trip.
class UserRatedEvent extends DomainEvent {
  final String tripId;
  final String riderId;
  final String driverId;
  final double rating;
  final String? review;
  final List<String> tags;

  UserRatedEvent({
    required this.tripId,
    required this.riderId,
    required this.driverId,
    required this.rating,
    this.review,
    this.tags = const [],
    String? correlationId,
  }) : super(correlationId: correlationId ?? tripId);

  @override
  Map<String, dynamic> toJson() => {
        'type': 'UserRated',
        'eventId': eventId,
        'timestamp': timestamp.toIso8601String(),
        'correlationId': correlationId,
        'tripId': tripId,
        'riderId': riderId,
        'driverId': driverId,
        'rating': rating,
        'review': review,
        'tags': tags,
      };
}

// ============================================================================
// Event Bus Implementation
// ============================================================================

/// Trippo Event Bus - A type-safe, lightweight event bus for domain events.
///
/// Features:
/// - **Type-safe subscriptions**: Subscribe to specific event types.
/// - **Event replay**: Optional replay of recent events for late subscribers.
/// - **Middleware**: Intercept, transform, or filter events before delivery.
/// - **Error isolation**: Errors in one handler do not affect others.
/// - **Event logging**: All events are logged for debugging and audit.
/// - **Offline support**: Events can be queued when offline and replayed later.
///
/// Usage:
/// ```dart
/// final eventBus = TrippoEventBus();
///
/// // Subscribe to specific event types
/// final sub = eventBus.on<TripCreatedEvent>().listen((event) {
///   print('New trip created: ${event.tripId}');
/// });
///
/// // Emit events
/// eventBus.emit(TripCreatedEvent(
///   tripId: 'trip_123',
///   riderId: 'rider_456',
///   ...
/// ));
///
/// // Subscribe to all events (for logging, analytics)
/// eventBus.onAll().listen((event) {
///   analytics.track(event.toJson());
/// });
///
/// // Cleanup
/// sub.cancel();
/// eventBus.dispose();
/// ```
class TrippoEventBus {
  // Stream controllers per event type
  final Map<Type, StreamController<DomainEvent>> _controllers = {};

  // All-events stream controller
  StreamController<DomainEvent>? _allEventsController;

  // Event history for replay (configurable size)
  final List<DomainEvent> _eventHistory = [];
  int maxHistorySize = 100;

  // Middleware chain
  final List<EventMiddleware> _middleware = [];

  // Event ID tracking for deduplication
  final Set<String> _processedEventIds = {};
  int maxProcessedIds = 1000;

  // Error handler
  Function(Object error, DomainEvent event)? onError;

  /// Whether the event bus has been disposed.
  bool _isDisposed = false;

  // ==================== Subscriptions ====================

  /// Subscribe to events of a specific type [T].
  ///
  /// Returns a broadcast stream that can be listened to multiple times.
  /// Late subscribers will not receive events emitted before they subscribed
  /// unless [replay] is set to the number of recent events to replay.
  Stream<T> on<T extends DomainEvent>({int replay = 0}) {
    _ensureNotDisposed();

    final controller = _getOrCreateController(T);

    if (replay > 0) {
      // Replay recent events of this type
      final recentEvents = _eventHistory
          .whereType<T>()
          .toList()
          .reversed
          .take(replay)
          .toList()
          .reversed;

      return Stream.multi((controller) {
        // First, emit replayed events
        for (final event in recentEvents) {
          controller.add(event);
        }
        // Then, add the live stream
        final subscription = controller.stream.listen(
          (event) => controller.add(event as T),
          onError: (e) => controller.addError(e),
        );
        controller.onCancel = () => subscription.cancel();
      });
    }

    return controller.stream.cast<T>();
  }

  /// Subscribe to all events emitted on the bus.
  ///
  /// Useful for cross-cutting concerns like logging, analytics, and
  /// offline synchronization.
  Stream<DomainEvent> onAll() {
    _ensureNotDisposed();
    _allEventsController ??= StreamController<DomainEvent>.broadcast();
    return _allEventsController!.stream;
  }

  // ==================== Emitting Events ====================

  /// Emit a domain event on the bus.
  ///
  /// The event passes through the middleware chain before being delivered
  /// to subscribers. If any middleware vetoes the event (returns `false`),
  /// it is silently dropped.
  ///
  /// Duplicate events (same [DomainEvent.eventId]) are automatically
  /// deduplicated to prevent double-processing.
  void emit(DomainEvent event) {
    _ensureNotDisposed();

    // Deduplication check
    if (_processedEventIds.contains(event.eventId)) {
      return; // Already processed
    }

    // Mark as processed
    _processedEventIds.add(event.eventId);
    if (_processedEventIds.length > maxProcessedIds) {
      _processedEventIds.remove(_processedEventIds.first);
    }

    // Run through middleware chain
    DomainEvent currentEvent = event;
    for (final middleware in _middleware) {
      final result = middleware.handle(currentEvent);
      if (result == null) {
        // Middleware vetoed the event
        return;
      }
      currentEvent = result;
    }

    // Store in history
    _eventHistory.add(currentEvent);
    if (_eventHistory.length > maxHistorySize) {
      _eventHistory.removeAt(0);
    }

    // Deliver to type-specific subscribers
    final typeController = _controllers[currentEvent.runtimeType];
    if (typeController != null && !typeController.isClosed) {
      try {
        typeController.add(currentEvent);
      } catch (e) {
        onError?.call(e, currentEvent);
      }
    }

    // Deliver to all-events subscribers
    if (_allEventsController != null && !_allEventsController!.isClosed) {
      try {
        _allEventsController!.add(currentEvent);
      } catch (e) {
        onError?.call(e, currentEvent);
      }
    }
  }

  /// Emit multiple events in batch.
  void emitBatch(List<DomainEvent> events) {
    for (final event in events) {
      emit(event);
    }
  }

  // ==================== Middleware ====================

  /// Add a middleware to the event processing pipeline.
  ///
  /// Middleware are executed in the order they are added.
  /// A middleware can:
  /// - Return the event (possibly modified) to continue processing.
  /// - Return `null` to veto (drop) the event.
  void addMiddleware(EventMiddleware middleware) {
    _middleware.add(middleware);
  }

  /// Remove a middleware from the pipeline.
  void removeMiddleware(EventMiddleware middleware) {
    _middleware.remove(middleware);
  }

  // ==================== History ====================

  /// Get recent events, optionally filtered by type.
  List<T> getRecentEvents<T extends DomainEvent>([int count = 10]) {
    return _eventHistory.whereType<T>().toList().reversed.take(count).toList().reversed.toList();
  }

  /// Get all events in history, optionally filtered by correlation ID.
  List<DomainEvent> getEventsByCorrelationId(String correlationId) {
    return _eventHistory
        .where((e) => e.correlationId == correlationId)
        .toList();
  }

  /// Clear event history.
  void clearHistory() {
    _eventHistory.clear();
    _processedEventIds.clear();
  }

  // ==================== Helpers ====================

  StreamController<DomainEvent> _getOrCreateController(Type type) {
    return _controllers.putIfAbsent(
      type,
      () => StreamController<DomainEvent>.broadcast(),
    );
  }

  void _ensureNotDisposed() {
    if (_isDisposed) {
      throw StateError('TrippoEventBus has been disposed');
    }
  }

  // ==================== Cleanup ====================

  /// Dispose the event bus and close all stream controllers.
  void dispose() {
    _isDisposed = true;
    for (final controller in _controllers.values) {
      controller.close();
    }
    _controllers.clear();
    _allEventsController?.close();
    _allEventsController = null;
    _eventHistory.clear();
    _processedEventIds.clear();
    _middleware.clear();
  }
}

// ============================================================================
// Event Middleware
// ============================================================================

/// Base class for event middleware.
///
/// Middleware can inspect, modify, or veto events before they reach
/// subscribers. This enables cross-cutting concerns like:
/// - Logging and auditing
/// - Offline queuing (persist events when network is unavailable)
/// - Rate limiting (prevent event flooding)
/// - Transformation (enrich events with additional data)
abstract class EventMiddleware {
  /// Handle an event. Return the event (possibly modified) to continue
  /// processing, or return `null` to veto the event.
  DomainEvent? handle(DomainEvent event);
}

/// Logging middleware — prints events to the console for debugging.
class LoggingEventMiddleware extends EventMiddleware {
  final void Function(String message)? logger;

  LoggingEventMiddleware({this.logger});

  @override
  DomainEvent? handle(DomainEvent event) {
    final message = '[EventBus] ${event.runtimeType} @ ${event.timestamp.toIso8601String()}'
        ' id=${event.eventId}'
        '${event.correlationId != null ? ' corr=${event.correlationId}' : ''}';

    if (logger != null) {
      logger!(message);
    }
    // In production, logger would be disabled or use a proper logging framework

    return event;
  }
}

/// Rate-limiting middleware — prevents event flooding by limiting how many
/// events of the same type can be emitted within a time window.
class RateLimitEventMiddleware extends EventMiddleware {
  final Map<Type, _EventRateLimit> _limits = {};
  final Map<Type, List<DateTime>> _timestamps = {};

  /// Configure rate limit for a specific event type.
  void configure<T extends DomainEvent>({required int maxEvents, required Duration window}) {
    _limits[T] = _EventRateLimit(maxEvents: maxEvents, window: window);
  }

  @override
  DomainEvent? handle(DomainEvent event) {
    final type = event.runtimeType;
    final limit = _limits[type];
    if (limit == null) return event;

    final now = DateTime.now();
    _timestamps[type] ??= [];

    // Remove expired timestamps
    _timestamps[type]!.removeWhere(
      (ts) => now.difference(ts) > limit.window,
    );

    // Check rate limit
    if (_timestamps[type]!.length >= limit.maxEvents) {
      return null; // Veto: rate limit exceeded
    }

    _timestamps[type]!.add(now);
    return event;
  }
}

/// Offline queue middleware — persists events when offline and replays
/// them when connectivity is restored. This is critical for Yemen where
/// network connectivity may be unreliable.
class OfflineQueueMiddleware extends EventMiddleware {
  final List<DomainEvent> _offlineQueue = [];
  bool _isOnline = true;

  /// Callback to persist queued events to local storage.
  final Future<void> Function(List<DomainEvent> events)? onFlushQueue;

  OfflineQueueMiddleware({this.onFlushQueue});

  /// Set the online/offline status.
  void setOnlineStatus(bool isOnline) {
    _isOnline = isOnline;
    if (isOnline) {
      _flushQueue();
    }
  }

  /// Get the number of queued events.
  int get queuedEventCount => _offlineQueue.length;

  @override
  DomainEvent? handle(DomainEvent event) {
    if (_isOnline) {
      return event;
    }

    // Queue the event for later delivery
    _offlineQueue.add(event);
    return null; // Don't deliver now — will be replayed when online
  }

  /// Flush the offline queue — replay all queued events.
  Future<void> _flushQueue() async {
    if (_offlineQueue.isEmpty) return;

    final events = List<DomainEvent>.from(_offlineQueue);
    _offlineQueue.clear();

    if (onFlushQueue != null) {
      await onFlushQueue!(events);
    }

    // Note: Re-emitting events requires access to the EventBus instance.
    // This is typically handled by the OfflineService which manages both
    // the event bus and the queue.
  }
}

// ============================================================================
// Helper Classes
// ============================================================================

class _EventRateLimit {
  final int maxEvents;
  final Duration window;

  const _EventRateLimit({required this.maxEvents, required this.window});
}

// ============================================================================
// Global Event Bus Instance
// ============================================================================

/// Global event bus instance for the Trippo platform.
///
/// This is a convenience accessor. In production, you would typically
/// manage the event bus lifecycle through Riverpod providers:
///
/// ```dart
/// final eventBusProvider = Provider<TrippoEventBus>((ref) {
///   final bus = TrippoEventBus();
///   bus.addMiddleware(LoggingEventMiddleware());
///   ref.onDispose(() => bus.dispose());
///   return bus;
/// });
/// ```
final eventBus = TrippoEventBus();
