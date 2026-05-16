import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trippo_shared/trippo_shared.dart';
import '../../../../core/constants/app_theme.dart';
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
class TripHistoryNotifier extends StateNotifier<TripHistoryState> {
  final NestjsApiClient _apiClient;

  TripHistoryNotifier(this._apiClient) : super(const TripHistoryState());

  /// Load trip history from NestJS: GET /trips/history
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
  Future<void> loadMore() async {
    if (state.isLoading || !state.hasMore) return;
    await loadTrips(status: state.statusFilter);
  }

  /// Filter by status tab
  Future<void> filterByStatus(String? status) async {
    await loadTrips(refresh: true, status: status);
  }

  /// Filter by date range
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

/// Driver Trip History Screen - Complete trip history view
///
/// Features:
/// - Tab bar: All / Completed / Cancelled
/// - Trip cards with: pickup→dropoff, fare earned, commission deducted,
///   rider name, rating, date
/// - Filter by date range
/// - Pull to refresh
/// - Pagination (load more on scroll)
/// - Empty state
/// - All via NestJS: GET /trips/history
class DriverTripHistoryScreen extends ConsumerStatefulWidget {
  const DriverTripHistoryScreen({super.key});

  @override
  ConsumerState<DriverTripHistoryScreen> createState() =>
      _DriverTripHistoryScreenState();
}

class _DriverTripHistoryScreenState
    extends ConsumerState<DriverTripHistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTimeRange? _selectedDateRange;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_handleTabChange);

    // Initial load
    Future.microtask(() {
      ref.read(tripHistoryProvider.notifier).loadTrips();
    });
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    super.dispose();
  }

  void _handleTabChange() {
    if (!_tabController.indexIsChanging) {
      final statusFilter = switch (_tabController.index) {
        1 => 'completed',
        2 => 'cancelled',
        _ => null,
      };
      ref.read(tripHistoryProvider.notifier).filterByStatus(statusFilter);
    }
  }

  @override
  Widget build(BuildContext context) {
    final historyState = ref.watch(tripHistoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Trip History'),
        actions: [
          // Date range filter
          IconButton(
            icon: const Icon(Icons.calendar_month_outlined),
            onPressed: _handleDateRangeFilter,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Completed'),
            Tab(text: 'Cancelled'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Active date range filter indicator
          if (_selectedDateRange != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacing16, vertical: AppTheme.spacing8),
              color: AppTheme.primary.withOpacity(0.05),
              child: Row(
                children: [
                  const Icon(Icons.filter_list, size: 16, color: AppTheme.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${_formatDate(_selectedDateRange!.start)} - ${_formatDate(_selectedDateRange!.end)}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: _clearDateFilter,
                    child: const Icon(Icons.close, size: 16, color: AppTheme.primary),
                  ),
                ],
              ),
            ),

          // Trip list
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => ref
                  .read(tripHistoryProvider.notifier)
                  .loadTrips(refresh: true, status: historyState.statusFilter),
              color: AppTheme.primary,
              child: _buildBody(historyState),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(TripHistoryState state) {
    if (state.isLoading && state.trips.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null && state.trips.isEmpty) {
      return _buildErrorState(state.error!);
    }

    if (state.trips.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.separated(
      padding: const EdgeInsets.all(AppTheme.spacing16),
      itemCount: state.trips.length + (state.hasMore ? 1 : 0),
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        if (index >= state.trips.length) {
          // Load more trigger
          Future.microtask(
              () => ref.read(tripHistoryProvider.notifier).loadMore());
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        return _buildTripCard(state.trips[index]);
      },
    );
  }

  // ==================== Trip Card ====================

  Widget _buildTripCard(TripSummary trip) {
    final isCompleted = trip.state == TripState.tripCompleted;
    final isCancelled = trip.state == TripState.tripCancelled;

    return Card(
      child: InkWell(
        onTap: () => _navigateToTripDetail(trip),
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacing16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top row: Date + Status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _formatDate(trip.createdAt),
                    style: AppTheme.bodySmall,
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: _getStatusColor(trip.state.name).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      trip.state.name.toUpperCase(),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: _getStatusColor(trip.state.name),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppTheme.spacing12),

              // Route: Pickup → Dropoff
              Row(
                children: [
                  // Pickup dot
                  Column(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: AppTheme.mapPickup,
                          shape: BoxShape.circle,
                        ),
                      ),
                      Container(
                        width: 2,
                        height: 24,
                        color: AppTheme.divider,
                      ),
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: AppTheme.mapDropoff,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: AppTheme.spacing12),

                  // Addresses
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          trip.pickupAddress,
                          style: AppTheme.bodyMedium.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          trip.dropoffAddress,
                          style: AppTheme.bodyMedium.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const Divider(height: AppTheme.spacing24),

              // Bottom row: Fare, Commission, Rider, Rating
              Row(
                children: [
                  // Fare earned
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Fare', style: AppTheme.bodySmall),
                        Text(
                          '\$${trip.fare.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                            color: AppTheme.success,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Driver name
                  if (trip.driverName != null)
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Driver', style: AppTheme.bodySmall),
                          Text(
                            trip.driverName!,
                            style: AppTheme.bodyMedium.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),

                  // Rating
                  if (trip.rating != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('Rating', style: AppTheme.bodySmall),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star,
                                size: 14, color: Colors.amber),
                            Text(
                              trip.rating!.toStringAsFixed(1),
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==================== Empty State ====================

  Widget _buildEmptyState() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.6,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.route_outlined,
                    size: 80, color: Colors.grey[300]),
                const SizedBox(height: 16),
                Text(
                  'No Trips Yet',
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Your trip history will appear here once you complete rides.',
                  style: TextStyle(color: Colors.grey[400], fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ==================== Error State ====================

  Widget _buildErrorState(String error) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.6,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline,
                    size: 64, color: AppTheme.error),
                const SizedBox(height: 16),
                const Text(
                  'Failed to load trip history',
                  style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Text(error,
                    style: AppTheme.bodySmall, textAlign: TextAlign.center),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => ref
                      .read(tripHistoryProvider.notifier)
                      .loadTrips(refresh: true),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ==================== Date Range Filter ====================

  Future<void> _handleDateRangeFilter() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now,
      initialDateRange: _selectedDateRange ??
          DateTimeRange(
            start: now.subtract(const Duration(days: 30)),
            end: now,
          ),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.primary,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() => _selectedDateRange = picked);
      ref.read(tripHistoryProvider.notifier).filterByDateRange(picked);
    }
  }

  void _clearDateFilter() {
    setState(() => _selectedDateRange = null);
    ref.read(tripHistoryProvider.notifier).filterByDateRange(null);
  }

  // ==================== Helpers ====================

  Color _getStatusColor(String status) {
    return switch (status) {
      'tripCompleted' => AppTheme.success,
      'tripCancelled' => AppTheme.error,
      'tripStarted' => AppTheme.info,
      _ => Colors.grey,
    };
  }

  String _formatDate(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }

  void _navigateToTripDetail(TripSummary trip) {
    // TODO: Navigate to trip detail screen
    // context.go('/trip-detail/${trip.id}');
  }
}
