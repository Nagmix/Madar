import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trippo_shared/trippo_shared.dart';
import '../../../../core/network/nestjs_api_client.dart';

/// Trip History API Provider
final tripHistoryApiProvider = Provider<NestjsApiClient>((ref) => NestjsApiClient());

/// Trip History State
class TripHistoryState {
  final List<TripSummary> trips;
  final bool isLoading;
  final String? error;
  final bool hasMore;
  final int currentPage;
  final String? statusFilter;
  final DateTimeRange? dateRange;

  const TripHistoryState({
    this.trips = const [],
    this.isLoading = false,
    this.error,
    this.hasMore = true,
    this.currentPage = 1,
    this.statusFilter,
    this.dateRange,
  });

  TripHistoryState copyWith({
    List<TripSummary>? trips,
    bool? isLoading,
    String? error,
    bool? hasMore,
    int? currentPage,
    String? statusFilter,
    DateTimeRange? dateRange,
  }) =>
      TripHistoryState(
        trips: trips ?? this.trips,
        isLoading: isLoading ?? this.isLoading,
        error: error,
        hasMore: hasMore ?? this.hasMore,
        currentPage: currentPage ?? this.currentPage,
        statusFilter: statusFilter ?? this.statusFilter,
        dateRange: dateRange ?? this.dateRange,
      );
}

/// Trip History Notifier
///
/// Manages the user's trip history state with pagination, filtering,
/// and NestJS API integration via GET /trips/history.
class TripHistoryNotifier extends StateNotifier<TripHistoryState> {
  final NestjsApiClient _apiClient;

  TripHistoryNotifier(this._apiClient) : super(const TripHistoryState());

  /// Load trip history from NestJS: GET /trips/history
  ///
  /// Set [refresh] to true to reset pagination and reload from page 1.
  /// Pass [status] to filter by trip status (e.g. 'completed', 'cancelled').
  Future<void> loadTrips({bool refresh = false, String? status}) async {
    if (refresh) {
      state = state.copyWith(currentPage: 1, statusFilter: status);
    }

    state = state.copyWith(isLoading: true, error: null);
    try {
      final trips = await _apiClient.getTripHistory(
        page: state.currentPage,
        pageSize: 20,
        status: status ?? state.statusFilter,
      );

      if (mounted) {
        state = state.copyWith(
          trips: refresh ? trips : [...state.trips, ...trips],
          isLoading: false,
          hasMore: trips.isNotEmpty,
          currentPage: state.currentPage + 1,
        );
      }
    } catch (e) {
      if (mounted) {
        state = state.copyWith(isLoading: false, error: e.toString());
      }
    }
  }

  /// Load more trips (pagination)
  ///
  /// Only fetches if not already loading and there are more pages available.
  Future<void> loadMore() async {
    if (state.isLoading || !state.hasMore) return;
    await loadTrips(status: state.statusFilter);
  }

  /// Filter by status tab
  ///
  /// Resets pagination and reloads trips filtered by [status].
  /// Pass null for the 'All' tab.
  Future<void> filterByStatus(String? status) async {
    await loadTrips(refresh: true, status: status);
  }

  /// Filter by date range
  ///
  /// Updates the date range filter and reloads trips.
  /// Pass null to clear the date filter.
  Future<void> filterByDateRange(DateTimeRange? range) async {
    state = state.copyWith(dateRange: range);
    await loadTrips(refresh: true, status: state.statusFilter);
  }
}

/// Trip History Provider
final tripHistoryProvider =
    StateNotifierProvider<TripHistoryNotifier, TripHistoryState>((ref) {
  return TripHistoryNotifier(ref.read(tripHistoryApiProvider));
});
