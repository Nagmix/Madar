// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'wallet_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

WalletModel _$WalletModelFromJson(Map<String, dynamic> json) {
  return _WalletModel.fromJson(json);
}

/// @nodoc
mixin _$WalletModel {
  String get id => throw _privateConstructorUsedError;
  String get driverId => throw _privateConstructorUsedError;
  double get availableBalance => throw _privateConstructorUsedError;
  double get pendingBalance => throw _privateConstructorUsedError;
  double get totalEarnings => throw _privateConstructorUsedError;
  double get totalWithdrawals => throw _privateConstructorUsedError;
  double get totalCommissions => throw _privateConstructorUsedError;
  double get totalIncentives => throw _privateConstructorUsedError;
  String get currency => throw _privateConstructorUsedError;
  WalletStatus get status => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this WalletModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of WalletModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $WalletModelCopyWith<WalletModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WalletModelCopyWith<$Res> {
  factory $WalletModelCopyWith(
          WalletModel value, $Res Function(WalletModel) then) =
      _$WalletModelCopyWithImpl<$Res, WalletModel>;
  @useResult
  $Res call(
      {String id,
      String driverId,
      double availableBalance,
      double pendingBalance,
      double totalEarnings,
      double totalWithdrawals,
      double totalCommissions,
      double totalIncentives,
      String currency,
      WalletStatus status,
      DateTime? createdAt,
      DateTime? updatedAt});
}

/// @nodoc
class _$WalletModelCopyWithImpl<$Res, $Val extends WalletModel>
    implements $WalletModelCopyWith<$Res> {
  _$WalletModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of WalletModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? driverId = null,
    Object? availableBalance = null,
    Object? pendingBalance = null,
    Object? totalEarnings = null,
    Object? totalWithdrawals = null,
    Object? totalCommissions = null,
    Object? totalIncentives = null,
    Object? currency = null,
    Object? status = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      driverId: null == driverId
          ? _value.driverId
          : driverId // ignore: cast_nullable_to_non_nullable
              as String,
      availableBalance: null == availableBalance
          ? _value.availableBalance
          : availableBalance // ignore: cast_nullable_to_non_nullable
              as double,
      pendingBalance: null == pendingBalance
          ? _value.pendingBalance
          : pendingBalance // ignore: cast_nullable_to_non_nullable
              as double,
      totalEarnings: null == totalEarnings
          ? _value.totalEarnings
          : totalEarnings // ignore: cast_nullable_to_non_nullable
              as double,
      totalWithdrawals: null == totalWithdrawals
          ? _value.totalWithdrawals
          : totalWithdrawals // ignore: cast_nullable_to_non_nullable
              as double,
      totalCommissions: null == totalCommissions
          ? _value.totalCommissions
          : totalCommissions // ignore: cast_nullable_to_non_nullable
              as double,
      totalIncentives: null == totalIncentives
          ? _value.totalIncentives
          : totalIncentives // ignore: cast_nullable_to_non_nullable
              as double,
      currency: null == currency
          ? _value.currency
          : currency // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as WalletStatus,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$WalletModelImplCopyWith<$Res>
    implements $WalletModelCopyWith<$Res> {
  factory _$$WalletModelImplCopyWith(
          _$WalletModelImpl value, $Res Function(_$WalletModelImpl) then) =
      __$$WalletModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String driverId,
      double availableBalance,
      double pendingBalance,
      double totalEarnings,
      double totalWithdrawals,
      double totalCommissions,
      double totalIncentives,
      String currency,
      WalletStatus status,
      DateTime? createdAt,
      DateTime? updatedAt});
}

