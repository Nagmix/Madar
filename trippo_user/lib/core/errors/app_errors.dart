import 'package:equatable/equatable.dart';

/// Base error class for the application
sealed class AppError extends Equatable {
  final String message;
  final String? code;
  final dynamic originalError;

  const AppError({
    required this.message,
    this.code,
    this.originalError,
  });

  @override
  List<Object?> get props => [message, code];
}

/// Network errors
class NetworkError extends AppError {
  final int? statusCode;

  const NetworkError({
    required super.message,
    super.code,
    super.originalError,
    this.statusCode,
  });

  @override
  List<Object?> get props => [message, code, statusCode];
}

/// Authentication errors
class AuthError extends AppError {
  const AuthError({
    required super.message,
    super.code,
    super.originalError,
  });
}

/// Validation errors
class ValidationError extends AppError {
  final Map<String, String>? fieldErrors;

  const ValidationError({
    required super.message,
    super.code,
    super.originalError,
    this.fieldErrors,
  });

  @override
  List<Object?> get props => [message, code, fieldErrors];
}

/// Location errors
class LocationError extends AppError {
  const LocationError({
    required super.message,
    super.code,
    super.originalError,
  });
}

/// Trip errors
class TripError extends AppError {
  const TripError({
    required super.message,
    super.code,
    super.originalError,
  });
}

/// Payment errors
class PaymentError extends AppError {
  const PaymentError({
    required super.message,
    super.code,
    super.originalError,
  });
}

/// Generic unexpected error
class UnexpectedError extends AppError {
  const UnexpectedError({
    super.message = 'An unexpected error occurred',
    super.code,
    super.originalError,
  });
}

/// Connection timeout error
class TimeoutError extends AppError {
  const TimeoutError({
    super.message = 'Request timed out',
    super.code,
    super.originalError,
  });
}

/// No connection error
class NoConnectionError extends AppError {
  const NoConnectionError({
    super.message = 'No internet connection',
    super.code,
    super.originalError,
  });
}
