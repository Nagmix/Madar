import 'package:dio/dio.dart';
import '../constants/api_constants.dart';

/// API Service - Central HTTP client for all API communications
/// Handles authentication, interceptors, error handling, and environment config
class ApiService {
  late final Dio _dio;
  String? _accessToken;
  String? _refreshToken;

  ApiService({String? baseUrl}) {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl ?? ApiConstants.devBaseUrl,
        connectTimeout: ApiConstants.connectionTimeout,
        receiveTimeout: ApiConstants.receiveTimeout,
        sendTimeout: ApiConstants.sendTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _setupInterceptors();
  }

  Dio get dio => _dio;

  void setTokens({required String accessToken, String? refreshToken}) {
    _accessToken = accessToken;
    _refreshToken = refreshToken;
  }

  void clearTokens() {
    _accessToken = null;
    _refreshToken = null;
  }

  String? get accessToken => _accessToken;

  void _setupInterceptors() {
    _dio.interceptors.addAll([
      _AuthInterceptor(this),
      _LoggingInterceptor(),
      _ErrorInterceptor(),
    ]);
  }

  // ==================== Generic HTTP Methods ====================

  Future<ApiResponse> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return ApiResponse.fromResponse(response);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<ApiResponse> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return ApiResponse.fromResponse(response);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<ApiResponse> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return ApiResponse.fromResponse(response);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<ApiResponse> patch(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.patch(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return ApiResponse.fromResponse(response);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<ApiResponse> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return ApiResponse.fromResponse(response);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // ==================== Error Handling ====================

  AppException _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return AppException(
          type: AppExceptionType.timeout,
          message: 'Connection timed out. Please try again.',
          originalError: e,
        );
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        final data = e.response?.data;
        String message = 'An error occurred';
        if (data is Map<String, dynamic>) {
          final rawMsg = data['message'] ?? data['error'] ?? message;
          message = rawMsg is List ? rawMsg.join('. ') : rawMsg.toString();
        }
        return AppException(
          type: _mapStatusCode(statusCode),
          message: message,
          statusCode: statusCode,
          originalError: e,
          data: data,
        );
      case DioExceptionType.cancel:
        return AppException(
          type: AppExceptionType.cancelled,
          message: 'Request was cancelled',
          originalError: e,
        );
      case DioExceptionType.connectionError:
        return AppException(
          type: AppExceptionType.noConnection,
          message: 'No internet connection',
          originalError: e,
        );
      default:
        return AppException(
          type: AppExceptionType.unknown,
          message: 'An unexpected error occurred',
          originalError: e,
        );
    }
  }

  AppExceptionType _mapStatusCode(int? statusCode) {
    switch (statusCode) {
      case 400:
        return AppExceptionType.badRequest;
      case 401:
        return AppExceptionType.unauthorized;
      case 403:
        return AppExceptionType.forbidden;
      case 404:
        return AppExceptionType.notFound;
      case 409:
        return AppExceptionType.conflict;
      case 422:
        return AppExceptionType.validationError;
      case 429:
        return AppExceptionType.rateLimited;
      case 500:
        return AppExceptionType.serverError;
      case 503:
        return AppExceptionType.serviceUnavailable;
      default:
        return AppExceptionType.unknown;
    }
  }
}

// ==================== Auth Interceptor ====================

class _AuthInterceptor extends Interceptor {
  final ApiService _apiService;

  _AuthInterceptor(this._apiService);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (_apiService._accessToken != null) {
      options.headers['Authorization'] = 'Bearer ${_apiService._accessToken}';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401 && _apiService._refreshToken != null) {
      try {
        // Attempt to refresh the token
        final response = await _apiService._dio.post(
          ApiConstants.refreshToken,
          data: {'refreshToken': _apiService._refreshToken},
        );

        if (response.statusCode == 200) {
          final newAccessToken = response.data['accessToken'];
          final newRefreshToken = response.data['refreshToken'];
          _apiService.setTokens(
            accessToken: newAccessToken,
            refreshToken: newRefreshToken,
          );

          // Retry the original request with new token
          err.requestOptions.headers['Authorization'] =
              'Bearer $newAccessToken';
          final retryResponse = await _apiService._dio.fetch(err.requestOptions);
          handler.resolve(retryResponse);
          return;
        }
      } catch (_) {
        // Refresh failed - clear tokens and let the error propagate
        _apiService.clearTokens();
      }
    }
    handler.next(err);
  }
}

// ==================== Logging Interceptor ====================

class _LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // In production, disable or reduce logging
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    handler.next(err);
  }
}

// ==================== Error Interceptor ====================

class _ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Centralized error processing could go here
    // e.g., logging to Sentry, analytics, etc.
    handler.next(err);
  }
}

// ==================== API Response ====================

class ApiResponse {
  final dynamic data;
  final int? statusCode;
  final Map<String, dynamic>? headers;
  final bool success;
  final String? message;

  ApiResponse({
    required this.data,
    this.statusCode,
    this.headers,
    required this.success,
    this.message,
  });

  factory ApiResponse.fromResponse(Response response) {
    final responseData = response.data;
    return ApiResponse(
      data: responseData is Map<String, dynamic>
          ? responseData['data'] ?? responseData
          : responseData,
      statusCode: response.statusCode,
      headers: response.headers.map,
      success: (response.statusCode ?? 0) >= 200 &&
          (response.statusCode ?? 0) < 300,
      message: responseData is Map<String, dynamic>
          ? (() { final m = responseData['message']; return m is List ? m.join('. ') : m?.toString(); })()
          : null,
    );
  }
}

// ==================== App Exception ====================

enum AppExceptionType {
  timeout,
  noConnection,
  unauthorized,
  forbidden,
  notFound,
  badRequest,
  conflict,
  validationError,
  rateLimited,
  serverError,
  serviceUnavailable,
  cancelled,
  unknown,
}

class AppException implements Exception {
  final AppExceptionType type;
  final String message;
  final int? statusCode;
  final dynamic originalError;
  final dynamic data;

  AppException({
    required this.type,
    required this.message,
    this.statusCode,
    this.originalError,
    this.data,
  });

  @override
  String toString() => 'AppException($type): $message';
}