/// @nodoc
class __$$WalletModelImplCopyWithImpl<$Res>
    extends _$WalletModelCopyWithImpl<$Res, _$WalletModelImpl>
    implements _$$WalletModelImplCopyWith<$Res> {
  __$$WalletModelImplCopyWithImpl(
      _$WalletModelImpl _value, $Res Function(_$WalletModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of WalletModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? driverId = null,
    Object? availableBalance = null,
    Object? pendingBalance = null,
    Object? totalEarnings = null,
    Object? totalWithdrawals = null,
    Object? totalCommissions = null,
    Object? totalIncentives = null,
    Object? currency = null,
    Object? status = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_$WalletModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      driverId: null == driverId
          ? _value.driverId
          : driverId // ignore: cast_nullable_to_non_nullable
              as String,
      availableBalance: null == availableBalance
          ? _value.availableBalance
          : availableBalance // ignore: cast_nullable_to_non_nullable
              as double,
      pendingBalance: null == pendingBalance
          ? _value.pendingBalance
          : pendingBalance // ignore: cast_nullable_to_non_nullable
              as double,
      totalEarnings: null == totalEarnings
          ? _value.totalEarnings
          : totalEarnings // ignore: cast_nullable_to_non_nullable
              as double,
      totalWithdrawals: null == totalWithdrawals
          ? _value.totalWithdrawals
          : totalWithdrawals // ignore: cast_nullable_to_non_nullable
              as double,
      totalCommissions: null == totalCommissions
          ? _value.totalCommissions
          : totalCommissions // ignore: cast_nullable_to_non_nullable
              as double,
      totalIncentives: null == totalIncentives
          ? _value.totalIncentives
          : totalIncentives // ignore: cast_nullable_to_non_nullable
              as double,
      currency: null == currency
          ? _value.currency
          : currency // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as WalletStatus,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$WalletModelImpl implements _WalletModel {
  const _$WalletModelImpl(
      {required this.id,
      required this.driverId,
      required this.availableBalance,
      required this.pendingBalance,
      required this.totalEarnings,
      required this.totalWithdrawals,
      required this.totalCommissions,
      required this.totalIncentives,
      required this.currency,
      this.status = WalletStatus.active,
      this.createdAt,
      this.updatedAt});

  factory _$WalletModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$WalletModelImplFromJson(json);

  @override
  final String id;
  @override
  final String driverId;
  @override
  final double availableBalance;
  @override
  final double pendingBalance;
  @override
  final double totalEarnings;
  @override
  final double totalWithdrawals;
  @override
  final double totalCommissions;
  @override
  final double totalIncentives;
  @override
  final String currency;
  @override
  @JsonKey()
  final WalletStatus status;
  @override
  final DateTime? createdAt;
  @override
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'WalletModel(id: $id, driverId: $driverId, availableBalance: $availableBalance, pendingBalance: $pendingBalance, totalEarnings: $totalEarnings, totalWithdrawals: $totalWithdrawals, totalCommissions: $totalCommissions, totalIncentives: $totalIncentives, currency: $currency, status: $status, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WalletModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.driverId, driverId) ||
                other.driverId == driverId) &&
            (identical(other.availableBalance, availableBalance) ||
                other.availableBalance == availableBalance) &&
            (identical(other.pendingBalance, pendingBalance) ||
                other.pendingBalance == pendingBalance) &&
            (identical(other.totalEarnings, totalEarnings) ||
                other.totalEarnings == totalEarnings) &&
            (identical(other.totalWithdrawals, totalWithdrawals) ||
                other.totalWithdrawals == totalWithdrawals) &&
            (identical(other.totalCommissions, totalCommissions) ||
                other.totalCommissions == totalCommissions) &&
            (identical(other.totalIncentives, totalIncentives) ||
                other.totalIncentives == totalIncentives) &&
            (identical(other.currency, currency) ||
                other.currency == currency) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      driverId,
      availableBalance,
      pendingBalance,
      totalEarnings,
      totalWithdrawals,
      totalCommissions,
      totalIncentives,
      currency,
      status,
      createdAt,
      updatedAt);

  /// Create a copy of WalletModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WalletModelImplCopyWith<_$WalletModelImpl> get copyWith =>
      __$$WalletModelImplCopyWithImpl<_$WalletModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$WalletModelImplToJson(
      this,
    );
  }
}

abstract class _WalletModel implements WalletModel {
  const factory _WalletModel(
      {required final String id,
      required final String driverId,
      required final double availableBalance,
      required final double pendingBalance,
      required final double totalEarnings,
      required final double totalWithdrawals,
      required final double totalCommissions,
      required final double totalIncentives,
      required final String currency,
      final WalletStatus status,
      final DateTime? createdAt,
      final DateTime? updatedAt}) = _$WalletModelImpl;

  factory _WalletModel.fromJson(Map<String, dynamic> json) =
      _$WalletModelImpl.fromJson;

  @override
  String get id;
  @override
  String get driverId;
  @override
  double get availableBalance;
  @override
  double get pendingBalance;
  @override
  double get totalEarnings;
  @override
  double get totalWithdrawals;
  @override
  double get totalCommissions;
  @override
  double get totalIncentives;
  @override
  String get currency;
  @override
  WalletStatus get status;
  @override
  DateTime? get createdAt;
  @override
  DateTime? get updatedAt;

