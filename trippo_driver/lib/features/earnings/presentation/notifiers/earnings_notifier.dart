import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trippo_shared/trippo_shared.dart';
import '../../../../core/app_providers.dart';
import '../../../../core/network/nestjs_api_client.dart';

/// Earnings Period
enum EarningsPeriod { today, week, month, custom }

/// Earnings breakdown for a specific period
class EarningsBreakdown {
  final double totalEarnings;
  final double totalTrips;
  final double totalCommission;
  final double netEarnings;
  final double totalIncentives;
  final double averageFare;
  final int tripCount;
  final int onlineMinutes;
  final double hourlyRate;
  final double acceptanceRate;
  final double cancellationRate;

  const EarningsBreakdown({
    this.totalEarnings = 0,
    this.totalTrips = 0,
    this.totalCommission = 0,
    this.netEarnings = 0,
    this.totalIncentives = 0,
    this.averageFare = 0,
    this.tripCount = 0,
    this.onlineMinutes = 0,
    this.hourlyRate = 0,
    this.acceptanceRate = 0,
    this.cancellationRate = 0,
  });

  factory EarningsBreakdown.fromJson(Map<String, dynamic> json) =>
      EarningsBreakdown(
        totalEarnings: (json['totalEarnings'] as num?)?.toDouble() ?? 0,
        totalTrips: (json['totalTrips'] as num?)?.toDouble() ?? 0,
        totalCommission: (json['totalCommission'] as num?)?.toDouble() ?? 0,
        netEarnings: (json['netEarnings'] as num?)?.toDouble() ?? 0,
        totalIncentives: (json['totalIncentives'] as num?)?.toDouble() ?? 0,
        averageFare: (json['averageFare'] as num?)?.toDouble() ?? 0,
        tripCount: json['tripCount'] as int? ?? 0,
        onlineMinutes: json['onlineMinutes'] as int? ?? 0,
        hourlyRate: (json['hourlyRate'] as num?)?.toDouble() ?? 0,
        acceptanceRate: (json['acceptanceRate'] as num?)?.toDouble() ?? 0,
        cancellationRate: (json['cancellationRate'] as num?)?.toDouble() ?? 0,
      );
}

/// Incentive progress tracking
class IncentiveProgress {
  final String incentiveId;
  final String name;
  final String description;
  final double targetValue;
  final double currentValue;
  final double bonusAmount;
  final double progressPercent;
  final DateTime? deadline;
  final bool isCompleted;

  const IncentiveProgress({
    required this.incentiveId,
    required this.name,
    this.description = '',
    this.targetValue = 0,
    this.currentValue = 0,
    this.bonusAmount = 0,
    this.progressPercent = 0,
    this.deadline,
    this.isCompleted = false,
  });

  factory IncentiveProgress.fromJson(Map<String, dynamic> json) =>
      IncentiveProgress(
        incentiveId: json['incentiveId'] as String? ?? '',
        name: json['name'] as String? ?? '',
        description: json['description'] as String? ?? '',
        targetValue: (json['targetValue'] as num?)?.toDouble() ?? 0,
        currentValue: (json['currentValue'] as num?)?.toDouble() ?? 0,
        bonusAmount: (json['bonusAmount'] as num?)?.toDouble() ?? 0,
        progressPercent: (json['progressPercent'] as num?)?.toDouble() ?? 0,
        deadline: json['deadline'] != null
            ? DateTime.tryParse(json['deadline'] as String)
            : null,
        isCompleted: json['isCompleted'] as bool? ?? false,
      );
}

/// Complete earnings data with breakdown by period + commission rate + incentives
class EarningsData {
  final EarningsBreakdown? todayBreakdown;
  final EarningsBreakdown? weekBreakdown;
  final EarningsBreakdown? monthBreakdown;
  final EarningsBreakdown? customBreakdown;
  final double commissionRate;
  final List<IncentiveProgress> incentiveProgress;
  final DateTime? lastUpdated;

  const EarningsData({
    this.todayBreakdown,
    this.weekBreakdown,
    this.monthBreakdown,
    this.customBreakdown,
    this.commissionRate = AppConstants.driverCommissionRate,
    this.incentiveProgress = const [],
    this.lastUpdated,
  });

  EarningsData copyWith({
    EarningsBreakdown? todayBreakdown,
    EarningsBreakdown? weekBreakdown,
    EarningsBreakdown? monthBreakdown,
    EarningsBreakdown? customBreakdown,
    double? commissionRate,
    List<IncentiveProgress>? incentiveProgress,
    DateTime? lastUpdated,
  }) =>
      EarningsData(
        todayBreakdown: todayBreakdown ?? this.todayBreakdown,
        weekBreakdown: weekBreakdown ?? this.weekBreakdown,
        monthBreakdown: monthBreakdown ?? this.monthBreakdown,
        customBreakdown: customBreakdown ?? this.customBreakdown,
        commissionRate: commissionRate ?? this.commissionRate,
        incentiveProgress: incentiveProgress ?? this.incentiveProgress,
        lastUpdated: lastUpdated ?? this.lastUpdated,
      );
}

