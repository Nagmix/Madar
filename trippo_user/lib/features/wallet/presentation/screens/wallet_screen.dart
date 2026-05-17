import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trippo_shared/trippo_shared.dart';
import '../notifiers/wallet_notifier.dart';

/// شاشة المحفظة - مدار
class WalletScreen extends ConsumerWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final walletState = ref.watch(walletProvider);

    return Scaffold(
      appBar: MadarAppBar(
        title: 'المحفظة',
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => _showTransactionHistory(context),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(walletProvider.notifier).loadBalance(),
        color: MadarTheme.primary,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(MadarTheme.space16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildBalanceCard(walletState),
              const SizedBox(height: MadarTheme.space24),
              _buildQuickActions(context, ref),
              const SizedBox(height: MadarTheme.space24),
              _buildRecentTransactions(context, walletState),
              const SizedBox(height: MadarTheme.space24),
              if (walletState.settlements.isNotEmpty)
                _buildRecentSettlements(walletState),
            ],
          ),
        ),
      ),
    );
  }

  // ── بطاقة الرصيد ──
  Widget _buildBalanceCard(WalletState state) {
    final wallet = state.wallet;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(MadarTheme.space24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [MadarTheme.primary, MadarTheme.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(MadarTheme.radiusXl),
        boxShadow: [
          MadarTheme.shadow(
            color: MadarTheme.primary.withOpacity(0.3),
            blur: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'الرصيد المتاح',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 14,
              fontFamily: MadarTheme.fontFamily,
            ),
          ),
          const SizedBox(height: 8),
          MadarPriceTag(
            amount: wallet?.availableBalance ?? 0,
            currency: 'ر.س',
            fontSize: 36,
            color: Colors.white,
          ),
          const SizedBox(height: MadarTheme.space16),
          const Divider(color: Colors.white24),
          const SizedBox(height: MadarTheme.space12),
          Row(
            children: [
              Expanded(
                child: _buildBalanceInfo(
                  'قيد الانتظار',
                  '${(wallet?.pendingBalance ?? 0).toStringAsFixed(2)} ر.س',
                ),
              ),
              Container(
                width: 1,
                height: 32,
                color: Colors.white24,
              ),
              Expanded(
                child: _buildBalanceInfo(
                  'إجمالي الأرباح',
                  '${(wallet?.totalEarnings ?? 0).toStringAsFixed(2)} ر.س',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceInfo(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 12,
            fontFamily: MadarTheme.fontFamily,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            fontFamily: MadarTheme.fontFamily,
          ),
        ),
      ],
    );
  }

  // ── الإجراءات السريعة ──
  Widget _buildQuickActions(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'إجراءات سريعة',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            fontFamily: MadarTheme.fontFamily,
            color: MadarTheme.textPrimary,
          ),
        ),
        const SizedBox(height: MadarTheme.space12),
        Row(
          children: [
            _buildActionButton(
              icon: Icons.add_circle_outline,
              label: 'إضافة رصيد',
              color: MadarTheme.primary,
              onTap: () {},
            ),
            const SizedBox(width: MadarTheme.space12),
            _buildActionButton(
              icon: Icons.arrow_outward,
              label: 'سحب',
              color: MadarTheme.accent,
              onTap: () => _showWithdrawSheet(context, ref),
            ),
            const SizedBox(width: MadarTheme.space12),
            _buildActionButton(
              icon: Icons.send_outlined,
              label: 'إرسال',
              color: MadarTheme.secondary,
              onTap: () {},
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(MadarTheme.radiusLg),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: MadarTheme.space16),
          decoration: BoxDecoration(
            color: color.withOpacity(0.06),
            borderRadius: BorderRadius.circular(MadarTheme.radiusLg),
            border: Border.all(color: color.withOpacity(0.15)),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                  fontFamily: MadarTheme.fontFamily,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── المعاملات الأخيرة ──
  Widget _buildRecentTransactions(BuildContext context, WalletState state) {
    if (state.transactions.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'المعاملات الأخيرة',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                fontFamily: MadarTheme.fontFamily,
                color: MadarTheme.textPrimary,
              ),
            ),
            TextButton(
              onPressed: () => _showTransactionHistory(context),
              child: Text(
                'عرض الكل',
                style: TextStyle(
                  color: MadarTheme.primary,
                  fontFamily: MadarTheme.fontFamily,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...state.transactions.take(5).map((tx) => _buildTransactionItem(tx)),
      ],
    );
  }

  Widget _buildTransactionItem(WalletTransaction tx) {
    final isCredit = tx.type == TransactionType.tripEarning ||
        tx.type == TransactionType.incentiveBonus ||
        tx.type == TransactionType.refund;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.all(MadarTheme.space12),
        decoration: BoxDecoration(
          color: MadarTheme.background,
          borderRadius: BorderRadius.circular(MadarTheme.radiusLg),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: (isCredit ? MadarTheme.success : MadarTheme.error)
                    .withOpacity(0.1),
                borderRadius: BorderRadius.circular(MadarTheme.radiusMd),
              ),
              child: Icon(
                isCredit ? Icons.arrow_downward : Icons.arrow_upward,
                color: isCredit ? MadarTheme.success : MadarTheme.error,
                size: 20,
              ),
            ),
            const SizedBox(width: MadarTheme.space12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tx.description,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                      fontFamily: MadarTheme.fontFamily,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    _formatDate(tx.createdAt),
                    style: TextStyle(
                      color: MadarTheme.textSecondary,
                      fontSize: 11,
                      fontFamily: MadarTheme.fontFamily,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '${isCredit ? '+' : '-'}${tx.amount.toStringAsFixed(2)} ر.س',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontFamily: MadarTheme.fontFamily,
                color: isCredit ? MadarTheme.success : MadarTheme.error,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentSettlements(WalletState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'التسويات',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            fontFamily: MadarTheme.fontFamily,
            color: MadarTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        ...state.settlements.take(3).map(
              (s) => ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.check_circle, color: MadarTheme.success),
                title: Text('الفترة: ${s.period}'),
                subtitle: Text('الصافي: ${s.netAmount.toStringAsFixed(2)} ر.س'),
                trailing: Text(s.status.name),
              ),
            ),
      ],
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showWithdrawSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(MadarTheme.radiusXxl)),
      ),
      builder: (context) => const _WithdrawSheet(),
    );
  }

  void _showTransactionHistory(BuildContext context) {
    // Navigate to full transaction history
  }
}

