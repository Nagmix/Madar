import 'dart:async';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../constants/api_constants.dart';

/// Socket Service - Real-time communication with backend via Socket.IO
/// Handles connection management, reconnection, room management, and event dispatching
class SocketService {
  IO.Socket? _socket;
  bool _isConnected = false;
  bool _isConnecting = false;
  String? _authToken;
  final Map<String, List<void Function(dynamic)>> _listeners = {};
  final List<_QueuedEvent> _eventQueue = [];

  // Stream controllers for connection state
  final _connectionStateController = StreamController<SocketConnectionState>.broadcast();
  Stream<SocketConnectionState> get connectionState => _connectionStateController.stream;

  bool get isConnected => _isConnected;
  IO.Socket? get socket => _socket;

  /// Initialize and connect to socket server
  void connect({
    required String authToken,
    String? socketUrl,
  }) {
    if (_isConnecting || _isConnected) return;

    _authToken = authToken;
    _isConnecting = true;

    final url = socketUrl ?? ApiConstants.devSocketUrl;

    _socket = IO.io(url, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
      'auth': {'token': authToken},
      'reconnection': true,
      'reconnectionAttempts': 20,
      'reconnectionDelay': 1000,
      'reconnectionDelayMax': 30000,
      'timeout': 10000,
    });

    _setupEventHandlers();
    _socket!.connect();
  }

  void _setupEventHandlers() {
    _socket!.onConnect((_) {
      _isConnected = true;
      _isConnecting = false;
      _connectionStateController.add(SocketConnectionState.connected);
      _flushEventQueue();
    });

    _socket!.onDisconnect((_) {
      _isConnected = false;
      _isConnecting = false;
      _connectionStateController.add(SocketConnectionState.disconnected);
    });

    _socket!.onConnectError((data) {
      _isConnecting = false;
      _connectionStateController.add(SocketConnectionState.error);
    });

    _socket!.onReconnect((_) {
      _isConnected = true;
      _isConnecting = false;
      _connectionStateController.add(SocketConnectionState.reconnected);
      _flushEventQueue();
    });

    _socket!.onReconnectAttempt((_) {
      _connectionStateController.add(SocketConnectionState.reconnecting);
    });

    _socket!.onReconnectFailed((_) {
      _connectionStateController.add(SocketConnectionState.reconnectFailed);
    });

    // Register all pending listeners
    _listeners.forEach((event, callbacks) {
      for (final callback in callbacks) {
        _socket!.on(event, callback);
      }
    });
  }

  /// Disconnect from socket server
  void disconnect() {
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
    _isConnected = false;
    _isConnecting = false;
    _connectionStateController.add(SocketConnectionState.disconnected);
  }

  /// Join a specific room (e.g., trip room, driver room)
  void joinRoom(String room) {
    if (_isConnected) {
      _socket!.emit('room:join', {'room': room});
    } else {
      _eventQueue.add(_QueuedEvent('room:join', {'room': room}));
    }
  }

  /// Leave a specific room
  void leaveRoom(String room) {
    if (_isConnected) {
      _socket!.emit('room:leave', {'room': room});
    }
  }

  /// Emit an event to the server
  void emit(String event, dynamic data) {
    if (_isConnected) {
      _socket!.emit(event, data);
    } else {
      _eventQueue.add(_QueuedEvent(event, data));
    }
  }

  /// Listen to a specific event
  void on(String event, void Function(dynamic) callback) {
    if (!_listeners.containsKey(event)) {
      _listeners[event] = [];
    }
    _listeners[event]!.add(callback);

    if (_isConnected && _socket != null) {
      _socket!.on(event, callback);
    }
  }

  /// Remove a listener for a specific event
  void off(String event, [void Function(dynamic)? callback]) {
    if (callback != null) {
      _listeners[event]?.remove(callback);
      _socket?.off(event, callback);
    } else {
      _listeners.remove(event);
      _socket?.off(event);
    }
  }

  /// Flush queued events when connection is restored
  void _flushEventQueue() {
    while (_eventQueue.isNotEmpty) {
      final queued = _eventQueue.removeAt(0);
      _socket?.emit(queued.event, queued.data);
    }
  }

  // ==================== Trip-specific Events ====================

  /// Listen for trip state updates
  void onTripUpdate(void Function(dynamic) callback) => on('trip:update', callback);

  /// Listen for driver location updates during trip
  void onDriverLocationUpdate(void Function(dynamic) callback) =>
      on('trip:driver_location', callback);

  /// Listen for dispatch notifications (driver app)
  void onDispatchNotification(void Function(dynamic) callback) =>
      on('dispatch:notification', callback);

  /// Emit driver location update
  void emitDriverLocation({
    required String tripId,
    required double latitude,
    required double longitude,
    double? heading,
    double? speed,
    double? accuracy,
  }) {
    emit('driver:location', {
      'tripId': tripId,
      'latitude': latitude,
      'longitude': longitude,
      'heading': heading,
      'speed': speed,
      'accuracy': accuracy,
      'timestamp': DateTime.now().toUtc().toIso8601String(),
    });
  }

  /// Emit driver response to dispatch
  void emitDispatchResponse({
    required String tripId,
    required bool accepted,
    String? reason,
  }) {
    emit('dispatch:response', {
      'tripId': tripId,
      'accepted': accepted,
      'reason': reason,
    });
  }

  /// Emit trip cancellation
  void emitTripCancel({
    required String tripId,
    required String reason,
    required String cancelledBy,
  }) {
    emit('trip:cancel', {
      'tripId': tripId,
      'reason': reason,
      'cancelledBy': cancelledBy,
    });
  }

  /// Emit rider rating
  void emitTripRating({
    required String tripId,
    required double rating,
    String? review,
  }) {
    emit('trip:rate', {
      'tripId': tripId,
      'rating': rating,
      'review': review,
    });
  }

  /// Send heartbeat
  void sendHeartbeat() {
    if (_isConnected) {
      _socket!.emit('ping', DateTime.now().millisecondsSinceEpoch);
    }
  }

  /// Dispose resources
  void dispose() {
    disconnect();
    _connectionStateController.close();
    _listeners.clear();
    _eventQueue.clear();
  }
}

/// Socket connection states
enum SocketConnectionState {
  connected,
  disconnected,
  connecting,
  reconnecting,
  reconnected,
  error,
  reconnectFailed,
}

/// Queued event for offline support
class _QueuedEvent {
  final String event;
  final dynamic data;

  _QueuedEvent(this.event, this.data);
}
