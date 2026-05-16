import 'package:freezed_annotation/freezed_annotation.dart';

part 'wallet_model.freezed.dart';
part 'wallet_model.g.dart';

/// Wallet model - represents a driver's wallet
@freezed
class WalletModel with _$WalletModel {
  const factory WalletModel({
    required String id,
    required String driverId,
    required double availableBalance,
    required double pendingBalance,
    required double totalEarnings,
    required double totalWithdrawals,
    required double totalCommissions,
    required double totalIncentives,
    required String currency,
    @Default(WalletStatus.active) WalletStatus status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _WalletModel;

  factory WalletModel.fromJson(Map<String, dynamic> json) =>
      _$WalletModelFromJson(json);
}

enum WalletStatus {
  @JsonValue('active')
  active,
  @JsonValue('frozen')
  frozen,
  @JsonValue('closed')
  closed,
}

/// Wallet transaction model
@freezed
class WalletTransaction with _$WalletTransaction {
  const factory WalletTransaction({
    required String id,
    required String walletId,
    required String driverId,
    required TransactionType type,
    required double amount,
    required double balanceAfter,
    required String currency,
    required String description,
    String? tripId,
    String? referenceId,
    TransactionStatus? status,
    DateTime? createdAt,
  }) = _WalletTransaction;

  factory WalletTransaction.fromJson(Map<String, dynamic> json) =>
      _$WalletTransactionFromJson(json);
}

enum TransactionType {
  @JsonValue('trip_earning')
  tripEarning,
  @JsonValue('commission_deduction')
  commissionDeduction,
  @JsonValue('withdrawal')
  withdrawal,
  @JsonValue('incentive_bonus')
  incentiveBonus,
  @JsonValue('cancellation_fee')
  cancellationFee,
  @JsonValue('adjustment')
  adjustment,
  @JsonValue('penalty')
  penalty,
  @JsonValue('refund')
  refund,
}

enum TransactionStatus {
  @JsonValue('pending')
  pending,
  @JsonValue('completed')
  completed,
  @JsonValue('failed')
  failed,
  @JsonValue('reversed')
  reversed,
}

/// Withdrawal request
@freezed
class WithdrawalRequest with _$WithdrawalRequest {
  const factory WithdrawalRequest({
    required String id,
    required String driverId,
    required double amount,
    required String currency,
    required WithdrawalMethod method,
    required String accountDetails,
    WithdrawalStatus? status,
    String? rejectionReason,
    DateTime? requestedAt,
    DateTime? processedAt,
  }) = _WithdrawalRequest;

  factory WithdrawalRequest.fromJson(Map<String, dynamic> json) =>
      _$WithdrawalRequestFromJson(json);
}

enum WithdrawalMethod {
  @JsonValue('bank_transfer')
  bankTransfer,
  @JsonValue('mobile_wallet')
  mobileWallet,
  @JsonValue('cash')
  cash,
}

enum WithdrawalStatus {
  @JsonValue('pending')
  pending,
  @JsonValue('approved')
  approved,
  @JsonValue('processing')
  processing,
  @JsonValue('completed')
  completed,
  @JsonValue('rejected')
  rejected,
}

/// Settlement model - periodic settlement for drivers
@freezed
class Settlement with _$Settlement {
  const factory Settlement({
    required String id,
    required String driverId,
    required String period,
    required double totalEarnings,
    required double totalCommissions,
    required double totalIncentives,
    required double netAmount,
    required String currency,
    required SettlementStatus status,
    @Default([]) List<String> tripIds,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? settledAt,
  }) = _Settlement;

  factory Settlement.fromJson(Map<String, dynamic> json) =>
      _$SettlementFromJson(json);
}

enum SettlementStatus {
  @JsonValue('pending')
  pending,
  @JsonValue('processing')
  processing,
  @JsonValue('settled')
  settled,
}
