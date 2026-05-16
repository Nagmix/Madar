import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trippo_shared/trippo_shared.dart';
import '../../../../core/constants/app_theme.dart';
import '../notifiers/trip_history_notifier.dart';

/// User Trip History Screen - Complete trip history view
///
/// Features:
/// - Tab bar: All / Completed / Cancelled
/// - Trip cards with: pickup→dropoff, fare, driver name, rating, date
/// - Filter by date range
/// - Pull to refresh
/// - Pagination (load more on scroll)
/// - Empty state, error state
/// - All via NestJS: GET /trips/history
class TripHistoryScreen extends ConsumerStatefulWidget {
  const TripHistoryScreen({super.key});

  @override
  ConsumerState<TripHistoryScreen> createState() => _TripHistoryScreenState();
}

class _TripHistoryScreenState extends ConsumerState<TripHistoryScreen>
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
    final isCompleted = trip.state == TripState.paymentCompleted ||
        trip.state == TripState.tripCompleted;
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
              // Top row: Date + Status badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _formatDate(trip.createdAt),
                    style: AppTheme.bodySmall,
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: _getStateColor(trip.state).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      _getStateLabel(trip.state),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: _getStateColor(trip.state),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppTheme.spacing12),

              // Route: Pickup → Dropoff
              Row(
                children: [
                  // Pickup / Dropoff dots with connecting line
                  Column(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
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
                        decoration: const BoxDecoration(
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

              // Bottom row: Fare, Driver, Rating
              Row(
                children: [
                  // Fare paid
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Fare', style: AppTheme.bodySmall),
                        Text(
                          '\$${trip.fare.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                            color: isCancelled ? AppTheme.textSecondary : AppTheme.success,
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
                            const Icon(Icons.star, size: 14, color: Colors.amber),
                            Text(
                              trip.rating!.toStringAsFixed(1),
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ],
                    ),
                ],
              ),

              // Vehicle type (if available)
              if (trip.vehicleType != null) ...[
                const SizedBox(height: AppTheme.spacing8),
                Row(
                  children: [
                    Icon(Icons.directions_car, size: 14, color: AppTheme.textHint),
                    const SizedBox(width: 4),
                    Text(
                      trip.vehicleType!,
                      style: AppTheme.caption,
                    ),
                  ],
                ),
              ],
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
                Icon(Icons.history_outlined,
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
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
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

  /// Get display color for trip state
  Color _getStateColor(TripState state) {
    return switch (state) {
      TripState.paymentCompleted => AppTheme.success,
      TripState.tripCompleted => AppTheme.success,
      TripState.tripCancelled => AppTheme.error,
      TripState.tripStarted => AppTheme.info,
      TripState.driverArriving => AppTheme.info,
      TripState.driverArrived => AppTheme.info,
      TripState.driverAssigned => AppTheme.warning,
      _ => Colors.grey,
    };
  }

  /// Get display label for trip state
  String _getStateLabel(TripState state) {
    return switch (state) {
      TripState.idle => 'IDLE',
      TripState.paymentCompleted => 'COMPLETED',
      TripState.tripCompleted => 'COMPLETED',
      TripState.tripCancelled => 'CANCELLED',
      TripState.tripStarted => 'IN PROGRESS',
      TripState.driverArriving => 'ARRIVING',
      TripState.driverArrived => 'ARRIVED',
      TripState.driverAssigned => 'ASSIGNED',
      TripState.searchingDriver => 'SEARCHING',
      TripState.tripPaused => 'PAUSED',
      TripState.tripResumed => 'RESUMED',
      TripState.paymentPending => 'PAYMENT PENDING',
    };
  }

  /// Format date as DD/MM/YYYY
  String _formatDate(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }

  void _navigateToTripDetail(TripSummary trip) {
    // TODO: Navigate to trip detail screen
    // context.go('/trip-detail/${trip.id}');
  }
}