// ─────────────────────────────────────────────────────────────
// ورقة السحب
// ─────────────────────────────────────────────────────────────
class _WithdrawSheet extends ConsumerStatefulWidget {
  const _WithdrawSheet();

  @override
  ConsumerState<_WithdrawSheet> createState() => _WithdrawSheetState();
}

class _WithdrawSheetState extends ConsumerState<_WithdrawSheet> {
  final _amountController = TextEditingController();
  WithdrawalMethod _selectedMethod = WithdrawalMethod.bankTransfer;
  final _accountController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _amountController.dispose();
    _accountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final wallet = ref.watch(walletProvider).wallet;
    final availableBalance = wallet?.availableBalance ?? 0;

    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'طلب سحب',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: MadarTheme.fontFamily,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(MadarTheme.space16),
            decoration: BoxDecoration(
              color: MadarTheme.primary.withOpacity(0.06),
              borderRadius: BorderRadius.circular(MadarTheme.radiusLg),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'الرصيد المتاح',
                  style: TextStyle(
                    fontSize: 14,
                    fontFamily: MadarTheme.fontFamily,
                  ),
                ),
                Text(
                  '${availableBalance.toStringAsFixed(2)} ر.س',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: MadarTheme.primary,
                    fontFamily: MadarTheme.fontFamily,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _amountController,
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: 'المبلغ',
              prefixText: 'ر.س ',
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(MadarTheme.radiusMd)),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'طريقة السحب',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontFamily: MadarTheme.fontFamily,
            ),
          ),
          const SizedBox(height: 8),
          ...WithdrawalMethod.values.map(
            (method) => RadioListTile<WithdrawalMethod>(
              value: method,
              groupValue: _selectedMethod,
              onChanged: (v) => setState(() => _selectedMethod = v!),
              title: Text(_getMethodLabel(method)),
              contentPadding: EdgeInsets.zero,
              dense: true,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _accountController,
            decoration: InputDecoration(
              labelText: _getAccountLabel(),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(MadarTheme.radiusMd)),
            ),
          ),
          const SizedBox(height: 24),
          MadarGradientButton(
            label: 'تقديم طلب السحب',
            onPressed: _isLoading ? null : _submitWithdrawal,
            isLoading: _isLoading,
            gradientColors: const [MadarTheme.primary, MadarTheme.primaryDark],
          ),
        ],
      ),
    );
  }

  String _getMethodLabel(WithdrawalMethod method) => switch (method) {
        WithdrawalMethod.bankTransfer => 'تحويل بنكي',
        WithdrawalMethod.mobileWallet => 'محفظة إلكترونية',
        WithdrawalMethod.cash => 'استلام نقدي',
      };

  String _getAccountLabel() => switch (_selectedMethod) {
        WithdrawalMethod.bankTransfer => 'رقم الآيبان / الحساب',
        WithdrawalMethod.mobileWallet => 'رقم المحفظة الإلكترونية',
        WithdrawalMethod.cash => 'رقم الهوية',
      };

  Future<void> _submitWithdrawal() async {
    final amount = double.tryParse(_amountController.text) ?? 0;
    if (amount <= 0 || _accountController.text.isEmpty) return;

    setState(() => _isLoading = true);

    final success = await ref.read(walletProvider.notifier).requestWithdrawal(
          amount: amount,
          method: _selectedMethod,
          accountDetails: _accountController.text,
        );

    if (mounted) {
      setState(() => _isLoading = false);
      if (success) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم تقديم طلب السحب بنجاح'),
          ),
        );
      }
    }
  }
}

