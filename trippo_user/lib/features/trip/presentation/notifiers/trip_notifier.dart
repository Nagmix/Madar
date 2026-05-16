import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trippo_shared/trippo_shared.dart';
import '../../../../core/app_providers.dart';

/// Trip State Notifier - Manages the complete trip lifecycle
/// Implements the Trip State Machine with valid transitions
class TripNotifier extends StateNotifier<TripState> {
  final Ref _ref;
  TripModel? _currentTrip;
  
  TripNotifier(this._ref) : super(TripState.searchingDriver);

  TripModel? get currentTrip => _currentTrip;

  /// Create a new trip request
  Future<void> createTrip(CreateTripRequest request) async {
    state = TripState.searchingDriver;
    
    try {
      final apiService = _ref.read(apiServiceProvider);
      final response = await apiService.post(
        ApiConstants.createTrip,
        data: request.toJson(),
      );
      
      _currentTrip = TripModel.fromJson(response.data as Map<String, dynamic>);
      state = TripState.searchingDriver;
      
      // Join the trip room for real-time updates
      final socketService = _ref.read(socketServiceProvider);
      socketService.joinRoom('trip:${_currentTrip!.id}');
      socketService.onTripUpdate(_handleTripUpdate);
      socketService.onDriverLocationUpdate(_handleDriverLocationUpdate);
    } catch (e) {
      state = TripState.searchingDriver;
      rethrow;
    }
  }

  /// Handle trip state update from server
  void _handleTripUpdate(dynamic data) {
    if (data is Map<String, dynamic>) {
      final newState = TripState.fromString(data['state'] as String? ?? '');
      if (isValidTransition(state, newState)) {
        state = newState;
        
        _currentTrip = _currentTrip?.copyWith(
          state: newState,
          driverId: data['driverId'] as String? ?? _currentTrip?.driverId,
        );
      }
    }
  }

  /// Handle driver location update
  void _handleDriverLocationUpdate(dynamic data) {
    // Will be handled by a separate provider
  }

  /// Cancel the current trip
  Future<void> cancelTrip({required String reason}) async {
    if (!cancelableStates.contains(state)) return;
    
    try {
      final socketService = _ref.read(socketServiceProvider);
      socketService.emitTripCancel(
        tripId: _currentTrip?.id ?? '',
        reason: reason,
        cancelledBy: 'rider',
      );
      
      state = TripState.tripCancelled;
      _currentTrip = _currentTrip?.copyWith(
        state: TripState.tripCancelled,
        cancellationReason: reason,
        cancelledBy: CancelledBy.rider,
        cancelledAt: DateTime.now(),
      );
      
      socketService.leaveRoom('trip:${_currentTrip?.id}');
    } catch (e) {
      rethrow;
    }
  }

  /// Rate the trip after completion
  Future<void> rateTrip({required double rating, String? review}) async {
    if (state != TripState.paymentCompleted && state != TripState.tripCompleted) return;
    
    try {
      final socketService = _ref.read(socketServiceProvider);
      socketService.emitTripRating(
        tripId: _currentTrip?.id ?? '',
        rating: rating,
        review: review,
      );
      
      _currentTrip = _currentTrip?.copyWith(
        riderRating: rating,
        riderReview: review,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Reset the trip state
  void reset() {
    state = TripState.searchingDriver;
    _currentTrip = null;
    
    final socketService = _ref.read(socketServiceProvider);
    if (_currentTrip != null) {
      socketService.leaveRoom('trip:${_currentTrip!.id}');
    }
    socketService.off('trip:update');
    socketService.off('trip:driver_location');
  }

  @override
  void dispose() {
    reset();
    super.dispose();
  }
}

/// Trip State Provider
final tripProvider = StateNotifierProvider<TripNotifier, TripState>((ref) {
  return TripNotifier(ref);
});

/// Current Trip Provider
final currentTripProvider = Provider<TripModel?>((ref) {
  final tripNotifier = ref.watch(tripProvider.notifier);
  return tripNotifier.currentTrip;
});

/// Is trip active provider
final isTripActiveProvider = Provider<bool>((ref) {
  final tripState = ref.watch(tripProvider);
  return activeTripStates.contains(tripState);
});
