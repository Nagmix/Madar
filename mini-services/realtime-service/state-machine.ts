// ============================================
// Trip State Machine - Validates all transitions
// ============================================

export type TripStatus =
  | 'SEARCHING_DRIVER'
  | 'DRIVER_ASSIGNED'
  | 'DRIVER_ARRIVING'
  | 'DRIVER_ARRIVED'
  | 'TRIP_STARTED'
  | 'TRIP_PAUSED'
  | 'TRIP_RESUMED'
  | 'TRIP_COMPLETED'
  | 'PAYMENT_PENDING'
  | 'PAYMENT_COMPLETED'
  | 'TRIP_CANCELLED'
  | 'TRIP_EXPIRED';

// Terminal states - no transitions allowed from these
const TERMINAL_STATES: TripStatus[] = [
  'TRIP_CANCELLED',
  'TRIP_EXPIRED',
  'PAYMENT_COMPLETED',
];

// Valid state transitions map
const VALID_TRANSITIONS: Record<TripStatus, TripStatus[]> = {
  SEARCHING_DRIVER: ['DRIVER_ASSIGNED', 'TRIP_EXPIRED', 'TRIP_CANCELLED'],
  DRIVER_ASSIGNED: ['DRIVER_ARRIVING', 'TRIP_CANCELLED'],
  DRIVER_ARRIVING: ['DRIVER_ARRIVED', 'TRIP_CANCELLED'],
  DRIVER_ARRIVED: ['TRIP_STARTED', 'TRIP_CANCELLED'],
  TRIP_STARTED: ['TRIP_PAUSED', 'TRIP_COMPLETED', 'TRIP_CANCELLED'],
  TRIP_PAUSED: ['TRIP_RESUMED', 'TRIP_CANCELLED'],
  TRIP_RESUMED: ['TRIP_PAUSED', 'TRIP_COMPLETED', 'TRIP_CANCELLED'],
  TRIP_COMPLETED: ['PAYMENT_PENDING'],
  PAYMENT_PENDING: ['PAYMENT_COMPLETED', 'PAYMENT_FAILED'],
  TRIP_CANCELLED: [],
  TRIP_EXPIRED: [],
  PAYMENT_COMPLETED: [],
  // PAYMENT_FAILED is not in our TripStatus enum, but we handle it as PAYMENT_PENDING retry
};

// Override: PAYMENT_FAILED maps back to PAYMENT_PENDING or TRIP_CANCELLED
// Since TripStatus doesn't have PAYMENT_FAILED, we'll treat it as a special case

export interface TransitionResult {
  valid: boolean;
  error?: string;
}

/**
 * Check if a state transition is valid
 */
export function isValidTransition(
  from: TripStatus,
  to: TripStatus
): boolean {
  if (TERMINAL_STATES.includes(from)) {
    return false;
  }
  const allowed = VALID_TRANSITIONS[from];
  if (!allowed) return false;
  return allowed.includes(to);
}

/**
 * Validate a state transition and return detailed result
 */
export function validateTransition(
  from: TripStatus,
  to: TripStatus
): TransitionResult {
  // Check if current state is terminal
  if (TERMINAL_STATES.includes(from)) {
    return {
      valid: false,
      error: `Cannot transition from terminal state '${from}'`,
    };
  }

  // Check if transition is defined
  const allowed = VALID_TRANSITIONS[from];
  if (!allowed) {
    return {
      valid: false,
      error: `No transitions defined for state '${from}'`,
    };
  }

  // Check if target state is allowed
  if (!allowed.includes(to)) {
    return {
      valid: false,
      error: `Invalid transition from '${from}' to '${to}'. Allowed: [${allowed.join(', ')}]`,
    };
  }

  return { valid: true };
}

/**
 * Get all possible next states from a given state
 */
export function getNextStates(current: TripStatus): TripStatus[] {
  if (TERMINAL_STATES.includes(current)) {
    return [];
  }
  return VALID_TRANSITIONS[current] || [];
}

/**
 * Check if a state is terminal (no further transitions)
 */
export function isTerminalState(state: TripStatus): boolean {
  return TERMINAL_STATES.includes(state);
}

/**
 * Get the appropriate timestamp field name for a given status
 */
export function getTimestampField(
  status: TripStatus
): string | null {
  const mapping: Record<string, string> = {
    DRIVER_ASSIGNED: 'driverAssignedAt',
    DRIVER_ARRIVING: 'driverArrivingAt',
    DRIVER_ARRIVED: 'driverArrivedAt',
    TRIP_STARTED: 'tripStartedAt',
    TRIP_COMPLETED: 'tripCompletedAt',
    TRIP_CANCELLED: 'tripCancelledAt',
    PAYMENT_COMPLETED: 'paymentCompletedAt',
  };
  return mapping[status] || null;
}
