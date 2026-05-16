import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trippo_shared/trippo_shared.dart';
import '../../../../core/network/nestjs_api_client.dart';

/// Wallet Service - Manages driver wallet via NestJS Wallet Module
/// 
/// NestJS Wallet Module Features:
/// - Balance tracking (available + pending)
/// - Commission deductions (configurable %)
/// - Settlement processing (daily/weekly)
/// - Withdrawal requests (bank transfer, mobile wallet, cash)
/// - Incentive bonuses (high rating, peak hours, streaks)
/// - Transaction history with filters
class WalletService {
  final NestjsApiClient _apiClient;

  WalletService(this._apiClient);

  /// Get wallet balance - GET /wallet/balance
  Future<WalletModel> getBalance() async {
    return await _apiClient.getWalletBalance();
  }

  /// Get transaction history - GET /wallet/transactions
  Future<List<WalletTransaction>> getTransactions({
    int page = 1,
    int pageSize = 20,
    TransactionType? type,
  }) async {
    return await _apiClient.getWalletTransactions(
      page: page,
      pageSize: pageSize,
      type: type?.name,
    );
  }

  /// Request withdrawal - POST /wallet/withdraw
  Future<WithdrawalRequest> requestWithdrawal({
    required double amount,
    required WithdrawalMethod method,
    required String accountDetails,
  }) async {
    return await _apiClient.requestWithdrawal(
      amount: amount,
      method: method.name,
      accountDetails: accountDetails,
    );
  }

  /// Get settlements - GET /wallet/settlements
  Future<List<Settlement>> getSettlements({int page = 1}) async {
    return await _apiClient.getSettlements(page: page);
  }
}

/// Wallet State
class WalletState {
  final WalletModel? wallet;
  final List<WalletTransaction> transactions;
  final List<Settlement> settlements;
  final List<WithdrawalRequest> withdrawalRequests;
  final bool isLoading;
  final String? error;

  const WalletState({
    this.wallet,
    this.transactions = const [],
    this.settlements = const [],
    this.withdrawalRequests = const [],
    this.isLoading = false,
    this.error,
  });

  WalletState copyWith({
    WalletModel? wallet,
    List<WalletTransaction>? transactions,
    List<Settlement>? settlements,
    List<WithdrawalRequest>? withdrawalRequests,
    bool? isLoading,
    String? error,
  }) =>
      WalletState(
        wallet: wallet ?? this.wallet,
        transactions: transactions ?? this.transactions,
        settlements: settlements ?? this.settlements,
        withdrawalRequests: withdrawalRequests ?? this.withdrawalRequests,
        isLoading: isLoading ?? this.isLoading,
        error: error,
      );
}

/// Wallet Notifier
class WalletNotifier extends StateNotifier<WalletState> {
  final WalletService _walletService;

  WalletNotifier(this._walletService) : super(const WalletState());

  /// Load wallet balance
  Future<void> loadBalance() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final wallet = await _walletService.getBalance();
      state = state.copyWith(wallet: wallet, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Load transactions
  Future<void> loadTransactions({TransactionType? type}) async {
    try {
      final transactions = await _walletService.getTransactions(type: type);
      state = state.copyWith(transactions: transactions);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Load settlements
  Future<void> loadSettlements() async {
    try {
      final settlements = await _walletService.getSettlements();
      state = state.copyWith(settlements: settlements);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Request withdrawal
  Future<bool> requestWithdrawal({
    required double amount,
    required WithdrawalMethod method,
    required String accountDetails,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final withdrawal = await _walletService.requestWithdrawal(
        amount: amount,
        method: method,
        accountDetails: accountDetails,
      );
      final updatedRequests = [...state.withdrawalRequests, withdrawal];
      state = state.copyWith(withdrawalRequests: updatedRequests, isLoading: false);
      await loadBalance(); // Refresh balance
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }
}

/// Providers
final walletServiceProvider = Provider<WalletService>((ref) {
  return WalletService(NestjsApiClient());
});

final walletProvider = StateNotifierProvider<WalletNotifier, WalletState>((ref) {
  return WalletNotifier(ref.read(walletServiceProvider));
});
