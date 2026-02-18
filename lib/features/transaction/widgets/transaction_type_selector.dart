import 'package:flutter/material.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/text_styles.dart';

/// Transaction type selector (Income/Expense)
class TransactionTypeSelector extends StatelessWidget {
  final bool isIncome;
  final ValueChanged<bool> onTypeChanged;

  const TransactionTypeSelector({
    required this.isIncome,
    required this.onTypeChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        border: Border.all(
          color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          // Income button
          Expanded(
            child: GestureDetector(
              onTap: () => onTypeChanged(true),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOutCubic,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: isIncome
                      ? AppColors.income.withAlpha(51)
                      : Colors.transparent,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.trending_up,
                      color: isIncome
                          ? AppColors.income
                          : (isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.lightTextSecondary),
                      size: 18,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Income',
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: isIncome
                            ? FontWeight.w600
                            : FontWeight.normal,
                        color: isIncome
                            ? AppColors.income
                            : (isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.lightTextSecondary),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Expense button
          Expanded(
            child: GestureDetector(
              onTap: () => onTypeChanged(false),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOutCubic,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: !isIncome
                      ? AppColors.expense.withAlpha(51)
                      : Colors.transparent,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.trending_down,
                      color: !isIncome
                          ? AppColors.expense
                          : (isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.lightTextSecondary),
                      size: 18,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Expense',
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: !isIncome
                            ? FontWeight.w600
                            : FontWeight.normal,
                        color: !isIncome
                            ? AppColors.expense
                            : (isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.lightTextSecondary),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
