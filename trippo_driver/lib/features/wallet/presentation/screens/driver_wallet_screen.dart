import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trippo_shared/trippo_shared.dart';
import '../../../../core/constants/app_theme.dart';
import '../notifiers/driver_wallet_notifier.dart';

/// شاشة المحفظة - مدار
class DriverWalletScreen extends ConsumerStatefulWidget {
  const DriverWalletScreen({super.key});

  @override
  ConsumerState<DriverWalletScreen> createState() => _DriverWalletScreenState();
}

class _DriverWalletScreenState extends ConsumerState<DriverWalletScreen> {
  @override
  void initState() {
    super.initState();
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
      backgroundColor: MadarTheme.background,
      appBar: AppBar(
        backgroundColor: MadarTheme.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        title: const Text(
          'المحفظة',
          style: TextStyle(
            fontFamily: MadarTheme.fontFamily,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => _showTransactionHistory(context),
            tooltip: 'سجل المعاملات',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        color: MadarTheme.primary,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(MadarTheme.space16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Error banner
              if (walletState.error != null) ...[
                _buildErrorBanner(walletState.error!),
                const SizedBox(height: MadarTheme.space16),
              ],

              // Balance Card
              _buildBalanceCard(walletState),

              const SizedBox(height: MadarTheme.space20),

              // Quick Actions Row
              _buildQuickActions(context),

              const SizedBox(height: MadarTheme.space20),

              // Earnings Summary
              _buildEarningsSummary(walletState),

              const SizedBox(height: MadarTheme.space20),

              // Commission Info Card
              _buildCommissionInfoCard(),

              const SizedBox(height: MadarTheme.space20),

              // Recent Transactions
              _buildRecentTransactions(walletState),

              const SizedBox(height: MadarTheme.space20),

              // Recent Settlements
              if (walletState.settlements.isNotEmpty) ...[
                _buildRecentSettlements(walletState),
                const SizedBox(height: MadarTheme.space20),
              ],

              const SizedBox(height: MadarTheme.space32),
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
      padding: const EdgeInsets.all(MadarTheme.space12),
      decoration: BoxDecoration(
        color: MadarTheme.error.withOpacity(0.08),
        borderRadius: BorderRadius.circular(MadarTheme.radiusMd),
        border: Border.all(color: MadarTheme.error.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: MadarTheme.error, size: 20),
          const SizedBox(width: MadarTheme.space8),
          Expanded(
            child: Text(
              error,
              style: const TextStyle(
                color: MadarTheme.error,
                fontSize: 13,
                fontWeight: FontWeight.w500,
                fontFamily: MadarTheme.fontFamily,
              ),
            ),
          ),
          InkWell(
            onTap: _onRefresh,
            child: const Icon(Icons.refresh, color: MadarTheme.error, size: 20),
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
      padding: const EdgeInsets.all(MadarTheme.space24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [MadarTheme.primary, MadarTheme.primaryDark],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(MadarTheme.radiusXl),
        boxShadow: [
          MadarTheme.shadow(
            color: MadarTheme.primary.withOpacity(0.4),
            blur: 20,
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
              const Icon(Icons.account_balance_wallet, color: Colors.white54, size: 18),
              const SizedBox(width: 6),
              const Text(
                'الرصيد المتاح',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontFamily: MadarTheme.fontFamily,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'ر.ي ${(wallet?.availableBalance ?? 0).toStringAsFixed(2)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.bold,
              fontFamily: MadarTheme.fontFamily,
            ),
          ),
          const SizedBox(height: MadarTheme.space20),

          // Pending & Total row
          Row(
            children: [
              _buildBalanceInfoItem(
                'قيد الانتظار',
                'ر.ي ${(wallet?.pendingBalance ?? 0).toStringAsFixed(2)}',
                Icons.schedule,
              ),
              const SizedBox(width: MadarTheme.space24),
              _buildBalanceInfoItem(
                'إجمالي الأرباح',
                'ر.ي ${(wallet?.totalEarnings ?? 0).toStringAsFixed(2)}',
                Icons.trending_up,
              ),
            ],
          ),
          const SizedBox(height: MadarTheme.space20),

          // Withdraw button
          MadarGradientButton(
            label: 'سحب أموال',
            icon: Icons.send,
            gradientColors: [Colors.white, Colors.white],
            onPressed: () => _showWithdrawSheet(context),
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
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white60,
                  fontSize: 11,
                  fontFamily: MadarTheme.fontFamily,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  fontFamily: MadarTheme.fontFamily,
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
          'إجراءات سريعة',
          style: TextStyle(
            fontFamily: MadarTheme.fontFamily,
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: MadarTheme.textPrimary,
          ),
        ),
        const SizedBox(height: MadarTheme.space12),
        Row(
          children: [
            _buildQuickActionButton(
              icon: Icons.send,
              label: 'سحب',
              color: MadarTheme.primary,
              onTap: () => _showWithdrawSheet(context),
            ),
            const SizedBox(width: MadarTheme.space12),
            _buildQuickActionButton(
              icon: Icons.receipt_long,
              label: 'التسويات',
              color: MadarTheme.primary,
              onTap: () => _showSettlements(context),
            ),
            const SizedBox(width: MadarTheme.space12),
            _buildQuickActionButton(
              icon: Icons.description_outlined,
              label: 'الكشوف',
              color: MadarTheme.accent,
              onTap: () => _showStatements(context),
            ),
            const SizedBox(width: MadarTheme.space12),
            _buildQuickActionButton(
              icon: Icons.card_giftcard,
              label: 'الحوافز',
              color: MadarTheme.warning,
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
        borderRadius: BorderRadius.circular(MadarTheme.radiusMd),
        child: Container(
          padding: const EdgeInsets.symmetric(
            vertical: MadarTheme.space16,
            horizontal: MadarTheme.space8,
          ),
          decoration: BoxDecoration(
            color: color.withOpacity(0.08),
            borderRadius: BorderRadius.circular(MadarTheme.radiusMd),
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
                  fontFamily: MadarTheme.fontFamily,
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
          'ملخص الأرباح',
          style: TextStyle(
            fontFamily: MadarTheme.fontFamily,
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: MadarTheme.textPrimary,
          ),
        ),
        const SizedBox(height: MadarTheme.space12),
        Row(
          children: [
            _buildEarningsCard(
              title: 'إجمالي الأرباح',
              amount: wallet?.totalEarnings ?? 0,
              icon: Icons.trending_up,
              color: MadarTheme.primary,
            ),
            const SizedBox(width: MadarTheme.space12),
            _buildEarningsCard(
              title: 'العمولات',
              amount: wallet?.totalCommissions ?? 0,
              icon: Icons.percent,
              color: MadarTheme.accent,
            ),
            const SizedBox(width: MadarTheme.space12),
            _buildEarningsCard(
              title: 'الحوافز',
              amount: wallet?.totalIncentives ?? 0,
              icon: Icons.card_giftcard,
              color: MadarTheme.success,
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
        padding: const EdgeInsets.all(MadarTheme.space12),
        decoration: MadarTheme.cardDecoration(),
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
                    color: MadarTheme.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    fontFamily: MadarTheme.fontFamily,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'ر.ي ${amount.toStringAsFixed(2)}',
              style: TextStyle(
                color: color,
                fontSize: 17,
                fontWeight: FontWeight.w700,
                fontFamily: MadarTheme.fontFamily,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== Commission Info Card ====================

  Widget _buildCommissionInfoCard() {
    final commissionRate = (AppConstants.driverCommissionRate * 100).toInt();
    final incentiveRate = (AppConstants.driverIncentiveBonusRate * 100).toInt();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(MadarTheme.space16),
      decoration: BoxDecoration(
        color: MadarTheme.primary.withOpacity(0.06),
        borderRadius: BorderRadius.circular(MadarTheme.radiusMd),
        border: Border.all(color: MadarTheme.primary.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: MadarTheme.primary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(MadarTheme.radiusSm),
                ),
                child: const Icon(Icons.info_outline, color: MadarTheme.primary, size: 18),
              ),
              const SizedBox(width: MadarTheme.space8),
              const Text(
                'معلومات العمولة',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: MadarTheme.textPrimary,
                  fontFamily: MadarTheme.fontFamily,
                ),
              ),
            ],
          ),
          const SizedBox(height: MadarTheme.space12),
          Row(
            children: [
              Expanded(
                child: _buildCommissionDetail('نسبتك', '$commissionRate%', MadarTheme.primary),
              ),
              Container(width: 1, height: 36, color: MadarTheme.textHint.withOpacity(0.3)),
              Expanded(
                child: _buildCommissionDetail('مكافأة الأداء', '$incentiveRate%', MadarTheme.success),
              ),
              Container(width: 1, height: 36, color: MadarTheme.textHint.withOpacity(0.3)),
              Expanded(
                child: _buildCommissionDetail('تحتفظ بـ', '${100 - commissionRate}%', MadarTheme.accent),
              ),
            ],
          ),
          const SizedBox(height: MadarTheme.space12),
          Text(
            'تُحسب العمولة بنسبة $commissionRate% من أجرة كل رحلة. تحصل على مكافأة إضافية $incentiveRate% للحفاظ على تقييم عالٍ.',
            style: const TextStyle(
              fontSize: 12,
              color: MadarTheme.textSecondary,
              height: 1.4,
              fontFamily: MadarTheme.fontFamily,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommissionDetail(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: color,
            fontFamily: MadarTheme.fontFamily,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: MadarTheme.textSecondary,
            fontFamily: MadarTheme.fontFamily,
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
              'المعاملات الأخيرة',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: MadarTheme.textPrimary,
                fontFamily: MadarTheme.fontFamily,
              ),
            ),
            if (transactions.isNotEmpty)
              TextButton(
                onPressed: () => _showTransactionHistory(context),
                child: const Text(
                  'عرض الكل',
                  style: TextStyle(fontFamily: MadarTheme.fontFamily),
                ),
              ),
          ],
        ),
        const SizedBox(height: MadarTheme.space8),
        if (state.isLoading && transactions.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(MadarTheme.space32),
              child: CircularProgressIndicator(color: MadarTheme.primary),
            ),
          )
        else if (transactions.isEmpty)
          MadarEmptyState(
            icon: Icons.receipt_long_outlined,
            title: 'لا توجد معاملات بعد',
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

    final color = isCredit ? MadarTheme.success : MadarTheme.error;

    return Padding(
      padding: const EdgeInsets.only(bottom: MadarTheme.space8),
      child: Container(
        padding: const EdgeInsets.all(MadarTheme.space12),
        decoration: MadarTheme.cardDecoration(
          radius: MadarTheme.radiusMd,
          elevation: MadarTheme.elevationLow,
        ),
        child: Row(
          children: [
            // Icon
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(MadarTheme.radiusSm),
              ),
              child: Icon(
                _getTransactionIcon(tx.type),
                color: color,
                size: 20,
              ),
            ),
            const SizedBox(width: MadarTheme.space12),

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
                      color: MadarTheme.textPrimary,
                      fontFamily: MadarTheme.fontFamily,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _formatDate(tx.createdAt),
                    style: const TextStyle(
                      color: MadarTheme.textHint,
                      fontSize: 11,
                      fontFamily: MadarTheme.fontFamily,
                    ),
                  ),
                ],
              ),
            ),

            // Amount
            Text(
              '${isCredit ? '+' : '-'}ر.ي ${tx.amount.toStringAsFixed(2)}',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: color,
                fontSize: 14,
                fontFamily: MadarTheme.fontFamily,
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
              'التسويات الأخيرة',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: MadarTheme.textPrimary,
                fontFamily: MadarTheme.fontFamily,
              ),
            ),
            TextButton(
              onPressed: () => _showSettlements(context),
              child: const Text(
                'عرض الكل',
                style: TextStyle(fontFamily: MadarTheme.fontFamily),
              ),
            ),
          ],
        ),
        const SizedBox(height: MadarTheme.space8),
        ...state.settlements.take(3).map((s) => _buildSettlementItem(s)),
      ],
    );
  }

  Widget _buildSettlementItem(Settlement settlement) {
    final statusColor = _getSettlementStatusColor(settlement.status);
    final statusLabel = _getSettlementStatusLabel(settlement.status);

    return Padding(
      padding: const EdgeInsets.only(bottom: MadarTheme.space8),
      child: Container(
        padding: const EdgeInsets.all(MadarTheme.space12),
        decoration: MadarTheme.cardDecoration(
          radius: MadarTheme.radiusMd,
          elevation: MadarTheme.elevationLow,
        ),
        child: Row(
          children: [
            // Status icon
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(MadarTheme.radiusSm),
              ),
              child: Icon(
                _getSettlementStatusIcon(settlement.status),
                color: statusColor,
                size: 20,
              ),
            ),
            const SizedBox(width: MadarTheme.space12),

            // Period & details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'الفترة: ${settlement.period}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                      color: MadarTheme.textPrimary,
                      fontFamily: MadarTheme.fontFamily,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'الصافي: ر.ي ${settlement.netAmount.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: MadarTheme.textSecondary,
                      fontSize: 12,
                      fontFamily: MadarTheme.fontFamily,
                    ),
                  ),
                ],
              ),
            ),

            // Status badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(MadarTheme.radiusSm),
              ),
              child: Text(
                statusLabel,
                style: TextStyle(
                  color: statusColor,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  fontFamily: MadarTheme.fontFamily,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getSettlementStatusColor(SettlementStatus status) => switch (status) {
        SettlementStatus.pending => MadarTheme.warning,
        SettlementStatus.processing => MadarTheme.primary,
        SettlementStatus.settled => MadarTheme.success,
      };

  String _getSettlementStatusLabel(SettlementStatus status) => switch (status) {
        SettlementStatus.pending => 'قيد الانتظار',
        SettlementStatus.processing => 'قيد المعالجة',
        SettlementStatus.settled => 'تم التسوية',
      };

  IconData _getSettlementStatusIcon(SettlementStatus status) => switch (status) {
        SettlementStatus.pending => Icons.schedule,
        SettlementStatus.processing => Icons.sync,
        SettlementStatus.settled => Icons.check_circle,
      };

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
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(MadarTheme.radiusXxl),
        ),
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
        left: MadarTheme.space24,
        right: MadarTheme.space24,
        top: MadarTheme.space24,
        bottom: MediaQuery.of(context).viewInsets.bottom + MadarTheme.space24,
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
                  'طلب سحب',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: MadarTheme.textPrimary,
                    fontFamily: MadarTheme.fontFamily,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),

            const SizedBox(height: MadarTheme.space16),

            // Available balance display
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(MadarTheme.space16),
              decoration: BoxDecoration(
                color: MadarTheme.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(MadarTheme.radiusMd),
                border: Border.all(color: MadarTheme.primary.withOpacity(0.2)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'المتاح',
                    style: TextStyle(
                      fontSize: 14,
                      color: MadarTheme.textSecondary,
                      fontFamily: MadarTheme.fontFamily,
                    ),
                  ),
                  Text(
                    'ر.ي ${availableBalance.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: MadarTheme.primary,
                      fontFamily: MadarTheme.fontFamily,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: MadarTheme.space16),

            // Min/Max info
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: MadarTheme.space12,
                vertical: MadarTheme.space8,
              ),
              decoration: BoxDecoration(
                color: MadarTheme.warning.withOpacity(0.08),
                borderRadius: BorderRadius.circular(MadarTheme.radiusSm),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: MadarTheme.warning, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    'الحد الأدنى: ر.ي ${AppConstants.minimumWithdrawalAmount.toStringAsFixed(0)} • '
                    'الحد الأقصى: ر.ي ${AppConstants.maximumWithdrawalAmount.toStringAsFixed(0)}',
                    style: const TextStyle(
                      color: MadarTheme.warning,
                      fontSize: 12,
                      fontFamily: MadarTheme.fontFamily,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: MadarTheme.space16),

            // Amount field
            MadarTextField(
              label: 'المبلغ',
              hint: 'أدخل مبلغ السحب',
              controller: _amountController,
              prefixIcon: Icons.attach_money,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              textDirection: TextDirection.ltr,
            ),

            const SizedBox(height: MadarTheme.space20),

            // Withdrawal method selection
            const Text(
              'طريقة السحب',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: MadarTheme.textPrimary,
                fontFamily: MadarTheme.fontFamily,
              ),
            ),
            const SizedBox(height: MadarTheme.space8),
            ...WithdrawalMethod.values.map((method) => Container(
                  margin: const EdgeInsets.only(bottom: MadarTheme.space8),
                  decoration: BoxDecoration(
                    color: _selectedMethod == method
                        ? MadarTheme.primary.withOpacity(0.06)
                        : MadarTheme.background,
                    borderRadius: BorderRadius.circular(MadarTheme.radiusMd),
                    border: Border.all(
                      color: _selectedMethod == method
                          ? MadarTheme.primary.withOpacity(0.3)
                          : MadarTheme.textHint.withOpacity(0.3),
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
                              ? MadarTheme.primary
                              : MadarTheme.textSecondary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _getMethodLabel(method),
                          style: const TextStyle(fontFamily: MadarTheme.fontFamily),
                        ),
                      ],
                    ),
                    subtitle: Text(
                      _getMethodDescription(method),
                      style: const TextStyle(
                        fontSize: 11,
                        color: MadarTheme.textHint,
                        fontFamily: MadarTheme.fontFamily,
                      ),
                    ),
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                    activeColor: MadarTheme.primary,
                  ),
                )),

            const SizedBox(height: MadarTheme.space16),

            // Account details field
            MadarTextField(
              label: _getAccountLabel(),
              hint: _getAccountHint(),
              controller: _accountController,
              prefixIcon: Icons.account_balance,
              textDirection: TextDirection.ltr,
            ),

            // Local error
            if (_localError != null) ...[
              const SizedBox(height: MadarTheme.space12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(MadarTheme.space8),
                decoration: BoxDecoration(
                  color: MadarTheme.error.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(MadarTheme.radiusSm),
                ),
                child: Text(
                  _localError!,
                  style: const TextStyle(
                    color: MadarTheme.error,
                    fontSize: 12,
                    fontFamily: MadarTheme.fontFamily,
                  ),
                ),
              ),
            ],

            const SizedBox(height: MadarTheme.space24),

            // Submit button
            MadarGradientButton(
              label: 'تأكيد طلب السحب',
              isLoading: _isLoading,
              gradientColors: const [MadarTheme.primary, MadarTheme.primaryDark],
              onPressed: _isLoading ? null : _submitWithdrawal,
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
        WithdrawalMethod.bankTransfer => 'تحويل بنكي',
        WithdrawalMethod.mobileWallet => 'محفظة إلكترونية',
        WithdrawalMethod.cash => 'استلام نقدي',
      };

  String _getMethodDescription(WithdrawalMethod method) => switch (method) {
        WithdrawalMethod.bankTransfer => 'تحويل لحسابك البنكي (1-3 أيام عمل)',
        WithdrawalMethod.mobileWallet => 'تحويل فوري للمحفظة الإلكترونية',
        WithdrawalMethod.cash => 'استلام من موقع معتمد',
      };

  String _getAccountLabel() => switch (_selectedMethod) {
        WithdrawalMethod.bankTransfer => 'رقم الآيبان / الحساب',
        WithdrawalMethod.mobileWallet => 'رقم المحفظة',
        WithdrawalMethod.cash => 'رقم الهوية',
      };

  String _getAccountHint() => switch (_selectedMethod) {
        WithdrawalMethod.bankTransfer => 'مثال: SA0380000000608010167519',
        WithdrawalMethod.mobileWallet => 'مثال: 05XXXXXXXX',
        WithdrawalMethod.cash => 'مثال: 1234567890',
      };

  Future<void> _submitWithdrawal() async {
    final amount = double.tryParse(_amountController.text) ?? 0;
    final accountDetails = _accountController.text.trim();

    if (amount <= 0) {
      setState(() => _localError = 'يرجى إدخال مبلغ صالح');
      return;
    }

    if (amount < AppConstants.minimumWithdrawalAmount) {
      setState(() {
        _localError =
            'الحد الأدنى للسحب ر.ي ${AppConstants.minimumWithdrawalAmount.toStringAsFixed(0)}';
      });
      return;
    }

    if (amount > AppConstants.maximumWithdrawalAmount) {
      setState(() {
        _localError =
            'الحد الأقصى للسحب ر.ي ${AppConstants.maximumWithdrawalAmount.toStringAsFixed(0)}';
      });
      return;
    }

    if (accountDetails.isEmpty) {
      setState(() => _localError = 'يرجى إدخال تفاصيل الحساب');
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
            content: const Text(
              'تم تقديم طلب السحب بنجاح',
              style: TextStyle(fontFamily: MadarTheme.fontFamily),
            ),
            backgroundColor: MadarTheme.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(MadarTheme.radiusMd),
            ),
          ),
        );
      } else {
        final error = ref.read(driverWalletProvider).error;
        setState(() => _localError = error ?? 'فشل طلب السحب');
      }
    }
  }
}

