import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../onboarding/providers/user_profile_provider.dart';

/// Category selector for transactions
class CategorySelector extends StatefulWidget {
  final String selectedCategory;
  final bool isIncome;
  final ValueChanged<String> onCategoryChanged;

  const CategorySelector({
    required this.selectedCategory,
    required this.isIncome,
    required this.onCategoryChanged,
    super.key,
  });

  @override
  State<CategorySelector> createState() => _CategorySelectorState();
}

class _CategorySelectorState extends State<CategorySelector> {
  // Default income categories
  static const List<String> incomeCategories = [
    'Salary',
    'Freelance',
    'Investment',
    'Bonus',
    'Gift',
    'Other',
  ];

  // Default expense categories for fallback - MUST match survey category names exactly
  static const List<String> defaultExpenseCategories = [
    'Food',
    'Housing',
    'Transport',
    'Entertainment',
    'Education',
    'Health',
    'Shopping',
    'Subscriptions',
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Get current categories based on income/expense
    List<String> currentCategories;
    if (widget.isIncome) {
      currentCategories = incomeCategories;
    } else {
      // For expenses, use default categories
      currentCategories = defaultExpenseCategories;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Category',
          style: AppTextStyles.bodyLarge.copyWith(
            fontWeight: FontWeight.w600,
            color: isDark
                ? AppColors.darkTextPrimary
                : AppColors.lightTextPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: currentCategories.map((cat) {
            final isSelected = widget.selectedCategory == cat;
            return GestureDetector(
              onTap: () => widget.onCategoryChanged(cat),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: isSelected
                      ? AppColors.primary.withOpacity(0.2)
                      : (isDark ? AppColors.darkCard : AppColors.lightCard),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primary
                        : (isDark
                              ? AppColors.darkDivider
                              : AppColors.lightDivider),
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Text(
                  cat,
                  style: AppTextStyles.label.copyWith(
                    fontWeight: isSelected
                        ? FontWeight.w600
                        : FontWeight.normal,
                    color: isSelected
                        ? AppColors.primary
                        : (isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
