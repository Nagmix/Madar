
import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:trippo_shared/trippo_shared.dart';
import '../../../../core/app_providers.dart';
import '../../../dispatch/presentation/notifiers/dispatch_notifier.dart';

/// Nearby area statistics (visible to driver when online)
class NearbyStats {
  final int nearbyDrivers;
  final int activeRequests;
  final double surgeMultiplier;
  final bool isHighDemandArea;

  const NearbyStats({
    this.nearbyDrivers = 0,
    this.activeRequests = 0,
    this.surgeMultiplier = 1.0,
    this.isHighDemandArea = false,
  });

  NearbyStats copyWith({
    int? nearbyDrivers,
    int? activeRequests,
    double? surgeMultiplier,
    bool? isHighDemandArea,
  }) =>
      NearbyStats(
        nearbyDrivers: nearbyDrivers ?? this.nearbyDrivers,
        activeRequests: activeRequests ?? this.activeRequests,
        surgeMultiplier: surgeMultiplier ?? this.surgeMultiplier,
        isHighDemandArea: isHighDemandArea ?? this.isHighDemandArea,
      );
}

/// Driver Home State
class DriverHomeState {
  /// Whether the driver is currently online (accepting rides)
  final bool isOnline;

  /// Current GPS location of the driver
  final LocationPoint? currentLocation;

  /// Current heading/bearing in degrees (0 = north, clockwise)
  final double heading;

  /// Nearby area statistics
  final NearbyStats nearbyStats;

  /// Whether location tracking is active
  final bool isTrackingLocation;

  /// Loading state for online/offline transitions
  final bool isLoading;

  /// Error message if any
  final String? error;

  /// Duration driver has been online in current session
  final Duration? onlineDuration;

  /// Timestamp when driver went online
  final DateTime? wentOnlineAt;

  /// Default fallback location (Sana'a, Yemen)
  static const LatLng defaultLocation = LatLng(15.3694, 44.1910);

  const DriverHomeState({
    this.isOnline = false,
    this.currentLocation,
    this.heading = 0,
    this.nearbyStats = const NearbyStats(),
    this.isTrackingLocation = false,
    this.isLoading = false,
    this.error,
    this.onlineDuration,
    this.wentOnlineAt,
  });

  DriverHomeState copyWith({
    bool? isOnline,
    LocationPoint? currentLocation,
    double? heading,
    NearbyStats? nearbyStats,
    bool? isTrackingLocation,
    bool? isLoading,
    String? error,
    Duration? onlineDuration,
    DateTime? wentOnlineAt,
  }) =>
      DriverHomeState(
        isOnline: isOnline ?? this.isOnline,
        currentLocation: currentLocation ?? this.currentLocation,
        heading: heading ?? this.heading,
        nearbyStats: nearbyStats ?? this.nearbyStats,
        isTrackingLocation: isTrackingLocation ?? this.isTrackingLocation,
        isLoading: isLoading ?? this.isLoading,
        error: error,
        onlineDuration: onlineDuration ?? this.onlineDuration,
        wentOnlineAt: wentOnlineAt ?? this.wentOnlineAt,
      );
}

/// Driver Home Notifier
/// Manages driver online/offline status and location tracking
/// When going online: starts GPS tracking, joins dispatch room
/// When going offline: stops GPS tracking, leaves dispatch room
/// Sends location updates every 5 seconds via Socket.IO when online
class DriverHomeNotifier extends StateNotifier<DriverHomeState> {
  final Ref _ref;
  Timer? _locationUpdateTimer;
  Timer? _onlineDurationTimer;
  StreamSubscription<Position>? _positionStreamSubscription;

  /// Location update interval when online (5 seconds)
  static const Duration _locationUpdateInterval = Duration(seconds: 5);

  /// Online duration update interval (1 second)
  static const Duration _durationUpdateInterval = Duration(seconds: 1);

  DriverHomeNotifier(this._ref) : super(const DriverHomeState());