  /// Create a copy of WalletModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WalletModelImplCopyWith<_$WalletModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

WalletTransaction _$WalletTransactionFromJson(Map<String, dynamic> json) {
  return _WalletTransaction.fromJson(json);
}

/// @nodoc
mixin _$WalletTransaction {
  String get id => throw _privateConstructorUsedError;
  String get walletId => throw _privateConstructorUsedError;
  String get driverId => throw _privateConstructorUsedError;
  TransactionType get type => throw _privateConstructorUsedError;
  double get amount => throw _privateConstructorUsedError;
  double get balanceAfter => throw _privateConstructorUsedError;
  String get currency => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  String? get tripId => throw _privateConstructorUsedError;
  String? get referenceId => throw _privateConstructorUsedError;
  TransactionStatus? get status => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;

  /// Serializes this WalletTransaction to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of WalletTransaction
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $WalletTransactionCopyWith<WalletTransaction> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WalletTransactionCopyWith<$Res> {
  factory $WalletTransactionCopyWith(
          WalletTransaction value, $Res Function(WalletTransaction) then) =
      _$WalletTransactionCopyWithImpl<$Res, WalletTransaction>;
  @useResult
  $Res call(
      {String id,
      String walletId,
      String driverId,
      TransactionType type,
      double amount,
      double balanceAfter,
      String currency,
      String description,
      String? tripId,
      String? referenceId,
      TransactionStatus? status,
      DateTime? createdAt});
}

/// @nodoc
class _$WalletTransactionCopyWithImpl<$Res, $Val extends WalletTransaction>
    implements $WalletTransactionCopyWith<$Res> {
  _$WalletTransactionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of WalletTransaction
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? walletId = null,
    Object? driverId = null,
    Object? type = null,
    Object? amount = null,
    Object? balanceAfter = null,
    Object? currency = null,
    Object? description = null,
    Object? tripId = freezed,
    Object? referenceId = freezed,
    Object? status = freezed,
    Object? createdAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      walletId: null == walletId
          ? _value.walletId
          : walletId // ignore: cast_nullable_to_non_nullable
              as String,
      driverId: null == driverId
          ? _value.driverId
          : driverId // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as TransactionType,
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as double,
      balanceAfter: null == balanceAfter
          ? _value.balanceAfter
          : balanceAfter // ignore: cast_nullable_to_non_nullable
              as double,
      currency: null == currency
          ? _value.currency
          : currency // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      tripId: freezed == tripId
          ? _value.tripId
          : tripId // ignore: cast_nullable_to_non_nullable
              as String?,
      referenceId: freezed == referenceId
          ? _value.referenceId
          : referenceId // ignore: cast_nullable_to_non_nullable
              as String?,
      status: freezed == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as TransactionStatus?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$WalletTransactionImplCopyWith<$Res>
    implements $WalletTransactionCopyWith<$Res> {
  factory _$$WalletTransactionImplCopyWith(_$WalletTransactionImpl value,
          $Res Function(_$WalletTransactionImpl) then) =
      __$$WalletTransactionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String walletId,
      String driverId,
      TransactionType type,
      double amount,
      double balanceAfter,
      String currency,
      String description,
      String? tripId,
      String? referenceId,
      TransactionStatus? status,
      DateTime? createdAt});
}

/// @nodoc
class __$$WalletTransactionImplCopyWithImpl<$Res>
    extends _$WalletTransactionCopyWithImpl<$Res, _$WalletTransactionImpl>
    implements _$$WalletTransactionImplCopyWith<$Res> {
  __$$WalletTransactionImplCopyWithImpl(_$WalletTransactionImpl _value,
      $Res Function(_$WalletTransactionImpl) _then)
      : super(_value, _then);

  /// Create a copy of WalletTransaction
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? walletId = null,
    Object? driverId = null,
    Object? type = null,
    Object? amount = null,
    Object? balanceAfter = null,
    Object? currency = null,
    Object? description = null,
    Object? tripId = freezed,
    Object? referenceId = freezed,
    Object? status = freezed,
    Object? createdAt = freezed,
  }) {
    return _then(_$WalletTransactionImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      walletId: null == walletId
          ? _value.walletId
          : walletId // ignore: cast_nullable_to_non_nullable
              as String,
      driverId: null == driverId
          ? _value.driverId
          : driverId // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as TransactionType,
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as double,
      balanceAfter: null == balanceAfter
          ? _value.balanceAfter
          : balanceAfter // ignore: cast_nullable_to_non_nullable
              as double,
      currency: null == currency
          ? _value.currency
          : currency // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      tripId: freezed == tripId
          ? _value.tripId
          : tripId // ignore: cast_nullable_to_non_nullable
              as String?,
      referenceId: freezed == referenceId
          ? _value.referenceId
          : referenceId // ignore: cast_nullable_to_non_nullable
              as String?,
      status: freezed == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as TransactionStatus?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$WalletTransactionImpl implements _WalletTransaction {
  const _$WalletTransactionImpl(
      {required this.id,
      required this.walletId,
      required this.driverId,
      required this.type,
      required this.amount,
      required this.balanceAfter,
      required this.currency,
      required this.description,
      this.tripId,
      this.referenceId,
      this.status,
      this.createdAt});

  factory _$WalletTransactionImpl.fromJson(Map<String, dynamic> json) =>
      _$$WalletTransactionImplFromJson(json);

  @override
  final String id;
  @override
  final String walletId;
  @override
  final String driverId;
  @override
  final TransactionType type;
  @override
  final double amount;
  @override
  final double balanceAfter;
  @override
  final String currency;
  @override
  final String description;
  @override
  final String? tripId;
  @override
  final String? referenceId;
  @override
  final TransactionStatus? status;
  @override
  final DateTime? createdAt;

  @override
  String toString() {
    return 'WalletTransaction(id: $id, walletId: $walletId, driverId: $driverId, type: $type, amount: $amount, balanceAfter: $balanceAfter, currency: $currency, description: $description, tripId: $tripId, referenceId: $referenceId, status: $status, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WalletTransactionImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.walletId, walletId) ||
                other.walletId == walletId) &&
            (identical(other.driverId, driverId) ||
                other.driverId == driverId) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.balanceAfter, balanceAfter) ||
                other.balanceAfter == balanceAfter) &&
            (identical(other.currency, currency) ||
                other.currency == currency) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.tripId, tripId) || other.tripId == tripId) &&
            (identical(other.referenceId, referenceId) ||
                other.referenceId == referenceId) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      walletId,
      driverId,
      type,
      amount,
      balanceAfter,
      currency,
      description,
      tripId,
      referenceId,
      status,
      createdAt);

  /// Create a copy of WalletTransaction
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WalletTransactionImplCopyWith<_$WalletTransactionImpl> get copyWith =>
      __$$WalletTransactionImplCopyWithImpl<_$WalletTransactionImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$WalletTransactionImplToJson(
      this,
    );
  }
}

