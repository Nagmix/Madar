import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trippo_shared/trippo_shared.dart';

import '../../../../core/constants/app_theme.dart';
import '../notifiers/driver_wallet_notifier.dart';

/// Driver Wallet Screen
///
/// Full-featured wallet screen for drivers showing balance, earnings,
/// transactions, settlements, commission info, and withdrawal options.
class DriverWalletScreen extends ConsumerStatefulWidget {
  const DriverWalletScreen({super.key});

  @override
  ConsumerState<DriverWalletScreen> createState() =>
      _DriverWalletScreenState();
}

class _DriverWalletScreenState extends ConsumerState<DriverWalletScreen> {
  @override
  void initState() {
    super.initState();
    // Load all wallet data on first build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(driverWalletProvider.notifier).loadAll();
    });
  }

  Future<void> _onRefresh() async {
    await ref.read(driverWalletProvider.notifier).loadAll();
  }

  @override
  Widget build(BuildContext context) {
    final walletState = ref.watch(driverWalletProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Wallet'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => _showTransactionHistory(context),
            tooltip: 'Transaction History',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        color: AppTheme.primary,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(AppTheme.spacing16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Error banner
              if (walletState.error != null) ...[
                _buildErrorBanner(walletState.error!),
                const SizedBox(height: AppTheme.spacing16),
              ],

              // Balance Card
              _buildBalanceCard(walletState),

              const SizedBox(height: AppTheme.spacing20),

              // Quick Actions Row
              _buildQuickActions(context),

              const SizedBox(height: AppTheme.spacing20),

              // Earnings Summary
              _buildEarningsSummary(walletState),

              const SizedBox(height: AppTheme.spacing20),

              // Commission Info Card
              _buildCommissionInfoCard(),

              const SizedBox(height: AppTheme.spacing20),

              // Recent Transactions
              _buildRecentTransactions(walletState),

              const SizedBox(height: AppTheme.spacing20),

              // Recent Settlements
              if (walletState.settlements.isNotEmpty) ...[
                _buildRecentSettlements(walletState),
                const SizedBox(height: AppTheme.spacing20),
              ],

              // Bottom padding for scroll
              const SizedBox(height: AppTheme.spacing32),
            ],
          ),
        ),
      ),
    );
  }

  // ==================== Error Banner ====================

  Widget _buildErrorBanner(String error) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppTheme.spacing12),
      decoration: BoxDecoration(
        color: AppTheme.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(color: AppTheme.error.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppTheme.error, size: 20),
          const SizedBox(width: AppTheme.spacing8),
          Expanded(
            child: Text(
              error,
              style: const TextStyle(
                color: AppTheme.error,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          InkWell(
            onTap: _onRefresh,
            child: const Icon(Icons.refresh, color: AppTheme.error, size: 20),
          ),
        ],
      ),
    );
  }

  // ==================== Balance Card ====================

  Widget _buildBalanceCard(DriverWalletState state) {
    final wallet = state.wallet;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppTheme.spacing24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.secondary, AppTheme.secondaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        boxShadow: [
          BoxShadow(
            color: AppTheme.secondary.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Available Balance label
          Row(
            children: [
              const Icon(Icons.account_balance_wallet,
                  color: Colors.white54, size: 18),
              const SizedBox(width: 6),
              const Text(
                'Available Balance',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '\$${(wallet?.availableBalance ?? 0).toStringAsFixed(2)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppTheme.spacing20),

          // Pending Balance & Total Earnings row
          Row(
            children: [
              _buildBalanceInfoItem(
                'Pending',
                '\$${(wallet?.pendingBalance ?? 0).toStringAsFixed(2)}',
                Icons.schedule,
              ),
              const SizedBox(width: AppTheme.spacing24),
              _buildBalanceInfoItem(
                'Total Earnings',
                '\$${(wallet?.totalEarnings ?? 0).toStringAsFixed(2)}',
                Icons.trending_up,
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacing20),

          // Withdraw Funds button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _showWithdrawSheet(context),
              icon: const Icon(Icons.send, size: 18),
              label: const Text('Withdraw Funds'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppTheme.secondary,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(AppTheme.radiusMedium),
                ),
                textStyle: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceInfoItem(String label, String value, IconData icon) {
    return Expanded(
      child: Row(
        children: [
          Icon(icon, color: Colors.white38, size: 16),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style:
                      const TextStyle(color: Colors.white60, fontSize: 11)),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==================== Quick Actions ====================

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: AppTheme.spacing12),
        Row(
          children: [
            _buildQuickActionButton(
              icon: Icons.send,
              label: 'Withdraw',
              color: AppTheme.primary,
              onTap: () => _showWithdrawSheet(context),
            ),
            const SizedBox(width: AppTheme.spacing12),
            _buildQuickActionButton(
              icon: Icons.receipt_long,
              label: 'Settlements',
              color: AppTheme.info,
              onTap: () => _showSettlements(context),
            ),
            const SizedBox(width: AppTheme.spacing12),
            _buildQuickActionButton(
              icon: Icons.description_outlined,
              label: 'Statements',
              color: AppTheme.accent,
              onTap: () => _showStatements(context),
            ),
            const SizedBox(width: AppTheme.spacing12),
            _buildQuickActionButton(
              icon: Icons.card_giftcard,
              label: 'Incentives',
              color: AppTheme.warning,
              onTap: () => _showIncentives(context),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        child: Container(
          padding: const EdgeInsets.symmetric(
            vertical: AppTheme.spacing16,
            horizontal: AppTheme.spacing8,
          ),
          decoration: BoxDecoration(
            color: color.withOpacity(0.08),
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            border: Border.all(color: color.withOpacity(0.2)),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==================== Earnings Summary ====================

  Widget _buildEarningsSummary(DriverWalletState state) {
    final wallet = state.wallet;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Earnings Summary',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: AppTheme.spacing12),
        Row(
          children: [
            _buildEarningsCard(
              title: 'Total Earnings',
              amount: wallet?.totalEarnings ?? 0,
              icon: Icons.trending_up,
              color: AppTheme.primary,
            ),
            const SizedBox(width: AppTheme.spacing12),
            _buildEarningsCard(
              title: 'Commissions',
              amount: wallet?.totalCommissions ?? 0,
              icon: Icons.percent,
              color: AppTheme.accent,
            ),
            const SizedBox(width: AppTheme.spacing12),
            _buildEarningsCard(
              title: 'Incentives',
              amount: wallet?.totalIncentives ?? 0,
              icon: Icons.card_giftcard,
              color: AppTheme.info,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEarningsCard({
    required String title,
    required double amount,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(AppTheme.spacing12),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 16),
                const SizedBox(width: 4),
                Text(
                  title,
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '\$${amount.toStringAsFixed(2)}',
              style: TextStyle(
                color: color,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== Commission Info Card ====================

  Widget _buildCommissionInfoCard() {
    final commissionRate =
        (AppConstants.driverCommissionRate * 100).toInt();
    final incentiveRate =
        (AppConstants.driverIncentiveBonusRate * 100).toInt();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppTheme.spacing16),
      decoration: BoxDecoration(
        color: AppTheme.info.withOpacity(0.06),
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(color: AppTheme.info.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppTheme.info.withOpacity(0.15),
                  borderRadius:
                      BorderRadius.circular(AppTheme.radiusSmall),
                ),
                child: const Icon(Icons.info_outline,
                    color: AppTheme.info, size: 18),
              ),
              const SizedBox(width: AppTheme.spacing8),
              const Text(
                'Commission Info',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacing12),
          Row(
            children: [
              Expanded(
                child: _buildCommissionDetail(
                  'Your Rate',
                  '$commissionRate%',
                  AppTheme.info,
                ),
              ),
              Container(
                width: 1,
                height: 36,
                color: AppTheme.divider,
              ),
              Expanded(
                child: _buildCommissionDetail(
                  'Incentive Bonus',
                  '$incentiveRate%',
                  AppTheme.primary,
                ),
              ),
              Container(
                width: 1,
                height: 36,
                color: AppTheme.divider,
              ),
              Expanded(
                child: _buildCommissionDetail(
                  'You Keep',
                  '${100 - commissionRate}%',
                  AppTheme.success,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacing12),
          Text(
            'Commission is calculated as $commissionRate% of each trip fare. '
            'You earn an additional $incentiveRate% bonus for maintaining high ratings.',
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.textSecondary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommissionDetail(
      String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }

  // ==================== Recent Transactions ====================

  Widget _buildRecentTransactions(DriverWalletState state) {
    final transactions = state.transactions;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Recent Transactions',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            if (transactions.isNotEmpty)
              TextButton(
                onPressed: () => _showTransactionHistory(context),
                child: const Text('View All'),
              ),
          ],
        ),
        const SizedBox(height: AppTheme.spacing8),
        if (state.isLoading && transactions.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(AppTheme.spacing32),
              child: CircularProgressIndicator(color: AppTheme.primary),
            ),
          )
        else if (transactions.isEmpty)
          _buildEmptyState(
            icon: Icons.receipt_long_outlined,
            message: 'No transactions yet',
          )
        else
          ...transactions.take(5).map((tx) => _buildTransactionItem(tx)),
      ],
    );
  }

  Widget _buildTransactionItem(WalletTransaction tx) {
    final isCredit = tx.type == TransactionType.tripEarning ||
        tx.type == TransactionType.incentiveBonus ||
        tx.type == TransactionType.refund ||
        tx.type == TransactionType.cancellationFee;

    final color = isCredit ? AppTheme.success : AppTheme.error;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spacing8),
      child: Container(
        padding: const EdgeInsets.all(AppTheme.spacing12),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius:
                    BorderRadius.circular(AppTheme.radiusSmall),
              ),
              child: Icon(
                _getTransactionIcon(tx.type),
                color: color,
                size: 20,
              ),
            ),
            const SizedBox(width: AppTheme.spacing12),

            // Description & Date
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tx.description,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                      color: AppTheme.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _formatDate(tx.createdAt),
                    style: const TextStyle(
                      color: AppTheme.textHint,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),

            // Amount
            Text(
              '${isCredit ? '+' : '-'}\$${tx.amount.toStringAsFixed(2)}',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: color,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getTransactionIcon(TransactionType type) => switch (type) {
        TransactionType.tripEarning => Icons.directions_car,
        TransactionType.commissionDeduction => Icons.percent,
        TransactionType.withdrawal => Icons.send,
        TransactionType.incentiveBonus => Icons.card_giftcard,
        TransactionType.cancellationFee => Icons.cancel,
        TransactionType.adjustment => Icons.tune,
        TransactionType.penalty => Icons.warning_amber,
        TransactionType.refund => Icons.replay,
      };

  // ==================== Recent Settlements ====================

  Widget _buildRecentSettlements(DriverWalletState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Recent Settlements',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            TextButton(
              onPressed: () => _showSettlements(context),
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: AppTheme.spacing8),
        ...state.settlements.take(3).map((s) => _buildSettlementItem(s)),
      ],
    );
  }

  Widget _buildSettlementItem(Settlement settlement) {
    final statusColor = _getSettlementStatusColor(settlement.status);
    final statusLabel = _getSettlementStatusLabel(settlement.status);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spacing8),
      child: Container(
        padding: const EdgeInsets.all(AppTheme.spacing12),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Status icon
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius:
                    BorderRadius.circular(AppTheme.radiusSmall),
              ),
              child: Icon(
                _getSettlementStatusIcon(settlement.status),
                color: statusColor,
                size: 20,
              ),
            ),
            const SizedBox(width: AppTheme.spacing12),

            // Period & details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Period: ${settlement.period}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Net: \$${settlement.netAmount.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            // Status badge
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius:
                    BorderRadius.circular(AppTheme.radiusSmall),
              ),
              child: Text(
                statusLabel,
                style: TextStyle(
                  color: statusColor,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getSettlementStatusColor(SettlementStatus status) =>
      switch (status) {
        SettlementStatus.pending => AppTheme.warning,
        SettlementStatus.processing => AppTheme.info,
        SettlementStatus.settled => AppTheme.success,
      };

  String _getSettlementStatusLabel(SettlementStatus status) => switch (status) {
        SettlementStatus.pending => 'Pending',
        SettlementStatus.processing => 'Processing',
        SettlementStatus.settled => 'Settled',
      };

  IconData _getSettlementStatusIcon(SettlementStatus status) => switch (status) {
        SettlementStatus.pending => Icons.schedule,
        SettlementStatus.processing => Icons.sync,
        SettlementStatus.settled => Icons.check_circle,
      };

  // ==================== Empty State ====================

  Widget _buildEmptyState({
    required IconData icon,
    required String message,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacing32),
        child: Column(
          children: [
            Icon(icon, size: 48, color: Colors.grey[300]),
            const SizedBox(height: 12),
            Text(
              message,
              style: const TextStyle(
                color: AppTheme.textHint,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== Helpers ====================

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  // ==================== Navigation Helpers ====================

  void _showTransactionHistory(BuildContext context) {
    // TODO: Navigate to full transaction history screen
  }

  void _showSettlements(BuildContext context) {
    // TODO: Navigate to settlements screen
  }

  void _showStatements(BuildContext context) {
    // TODO: Navigate to statements screen
  }

  void _showIncentives(BuildContext context) {
    // TODO: Navigate to incentives screen
  }

  // ==================== Withdrawal Bottom Sheet ====================

  void _showWithdrawSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(AppTheme.radiusXLarge)),
      ),
      builder: (context) => const _DriverWithdrawSheet(),
    );
  }
}

// ==================== Withdrawal Bottom Sheet ====================

class _DriverWithdrawSheet extends ConsumerStatefulWidget {
  const _DriverWithdrawSheet();

  @override
  ConsumerState<_DriverWithdrawSheet> createState() =>
      _DriverWithdrawSheetState();
}

class _DriverWithdrawSheetState extends ConsumerState<_DriverWithdrawSheet> {
  final _amountController = TextEditingController();
  WithdrawalMethod _selectedMethod = WithdrawalMethod.bankTransfer;
  final _accountController = TextEditingController();
  bool _isLoading = false;
  String? _localError;

  @override
  void dispose() {
    _amountController.dispose();
    _accountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final wallet = ref.watch(driverWalletProvider).wallet;
    final availableBalance = wallet?.availableBalance ?? 0;

    return Padding(
      padding: EdgeInsets.only(
        left: AppTheme.spacing24,
        right: AppTheme.spacing24,
        top: AppTheme.spacing24,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppTheme.spacing24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Request Withdrawal',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),

            const SizedBox(height: AppTheme.spacing16),

            // Available balance display
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppTheme.spacing16),
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                border: Border.all(color: AppTheme.primary.withOpacity(0.2)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Available',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  Text(
                    '\$${availableBalance.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primary,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppTheme.spacing16),

            // Min/Max info
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spacing12,
                vertical: AppTheme.spacing8,
              ),
              decoration: BoxDecoration(
                color: AppTheme.warning.withOpacity(0.08),
                borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline,
                      color: AppTheme.warning, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    'Min: \$${AppConstants.minimumWithdrawalAmount.toStringAsFixed(0)} • '
                    'Max: \$${AppConstants.maximumWithdrawalAmount.toStringAsFixed(0)}',
                    style: const TextStyle(
                      color: AppTheme.warning,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppTheme.spacing16),

            // Amount field
            TextField(
              controller: _amountController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Amount',
                prefixText: '\$ ',
                hintText: 'Enter withdrawal amount',
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(AppTheme.radiusMedium),
                ),
              ),
            ),

            const SizedBox(height: AppTheme.spacing20),

            // Withdrawal method selection
            const Text(
              'Withdrawal Method',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: AppTheme.spacing8),
            ...WithdrawalMethod.values.map((method) => Container(
                  margin: const EdgeInsets.only(bottom: AppTheme.spacing8),
                  decoration: BoxDecoration(
                    color: _selectedMethod == method
                        ? AppTheme.primary.withOpacity(0.06)
                        : AppTheme.background,
                    borderRadius:
                        BorderRadius.circular(AppTheme.radiusMedium),
                    border: Border.all(
                      color: _selectedMethod == method
                          ? AppTheme.primary.withOpacity(0.3)
                          : AppTheme.divider,
                    ),
                  ),
                  child: RadioListTile<WithdrawalMethod>(
                    value: method,
                    groupValue: _selectedMethod,
                    onChanged: (v) => setState(() => _selectedMethod = v!),
                    title: Row(
                      children: [
                        Icon(
                          _getMethodIcon(method),
                          size: 20,
                          color: _selectedMethod == method
                              ? AppTheme.primary
                              : AppTheme.textSecondary,
                        ),
                        const SizedBox(width: 8),
                        Text(_getMethodLabel(method)),
                      ],
                    ),
                    subtitle: Text(
                      _getMethodDescription(method),
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppTheme.textHint,
                      ),
                    ),
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                    activeColor: AppTheme.primary,
                  ),
                )),

            const SizedBox(height: AppTheme.spacing16),

            // Account details field
            TextField(
              controller: _accountController,
              decoration: InputDecoration(
                labelText: _getAccountLabel(),
                hintText: _getAccountHint(),
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(AppTheme.radiusMedium),
                ),
              ),
            ),

            // Local error
            if (_localError != null) ...[
              const SizedBox(height: AppTheme.spacing12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppTheme.spacing8),
                decoration: BoxDecoration(
                  color: AppTheme.error.withOpacity(0.08),
                  borderRadius:
                      BorderRadius.circular(AppTheme.radiusSmall),
                ),
                child: Text(
                  _localError!,
                  style: const TextStyle(
                    color: AppTheme.error,
                    fontSize: 12,
                  ),
                ),
              ),
            ],

            const SizedBox(height: AppTheme.spacing24),

            // Submit button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submitWithdrawal,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(AppTheme.radiusMedium),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Submit Withdrawal Request'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getMethodIcon(WithdrawalMethod method) => switch (method) {
        WithdrawalMethod.bankTransfer => Icons.account_balance,
        WithdrawalMethod.mobileWallet => Icons.phone_android,
        WithdrawalMethod.cash => Icons.money,
      };

  String _getMethodLabel(WithdrawalMethod method) => switch (method) {
        WithdrawalMethod.bankTransfer => 'Bank Transfer',
        WithdrawalMethod.mobileWallet => 'Mobile Wallet',
        WithdrawalMethod.cash => 'Cash Pickup',
      };

  String _getMethodDescription(WithdrawalMethod method) => switch (method) {
        WithdrawalMethod.bankTransfer =>
          'Transfer to your bank account (1-3 business days)',
        WithdrawalMethod.mobileWallet =>
          'Instant transfer to mobile wallet',
        WithdrawalMethod.cash =>
          'Pick up cash from authorized location',
      };

  String _getAccountLabel() => switch (_selectedMethod) {
        WithdrawalMethod.bankTransfer => 'IBAN / Account Number',
        WithdrawalMethod.mobileWallet => 'Mobile Wallet Number',
        WithdrawalMethod.cash => 'ID Number',
      };

  String _getAccountHint() => switch (_selectedMethod) {
        WithdrawalMethod.bankTransfer => 'e.g. SA0380000000608010167519',
        WithdrawalMethod.mobileWallet => 'e.g. 05XXXXXXXX',
        WithdrawalMethod.cash => 'e.g. 1234567890',
      };

  Future<void> _submitWithdrawal() async {
    final amount = double.tryParse(_amountController.text) ?? 0;
    final accountDetails = _accountController.text.trim();

    // Validate inputs
    if (amount <= 0) {
      setState(() => _localError = 'Please enter a valid amount');
      return;
    }

    if (amount < AppConstants.minimumWithdrawalAmount) {
      setState(() {
        _localError =
            'Minimum withdrawal amount is \$${AppConstants.minimumWithdrawalAmount.toStringAsFixed(0)}';
      });
      return;
    }

    if (amount > AppConstants.maximumWithdrawalAmount) {
      setState(() {
        _localError =
            'Maximum withdrawal amount is \$${AppConstants.maximumWithdrawalAmount.toStringAsFixed(0)}';
      });
      return;
    }

    if (accountDetails.isEmpty) {
      setState(() => _localError = 'Please enter account details');
      return;
    }

    setState(() {
      _isLoading = true;
      _localError = null;
    });

    final success =
        await ref.read(driverWalletProvider.notifier).requestWithdrawal(
              amount: amount,
              method: _selectedMethod,
              accountDetails: accountDetails,
            );

    if (mounted) {
      setState(() => _isLoading = false);

      if (success) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Withdrawal request submitted successfully'),
            backgroundColor: AppTheme.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(AppTheme.radiusMedium),
            ),
          ),
        );
      } else {
        // Show error from notifier state
        final error = ref.read(driverWalletProvider).error;
        setState(() => _localError = error ?? 'Withdrawal request failed');
      }
    }
  }
}
