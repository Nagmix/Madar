/// Wallet Service - Centralized wallet operations for Trippo Platform
///
/// Manages driver and rider wallets through the NestJS Wallet Module.
/// Provides a unified API for balance queries, transactions, withdrawals,
/// settlements, commissions, and incentives.
///
/// NestJS Wallet Module Endpoints:
/// - GET  /wallet/balance          — Get current wallet balance
/// - GET  /wallet/transactions     — List transactions (paginated)
/// - POST /wallet/withdraw         — Request withdrawal
/// - GET  /wallet/settlements      — List settlements
/// - GET  /wallet/incentives       — List active incentives
///
/// Architecture:
/// ```
///   WalletScreen / WalletNotifier
///         |
///         v
///   WalletService (this file)
///     ├── ApiService (HTTP to NestJS)
///     ├── SocketService (real-time wallet updates)
///     ├── EventBus (WalletTransaction events)
///     └── OfflineService (offline queue for withdrawals)
/// ```
library;

import 'dart:async';
import 'api_service.dart';
import 'event_bus_service.dart';
import 'socket_service.dart';
import '../constants/api_constants.dart';
import '../constants/app_constants.dart';
import '../models/wallet_model.dart';

// ============================================================================
// Wallet Service
// ============================================================================

/// Centralized wallet service that both the User App and Driver App use
/// to interact with the NestJS Wallet Module.
class WalletService {
  final ApiService _apiService;
  final SocketService _socketService;
  final TrippoEventBus _eventBus;

  // Stream controllers
  final _balanceController = StreamController<WalletBalance>.broadcast();
  final _transactionController =
      StreamController<WalletTransaction>.broadcast();

  // Local state
  WalletBalance? _cachedBalance;
  List<WalletTransaction> _recentTransactions = [];

  WalletService({
    required ApiService apiService,
    required SocketService socketService,
    required TrippoEventBus eventBus,
  })  : _apiService = apiService,
        _socketService = socketService,
        _eventBus = eventBus {
    _setupSocketListeners();
  }

  // ==================== Streams ====================

  /// Stream of wallet balance updates (real-time via Socket.IO).
  Stream<WalletBalance> get onBalanceUpdate => _balanceController.stream;

  /// Stream of new transactions (real-time via Socket.IO).
  Stream<WalletTransaction> get onNewTransaction =>
      _transactionController.stream;

  /// Current cached balance (null if not loaded yet).
  WalletBalance? get cachedBalance => _cachedBalance;

  // ==================== Balance ====================

  /// Get current wallet balance from NestJS: GET /wallet/balance
  ///
  /// Returns:
  /// - [WalletBalance] with available, pending, and total earnings.
  /// - Cached locally for offline access.
  Future<WalletBalance> getBalance() async {
    try {
      final response = await _apiService.get(ApiConstants.walletBalance);

      final balance = WalletBalance.fromJson(
        response.data is Map<String, dynamic>
            ? response.data
            : Map<String, dynamic>.from(response.data as Map),
      );

      _cachedBalance = balance;
      _balanceController.add(balance);

      return balance;
    } catch (e) {
      rethrow;
    }
  }

  // ==================== Transactions ====================