abstract class _WalletTransaction implements WalletTransaction {
  const factory _WalletTransaction(
      {required final String id,
      required final String walletId,
      required final String driverId,
      required final TransactionType type,
      required final double amount,
      required final double balanceAfter,
      required final String currency,
      required final String description,
      final String? tripId,
      final String? referenceId,
      final TransactionStatus? status,
      final DateTime? createdAt}) = _$WalletTransactionImpl;

  factory _WalletTransaction.fromJson(Map<String, dynamic> json) =
      _$WalletTransactionImpl.fromJson;

  @override
  String get id;
  @override
  String get walletId;
  @override
  String get driverId;
  @override
  TransactionType get type;
  @override
  double get amount;
  @override
  double get balanceAfter;
  @override
  String get currency;
  @override
  String get description;
  @override
  String? get tripId;
  @override
  String? get referenceId;
  @override
  TransactionStatus? get status;
  @override
  DateTime? get createdAt;

  /// Create a copy of WalletTransaction
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WalletTransactionImplCopyWith<_$WalletTransactionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

WithdrawalRequest _$WithdrawalRequestFromJson(Map<String, dynamic> json) {
  return _WithdrawalRequest.fromJson(json);
}

/// @nodoc
mixin _$WithdrawalRequest {
  String get id => throw _privateConstructorUsedError;
  String get driverId => throw _privateConstructorUsedError;
  double get amount => throw _privateConstructorUsedError;
  String get currency => throw _privateConstructorUsedError;
  WithdrawalMethod get method => throw _privateConstructorUsedError;
  String get accountDetails => throw _privateConstructorUsedError;
  WithdrawalStatus? get status => throw _privateConstructorUsedError;
  String? get rejectionReason => throw _privateConstructorUsedError;
  DateTime? get requestedAt => throw _privateConstructorUsedError;
  DateTime? get processedAt => throw _privateConstructorUsedError;

  /// Serializes this WithdrawalRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of WithdrawalRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $WithdrawalRequestCopyWith<WithdrawalRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WithdrawalRequestCopyWith<$Res> {
  factory $WithdrawalRequestCopyWith(
          WithdrawalRequest value, $Res Function(WithdrawalRequest) then) =
      _$WithdrawalRequestCopyWithImpl<$Res, WithdrawalRequest>;
  @useResult
  $Res call(
      {String id,
      String driverId,
      double amount,
      String currency,
      WithdrawalMethod method,
      String accountDetails,
      WithdrawalStatus? status,
      String? rejectionReason,
      DateTime? requestedAt,
      DateTime? processedAt});
}

/// @nodoc
class _$WithdrawalRequestCopyWithImpl<$Res, $Val extends WithdrawalRequest>
    implements $WithdrawalRequestCopyWith<$Res> {
  _$WithdrawalRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of WithdrawalRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? driverId = null,
    Object? amount = null,
    Object? currency = null,
    Object? method = null,
    Object? accountDetails = null,
    Object? status = freezed,
    Object? rejectionReason = freezed,
    Object? requestedAt = freezed,
    Object? processedAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      driverId: null == driverId
          ? _value.driverId
          : driverId // ignore: cast_nullable_to_non_nullable
              as String,
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as double,
      currency: null == currency
          ? _value.currency
          : currency // ignore: cast_nullable_to_non_nullable
              as String,
      method: null == method
          ? _value.method
          : method // ignore: cast_nullable_to_non_nullable
              as WithdrawalMethod,
      accountDetails: null == accountDetails
          ? _value.accountDetails
          : accountDetails // ignore: cast_nullable_to_non_nullable
              as String,
      status: freezed == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as WithdrawalStatus?,
      rejectionReason: freezed == rejectionReason
          ? _value.rejectionReason
          : rejectionReason // ignore: cast_nullable_to_non_nullable
              as String?,
      requestedAt: freezed == requestedAt
          ? _value.requestedAt
          : requestedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      processedAt: freezed == processedAt
          ? _value.processedAt
          : processedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$WithdrawalRequestImplCopyWith<$Res>
    implements $WithdrawalRequestCopyWith<$Res> {
  factory _$$WithdrawalRequestImplCopyWith(_$WithdrawalRequestImpl value,
          $Res Function(_$WithdrawalRequestImpl) then) =
      __$$WithdrawalRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String driverId,
      double amount,
      String currency,
      WithdrawalMethod method,
      String accountDetails,
      WithdrawalStatus? status,
      String? rejectionReason,
      DateTime? requestedAt,
      DateTime? processedAt});
}

