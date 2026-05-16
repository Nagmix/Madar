import 'dart:async';
import 'api_service.dart';
import 'socket_service.dart';
import '../constants/api_constants.dart';
import '../constants/app_constants.dart';
import '../models/dispatch_model.dart';
import '../models/trip_model.dart';

/// DispatchService - Manages driver dispatch via NestJS Dispatch Module
///
/// NestJS Dispatch Module uses PostGIS for geospatial queries:
/// - ST_Distance for nearest driver search
/// - Driver scoring algorithm (rating, acceptance rate, proximity)
/// - Auto-retry on driver rejection
/// - Timeout handling via BullMQ jobs
///
/// Flutter is the client; NestJS handles all dispatch logic,
/// driver scoring, retry logic, and BullMQ job management.
class DispatchService {
  final ApiService _apiService;
  final SocketService _socketService;

  // Stream controller for dispatch events
  final _dispatchEventController = StreamController<DispatchEvent>.broadcast();

  // Active dispatch tracking
  String? _activeDispatchId;

  DispatchService({
    required ApiService apiService,
    required SocketService socketService,
  })  : _apiService = apiService,
        _socketService = socketService {
    _setupSocketListeners();
  }

  // ==================== Streams ====================

  /// Listen for dispatch events via Socket.IO:
  /// - 'dispatch:new' - new dispatch for driver
  /// - 'dispatch:accepted' - driver accepted (for rider)
  /// - 'dispatch:rejected' - driver rejected
  /// - 'dispatch:cancelled' - rider cancelled
  /// - 'dispatch:expired' - dispatch timed out
  /// - 'dispatch:driver_location' - driver heading to pickup
  Stream<DispatchEvent> get onDispatchEvent => _dispatchEventController.stream;

  /// Currently active dispatch ID
  String? get activeDispatchId => _activeDispatchId;

  // ==================== Rider Operations ====================

  /// Request a ride (rider side) - POST /dispatch/request
  /// Triggers: BullMQ job → search nearby drivers → send dispatch notifications
  ///
  /// The NestJS backend:
  /// 1. Creates a BullMQ job for dispatch
  /// 2. Uses PostGIS ST_Distance to find nearby drivers
  /// 3. Scores drivers using: rating, acceptance rate, proximity, ETA
  /// 4. Sends dispatch notifications to top-scoring drivers
  /// 5. Auto-retries with next batch if driver rejects
  /// 6. Returns the dispatch result
  Future<DispatchResult> requestRide(CreateTripRequest request) async {
    try {
      final response = await _apiService.post(
        ApiConstants.requestRide,
        data: request.toJson(),
      );

      final result = DispatchResult.fromJson(
        response.data is Map<String, dynamic>
            ? response.data
            : Map<String, dynamic>.from(response.data as Map),
      );

      _activeDispatchId = result.tripId;

      // Join rider's dispatch room for real-time updates
      joinRiderRoom(result.tripId);

      return result;
    } catch (e) {
      rethrow;
    }
  }

  /// Cancel dispatch request - POST /dispatch/:id/cancel
  /// Rider cancels the dispatch while searching for drivers.
  Future<void> cancelDispatch(String dispatchId) async {
    try {
      await _apiService.post(
        '${ApiConstants.requestRide}/$dispatchId/cancel',
      );

      // Leave rider's dispatch room
      leaveRiderRoom(dispatchId);

      _dispatchEventController.add(DispatchEvent(
        type: DispatchEventType.cancelled,
        tripId: dispatchId,
        timestamp: DateTime.now(),
      ));

      if (_activeDispatchId == dispatchId) {
        _activeDispatchId = null;
      }
    } catch (e) {
      rethrow;
    }
  }

  // ==================== Driver Operations ====================

  /// Accept dispatch (driver side) - POST /dispatch/:id/accept
  /// Driver accepts the incoming ride request.
  /// NestJS backend updates the trip state and notifies the rider.
  Future<DispatchResult> acceptDispatch(String dispatchId) async {
    try {
      final response = await _apiService.post(
        '${ApiConstants.requestRide}/$dispatchId/accept',
      );

      final result = DispatchResult.fromJson(
        response.data is Map<String, dynamic>
            ? response.data
            : Map<String, dynamic>.from(response.data as Map),
      );

      _dispatchEventController.add(DispatchEvent(
        type: DispatchEventType.accepted,
        tripId: dispatchId,
        data: result.toJson(),
        timestamp: DateTime.now(),
      ));

      return result;
    } catch (e) {
      rethrow;
    }
  }

  /// Reject dispatch (driver side) - POST /dispatch/:id/reject
  /// Driver rejects the incoming ride request.
  /// NestJS backend auto-retries with the next available driver.
  Future<void> rejectDispatch(String dispatchId, {String? reason}) async {
    try {
      await _apiService.post(
        '${ApiConstants.requestRide}/$dispatchId/reject',
        data: {
          if (reason != null) 'reason': reason,
        },
      );

      _dispatchEventController.add(DispatchEvent(
        type: DispatchEventType.rejected,
        tripId: dispatchId,
        timestamp: DateTime.now(),
      ));
    } catch (e) {
      rethrow;
    }
  }

  // ==================== Status ====================

