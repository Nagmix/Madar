import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trippo_shared/trippo_shared.dart';
import '../../../../core/app_providers.dart';
import '../../../../core/network/nestjs_api_client.dart';
import '../../../auth/presentation/notifiers/driver_auth_notifier.dart';

/// Dispatch State
class DispatchState {
  /// List of incoming dispatch notifications waiting for response
  final List<DriverDispatchNotification> incomingDispatches;

  /// Currently active dispatch being shown to the driver
  final DriverDispatchNotification? activeDispatch;

  /// Whether we're currently listening for dispatches (driver is online)
  final bool isListening;

  /// Loading state for accept/reject actions
  final bool isLoading;

  /// Error message if any
  final String? error;

  /// Timeout countdown for active dispatch (seconds remaining)
  final int? countdownSeconds;

  const DispatchState({
    this.incomingDispatches = const [],
    this.activeDispatch,
    this.isListening = false,
    this.isLoading = false,
    this.error,
    this.countdownSeconds,
  });

  DispatchState copyWith({
    List<DriverDispatchNotification>? incomingDispatches,
    DriverDispatchNotification? activeDispatch,
    bool? isListening,
    bool? isLoading,
    String? error,
    int? countdownSeconds,
  }) =>
      DispatchState(
        incomingDispatches: incomingDispatches ?? this.incomingDispatches,
        activeDispatch: activeDispatch ?? this.activeDispatch,
        isListening: isListening ?? this.isListening,
        isLoading: isLoading ?? this.isLoading,
        error: error,
        countdownSeconds: countdownSeconds ?? this.countdownSeconds,
      );

  /// Clear active dispatch (after timeout or response)
  DispatchState clearActiveDispatch() => DispatchState(
        incomingDispatches: incomingDispatches,
        activeDispatch: null,
        isListening: isListening,
        isLoading: false,
        error: error,
        countdownSeconds: null,
      );
}

/// Dispatch Notifier
/// Manages incoming ride dispatch requests for the driver
/// Handles Socket.IO events: dispatch:new, dispatch:cancelled, dispatch:expired
/// Auto-timeout logic: 30 seconds to respond before dispatch expires
class DispatchNotifier extends StateNotifier<DispatchState> {
  final Ref _ref;
  Timer? _timeoutTimer;
  Timer? _countdownTimer;

  /// Default response timeout from API constants
  static const int _defaultTimeoutSeconds = 30;

  DispatchNotifier(this._ref) : super(const DispatchState());

  /// Start listening for dispatch notifications
  /// Joins the driver's dispatch room via Socket.IO
  void startListening() {
    if (state.isListening) return;

    final socketService = _ref.read(driverSocketServiceProvider);
    final driverId = _ref.read(currentDriverProvider)?.id;

    if (driverId == null) return;

    // Join the driver's dispatch room
    socketService.joinRoom('dispatch:driver:$driverId');

    // Listen for new dispatch notifications
    socketService.on('dispatch:new', _handleNewDispatch);

    // Listen for dispatch cancellations
    socketService.on('dispatch:cancelled', _handleDispatchCancelled);

    // Listen for dispatch expirations
    socketService.on('dispatch:expired', _handleDispatchExpired);

    state = state.copyWith(isListening: true);
  }

  /// Stop listening for dispatch notifications
  /// Leaves the driver's dispatch room
  void stopListening() {
    final socketService = _ref.read(driverSocketServiceProvider);
    final driverId = _ref.read(currentDriverProvider)?.id;

    if (driverId != null) {
      socketService.leaveRoom('dispatch:driver:$driverId');
    }

    // Remove all dispatch listeners
    socketService.off('dispatch:new', _handleNewDispatch);
    socketService.off('dispatch:cancelled', _handleDispatchCancelled);
    socketService.off('dispatch:expired', _handleDispatchExpired);

    // Cancel any active timers
    _cancelTimers();

    state = const DispatchState();
  }

  /// Handle new dispatch notification from Socket.IO
  void _handleNewDispatch(dynamic data) {
    if (data is Map<String, dynamic>) {
      try {
        final notification =
            DriverDispatchNotification.fromJson(data);

        // Add to incoming list and set as active
        final updatedList = [...state.incomingDispatches, notification];

        state = state.copyWith(
          incomingDispatches: updatedList,
          activeDispatch: notification,
        );

        // Start auto-timeout countdown
        _startTimeoutCountdown(
          notification.responseTimeoutSeconds > 0
              ? notification.responseTimeoutSeconds
              : _defaultTimeoutSeconds,
        );
      } catch (e) {
        state = state.copyWith(error: 'Failed to parse dispatch notification');
      }
    }
  }