/// @nodoc
class __$$WithdrawalRequestImplCopyWithImpl<$Res>
    extends _$WithdrawalRequestCopyWithImpl<$Res, _$WithdrawalRequestImpl>
    implements _$$WithdrawalRequestImplCopyWith<$Res> {
  __$$WithdrawalRequestImplCopyWithImpl(_$WithdrawalRequestImpl _value,
      $Res Function(_$WithdrawalRequestImpl) _then)
      : super(_value, _then);

  /// Create a copy of WithdrawalRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? driverId = null,
    Object? amount = null,
    Object? currency = null,
    Object? method = null,
    Object? accountDetails = null,
    Object? status = freezed,
    Object? rejectionReason = freezed,
    Object? requestedAt = freezed,
    Object? processedAt = freezed,
  }) {
    return _then(_$WithdrawalRequestImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      driverId: null == driverId
          ? _value.driverId
          : driverId // ignore: cast_nullable_to_non_nullable
              as String,
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as double,
      currency: null == currency
          ? _value.currency
          : currency // ignore: cast_nullable_to_non_nullable
              as String,
      method: null == method
          ? _value.method
          : method // ignore: cast_nullable_to_non_nullable
              as WithdrawalMethod,
      accountDetails: null == accountDetails
          ? _value.accountDetails
          : accountDetails // ignore: cast_nullable_to_non_nullable
              as String,
      status: freezed == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as WithdrawalStatus?,
      rejectionReason: freezed == rejectionReason
          ? _value.rejectionReason
          : rejectionReason // ignore: cast_nullable_to_non_nullable
              as String?,
      requestedAt: freezed == requestedAt
          ? _value.requestedAt
          : requestedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      processedAt: freezed == processedAt
          ? _value.processedAt
          : processedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$WithdrawalRequestImpl implements _WithdrawalRequest {
  const _$WithdrawalRequestImpl(
      {required this.id,
      required this.driverId,
      required this.amount,
      required this.currency,
      required this.method,
      required this.accountDetails,
      this.status,
      this.rejectionReason,
      this.requestedAt,
      this.processedAt});

  factory _$WithdrawalRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$WithdrawalRequestImplFromJson(json);

  @override
  final String id;
  @override
  final String driverId;
  @override
  final double amount;
  @override
  final String currency;
  @override
  final WithdrawalMethod method;
  @override
  final String accountDetails;
  @override
  final WithdrawalStatus? status;
  @override
  final String? rejectionReason;
  @override
  final DateTime? requestedAt;
  @override
  final DateTime? processedAt;

  @override
  String toString() {
    return 'WithdrawalRequest(id: $id, driverId: $driverId, amount: $amount, currency: $currency, method: $method, accountDetails: $accountDetails, status: $status, rejectionReason: $rejectionReason, requestedAt: $requestedAt, processedAt: $processedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WithdrawalRequestImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.driverId, driverId) ||
                other.driverId == driverId) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.currency, currency) ||
                other.currency == currency) &&
            (identical(other.method, method) || other.method == method) &&
            (identical(other.accountDetails, accountDetails) ||
                other.accountDetails == accountDetails) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.rejectionReason, rejectionReason) ||
                other.rejectionReason == rejectionReason) &&
            (identical(other.requestedAt, requestedAt) ||
                other.requestedAt == requestedAt) &&
            (identical(other.processedAt, processedAt) ||
                other.processedAt == processedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      driverId,
      amount,
      currency,
      method,
      accountDetails,
      status,
      rejectionReason,
      requestedAt,
      processedAt);

  /// Create a copy of WithdrawalRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WithdrawalRequestImplCopyWith<_$WithdrawalRequestImpl> get copyWith =>
      __$$WithdrawalRequestImplCopyWithImpl<_$WithdrawalRequestImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$WithdrawalRequestImplToJson(
      this,
    );
  }
}