  /// Check and request location permission
  /// Returns true if permission is granted
  Future<bool> _checkLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      return false;
    }
    return true;
  }

  /// Get current GPS position
  Future<Position?> _getCurrentPosition() async {
    final hasPermission = await _checkLocationPermission();
    if (!hasPermission) return null;

    try {
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );
    } catch (e) {
      return null;
    }
  }

  /// Extract user-friendly Arabic error message from DioException
  String _extractErrorMessage(dynamic error) {
    if (error is DioException) {
      final statusCode = error.response?.statusCode;
      final data = error.response?.data;
      
      // Extract message from response body
      String? serverMessage;
      if (data is Map<String, dynamic>) {
        final rawMessage = data['message'];
        if (rawMessage is String) {
          serverMessage = rawMessage;
        } else if (rawMessage is List) {
          serverMessage = rawMessage.join('; ');
        }
      }
      
      switch (statusCode) {
        case 401:
          return 'انتهت صلاحية الجلسة، يرجى إعادة تسجيل الدخول';
        case 403:
          if (serverMessage?.contains('suspended') == true) {
            return 'حسابك معلق، يرجى التواصل مع الدعم';
          }
          if (serverMessage?.contains('document') == true || serverMessage?.contains('Documents') == true) {
            return 'يجب التحقق من المستندات أولاً قبل الاتصال';
          }
          if (serverMessage?.contains('vehicle') == true || serverMessage?.contains('Vehicle') == true) {
            return 'يجب اعتماد المركبة أولاً قبل الاتصال';
          }
          return 'غير مصرح بهذا الإجراء';
        case 404:
          return 'لم يتم العثور على ملف السائق، سيتم إنشاؤه تلقائياً';
        case 429:
          return 'طلبات كثيرة جداً، يرجى المحاولة لاحقاً';
        case 500:
          return 'خطأ في الخادم، يرجى المحاولة لاحقاً';
        case null:
          if (error.type == DioExceptionType.connectionTimeout ||
              error.type == DioExceptionType.sendTimeout ||
              error.type == DioExceptionType.receiveTimeout) {
            return 'انتهت مهلة الاتصال، تحقق من الإنترنت';
          }
          if (error.type == DioExceptionType.connectionError) {
            return 'لا يوجد اتصال بالإنترنت';
          }
          return 'خطأ في الاتصال بالخادم';
        default:
          return serverMessage ?? 'حدث خطأ غير متوقع';
      }
    }
    return error.toString();
  }

  /// Go online - POST /drivers/online with current GPS
  /// If driver profile doesn't exist (404), auto-create it and retry
  Future<void> goOnline() async {
    if (state.isOnline) return;

    state = state.copyWith(isLoading: true, error: null);

    try {
      // Get current GPS position first
      final position = await _getCurrentPosition();
      if (position == null) {
        state = state.copyWith(
          isLoading: false,
          error: 'لا يمكن الحصول على الموقع الحالي. يرجى تفعيل GPS ومنح إذن الموقع',
        );
        return;
      }

      final currentLocation = LocationPoint(
        latitude: position.latitude,
        longitude: position.longitude,
        accuracy: position.accuracy,
        heading: position.heading,
        speed: position.speed,
        timestamp: DateTime.now(),
      );

      // Tell server the driver is online with current GPS
      final apiClient = _ref.read(nestjsApiClientProvider);
      
      try {
        await apiClient.setDriverOnline(
          latitude: currentLocation.latitude,
          longitude: currentLocation.longitude,
          heading: currentLocation.heading,
          accuracy: currentLocation.accuracy,
        );
      } on DioException catch (e) {
        // If 404 - driver profile not found, auto-create it and retry
        if (e.response?.statusCode == 404) {
          try {
            await apiClient.createDriverProfile(
              isAvailable: true,
              vehicle: {
                'name': 'Default Vehicle',
                'plateNumber': 'TEMP',
                'type': 'SEDAN',
                'color': 'White',
                'model': 'Standard',
                'year': '2024',
                'seats': 4,
              },
            );
            // Retry going online after profile creation
            await apiClient.setDriverOnline(
              latitude: currentLocation.latitude,
              longitude: currentLocation.longitude,
              heading: currentLocation.heading,
              accuracy: currentLocation.accuracy,
            );
          } catch (profileError) {
            // If profile creation also fails, show appropriate error
            throw profileError;
          }
        } else if (e.response?.statusCode == 401) {
          // Token expired - clear auth data and show message
          state = state.copyWith(
            isLoading: false,
            error: 'انتهت صلاحية الجلسة، يرجى إعادة تسجيل الدخول',
          );
          return;
        } else {
          rethrow;
        }
      }

      // Start real-time position stream
      _startPositionStream();

      // Start dispatch listening
      final dispatchNotifier = _ref.read(dispatchProvider.notifier);
      dispatchNotifier.startListening();

      // Start periodic location updates via Socket.IO (every 5 seconds)
      _startLocationUpdateTimer();

      // Start online duration timer
      _startOnlineDurationTimer();

      state = state.copyWith(
        isOnline: true,
        currentLocation: currentLocation,
        heading: currentLocation.heading,
        isLoading: false,
        wentOnlineAt: DateTime.now(),
        error: null,
      );
    } on DioException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: _extractErrorMessage(e),
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: _extractErrorMessage(e),
      );
    }
  }

  /// Go offline - POST /drivers/offline
  Future<void> goOffline() async {
    if (!state.isOnline) return;

    state = state.copyWith(isLoading: true, error: null);

    try {
      final apiClient = _ref.read(nestjsApiClientProvider);
      await apiClient.setDriverOffline();

      _stopPositionStream();
      _stopLocationUpdateTimer();
      _stopOnlineDurationTimer();

      final dispatchNotifier = _ref.read(dispatchProvider.notifier);
      dispatchNotifier.stopListening();

      state = state.copyWith(
        isOnline: false,
        isTrackingLocation: false,
        isLoading: false,
        onlineDuration: Duration.zero,
        wentOnlineAt: null,
        error: null,
      );
    } on DioException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: _extractErrorMessage(e),
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: _extractErrorMessage(e),
      );
    }
  }

  /// Start watching GPS position stream
  void _startPositionStream() {
    _stopPositionStream();

    _positionStreamSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5,
      ),
    ).listen((Position position) {
      final newLocation = LocationPoint(
        latitude: position.latitude,
        longitude: position.longitude,
        accuracy: position.accuracy,
        heading: position.heading,
        speed: position.speed,
        timestamp: DateTime.now(),
      );

      state = state.copyWith(
        currentLocation: newLocation,
        heading: position.heading,
      );
    });

    state = state.copyWith(isTrackingLocation: true);
  }

  /// Stop GPS position stream
  void _stopPositionStream() {
    _positionStreamSubscription?.cancel();
    _positionStreamSubscription = null;
  }

  /// Start periodic location update timer (sends to server every 5 seconds)
  void _startLocationUpdateTimer() {
    _stopLocationUpdateTimer();

    _locationUpdateTimer = Timer.periodic(_locationUpdateInterval, (_) {
      if (state.isOnline && state.currentLocation != null) {
        // Send location update via API
        final apiClient = _ref.read(nestjsApiClientProvider);
        apiClient.updateDriverLocation(
          latitude: state.currentLocation!.latitude,
          longitude: state.currentLocation!.longitude,
          heading: state.currentLocation!.heading,
          speed: state.currentLocation!.speed,
          accuracy: state.currentLocation!.accuracy,
        );
      }
    });
  }

  /// Stop periodic location update timer
  void _stopLocationUpdateTimer() {
    _locationUpdateTimer?.cancel();
    _locationUpdateTimer = null;
  }

  /// Start online duration timer
  void _startOnlineDurationTimer() {
    _stopOnlineDurationTimer();

    _onlineDurationTimer = Timer.periodic(_durationUpdateInterval, (_) {
      if (state.wentOnlineAt != null) {
        final duration = DateTime.now().difference(state.wentOnlineAt!);
        state = state.copyWith(onlineDuration: duration);
      }
    });
  }

  /// Stop online duration timer
  void _stopOnlineDurationTimer() {
    _onlineDurationTimer?.cancel();
    _onlineDurationTimer = null;
  }

  /// Toggle online/offline status
  Future<void> toggleOnlineStatus() async {
    if (state.isOnline) {
      await goOffline();
    } else {
      await goOnline();
    }
  }

  /// Update nearby stats (received from server via Socket.IO)
  void updateNearbyStats(NearbyStats stats) {
    state = state.copyWith(nearbyStats: stats);
  }

  /// Get current LatLng for the map
  LatLng get currentLatLng {
    if (state.currentLocation != null) {
      return LatLng(state.currentLocation!.latitude, state.currentLocation!.longitude);
    }
    return DriverHomeState.defaultLocation;
  }

  @override
  void dispose() {
    _stopLocationUpdateTimer();
    _stopOnlineDurationTimer();
    _stopPositionStream();
    super.dispose();
  }
}