  /// Handle dispatch cancellation from Socket.IO
  void _handleDispatchCancelled(dynamic data) {
    if (data is Map<String, dynamic>) {
      final cancelledTripId = data['tripId'] as String?;

      if (cancelledTripId != null) {
        // Remove from incoming list
        final updatedList = state.incomingDispatches
            .where((d) => d.tripId != cancelledTripId)
            .toList();

        // Clear active dispatch if it's the cancelled one
        final isActiveCancelled =
            state.activeDispatch?.tripId == cancelledTripId;

        if (isActiveCancelled) {
          _cancelTimers();
          state = state.copyWith(
            incomingDispatches: updatedList,
          ).clearActiveDispatch();
        } else {
          state = state.copyWith(incomingDispatches: updatedList);
        }
      }
    }
  }

  /// Handle dispatch expiration from Socket.IO
  void _handleDispatchExpired(dynamic data) {
    if (data is Map<String, dynamic>) {
      final expiredTripId = data['tripId'] as String?;

      if (expiredTripId != null) {
        // Remove from incoming list
        final updatedList = state.incomingDispatches
            .where((d) => d.tripId != expiredTripId)
            .toList();

        // Clear active dispatch if it's the expired one
        final isActiveExpired = state.activeDispatch?.tripId == expiredTripId;

        if (isActiveExpired) {
          _cancelTimers();
          state = state.copyWith(
            incomingDispatches: updatedList,
          ).clearActiveDispatch();
        } else {
          state = state.copyWith(incomingDispatches: updatedList);
        }
      }
    }
  }

  /// Accept a dispatch request - POST /dispatch/:id/accept
  /// Emits accept response via Socket.IO and calls REST API
  Future<void> acceptDispatch(String dispatchId) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final apiClient = _ref.read(nestjsApiClientProvider);
      await apiClient.acceptDispatch(dispatchId);

      // Also emit via socket for real-time acknowledgment
      final socketService = _ref.read(driverSocketServiceProvider);
      socketService.emitDispatchResponse(
        tripId: dispatchId,
        accepted: true,
      );

      // Cancel timeout timers
      _cancelTimers();

      // Remove from incoming list
      final updatedList = state.incomingDispatches
          .where((d) => d.tripId != dispatchId)
          .toList();

      state = state.copyWith(
        incomingDispatches: updatedList,
        isLoading: false,
      ).clearActiveDispatch();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  /// Reject a dispatch request - POST /dispatch/:id/reject
  /// Emits reject response via Socket.IO and calls REST API
  Future<void> rejectDispatch(String dispatchId, {String? reason}) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final apiClient = _ref.read(nestjsApiClientProvider);
      await apiClient.rejectDispatch(dispatchId, reason: reason);

      // Also emit via socket for real-time acknowledgment
      final socketService = _ref.read(driverSocketServiceProvider);
      socketService.emitDispatchResponse(
        tripId: dispatchId,
        accepted: false,
        reason: reason,
      );

      // Cancel timeout timers
      _cancelTimers();

      // Remove from incoming list
      final updatedList = state.incomingDispatches
          .where((d) => d.tripId != dispatchId)
          .toList();

      state = state.copyWith(
        incomingDispatches: updatedList,
        isLoading: false,
      ).clearActiveDispatch();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  /// Start auto-timeout countdown for active dispatch
  void _startTimeoutCountdown(int timeoutSeconds) {
    _cancelTimers();

    var remaining = timeoutSeconds;

    // Update countdown every second
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      remaining--;
      state = state.copyWith(countdownSeconds: remaining);

      if (remaining <= 0) {
        timer.cancel();
        _handleTimeout();
      }
    });

    // Safety timeout timer
    _timeoutTimer = Timer(Duration(seconds: timeoutSeconds), () {
      _handleTimeout();
    });
  }

  /// Handle dispatch timeout (driver didn't respond in time)
  void _handleTimeout() {
    _cancelTimers();

    // If there's an active dispatch, auto-reject it
    if (state.activeDispatch != null) {
      final socketService = _ref.read(driverSocketServiceProvider);
      socketService.emitDispatchResponse(
        tripId: state.activeDispatch!.tripId,
        accepted: false,
        reason: 'timeout',
      );

      // Remove from incoming list
      final updatedList = state.incomingDispatches
          .where((d) => d.tripId != state.activeDispatch!.tripId)
          .toList();

      state = state.copyWith(incomingDispatches: updatedList).clearActiveDispatch();
    }
  }

  /// Cancel all active timers
  void _cancelTimers() {
    _timeoutTimer?.cancel();
    _timeoutTimer = null;
    _countdownTimer?.cancel();
    _countdownTimer = null;
  }

  @override
  void dispose() {
    _cancelTimers();
    stopListening();
    super.dispose();
  }
}

/// Dispatch Provider
final dispatchProvider =
    StateNotifierProvider<DispatchNotifier, DispatchState>((ref) {
  return DispatchNotifier(ref);
});

/// Is there an active dispatch notification showing
final hasActiveDispatchProvider = Provider<bool>((ref) {
  final dispatchState = ref.watch(dispatchProvider);
  return dispatchState.activeDispatch != null;
});

/// Dispatch countdown provider
final dispatchCountdownProvider = Provider<int?>((ref) {
  final dispatchState = ref.watch(dispatchProvider);
  return dispatchState.countdownSeconds;
});
