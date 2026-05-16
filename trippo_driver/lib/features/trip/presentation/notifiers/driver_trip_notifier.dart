import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trippo_shared/trippo_shared.dart';
import '../../../../core/app_providers.dart';
import '../../../../core/network/nestjs_api_client.dart';

/// Driver Trip State
class DriverTripState {
  final TripState tripState;
  final TripModel? currentTrip;
  final List<TripSummary> activeTrips;
  final bool isLoading;
  final String? error;

  const DriverTripState({
    this.tripState = TripState.searchingDriver,
    this.currentTrip,
    this.activeTrips = const [],
    this.isLoading = false,
    this.error,
  });

  DriverTripState copyWith({
    TripState? tripState,
    TripModel? currentTrip,
    List<TripSummary>? activeTrips,
    bool? isLoading,
    String? error,
  }) =>
      DriverTripState(
        tripState: tripState ?? this.tripState,
        currentTrip: currentTrip ?? this.currentTrip,
        activeTrips: activeTrips ?? this.activeTrips,
        isLoading: isLoading ?? this.isLoading,
        error: error,
      );
}

/// Driver Trip Notifier
/// Manages the driver-side trip lifecycle with state machine validation
/// Listens to Socket.IO for real-time trip updates
/// All state transitions validated using isValidTransition() from shared
class DriverTripNotifier extends StateNotifier<DriverTripState> {
  final Ref _ref;
  StreamSubscription<SocketConnectionState>? _socketStateSubscription;

  DriverTripNotifier(this._ref) : super(const DriverTripState()) {
    _setupSocketListeners();
  }

  /// Setup Socket.IO listeners for trip updates
  void _setupSocketListeners() {
    final socketService = _ref.read(driverSocketServiceProvider);

    // Listen for trip state updates from server
    socketService.on('trip:update', _handleTripUpdate);

    // Listen for driver location requests during trip
    socketService.on('trip:driver_location', _handleDriverLocationRequest);
  }

  /// Handle trip state update from server via Socket.IO
  void _handleTripUpdate(dynamic data) {
    if (data is Map<String, dynamic>) {
      final newState = TripState.fromString(data['state'] as String? ?? '');

      // Validate state transition using shared state machine
      if (isValidTransition(state.tripState, newState)) {
        final updatedTrip = data['trip'] != null
            ? TripModel.fromJson(data['trip'] as Map<String, dynamic>)
            : state.currentTrip;

        state = state.copyWith(
          tripState: newState,
          currentTrip: updatedTrip,
        );
      } else if (newState != state.tripState) {
        // Invalid transition - force sync from server
        _syncTripFromServer();
      }
    }
  }

  /// Handle driver location request from server
  void _handleDriverLocationRequest(dynamic data) {
    // Location updates are handled by DriverHomeNotifier
    // This listener ensures we stay in the trip room
  }

  /// Accept a trip dispatch - POST /trips/:id/accept
  /// Transitions: SEARCHING_DRIVER -> DRIVER_ASSIGNED
  Future<void> acceptTrip(String tripId) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final apiClient = _ref.read(nestjsApiClientProvider);
      final trip = await apiClient.acceptTrip(tripId);

      // Validate the transition
      final newState = trip.state;
      if (!isValidTransition(state.tripState, newState)) {
        // Server accepted it, so trust the server state
        // (could happen if initial state was SEARCHING_DRIVER)
      }

      // Join the trip room for real-time updates
      final socketService = _ref.read(driverSocketServiceProvider);
      socketService.joinRoom('trip:$tripId');