/// Driver Home Provider
final driverHomeProvider =
    StateNotifierProvider<DriverHomeNotifier, DriverHomeState>((ref) {
  return DriverHomeNotifier(ref);
});

/// Is driver online provider
final isDriverOnlineProvider = Provider<bool>((ref) {
  final homeState = ref.watch(driverHomeProvider);
  return homeState.isOnline;
});

/// Driver current location provider
final driverCurrentLocationProvider = Provider<LocationPoint?>((ref) {
  final homeState = ref.watch(driverHomeProvider);
  return homeState.currentLocation;
});

/// Driver current heading provider
final driverHeadingProvider = Provider<double>((ref) {
  final homeState = ref.watch(driverHomeProvider);
  return homeState.heading;
});

/// Driver online duration provider
final driverOnlineDurationProvider = Provider<Duration?>((ref) {
  final homeState = ref.watch(driverHomeProvider);
  return homeState.onlineDuration;
});

/// Nearby stats provider
final nearbyStatsProvider = Provider<NearbyStats>((ref) {
  final homeState = ref.watch(driverHomeProvider);
  return homeState.nearbyStats;
});

/// Vehicle input model for profile creation
class VehicleInput {
  final String name;
  final String plateNumber;
  final String type;
  final String? color;
  final String? model;
  final String? year;
  final int? seats;

  const VehicleInput({
    required this.name,
    required this.plateNumber,
    required this.type,
    this.color,
    this.model,
    this.year,
    this.seats,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'plateNumber': plateNumber,
    'type': type,
    if (color != null) 'color': color,
    if (model != null) 'model': model,
    if (year != null) 'year': year,
    if (seats != null) 'seats': seats,
  };
}

