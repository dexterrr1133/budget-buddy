import 'package:flutter/material.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/radius.dart';
import '../../../core/theme/shadows.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/theme/text_styles.dart';

/// Individual category budget card with progress tracking
class CategoryBudgetCard extends StatefulWidget {
  final String categoryName;
  final double amountSpent;
  final double budgetLimit;
  final IconData icon;
  final Color accentColor;
  final int animationDelay;

  const CategoryBudgetCard({
    required this.categoryName,
    required this.amountSpent,
    required this.budgetLimit,
    required this.icon,
    required this.accentColor,
    this.animationDelay = 0,
    super.key,
  });

  @override
  State<CategoryBudgetCard> createState() => _CategoryBudgetCardState();
}

class _CategoryBudgetCardState extends State<CategoryBudgetCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _slideController;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    Future.delayed(Duration(milliseconds: widget.animationDelay), () {
      if (mounted) _slideController.forward();
    });
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  String _formatAmount(double amount) {
    if (amount >= 1000000) {
      return '₱${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '₱${(amount / 1000).toStringAsFixed(1)}K';
    }
    return '₱${amount.toStringAsFixed(0)}';
  }

  double get _percentageUsed {
    if (widget.budgetLimit == 0) return 0;
    return (widget.amountSpent / widget.budgetLimit).clamp(0, 1);
  }

  bool get _isOverBudget => widget.amountSpent > widget.budgetLimit;

  Color _getProgressColor() {
    if (_isOverBudget) return AppColors.expense;
    if (_percentageUsed > 0.8) return AppColors.warning;
    return AppColors.income;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SlideTransition(
      position: Tween<Offset>(begin: const Offset(0.3, 0), end: Offset.zero)
          .animate(
            CurvedAnimation(
              parent: _slideController,
              curve: Curves.easeOutCubic,
            ),
          ),
      child: FadeTransition(
        opacity: _slideController,
        child: Container(
          margin: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenPadding,
            vertical: AppSpacing.sm,
          ),
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.card),
            color: isDark ? AppColors.darkCard : AppColors.lightCard,
            border: Border.all(
              color: _isOverBudget
                  ? AppColors.expense.withOpacity(0.3)
                  : (isDark
                        ? AppColors.darkDivider.withOpacity(0.5)
                        : AppColors.lightDivider),
              width: _isOverBudget ? 1.5 : 1,
            ),
            boxShadow: AppShadows.card(isDark),
          ),
          child: Column(
            children: [
              // Top row with icon, name, and amount
              Row(
                children: [
                  // Icon
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: widget.accentColor.withOpacity(0.15),
                    ),
                    child: Icon(
                      widget.icon,
                      color: widget.accentColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  // Category name and spent
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.categoryName,
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.lightTextPrimary,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.micro),
                        Text(
                          'Spent: ${_formatAmount(widget.amountSpent)}',
                          style: AppTextStyles.label.copyWith(
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.lightTextSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Budget limit
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        _formatAmount(widget.budgetLimit),
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.bold,
                          color: _isOverBudget
                              ? AppColors.expense
                              : (isDark
                                    ? AppColors.darkTextPrimary
                                    : AppColors.lightTextPrimary),
                        ),
                      ),
                      if (_isOverBudget)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.warning_rounded,
                              size: 12,
                              color: AppColors.expense,
                            ),
                            const SizedBox(width: AppSpacing.micro),
                            Text(
                              'Over',
                              style: AppTextStyles.label.copyWith(
                                color: AppColors.expense,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              // Progress bar
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AnimatedBuilder(
                    animation: _slideController,
                    builder: (context, _) {
                      return SizedBox(
                        width: double.infinity,
                        child: Container(
                          height: 6,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(AppRadius.xs),
                            color: isDark
                                ? AppColors.darkDivider
                                : AppColors.lightDivider,
                          ),
                          child: Stack(
                            children: [
                              FractionallySizedBox(
                                widthFactor:
                                    (_percentageUsed * _slideController.value)
                                        .clamp(0, 1),
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(
                                      AppRadius.xs,
                                    ),
                                    color: _getProgressColor(),
                                    boxShadow: [
                                      BoxShadow(
                                        color: _getProgressColor().withOpacity(
                                          0.3,
                                        ),
                                        blurRadius: 6,
                                        offset: const Offset(0, 1),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    '${(_percentageUsed * 100).toStringAsFixed(0)}% used',
                    style: AppTextStyles.label.copyWith(
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
                      fontSize: AppTextStyles.captionSmall.fontSize,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