  /// Get wallet transactions with pagination.
  /// NestJS: GET /wallet/transactions?page=1&pageSize=20&type=trip_earning
  ///
  /// [page] — Page number (1-indexed).
  /// [pageSize] — Number of transactions per page.
  /// [type] — Optional filter by transaction type.
  /// [startDate] / [endDate] — Optional date range filter.
  Future<WalletTransactionsResult> getTransactions({
    int page = 1,
    int pageSize = AppConstants.defaultPageSize,
    String? type,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'pageSize': pageSize,
      };

      if (type != null) queryParams['type'] = type;
      if (startDate != null) {
        queryParams['startDate'] = startDate.toUtc().toIso8601String();
      }
      if (endDate != null) {
        queryParams['endDate'] = endDate.toUtc().toIso8601String();
      }

      final response = await _apiService.get(
        ApiConstants.walletTransactions,
        queryParameters: queryParams,
      );

      final data = response.data;
      final result = WalletTransactionsResult.fromJson(
        data is Map<String, dynamic>
            ? data
            : Map<String, dynamic>.from(data as Map),
      );

      // Cache recent transactions
      if (page == 1) {
        _recentTransactions = result.transactions;
      }

      return result;
    } catch (e) {
      rethrow;
    }
  }

  // ==================== Withdrawals ====================

  /// Request a withdrawal from the driver wallet.
  /// NestJS: POST /wallet/withdraw
  ///
  /// The NestJS backend:
  /// 1. Validates the withdrawal amount against available balance.
  /// 2. Creates a WithdrawalRequest record (status: PENDING).
  /// 3. Admin can approve or reject the withdrawal.
  /// 4. On approval, the amount is deducted from the wallet.
  ///
  /// [amount] — Must be >= minimumWithdrawalAmount and <= availableBalance.
  /// [method] — Withdrawal method (bank_transfer, mobile_wallet, cash).
  /// [accountDetails] — Bank IBAN, mobile number, or ID number.
  Future<WithdrawalResult> requestWithdrawal({
    required double amount,
    required String method,
    required String accountDetails,
  }) async {
    // Client-side validation
    if (amount < AppConstants.minimumWithdrawalAmount) {
      throw WalletException(
        type: WalletExceptionType.belowMinimum,
        message: 'Minimum withdrawal amount is \$${AppConstants.minimumWithdrawalAmount}',
      );
    }

    if (amount > AppConstants.maximumWithdrawalAmount) {
      throw WalletException(
        type: WalletExceptionType.aboveMaximum,
        message: 'Maximum withdrawal amount is \$${AppConstants.maximumWithdrawalAmount}',
      );
    }

    if (_cachedBalance != null && amount > _cachedBalance!.availableBalance) {
      throw WalletException(
        type: WalletExceptionType.insufficientBalance,
        message: 'Insufficient available balance',
      );
    }

    try {
      final response = await _apiService.post(
        ApiConstants.walletWithdraw,
        data: {
          'amount': amount,
          'method': method,
          'accountDetails': accountDetails,
        },
      );

      final result = WithdrawalResult.fromJson(
        response.data is Map<String, dynamic>
            ? response.data
            : Map<String, dynamic>.from(response.data as Map),
      );

      // Refresh balance after withdrawal request
      await getBalance();

      // Emit wallet transaction event
      _eventBus.emit(WalletTransactionEvent(
        walletId: result.withdrawalId,
        userId: '', // Filled by the app layer
        transactionType: 'withdrawal_request',
        amount: -amount,
        balanceAfter: _cachedBalance?.availableBalance ?? 0,
      ));

      return result;
    } catch (e) {
      rethrow;
    }
  }

  // ==================== Settlements ====================

  /// Get driver settlements (periodic payment summaries).
  /// NestJS: GET /wallet/settlements?page=1&pageSize=20
  ///
  /// Settlements are created by the NestJS backend at regular intervals
  /// (daily/weekly) and contain:
  /// - Total trip earnings for the period
  /// - Total commissions deducted
  /// - Incentives earned
  /// - Net payout amount
  Future<SettlementsResult> getSettlements({
    int page = 1,
    int pageSize = AppConstants.defaultPageSize,
    String? status,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'pageSize': pageSize,
      };
      if (status != null) queryParams['status'] = status;

      final response = await _apiService.get(
        ApiConstants.walletSettlements,
        queryParameters: queryParams,
      );

      return SettlementsResult.fromJson(
        response.data is Map<String, dynamic>
            ? response.data
            : Map<String, dynamic>.from(response.data as Map),
      );
    } catch (e) {
      rethrow;
    }
  }

  // ==================== Earnings Summary ====================

  /// Get driver earnings summary for a period.
  /// NestJS: GET /drivers/earnings?period=today
  ///
  /// Returns a breakdown of earnings, commissions, incentives, and
  /// trip counts for the specified period.
  Future<EarningsSummary> getEarningsSummary({
    required String period, // 'today', 'week', 'month'
  }) async {
    try {
      final response = await _apiService.get(
        ApiConstants.driverEarnings,
        queryParameters: {'period': period},
      );

      return EarningsSummary.fromJson(
        response.data is Map<String, dynamic>
            ? response.data
            : Map<String, dynamic>.from(response.data as Map),
      );
    } catch (e) {
      rethrow;
    }
  }

  // ==================== Incentives ====================

  /// Get active incentives for the driver.
  /// NestJS: GET /wallet/incentives
  ///
  /// Incentives are bonuses offered to drivers for meeting certain
  /// criteria (e.g., complete 10 trips for a $15 bonus).
  Future<List<DriverIncentive>> getActiveIncentives() async {
    try {
      final response = await _apiService.get('/wallet/incentives');

      final data = response.data;
      if (data is List) {
        return data
            .map((e) => DriverIncentive.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }

  // ==================== Real-time Updates ====================

  /// Setup Socket.IO listeners for real-time wallet updates.
  void _setupSocketListeners() {
    // Wallet balance updated (e.g., trip earning credited)
    _socketService.on('wallet:balance_updated', (data) {
      try {
        final parsed = _parseData(data);
        final balance = WalletBalance.fromJson(parsed);
        _cachedBalance = balance;
        _balanceController.add(balance);
      } catch (_) {
        // Ignore malformed data
      }
    });

    // New transaction (e.g., trip earning, commission deducted)
    _socketService.on('wallet:transaction', (data) {
      try {
        final parsed = _parseData(data);
        final transaction = WalletTransaction.fromJson(parsed);
        _transactionController.add(transaction);
        _recentTransactions.insert(0, transaction);

        // Emit domain event
        _eventBus.emit(WalletTransactionEvent(
          walletId: parsed['walletId'] as String? ?? '',
          userId: parsed['userId'] as String? ?? '',
          transactionType: parsed['type'] as String? ?? '',
          amount: (parsed['amount'] as num?)?.toDouble() ?? 0,
          balanceAfter: (parsed['balanceAfter'] as num?)?.toDouble() ?? 0,
        ));
      } catch (_) {
        // Ignore malformed data
      }
    });

    // Withdrawal status updated
    _socketService.on('wallet:withdrawal_updated', (data) {
      try {
        final parsed = _parseData(data);
        // Refresh balance when withdrawal status changes
        getBalance();
      } catch (_) {}
    });
  }

  /// Parse socket data to Map<String, dynamic>
  Map<String, dynamic> _parseData(dynamic data) {
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    return {};
  }

  // ==================== Cleanup ====================

  /// Dispose resources and remove socket listeners.
  void dispose() {
    _balanceController.close();
    _transactionController.close();
    _socketService.off('wallet:balance_updated');
    _socketService.off('wallet:transaction');
    _socketService.off('wallet:withdrawal_updated');
  }
}

// ============================================================================
// Data Models
// ============================================================================

/// Wallet balance model.
class WalletBalance {
  final String walletId;
  final double availableBalance;
  final double pendingBalance;
  final double totalEarnings;
  final double totalWithdrawals;
  final double totalCommissions;
  final DateTime updatedAt;

  WalletBalance({
    required this.walletId,
    required this.availableBalance,
    required this.pendingBalance,
    required this.totalEarnings,
    required this.totalWithdrawals,
    required this.totalCommissions,
    DateTime? updatedAt,
  }) : updatedAt = updatedAt ?? DateTime.now();

  factory WalletBalance.fromJson(Map<String, dynamic> json) {
    return WalletBalance(
      walletId: json['walletId'] as String? ?? json['id'] as String? ?? '',
      availableBalance:
          (json['availableBalance'] as num?)?.toDouble() ?? 0.0,
      pendingBalance: (json['pendingBalance'] as num?)?.toDouble() ?? 0.0,
      totalEarnings: (json['totalEarnings'] as num?)?.toDouble() ?? 0.0,
      totalWithdrawals: (json['totalWithdrawals'] as num?)?.toDouble() ?? 0.0,
      totalCommissions: (json['totalCommissions'] as num?)?.toDouble() ?? 0.0,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }
}

/// Wallet transactions result with pagination.
class WalletTransactionsResult {
  final List<WalletTransaction> transactions;
  final int total;
  final int page;
  final int pageSize;
  final bool hasMore;

  WalletTransactionsResult({
    required this.transactions,
    required this.total,
    required this.page,
    required this.pageSize,
    required this.hasMore,
  });

  factory WalletTransactionsResult.fromJson(Map<String, dynamic> json) {
    final items = (json['items'] as List<dynamic>?)
            ?.map((e) => WalletTransaction.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];

    return WalletTransactionsResult(
      transactions: items,
      total: json['total'] as int? ?? items.length,
      page: json['page'] as int? ?? 1,
      pageSize: json['pageSize'] as int? ?? 20,
      hasMore: json['hasMore'] as bool? ??
          (items.length >= (json['pageSize'] as int? ?? 20)),
    );
  }
}

/// Withdrawal request result.
class WithdrawalResult {
  final String withdrawalId;
  final double amount;
  final String method;
  final String status;
  final DateTime createdAt;

  WithdrawalResult({
    required this.withdrawalId,
    required this.amount,
    required this.method,
    required this.status,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory WithdrawalResult.fromJson(Map<String, dynamic> json) {
    return WithdrawalResult(
      withdrawalId: json['id'] as String? ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      method: json['method'] as String? ?? '',
      status: json['status'] as String? ?? 'pending',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
    );
  }
}

/// Settlements result with pagination.
class SettlementsResult {
  final List<Settlement> settlements;
  final int total;
  final bool hasMore;

  SettlementsResult({
    required this.settlements,
    required this.total,
    required this.hasMore,
  });

  factory SettlementsResult.fromJson(Map<String, dynamic> json) {
    final items = (json['items'] as List<dynamic>?)
            ?.map((e) => Settlement.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];

    return SettlementsResult(
      settlements: items,
      total: json['total'] as int? ?? items.length,
      hasMore: json['hasMore'] as bool? ?? false,
    );
  }
}

/// Settlement model.
class Settlement {
  final String id;
  final String period;
  final double totalEarnings;
  final double totalCommissions;
  final double incentives;
  final double netAmount;
  final String status;

  Settlement({
    required this.id,
    required this.period,
    required this.totalEarnings,
    required this.totalCommissions,
    required this.incentives,
    required this.netAmount,
    required this.status,
  });

  factory Settlement.fromJson(Map<String, dynamic> json) {
    return Settlement(
      id: json['id'] as String? ?? '',
      period: json['period'] as String? ?? '',
      totalEarnings: (json['totalEarnings'] as num?)?.toDouble() ?? 0.0,
      totalCommissions: (json['totalCommissions'] as num?)?.toDouble() ?? 0.0,
      incentives: (json['incentives'] as num?)?.toDouble() ?? 0.0,
      netAmount: (json['netAmount'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] as String? ?? 'pending',
    );
  }
}

/// Earnings summary for a period.
class EarningsSummary {
  final String period;
  final double totalEarnings;
  final double totalCommissions;
  final double netEarnings;
  final double incentives;
  final int totalTrips;
  final double totalOnlineHours;
  final double averagePerTrip;
  final double commissionRate;

  EarningsSummary({
    required this.period,
    required this.totalEarnings,
    required this.totalCommissions,
    required this.netEarnings,
    required this.incentives,
    required this.totalTrips,
    required this.totalOnlineHours,
    required this.averagePerTrip,
    required this.commissionRate,
  });

  factory EarningsSummary.fromJson(Map<String, dynamic> json) {
    return EarningsSummary(
      period: json['period'] as String? ?? 'today',
      totalEarnings: (json['totalEarnings'] as num?)?.toDouble() ?? 0.0,
      totalCommissions: (json['totalCommissions'] as num?)?.toDouble() ?? 0.0,
      netEarnings: (json['netEarnings'] as num?)?.toDouble() ?? 0.0,
      incentives: (json['incentives'] as num?)?.toDouble() ?? 0.0,
      totalTrips: json['totalTrips'] as int? ?? 0,
      totalOnlineHours:
          (json['totalOnlineHours'] as num?)?.toDouble() ?? 0.0,
      averagePerTrip: (json['averagePerTrip'] as num?)?.toDouble() ?? 0.0,
      commissionRate: (json['commissionRate'] as num?)?.toDouble() ??
          AppConstants.driverCommissionRate,
    );
  }
}

/// Driver incentive model.
class DriverIncentive {
  final String id;
  final String title;
  final String description;
  final double bonusAmount;
  final int targetTrips;
  final int completedTrips;
  final DateTime expiresAt;
  final bool isActive;

  DriverIncentive({
    required this.id,
    required this.title,
    required this.description,
    required this.bonusAmount,
    required this.targetTrips,
    required this.completedTrips,
    required this.expiresAt,
    required this.isActive,
  });

  double get progress =>
      targetTrips > 0 ? completedTrips / targetTrips : 0.0;

  factory DriverIncentive.fromJson(Map<String, dynamic> json) {
    return DriverIncentive(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      bonusAmount: (json['bonusAmount'] as num?)?.toDouble() ?? 0.0,
      targetTrips: json['targetTrips'] as int? ?? 0,
      completedTrips: json['completedTrips'] as int? ?? 0,
      expiresAt: json['expiresAt'] != null
          ? DateTime.parse(json['expiresAt'] as String)
          : DateTime.now().add(const Duration(days: 1)),
      isActive: json['isActive'] as bool? ?? true,
    );
  }
}

// ============================================================================
// Exceptions
// ============================================================================

enum WalletExceptionType {
  belowMinimum,
  aboveMaximum,
  insufficientBalance,
  withdrawalPending,
  serverError,
}

class WalletException implements Exception {
  final WalletExceptionType type;
  final String message;

  WalletException({required this.type, required this.message});

  @override
  String toString() => 'WalletException($type): $message';
}
