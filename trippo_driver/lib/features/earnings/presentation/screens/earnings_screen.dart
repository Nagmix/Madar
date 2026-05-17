import 'package:flutter/material.dart';
import 'package:trippo_shared/trippo_shared.dart';

/// شاشة الأرباح - مدار
class DriverEarningsScreen extends StatefulWidget {
  const DriverEarningsScreen({super.key});

  @override
  State<DriverEarningsScreen> createState() => _DriverEarningsScreenState();
}

class _DriverEarningsScreenState extends State<DriverEarningsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedPeriod = 'today';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MadarTheme.background,
      appBar: AppBar(
        backgroundColor: MadarTheme.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        title: const Text(
          'الأرباح',
          style: TextStyle(
            fontFamily: MadarTheme.fontFamily,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: MadarTheme.primary,
          unselectedLabelColor: MadarTheme.textSecondary,
          indicatorColor: MadarTheme.primary,
          indicatorSize: TabBarIndicatorSize.tab,
          labelStyle: const TextStyle(
            fontFamily: MadarTheme.fontFamily,
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
          unselectedLabelStyle: const TextStyle(
            fontFamily: MadarTheme.fontFamily,
            fontWeight: FontWeight.w400,
            fontSize: 14,
          ),
          tabs: const [
            Tab(text: 'اليوم'),
            Tab(text: 'هذا الأسبوع'),
            Tab(text: 'هذا الشهر'),
          ],
          onTap: (index) {
            setState(() {
              _selectedPeriod = switch (index) {
                0 => 'today',
                1 => 'week',
                2 => 'month',
                _ => 'today'
              };
            });
          },
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildEarningsContent('today'),
          _buildEarningsContent('week'),
          _buildEarningsContent('month'),
        ],
      ),
    );
  }

  Widget _buildEarningsContent(String period) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(MadarTheme.space16),
      child: Column(
        children: [
          // Main earnings card with dark gradient
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(MadarTheme.space24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [MadarTheme.darkSurface, Color(0xFF16213E)],
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
              ),
              borderRadius: BorderRadius.circular(MadarTheme.radiusXl),
              boxShadow: [
                MadarTheme.shadow(
                  color: MadarTheme.darkSurface.withOpacity(0.4),
                  blur: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  period == 'today'
                      ? 'أرباح اليوم'
                      : period == 'week'
                          ? 'أرباح الأسبوع'
                          : 'أرباح الشهر',
                  style: const TextStyle(
                    fontFamily: MadarTheme.fontFamily,
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                const MadarPriceTag(
                  amount: 85.50,
                  fontSize: 40,
                  currency: 'ر.س',
                  color: Colors.white,
                ),
                const SizedBox(height: MadarTheme.space20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStatColumn('الرحلات', '8', Icons.route, Colors.white54),
                    _buildStatColumn('الساعات', '5.2', Icons.schedule, Colors.white54),
                    _buildStatColumn('متوسط/رحلة', 'ر.س 10.69', Icons.trending_up, Colors.white54),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: MadarTheme.space24),

          // Earnings breakdown
          MadarCard(
            padding: const EdgeInsets.all(MadarTheme.space20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'التفاصيل',
                  style: TextStyle(
                    fontFamily: MadarTheme.fontFamily,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: MadarTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: MadarTheme.space16),
                _buildBreakdownRow(
                  Icons.attach_money,
                  'أجرة الرحلات',
                  'ر.س 106.88',
                  isPositive: true,
                ),
                _buildBreakdownRow(
                  Icons.percent,
                  'العمولة (20%)',
                  '-ر.س 21.38',
                  isPositive: false,
                ),
                _buildBreakdownRow(
                  Icons.card_giftcard,
                  'الحوافز',
                  '+ر.س 5.00',
                  isPositive: true,
                ),
                _buildBreakdownRow(
                  Icons.access_time,
                  'رسوم الانتظار',
                  '+ر.س 2.50',
                  isPositive: true,
                ),
                const Divider(height: MadarTheme.space24),
                _buildBreakdownRow(
                  Icons.account_balance_wallet,
                  'صافي الأرباح',
                  'ر.س 85.50',
                  isPositive: true,
                  isBold: true,
                ),
              ],
            ),
          ),

          const SizedBox(height: MadarTheme.space20),

          // Commission info
          Container(
            padding: const EdgeInsets.all(MadarTheme.space16),
            decoration: BoxDecoration(
              color: MadarTheme.primary.withOpacity(0.06),
              borderRadius: BorderRadius.circular(MadarTheme.radiusMd),
              border: Border.all(color: MadarTheme.primary.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: MadarTheme.primary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(MadarTheme.radiusSm),
                  ),
                  child: const Icon(Icons.info_outline,
                      color: MadarTheme.primary, size: 18),
                ),
                const SizedBox(width: MadarTheme.space12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'نسبة العمولة: 20%',
                        style: TextStyle(
                          fontFamily: MadarTheme.fontFamily,
                          fontWeight: FontWeight.w600,
                          color: MadarTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'تُخصم العمولة تلقائياً من أجرة كل رحلة',
                        style: TextStyle(
                          fontFamily: MadarTheme.fontFamily,
                          fontSize: 12,
                          color: MadarTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: MadarTheme.space20),

          // Incentive progress
          Container(
            padding: const EdgeInsets.all(MadarTheme.space16),
            decoration: BoxDecoration(
              color: MadarTheme.accent.withOpacity(0.06),
              borderRadius: BorderRadius.circular(MadarTheme.radiusMd),
              border: Border.all(color: MadarTheme.accent.withOpacity(0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.card_giftcard, color: MadarTheme.accent),
                    const SizedBox(width: 8),
                    const Text(
                      'تقدم الحوافز',
                      style: TextStyle(
                        fontFamily: MadarTheme.fontFamily,
                        fontWeight: FontWeight.w600,
                        color: MadarTheme.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: MadarTheme.space12),
                const Text(
                  'أكمل 10 رحلات اليوم للحصول على مكافأة ر.س 15',
                  style: TextStyle(
                    fontFamily: MadarTheme.fontFamily,
                    color: MadarTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: MadarTheme.space8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: 0.8,
                    backgroundColor: MadarTheme.textHint.withOpacity(0.2),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                        MadarTheme.accent),
                    minHeight: 8,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '8/10 رحلات مكتملة',
                  style: TextStyle(
                    fontFamily: MadarTheme.fontFamily,
                    fontSize: 12,
                    color: MadarTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String label, String value, IconData icon, Color iconColor) {
    return Column(
      children: [
        Icon(icon, color: iconColor, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontFamily: MadarTheme.fontFamily,
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontFamily: MadarTheme.fontFamily,
            color: iconColor,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _buildBreakdownRow(
    IconData icon,
    String label,
    String value, {
    required bool isPositive,
    bool isBold = false,
  }) {
    final valueColor = isPositive ? MadarTheme.success : MadarTheme.error;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: MadarTheme.space8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: (isPositive ? MadarTheme.success : MadarTheme.error)
                  .withOpacity(0.1),
              borderRadius: BorderRadius.circular(MadarTheme.radiusSm),
            ),
            child: Icon(icon, size: 16, color: valueColor),
          ),
          const SizedBox(width: MadarTheme.space12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontFamily: MadarTheme.fontFamily,
                fontWeight: isBold ? FontWeight.w700 : FontWeight.w400,
                color: MadarTheme.textPrimary,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontFamily: MadarTheme.fontFamily,
              fontWeight: isBold ? FontWeight.w700 : FontWeight.w600,
              color: isBold ? MadarTheme.primary : valueColor,
            ),
          ),
        ],
      ),
    );
  }
}

