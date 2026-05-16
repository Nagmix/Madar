// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wallet_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$WalletModelImpl _$$WalletModelImplFromJson(Map<String, dynamic> json) =>
    _$WalletModelImpl(
      id: json['id'] as String,
      driverId: json['driverId'] as String,
      availableBalance: (json['availableBalance'] as num).toDouble(),
      pendingBalance: (json['pendingBalance'] as num).toDouble(),
      totalEarnings: (json['totalEarnings'] as num).toDouble(),
      totalWithdrawals: (json['totalWithdrawals'] as num).toDouble(),
      totalCommissions: (json['totalCommissions'] as num).toDouble(),
      totalIncentives: (json['totalIncentives'] as num).toDouble(),
      currency: json['currency'] as String,
      status: $enumDecodeNullable(_$WalletStatusEnumMap, json['status']) ??
          WalletStatus.active,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$WalletModelImplToJson(_$WalletModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'driverId': instance.driverId,
      'availableBalance': instance.availableBalance,
      'pendingBalance': instance.pendingBalance,
      'totalEarnings': instance.totalEarnings,
      'totalWithdrawals': instance.totalWithdrawals,
      'totalCommissions': instance.totalCommissions,
      'totalIncentives': instance.totalIncentives,
      'currency': instance.currency,
      'status': _$WalletStatusEnumMap[instance.status]!,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

const _$WalletStatusEnumMap = {
  WalletStatus.active: 'active',
  WalletStatus.frozen: 'frozen',
  WalletStatus.closed: 'closed',
};

_$WalletTransactionImpl _$$WalletTransactionImplFromJson(
        Map<String, dynamic> json) =>
    _$WalletTransactionImpl(
      id: json['id'] as String,
      walletId: json['walletId'] as String,
      driverId: json['driverId'] as String,
      type: $enumDecode(_$TransactionTypeEnumMap, json['type']),
      amount: (json['amount'] as num).toDouble(),
      balanceAfter: (json['balanceAfter'] as num).toDouble(),
      currency: json['currency'] as String,
      description: json['description'] as String,
      tripId: json['tripId'] as String?,
      referenceId: json['referenceId'] as String?,
      status: $enumDecodeNullable(_$TransactionStatusEnumMap, json['status']),
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$WalletTransactionImplToJson(
        _$WalletTransactionImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'walletId': instance.walletId,
      'driverId': instance.driverId,
      'type': _$TransactionTypeEnumMap[instance.type]!,
      'amount': instance.amount,
      'balanceAfter': instance.balanceAfter,
      'currency': instance.currency,
      'description': instance.description,
      'tripId': instance.tripId,
      'referenceId': instance.referenceId,
      'status': _$TransactionStatusEnumMap[instance.status],
      'createdAt': instance.createdAt?.toIso8601String(),
    };

const _$TransactionTypeEnumMap = {
  TransactionType.tripEarning: 'trip_earning',
  TransactionType.commissionDeduction: 'commission_deduction',
  TransactionType.withdrawal: 'withdrawal',
  TransactionType.incentiveBonus: 'incentive_bonus',
  TransactionType.cancellationFee: 'cancellation_fee',
  TransactionType.adjustment: 'adjustment',
  TransactionType.penalty: 'penalty',
  TransactionType.refund: 'refund',
};

const _$TransactionStatusEnumMap = {
  TransactionStatus.pending: 'pending',
  TransactionStatus.completed: 'completed',
  TransactionStatus.failed: 'failed',
  TransactionStatus.reversed: 'reversed',
};

_$WithdrawalRequestImpl _$$WithdrawalRequestImplFromJson(
        Map<String, dynamic> json) =>
    _$WithdrawalRequestImpl(
      id: json['id'] as String,
      driverId: json['driverId'] as String,
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String,
      method: $enumDecode(_$WithdrawalMethodEnumMap, json['method']),
      accountDetails: json['accountDetails'] as String,
      status: $enumDecodeNullable(_$WithdrawalStatusEnumMap, json['status']),
      rejectionReason: json['rejectionReason'] as String?,
      requestedAt: json['requestedAt'] == null
          ? null
          : DateTime.parse(json['requestedAt'] as String),
      processedAt: json['processedAt'] == null
          ? null
          : DateTime.parse(json['processedAt'] as String),
    );

Map<String, dynamic> _$$WithdrawalRequestImplToJson(
        _$WithdrawalRequestImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'driverId': instance.driverId,
      'amount': instance.amount,
      'currency': instance.currency,
      'method': _$WithdrawalMethodEnumMap[instance.method]!,
      'accountDetails': instance.accountDetails,
      'status': _$WithdrawalStatusEnumMap[instance.status],
      'rejectionReason': instance.rejectionReason,
      'requestedAt': instance.requestedAt?.toIso8601String(),
      'processedAt': instance.processedAt?.toIso8601String(),
    };

const _$WithdrawalMethodEnumMap = {
  WithdrawalMethod.bankTransfer: 'bank_transfer',
  WithdrawalMethod.mobileWallet: 'mobile_wallet',
  WithdrawalMethod.cash: 'cash',
};

const _$WithdrawalStatusEnumMap = {
  WithdrawalStatus.pending: 'pending',
  WithdrawalStatus.approved: 'approved',
  WithdrawalStatus.processing: 'processing',
  WithdrawalStatus.completed: 'completed',
  WithdrawalStatus.rejected: 'rejected',
};

_$SettlementImpl _$$SettlementImplFromJson(Map<String, dynamic> json) =>
    _$SettlementImpl(
      id: json['id'] as String,
      driverId: json['driverId'] as String,
      period: json['period'] as String,
      totalEarnings: (json['totalEarnings'] as num).toDouble(),
      totalCommissions: (json['totalCommissions'] as num).toDouble(),
      totalIncentives: (json['totalIncentives'] as num).toDouble(),
      netAmount: (json['netAmount'] as num).toDouble(),
      currency: json['currency'] as String,
      status: $enumDecode(_$SettlementStatusEnumMap, json['status']),
      tripIds: (json['tripIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      startDate: json['startDate'] == null
          ? null
          : DateTime.parse(json['startDate'] as String),
      endDate: json['endDate'] == null
          ? null
          : DateTime.parse(json['endDate'] as String),
      settledAt: json['settledAt'] == null
          ? null
          : DateTime.parse(json['settledAt'] as String),
    );

Map<String, dynamic> _$$SettlementImplToJson(_$SettlementImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'driverId': instance.driverId,
      'period': instance.period,
      'totalEarnings': instance.totalEarnings,
      'totalCommissions': instance.totalCommissions,
      'totalIncentives': instance.totalIncentives,
      'netAmount': instance.netAmount,
      'currency': instance.currency,
      'status': _$SettlementStatusEnumMap[instance.status]!,
      'tripIds': instance.tripIds,
      'startDate': instance.startDate?.toIso8601String(),
      'endDate': instance.endDate?.toIso8601String(),
      'settledAt': instance.settledAt?.toIso8601String(),
    };

const _$SettlementStatusEnumMap = {
  SettlementStatus.pending: 'pending',
  SettlementStatus.processing: 'processing',
  SettlementStatus.settled: 'settled',
};