abstract class _WithdrawalRequest implements WithdrawalRequest {
  const factory _WithdrawalRequest(
      {required final String id,
      required final String driverId,
      required final double amount,
      required final String currency,
      required final WithdrawalMethod method,
      required final String accountDetails,
      final WithdrawalStatus? status,
      final String? rejectionReason,
      final DateTime? requestedAt,
      final DateTime? processedAt}) = _$WithdrawalRequestImpl;

  factory _WithdrawalRequest.fromJson(Map<String, dynamic> json) =
      _$WithdrawalRequestImpl.fromJson;

  @override
  String get id;
  @override
  String get driverId;
  @override
  double get amount;
  @override
  String get currency;
  @override
  WithdrawalMethod get method;
  @override
  String get accountDetails;
  @override
  WithdrawalStatus? get status;
  @override
  String? get rejectionReason;
  @override
  DateTime? get requestedAt;
  @override
  DateTime? get processedAt;

  /// Create a copy of WithdrawalRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WithdrawalRequestImplCopyWith<_$WithdrawalRequestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Settlement _$SettlementFromJson(Map<String, dynamic> json) {
  return _Settlement.fromJson(json);
}

/// @nodoc
mixin _$Settlement {
  String get id => throw _privateConstructorUsedError;
  String get driverId => throw _privateConstructorUsedError;
  String get period => throw _privateConstructorUsedError;
  double get totalEarnings => throw _privateConstructorUsedError;
  double get totalCommissions => throw _privateConstructorUsedError;
  double get totalIncentives => throw _privateConstructorUsedError;
  double get netAmount => throw _privateConstructorUsedError;
  String get currency => throw _privateConstructorUsedError;
  SettlementStatus get status => throw _privateConstructorUsedError;
  List<String> get tripIds => throw _privateConstructorUsedError;
  DateTime? get startDate => throw _privateConstructorUsedError;
  DateTime? get endDate => throw _privateConstructorUsedError;
  DateTime? get settledAt => throw _privateConstructorUsedError;

  /// Serializes this Settlement to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Settlement
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SettlementCopyWith<Settlement> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SettlementCopyWith<$Res> {
  factory $SettlementCopyWith(
          Settlement value, $Res Function(Settlement) then) =
      _$SettlementCopyWithImpl<$Res, Settlement>;
  @useResult
  $Res call(
      {String id,
      String driverId,
      String period,
      double totalEarnings,
      double totalCommissions,
      double totalIncentives,
      double netAmount,
      String currency,
      SettlementStatus status,
      List<String> tripIds,
      DateTime? startDate,
      DateTime? endDate,
      DateTime? settledAt});
}

/// @nodoc
class _$SettlementCopyWithImpl<$Res, $Val extends Settlement>
    implements $SettlementCopyWith<$Res> {
  _$SettlementCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Settlement
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? driverId = null,
    Object? period = null,
    Object? totalEarnings = null,
    Object? totalCommissions = null,
    Object? totalIncentives = null,
    Object? netAmount = null,
    Object? currency = null,
    Object? status = null,
    Object? tripIds = null,
    Object? startDate = freezed,
    Object? endDate = freezed,
    Object? settledAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      driverId: null == driverId
          ? _value.driverId
          : driverId // ignore: cast_nullable_to_non_nullable
              as String,
      period: null == period
          ? _value.period
          : period // ignore: cast_nullable_to_non_nullable
              as String,
      totalEarnings: null == totalEarnings
          ? _value.totalEarnings
          : totalEarnings // ignore: cast_nullable_to_non_nullable
              as double,
      totalCommissions: null == totalCommissions
          ? _value.totalCommissions
          : totalCommissions // ignore: cast_nullable_to_non_nullable
              as double,
      totalIncentives: null == totalIncentives
          ? _value.totalIncentives
          : totalIncentives // ignore: cast_nullable_to_non_nullable
              as double,
      netAmount: null == netAmount
          ? _value.netAmount
          : netAmount // ignore: cast_nullable_to_non_nullable
              as double,
      currency: null == currency
          ? _value.currency
          : currency // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as SettlementStatus,
      tripIds: null == tripIds
          ? _value.tripIds
          : tripIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      startDate: freezed == startDate
          ? _value.startDate
          : startDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      endDate: freezed == endDate
          ? _value.endDate
          : endDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      settledAt: freezed == settledAt
          ? _value.settledAt
          : settledAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SettlementImplCopyWith<$Res>
    implements $SettlementCopyWith<$Res> {
  factory _$$SettlementImplCopyWith(
          _$SettlementImpl value, $Res Function(_$SettlementImpl) then) =
      __$$SettlementImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String driverId,
      String period,
      double totalEarnings,
      double totalCommissions,
      double totalIncentives,
      double netAmount,
      String currency,
      SettlementStatus status,
      List<String> tripIds,
      DateTime? startDate,
      DateTime? endDate,
      DateTime? settledAt});
}

