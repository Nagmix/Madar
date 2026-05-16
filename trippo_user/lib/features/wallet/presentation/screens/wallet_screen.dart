import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trippo_shared/trippo_shared.dart';
import '../notifiers/wallet_notifier.dart';

/// Wallet Screen - Shows driver wallet balance, transactions, and withdrawal
class WalletScreen extends ConsumerWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final walletState = ref.watch(walletProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Wallet'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => _showTransactionHistory(context),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(walletProvider.notifier).loadBalance(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Balance Card
              _buildBalanceCard(walletState),
              
              const SizedBox(height: 24),
              
              // Quick Actions
              _buildQuickActions(context, ref),
              
              const SizedBox(height: 24),
              
              // Recent Transactions
              _buildRecentTransactions(context, walletState),
              
              const SizedBox(height: 24),
              
              // Recent Settlements
              if (walletState.settlements.isNotEmpty)
                _buildRecentSettlements(walletState),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBalanceCard(WalletState state) {
    final wallet = state.wallet;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF00C853), Color(0xFF009624)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00C853).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Available Balance',
            style: TextStyle(color: Colors.white70, fontSize: 14),
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
          const SizedBox(height: 16),
          Row(
            children: [
              _buildBalanceInfo(
                'Pending',
                '\$${(wallet?.pendingBalance ?? 0).toStringAsFixed(2)}',
              ),
              const SizedBox(width: 24),
              _buildBalanceInfo(
                'Total Earnings',
                '\$${(wallet?.totalEarnings ?? 0).toStringAsFixed(2)}',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceInfo(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        _buildActionButton(
          icon: Icons.money_off,
          label: 'Withdraw',
          color: Colors.green,
          onTap: () => _showWithdrawSheet(context, ref),
        ),
        const SizedBox(width: 12),
        _buildActionButton(
          icon: Icons.receipt_long,
          label: 'Settlements',
          color: Colors.blue,
          onTap: () => _showSettlements(context),
        ),
        const SizedBox(width: 12),
        _buildActionButton(
          icon: Icons.card_giftcard,
          label: 'Incentives',
          color: Colors.orange,
          onTap: () {},
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
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentTransactions(BuildContext context, WalletState state) {
    if (state.transactions.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Recent Transactions', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            TextButton(
              onPressed: () => _showTransactionHistory(context),
              child: const Text('View All'),
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
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: (isCredit ? Colors.green : Colors.red).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                isCredit ? Icons.arrow_downward : Icons.arrow_upward,
                color: isCredit ? Colors.green : Colors.red,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tx.description,
                    style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    _formatDate(tx.createdAt),
                    style: TextStyle(color: Colors.grey[500], fontSize: 11),
                  ),
                ],
              ),
            ),
            Text(
              '${isCredit ? '+' : '-'}\$${tx.amount.toStringAsFixed(2)}',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isCredit ? Colors.green : Colors.red,
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
        const Text('Settlements', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        ...state.settlements.take(3).map((s) => ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.check_circle, color: Colors.green),
          title: Text('Period: ${s.period}'),
          subtitle: Text('Net: \$${s.netAmount.toStringAsFixed(2)}'),
          trailing: Text(s.status.name),
        )),
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
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => const _WithdrawSheet(),
    );
  }

  void _showTransactionHistory(BuildContext context) {
    // Navigate to full transaction history
  }

  void _showSettlements(BuildContext context) {
    // Navigate to settlements screen
  }
}

/// Withdrawal Bottom Sheet
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
        left: 24, right: 24, top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Request Withdrawal', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Available balance
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Available', style: TextStyle(fontSize: 14)),
                Text(
                  '\$${availableBalance.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Amount
          TextField(
            controller: _amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: 'Amount',
              prefixText: '\$ ',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Withdrawal method
          const Text('Withdrawal Method', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          ...WithdrawalMethod.values.map((method) => RadioListTile<WithdrawalMethod>(
            value: method,
            groupValue: _selectedMethod,
            onChanged: (v) => setState(() => _selectedMethod = v!),
            title: Text(_getMethodLabel(method)),
            contentPadding: EdgeInsets.zero,
            dense: true,
          )),
          
          const SizedBox(height: 16),
          
          // Account details
          TextField(
            controller: _accountController,
            decoration: InputDecoration(
              labelText: _getAccountLabel(),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Submit
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _submitWithdrawal,
              child: _isLoading
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Submit Withdrawal Request'),
            ),
          ),
        ],
      ),
    );
  }

  String _getMethodLabel(WithdrawalMethod method) => switch (method) {
    WithdrawalMethod.bankTransfer => 'Bank Transfer',
    WithdrawalMethod.mobileWallet => 'Mobile Wallet',
    WithdrawalMethod.cash => 'Cash Pickup',
  };

  String _getAccountLabel() => switch (_selectedMethod) {
    WithdrawalMethod.bankTransfer => 'IBAN / Account Number',
    WithdrawalMethod.mobileWallet => 'Mobile Wallet Number',
    WithdrawalMethod.cash => 'ID Number',
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
          const SnackBar(content: Text('Withdrawal request submitted successfully')),
        );
      }
    }
  }
}
