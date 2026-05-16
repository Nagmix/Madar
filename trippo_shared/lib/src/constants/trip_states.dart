/// Trip States - Trip State Machine
/// Defines all possible states a trip can be in
/// and valid transitions between them
library;

/// All possible trip states in the system
enum TripState {
  /// Initial state - searching for available driver
  searchingDriver('SEARCHING_DRIVER'),

  /// A driver has been assigned to the trip
  driverAssigned('DRIVER_ASSIGNED'),

  /// Driver is heading to pickup location
  driverArriving('DRIVER_ARRIVING'),

  /// Driver has arrived at pickup location
  driverArrived('DRIVER_ARRIVED'),

  /// Trip has started - driver and rider are en route
  tripStarted('TRIP_STARTED'),

  /// Trip is temporarily paused (traffic, etc.)
  tripPaused('TRIP_PAUSED'),

  /// Trip has resumed after being paused
  tripResumed('TRIP_RESUMED'),

  /// Trip has been completed - arrived at destination
  tripCompleted('TRIP_COMPLETED'),

  /// Waiting for payment to be processed
  paymentPending('PAYMENT_PENDING'),

  /// Payment has been completed successfully
  paymentCompleted('PAYMENT_COMPLETED'),

  /// Trip has been cancelled (by rider or driver)
  tripCancelled('TRIP_CANCELLED');

  const TripState(this.value);
  final String value;

  /// Parse from string value
  static TripState fromString(String value) {
    return TripState.values.firstWhere(
      (state) => state.value == value,
      orElse: () => TripState.searchingDriver,
    );
  }
}

/// Valid state transitions map
/// Key: current state, Value: list of valid next states
const Map<TripState, List<TripState>> tripStateTransitions = {
  TripState.searchingDriver: [
    TripState.driverAssigned,
    TripState.tripCancelled,
  ],
  TripState.driverAssigned: [
    TripState.driverArriving,
    TripState.tripCancelled,
  ],
  TripState.driverArriving: [
    TripState.driverArrived,
    TripState.tripCancelled,
  ],
  TripState.driverArrived: [
    TripState.tripStarted,
    TripState.tripCancelled,
  ],
  TripState.tripStarted: [
    TripState.tripPaused,
    TripState.tripCompleted,
    TripState.tripCancelled,
  ],
  TripState.tripPaused: [
    TripState.tripResumed,
    TripState.tripCancelled,
  ],
  TripState.tripResumed: [
    TripState.tripPaused,
    TripState.tripCompleted,
    TripState.tripCancelled,
  ],
  TripState.tripCompleted: [
    TripState.paymentPending,
  ],
  TripState.paymentPending: [
    TripState.paymentCompleted,
  ],
  TripState.paymentCompleted: [],
  TripState.tripCancelled: [],
};

/// Terminal states - no further transitions possible
const Set<TripState> terminalStates = {
  TripState.paymentCompleted,
  TripState.tripCancelled,
};

/// Check if a transition from [from] to [to] is valid
bool isValidTransition(TripState from, TripState to) {
  return tripStateTransitions[from]?.contains(to) ?? false;
}

/// Cancelable states - states from which the trip can be cancelled
const Set<TripState> cancelableStates = {
  TripState.searchingDriver,
  TripState.driverAssigned,
  TripState.driverArriving,
  TripState.driverArrived,
  TripState.tripStarted,
  TripState.tripPaused,
  TripState.tripResumed,
};

/// Active trip states - states where the trip is "in progress"
const Set<TripState> activeTripStates = {
  TripState.driverAssigned,
  TripState.driverArriving,
  TripState.driverArrived,
  TripState.tripStarted,
  TripState.tripPaused,
  TripState.tripResumed,
};
