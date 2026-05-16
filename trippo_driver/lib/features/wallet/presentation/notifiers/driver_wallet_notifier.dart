import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trippo_shared/trippo_shared.dart';
import '../../../core/app_providers.dart';
import '../../../core/network/nestjs_api_client.dart';

/// Driver Wallet State
class DriverWalletState {
  final WalletModel? wallet;
  final List<WalletTransaction> transactions;
  final List<Settlement> settlements;
  final List<WithdrawalRequest> withdrawalRequests;
  final bool isLoading;
  final String? error;

  const DriverWalletState({
    this.wallet,
    this.transactions = const [],
    this.settlements = const [],
    this.withdrawalRequests = const [],
    this.isLoading = false,
    this.error,
  });

  DriverWalletState copyWith({
    WalletModel? wallet,
    List<WalletTransaction>? transactions,
    List<Settlement>? settlements,
    List<WithdrawalRequest>? withdrawalRequests,
    bool? isLoading,
    String? error,
  }) =>
      DriverWalletState(
        wallet: wallet ?? this.wallet,
        transactions: transactions ?? this.transactions,
        settlements: settlements ?? this.settlements,
        withdrawalRequests: withdrawalRequests ?? this.withdrawalRequests,
        isLoading: isLoading ?? this.isLoading,
        error: error,
      );
}

/// Driver Wallet Notifier
/// Manages driver wallet via NestJS Wallet Module
/// Handles balance, transactions, settlements, and withdrawals
/// Same pattern as user wallet notifier but with driver-specific settlement features
class DriverWalletNotifier extends StateNotifier<DriverWalletState> {
  final Ref _ref;

  DriverWalletNotifier(this._ref) : super(const DriverWalletState());

  /// Load wallet balance - GET /wallet/balance
  Future<void> loadBalance() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final apiClient = _ref.read(nestjsApiClientProvider);
      final wallet = await apiClient.getWalletBalance();
      state = state.copyWith(wallet: wallet, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Load transaction history - GET /wallet/transactions
  Future<void> loadTransactions({
    int page = 1,
    int pageSize = 20,
    TransactionType? type,
  }) async {
    try {
      final apiClient = _ref.read(nestjsApiClientProvider);
      final transactions = await apiClient.getWalletTransactions(
        page: page,
        pageSize: pageSize,
        type: type?.name,
      );
      state = state.copyWith(transactions: transactions);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Request withdrawal - POST /wallet/withdraw
  /// Driver can withdraw via bank transfer, mobile wallet, or cash
  Future<bool> requestWithdrawal({
    required double amount,
    required WithdrawalMethod method,
    required String accountDetails,
  }) async {
    // Validate minimum withdrawal amount
    if (amount < AppConstants.minimumWithdrawalAmount) {
      state = state.copyWith(
        error:
            'Minimum withdrawal amount is ${AppConstants.minimumWithdrawalAmount}',
      );
      return false;
    }

    // Validate maximum withdrawal amount
    if (amount > AppConstants.maximumWithdrawalAmount) {
      state = state.copyWith(
        error:
            'Maximum withdrawal amount is ${AppConstants.maximumWithdrawalAmount}',
      );
      return false;
    }

    // Check available balance
    if (state.wallet != null &&
        amount > state.wallet!.availableBalance) {
      state = state.copyWith(
        error: 'Insufficient balance for withdrawal',
      );
      return false;
    }

    state = state.copyWith(isLoading: true, error: null);
    try {
      final apiClient = _ref.read(nestjsApiClientProvider);
      final withdrawal = await apiClient.requestWithdrawal(
        amount: amount,
        method: method.name,
        accountDetails: accountDetails,
      );

      final updatedRequests = [...state.withdrawalRequests, withdrawal];
      state = state.copyWith(
        withdrawalRequests: updatedRequests,
        isLoading: false,
      );

      // Refresh balance after withdrawal request
      await loadBalance();
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  /// Load settlements - GET /wallet/settlements
  /// Settlements are periodic payouts (daily/weekly) for completed trips
  Future<void> loadSettlements({int page = 1}) async {
    try {
      final apiClient = _ref.read(nestjsApiClientProvider);
      final settlements = await apiClient.getSettlements(page: page);
      state = state.copyWith(settlements: settlements);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Load all wallet data at once
  Future<void> loadAll() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await Future.wait([
        loadBalance(),
        loadTransactions(),
        loadSettlements(),
      ]);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

/// Driver Wallet Provider
final driverWalletProvider =
    StateNotifierProvider<DriverWalletNotifier, DriverWalletState>((ref) {
  return DriverWalletNotifier(ref);
});

/// Available balance provider
final availableBalanceProvider = Provider<double>((ref) {
  final walletState = ref.watch(driverWalletProvider);
  return walletState.wallet?.availableBalance ?? 0;
});

/// Pending balance provider
final pendingBalanceProvider = Provider<double>((ref) {
  final walletState = ref.watch(driverWalletProvider);
  return walletState.wallet?.pendingBalance ?? 0;
});

/// Total earnings provider
final totalEarningsProvider = Provider<double>((ref) {
  final walletState = ref.watch(driverWalletProvider);
  return walletState.wallet?.totalEarnings ?? 0;
});