/// Earnings State
class EarningsState {
  final EarningsData earningsData;
  final bool isLoading;
  final String? error;

  const EarningsState({
    this.earningsData = const EarningsData(),
    this.isLoading = false,
    this.error,
  });

  EarningsState copyWith({
    EarningsData? earningsData,
    bool? isLoading,
    String? error,
  }) =>
      EarningsState(
        earningsData: earningsData ?? this.earningsData,
        isLoading: isLoading ?? this.isLoading,
        error: error,
      );
}

/// Earnings Notifier
/// Manages driver earnings data via NestJS Driver Module
/// Supports today/week/month breakdown, commission rate, and incentive progress
class EarningsNotifier extends StateNotifier<EarningsState> {
  final Ref _ref;

  EarningsNotifier(this._ref) : super(const EarningsState());

  /// Load earnings for a specific period - GET /drivers/earnings?period=
  Future<void> loadEarnings(EarningsPeriod period,
      {DateTime? startDate, DateTime? endDate}) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final apiClient = _ref.read(nestjsApiClientProvider);

      final periodStr = _periodToString(period);
      final data = await apiClient.getDriverEarnings(
        period: periodStr,
        startDate: startDate,
        endDate: endDate,
      );

      final breakdown = EarningsBreakdown.fromJson(data);

      EarningsData updatedEarnings;
      switch (period) {
        case EarningsPeriod.today:
          updatedEarnings = state.earningsData.copyWith(
            todayBreakdown: breakdown,
            lastUpdated: DateTime.now(),
          );
          break;
        case EarningsPeriod.week:
          updatedEarnings = state.earningsData.copyWith(
            weekBreakdown: breakdown,
            lastUpdated: DateTime.now(),
          );
          break;
        case EarningsPeriod.month:
          updatedEarnings = state.earningsData.copyWith(
            monthBreakdown: breakdown,
            lastUpdated: DateTime.now(),
          );
          break;
        case EarningsPeriod.custom:
          updatedEarnings = state.earningsData.copyWith(
            customBreakdown: breakdown,
            lastUpdated: DateTime.now(),
          );
          break;
      }

      // Update commission rate from API response if available
      final commissionRate =
          (data['commissionRate'] as num?)?.toDouble() ??
              AppConstants.driverCommissionRate;
      updatedEarnings = updatedEarnings.copyWith(
        commissionRate: commissionRate,
      );

      state = state.copyWith(
        earningsData: updatedEarnings,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Load incentive progress - from earnings API
  /// GET /drivers/earnings with incentive details
  Future<void> loadIncentiveProgress() async {
    try {
      final apiClient = _ref.read(nestjsApiClientProvider);
      final data = await apiClient.getDriverEarnings(period: 'incentives');

      final incentives = <IncentiveProgress>[];
      if (data['incentives'] is List) {
        for (final item in data['incentives'] as List<dynamic>) {
          if (item is Map<String, dynamic>) {
            incentives.add(IncentiveProgress.fromJson(item));
          }
        }
      }

      state = state.copyWith(
        earningsData: state.earningsData.copyWith(
          incentiveProgress: incentives,
        ),
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Load all earnings data at once (today + week + month)
  Future<void> loadAllEarnings() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // Load all three periods in parallel
      await Future.wait([
        loadEarnings(EarningsPeriod.today),
        loadEarnings(EarningsPeriod.week),
        loadEarnings(EarningsPeriod.month),
      ]);

      // Then load incentives
      await loadIncentiveProgress();

      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Convert EarningsPeriod enum to API string
  String _periodToString(EarningsPeriod period) {
    switch (period) {
      case EarningsPeriod.today:
        return 'today';
      case EarningsPeriod.week:
        return 'week';
      case EarningsPeriod.month:
        return 'month';
      case EarningsPeriod.custom:
        return 'custom';
    }
  }
}

/// Earnings Provider
final earningsProvider =
    StateNotifierProvider<EarningsNotifier, EarningsState>((ref) {
  return EarningsNotifier(ref);
});

/// Today's earnings provider
final todayEarningsProvider = Provider<EarningsBreakdown?>((ref) {
  final earningsState = ref.watch(earningsProvider);
  return earningsState.earningsData.todayBreakdown;
});

/// Week's earnings provider
final weekEarningsProvider = Provider<EarningsBreakdown?>((ref) {
  final earningsState = ref.watch(earningsProvider);
  return earningsState.earningsData.weekBreakdown;
});

/// Month's earnings provider
final monthEarningsProvider = Provider<EarningsBreakdown?>((ref) {
  final earningsState = ref.watch(earningsProvider);
  return earningsState.earningsData.monthBreakdown;
});

/// Incentive progress provider
final incentiveProgressProvider = Provider<List<IncentiveProgress>>((ref) {
  final earningsState = ref.watch(earningsProvider);
  return earningsState.earningsData.incentiveProgress;
});