/// @nodoc
class __$$SettlementImplCopyWithImpl<$Res>
    extends _$SettlementCopyWithImpl<$Res, _$SettlementImpl>
    implements _$$SettlementImplCopyWith<$Res> {
  __$$SettlementImplCopyWithImpl(
      _$SettlementImpl _value, $Res Function(_$SettlementImpl) _then)
      : super(_value, _then);

  /// Create a copy of Settlement
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? driverId = null,
    Object? period = null,
    Object? totalEarnings = null,
    Object? totalCommissions = null,
    Object? totalIncentives = null,
    Object? netAmount = null,
    Object? currency = null,
    Object? status = null,
    Object? tripIds = null,
    Object? startDate = freezed,
    Object? endDate = freezed,
    Object? settledAt = freezed,
  }) {
    return _then(_$SettlementImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      driverId: null == driverId
          ? _value.driverId
          : driverId // ignore: cast_nullable_to_non_nullable
              as String,
      period: null == period
          ? _value.period
          : period // ignore: cast_nullable_to_non_nullable
              as String,
      totalEarnings: null == totalEarnings
          ? _value.totalEarnings
          : totalEarnings // ignore: cast_nullable_to_non_nullable
              as double,
      totalCommissions: null == totalCommissions
          ? _value.totalCommissions
          : totalCommissions // ignore: cast_nullable_to_non_nullable
              as double,
      totalIncentives: null == totalIncentives
          ? _value.totalIncentives
          : totalIncentives // ignore: cast_nullable_to_non_nullable
              as double,
      netAmount: null == netAmount
          ? _value.netAmount
          : netAmount // ignore: cast_nullable_to_non_nullable
              as double,
      currency: null == currency
          ? _value.currency
          : currency // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as SettlementStatus,
      tripIds: null == tripIds
          ? _value._tripIds
          : tripIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      startDate: freezed == startDate
          ? _value.startDate
          : startDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      endDate: freezed == endDate
          ? _value.endDate
          : endDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      settledAt: freezed == settledAt
          ? _value.settledAt
          : settledAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SettlementImpl implements _Settlement {
  const _$SettlementImpl(
      {required this.id,
      required this.driverId,
      required this.period,
      required this.totalEarnings,
      required this.totalCommissions,
      required this.totalIncentives,
      required this.netAmount,
      required this.currency,
      required this.status,
      final List<String> tripIds = const [],
      this.startDate,
      this.endDate,
      this.settledAt})
      : _tripIds = tripIds;

  factory _$SettlementImpl.fromJson(Map<String, dynamic> json) =>
      _$$SettlementImplFromJson(json);

  @override
  final String id;
  @override
  final String driverId;
  @override
  final String period;
  @override
  final double totalEarnings;
  @override
  final double totalCommissions;
  @override
  final double totalIncentives;
  @override
  final double netAmount;
  @override
  final String currency;
  @override
  final SettlementStatus status;
  final List<String> _tripIds;
  @override
  @JsonKey()
  List<String> get tripIds {
    if (_tripIds is EqualUnmodifiableListView) return _tripIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_tripIds);
  }

  @override
  final DateTime? startDate;
  @override
  final DateTime? endDate;
  @override
  final DateTime? settledAt;

  @override
  String toString() {
    return 'Settlement(id: $id, driverId: $driverId, period: $period, totalEarnings: $totalEarnings, totalCommissions: $totalCommissions, totalIncentives: $totalIncentives, netAmount: $netAmount, currency: $currency, status: $status, tripIds: $tripIds, startDate: $startDate, endDate: $endDate, settledAt: $settledAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SettlementImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.driverId, driverId) ||
                other.driverId == driverId) &&
            (identical(other.period, period) || other.period == period) &&
            (identical(other.totalEarnings, totalEarnings) ||
                other.totalEarnings == totalEarnings) &&
            (identical(other.totalCommissions, totalCommissions) ||
                other.totalCommissions == totalCommissions) &&
            (identical(other.totalIncentives, totalIncentives) ||
                other.totalIncentives == totalIncentives) &&
            (identical(other.netAmount, netAmount) ||
                other.netAmount == netAmount) &&
            (identical(other.currency, currency) ||
                other.currency == currency) &&
            (identical(other.status, status) || other.status == status) &&
            const DeepCollectionEquality().equals(other._tripIds, _tripIds) &&
            (identical(other.startDate, startDate) ||
                other.startDate == startDate) &&
            (identical(other.endDate, endDate) || other.endDate == endDate) &&
            (identical(other.settledAt, settledAt) ||
                other.settledAt == settledAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      driverId,
      period,
      totalEarnings,
      totalCommissions,
      totalIncentives,
      netAmount,
      currency,
      status,
      const DeepCollectionEquality().hash(_tripIds),
      startDate,
      endDate,
      settledAt);

  /// Create a copy of Settlement
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SettlementImplCopyWith<_$SettlementImpl> get copyWith =>
      __$$SettlementImplCopyWithImpl<_$SettlementImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SettlementImplToJson(
      this,
    );
  }
}

abstract class _Settlement implements Settlement {
  const factory _Settlement(
      {required final String id,
      required final String driverId,
      required final String period,
      required final double totalEarnings,
      required final double totalCommissions,
      required final double totalIncentives,
      required final double netAmount,
      required final String currency,
      required final SettlementStatus status,
      final List<String> tripIds,
      final DateTime? startDate,
      final DateTime? endDate,
      final DateTime? settledAt}) = _$SettlementImpl;

  factory _Settlement.fromJson(Map<String, dynamic> json) =
      _$SettlementImpl.fromJson;

  @override
  String get id;
  @override
  String get driverId;
  @override
  String get period;
  @override
  double get totalEarnings;
  @override
  double get totalCommissions;
  @override
  double get totalIncentives;
  @override
  double get netAmount;
  @override
  String get currency;
  @override
  SettlementStatus get status;
  @override
  List<String> get tripIds;
  @override
  DateTime? get startDate;
  @override
  DateTime? get endDate;
  @override
  DateTime? get settledAt;

  /// Create a copy of Settlement
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SettlementImplCopyWith<_$SettlementImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