      state = state.copyWith(
        tripState: newState,
        currentTrip: trip,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  /// Driver arrived at pickup location - POST /trips/:id/arrived
  /// Transitions: DRIVER_ARRIVING -> DRIVER_ARRIVED
  Future<void> arrivedAtPickup(String tripId) async {
    final targetState = TripState.driverArrived;
    if (!isValidTransition(state.tripState, targetState)) {
      state = state.copyWith(
        error: 'Cannot arrive: invalid transition from ${state.tripState.value}',
      );
      return;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      final apiClient = _ref.read(nestjsApiClientProvider);
      final trip = await apiClient.arrivedAtPickup(tripId);

      state = state.copyWith(
        tripState: targetState,
        currentTrip: trip,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  /// Start the trip - POST /trips/:id/start
  /// Transitions: DRIVER_ARRIVED -> TRIP_STARTED
  Future<void> startTrip(String tripId) async {
    final targetState = TripState.tripStarted;
    if (!isValidTransition(state.tripState, targetState)) {
      state = state.copyWith(
        error: 'Cannot start trip: invalid transition from ${state.tripState.value}',
      );
      return;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      final apiClient = _ref.read(nestjsApiClientProvider);
      final trip = await apiClient.startTrip(tripId);

      // Switch GPS to active mode for more frequent updates
      final gpsService = _ref.read(gpsTrackingServiceProvider);
      gpsService.switchToActiveMode();

      state = state.copyWith(
        tripState: targetState,
        currentTrip: trip,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  /// Complete the trip - POST /trips/:id/complete
  /// Transitions: TRIP_STARTED | TRIP_RESUMED -> TRIP_COMPLETED
  Future<void> completeTrip(String tripId) async {
    final targetState = TripState.tripCompleted;
    if (!isValidTransition(state.tripState, targetState)) {
      state = state.copyWith(
        error: 'Cannot complete trip: invalid transition from ${state.tripState.value}',
      );
      return;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      final apiClient = _ref.read(nestjsApiClientProvider);
      final trip = await apiClient.completeTrip(tripId);

      // Switch GPS back to passive mode
      final gpsService = _ref.read(gpsTrackingServiceProvider);
      gpsService.switchToPassiveMode();

      // Leave the trip room
      final socketService = _ref.read(driverSocketServiceProvider);
      socketService.leaveRoom('trip:$tripId');

      state = state.copyWith(
        tripState: targetState,
        currentTrip: trip,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  /// Pause the trip - POST /trips/:id/pause
  /// Transitions: TRIP_STARTED | TRIP_RESUMED -> TRIP_PAUSED
  Future<void> pauseTrip(String tripId, {String? reason}) async {
    final targetState = TripState.tripPaused;
    if (!isValidTransition(state.tripState, targetState)) {
      state = state.copyWith(
        error: 'Cannot pause trip: invalid transition from ${state.tripState.value}',
      );
      return;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      final apiClient = _ref.read(nestjsApiClientProvider);
      final trip = await apiClient.pauseTrip(tripId, reason: reason);

      state = state.copyWith(
        tripState: targetState,
        currentTrip: trip,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  /// Resume the trip - POST /trips/:id/resume
  /// Transitions: TRIP_PAUSED -> TRIP_RESUMED
  Future<void> resumeTrip(String tripId) async {
    final targetState = TripState.tripResumed;
    if (!isValidTransition(state.tripState, targetState)) {
      state = state.copyWith(
        error: 'Cannot resume trip: invalid transition from ${state.tripState.value}',
      );
      return;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      final apiClient = _ref.read(nestjsApiClientProvider);
      final trip = await apiClient.resumeTrip(tripId);

      // Switch back to active GPS mode
      final gpsService = _ref.read(gpsTrackingServiceProvider);
      gpsService.switchToActiveMode();

      state = state.copyWith(
        tripState: targetState,
        currentTrip: trip,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  /// Cancel the trip - POST /trips/:id/cancel
  /// Valid from any cancelable state
  Future<void> cancelTrip(String tripId, String reason) async {
    if (!cancelableStates.contains(state.tripState)) {
      state = state.copyWith(
        error: 'Cannot cancel trip: current state ${state.tripState.value} is not cancelable',
      );
      return;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      final apiClient = _ref.read(nestjsApiClientProvider);
      final trip = await apiClient.cancelTrip(
        tripId: tripId,
        reason: reason,
      );

      // Leave the trip room
      final socketService = _ref.read(driverSocketServiceProvider);
      socketService.leaveRoom('trip:$tripId');

      // Switch GPS back to passive mode
      final gpsService = _ref.read(gpsTrackingServiceProvider);
      gpsService.switchToPassiveMode();

      state = state.copyWith(
        tripState: TripState.tripCancelled,
        currentTrip: trip,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  /// Load active trips for the driver - GET /trips/history?status=active
  Future<void> loadActiveTrips() async {
    try {
      final apiClient = _ref.read(nestjsApiClientProvider);
      final trips = await apiClient.getTripHistory(status: 'active');
      state = state.copyWith(activeTrips: trips);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Force sync trip state from server
  Future<void> _syncTripFromServer() async {
    if (state.currentTrip == null) return;

    try {
      final apiClient = _ref.read(nestjsApiClientProvider);
      final trip = await apiClient.getTripDetails(state.currentTrip!.id);
      state = state.copyWith(
        tripState: trip.state,
        currentTrip: trip,
      );
    } catch (_) {
      // Silently fail - will retry on next socket event
    }
  }

  /// Reset trip state - called when trip is fully completed
  void reset() {
    if (state.currentTrip != null) {
      final socketService = _ref.read(driverSocketServiceProvider);
      socketService.leaveRoom('trip:${state.currentTrip!.id}');
      socketService.off('trip:update', _handleTripUpdate);
      socketService.off('trip:driver_location', _handleDriverLocationRequest);
    }

    state = const DriverTripState();
  }

  @override
  void dispose() {
    _socketStateSubscription?.cancel();
    reset();
    super.dispose();
  }
}

/// Driver Trip Provider
final driverTripProvider =
    StateNotifierProvider<DriverTripNotifier, DriverTripState>((ref) {
  return DriverTripNotifier(ref);
});

/// Current driver trip provider
final currentDriverTripProvider = Provider<TripModel?>((ref) {
  final tripState = ref.watch(driverTripProvider);
  return tripState.currentTrip;
});

/// Is driver on an active trip provider
final isDriverOnTripProvider = Provider<bool>((ref) {
  final tripState = ref.watch(driverTripProvider);
  return activeTripStates.contains(tripState.tripState);
});

/// Driver trip state value provider (convenience)
final driverTripStateProvider = Provider<TripState>((ref) {
  final tripState = ref.watch(driverTripProvider);
  return tripState.tripState;
});