  /// Get dispatch status - GET /dispatch/:id
  /// Poll the current status of a dispatch request.
  Future<DispatchResult> getDispatchStatus(String dispatchId) async {
    try {
      final response = await _apiService.get(
        '${ApiConstants.requestRide}/$dispatchId',
      );

      return DispatchResult.fromJson(
        response.data is Map<String, dynamic>
            ? response.data
            : Map<String, dynamic>.from(response.data as Map),
      );
    } catch (e) {
      rethrow;
    }
  }

  // ==================== Socket.IO Room Management ====================

  /// Join rider's dispatch room for real-time updates
  /// Riders join to receive: dispatch:accepted, dispatch:cancelled, dispatch:expired
  void joinRiderRoom(String tripId) {
    _socketService.joinRoom('dispatch:rider:$tripId');
  }

  /// Leave rider's dispatch room
  void leaveRiderRoom(String tripId) {
    _socketService.leaveRoom('dispatch:rider:$tripId');
  }

  /// Join driver's dispatch room for receiving requests
  /// Drivers join to receive: dispatch:new
  void joinDriverRoom(String driverId) {
    _socketService.joinRoom('dispatch:driver:$driverId');
  }

  /// Leave driver's dispatch room
  void leaveDriverRoom(String driverId) {
    _socketService.leaveRoom('dispatch:driver:$driverId');
  }

  // ==================== Socket.IO Event Listeners ====================

  /// Setup all Socket.IO listeners for dispatch events
  void _setupSocketListeners() {
    // New dispatch for driver (incoming ride request)
    _socketService.on('dispatch:new', (data) {
      try {
        final parsed = _parseData(data);
        final notification = DriverDispatchNotification.fromJson(parsed);
        _dispatchEventController.add(DispatchEvent(
          type: DispatchEventType.newDispatch,
          tripId: notification.tripId,
          data: notification.toJson(),
          timestamp: DateTime.now(),
        ));
      } catch (_) {
        // Ignore malformed dispatch data
      }
    });

    // Driver accepted (for rider)
    _socketService.on('dispatch:accepted', (data) {
      try {
        final parsed = _parseData(data);
        final result = DispatchResult.fromJson(parsed);
        _activeDispatchId = null;
        _dispatchEventController.add(DispatchEvent(
          type: DispatchEventType.accepted,
          tripId: result.tripId,
          data: result.toJson(),
          timestamp: DateTime.now(),
        ));
      } catch (_) {
        // Ignore malformed dispatch data
      }
    });

    // Driver rejected
    _socketService.on('dispatch:rejected', (data) {
      try {
        final parsed = _parseData(data);
        _dispatchEventController.add(DispatchEvent(
          type: DispatchEventType.rejected,
          tripId: parsed['tripId'] as String? ?? '',
          data: parsed,
          timestamp: DateTime.now(),
        ));
      } catch (_) {
        // Ignore malformed dispatch data
      }
    });

    // Rider cancelled
    _socketService.on('dispatch:cancelled', (data) {
      try {
        final parsed = _parseData(data);
        _dispatchEventController.add(DispatchEvent(
          type: DispatchEventType.cancelled,
          tripId: parsed['tripId'] as String? ?? '',
          data: parsed,
          timestamp: DateTime.now(),
        ));
      } catch (_) {
        // Ignore malformed dispatch data
      }
    });

    // Dispatch expired (timed out)
    _socketService.on('dispatch:expired', (data) {
      try {
        final parsed = _parseData(data);
        _activeDispatchId = null;
        _dispatchEventController.add(DispatchEvent(
          type: DispatchEventType.expired,
          tripId: parsed['tripId'] as String? ?? '',
          data: parsed,
          timestamp: DateTime.now(),
        ));
      } catch (_) {
        // Ignore malformed dispatch data
      }
    });

    // Driver location update (driver heading to pickup)
    _socketService.on('dispatch:driver_location', (data) {
      try {
        final parsed = _parseData(data);
        _dispatchEventController.add(DispatchEvent(
          type: DispatchEventType.driverLocation,
          tripId: parsed['tripId'] as String? ?? '',
          data: parsed,
          timestamp: DateTime.now(),
        ));
      } catch (_) {
        // Ignore malformed dispatch data
      }
    });
  }

  /// Parse incoming socket data to Map<String, dynamic>
  Map<String, dynamic> _parseData(dynamic data) {
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    return {};
  }

  // ==================== Cleanup ====================

  /// Dispose resources and remove all socket listeners
  void dispose() {
    _dispatchEventController.close();
    _socketService.off('dispatch:new');
    _socketService.off('dispatch:accepted');
    _socketService.off('dispatch:rejected');
    _socketService.off('dispatch:cancelled');
    _socketService.off('dispatch:expired');
    _socketService.off('dispatch:driver_location');
  }
}

/// Dispatch event types emitted via Stream
enum DispatchEventType {
  /// New dispatch received by driver
  newDispatch,

  /// Driver accepted the dispatch
  accepted,

  /// Driver rejected the dispatch
  rejected,

  /// Rider cancelled the dispatch
  cancelled,

  /// Dispatch timed out (BullMQ job expired)
  expired,

  /// Driver location update (heading to pickup)
  driverLocation,
}

/// Dispatch event wrapper for Stream emissions
class DispatchEvent {
  /// Type of dispatch event
  final DispatchEventType type;

  /// Trip ID associated with the dispatch
  final String tripId;

  /// Additional event data (varies by type)
  final Map<String, dynamic>? data;

  /// When the event occurred
  final DateTime timestamp;

  DispatchEvent({
    required this.type,
    required this.tripId,
    this.data,
    required this.timestamp,
  });
}
