import 'package:flutter/material.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/radius.dart';
import '../../../core/theme/shadows.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/theme/text_styles.dart';
import 'financial_stat_card.dart';

/// Total balance summary card with income and expense stats
class BalanceSummaryCard extends StatefulWidget {
  final double totalBalance;
  final double totalIncome;
  final double totalExpenses;

  const BalanceSummaryCard({
    required this.totalBalance,
    required this.totalIncome,
    required this.totalExpenses,
    super.key,
  });

  @override
  State<BalanceSummaryCard> createState() => _BalanceSummaryCardState();
}

class _BalanceSummaryCardState extends State<BalanceSummaryCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _formatBalance(double amount) {
    if (amount >= 1000000) {
      return '₱${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '₱${(amount / 1000).toStringAsFixed(1)}K';
    }
    return '₱${amount.toStringAsFixed(2)}';
  }

  @override
  Widget build(BuildContext context) {
    final isNegative = widget.totalBalance < 0;

    return SlideTransition(
      position: Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
          .animate(
            CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
          ),
      child: FadeTransition(
        opacity: _controller,
        child: Container(
          margin: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenPadding,
            vertical: AppSpacing.lg,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.xxl),
            gradient: LinearGradient(
              colors: [AppColors.primary, AppColors.primaryLight],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: AppShadows.floating,
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xxl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Label
                Text(
                  'Total Balance',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: Colors.white.withOpacity(0.85),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                // Balance amount
                Text(
                  _formatBalance(widget.totalBalance),
                  style: AppTextStyles.balanceXL.copyWith(
                    color: isNegative
                        ? AppColors.expense.withOpacity(0.9)
                        : Colors.white,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl),
                // Stat cards row
                Row(
                  children: [
                    Expanded(
                      child: FinancialStatCard(
                        label: 'Income',
                        amount: widget.totalIncome,
                        icon: Icons.trending_up,
                        accentColor: AppColors.income,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: FinancialStatCard(
                        label: 'Expenses',
                        amount: widget.totalExpenses,
                        icon: Icons.trending_down,
                        accentColor: AppColors.expense,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
