import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/radius.dart';
import '../../../core/theme/shadows.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/theme/text_styles.dart';
import '../../onboarding/providers/user_profile_provider.dart';
import '../../../providers/transaction_provider.dart';
import '../controllers/budget_controller.dart';
import '../widgets/monthly_summary_card.dart';
import '../widgets/category_budget_card.dart';
import '../../home/widgets/modern_bottom_nav_bar.dart';
import '../../home/widgets/floating_add_button.dart';
import '../../transaction/screens/add_transaction_modal.dart';

/// Modern budget tracking screen
class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  late BudgetController _controller;
  final ScrollController _scrollController = ScrollController();

  // Category definitions with icons and colors - MUST match survey category names exactly
  final Map<String, Map<String, dynamic>> categoryDefinitions = {
    'Food': {'icon': Icons.restaurant, 'color': const Color(0xFFFF6B6B)},
    'Housing': {'icon': Icons.home, 'color': const Color(0xFF845EC2)},
    'Transport': {
      'icon': Icons.directions_car,
      'color': const Color(0xFF4ECDC4),
    },
    'Entertainment': {'icon': Icons.movie, 'color': const Color(0xFFFFE66D)},
    'Education': {'icon': Icons.school, 'color': const Color(0xFF6C5CE7)},
    'Health': {'icon': Icons.favorite, 'color': const Color(0xFFD65DB1)},
    'Shopping': {'icon': Icons.shopping_bag, 'color': const Color(0xFFC44569)},
    'Subscriptions': {
      'icon': Icons.subscriptions,
      'color': const Color(0xFFFF6F91),
    },
  };

  @override
  void initState() {
    super.initState();
    _controller = BudgetController();
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  String _getCurrentMonthYear() {
    return DateFormat('MMMM yyyy').format(DateTime.now());
  }

  void _onAddTransactionTap() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AddTransactionModal(),
    );
  }

  void _onNavTabChanged(int index) {
    _controller.setSelectedNavIndex(index);

    // Navigate to different screens based on tab index
    switch (index) {
      case 0:
        // Home tab
        Navigator.pushNamed(context, '/home');
        break;
      case 1:
        // Budget tab - already on budget screen
        break;
      case 2:
        // Activity tab - TODO: Navigate to activity screen
        Navigator.pushNamed(context, '/activity');
        break;
      case 3:
        // Advisor tab - Navigate to chat advisor
        Navigator.pushNamed(context, '/chat');
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final profile = context.watch<UserProfileProvider>().profile;
    final txProvider = context.watch<TransactionProvider>();
    final userName = profile?.userName ?? 'Friend';

    // Get data from profile survey
    final monthlyBudget = profile?.monthlyBudget ?? 50000.00;
    final currentFunds = profile?.currentFunds ?? 0.00;
    final spendingCategories = profile?.spendingCategories ?? [];

    print('DEBUG Budget Screen:');
    print('  Profile: $profile');
    print('  Monthly Budget: $monthlyBudget');
    print('  Spending Categories: $spendingCategories');
    print('  Transaction Count: ${txProvider.items.length}');

    // Build categories list from survey data with actual spending
    final categories = _buildCategoriesFromSurvey(
      spendingCategories,
      txProvider.items,
      monthlyBudget,
    );

    // Calculate total spent from categories
    final totalSpent = categories.fold<double>(
      0.0,
      (sum, category) => sum + (category['spent'] as double? ?? 0.0),
    );

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.darkBackground
          : AppColors.lightBackground,
      body: Stack(
        children: [
          // Main scrollable content
          CustomScrollView(
            controller: _scrollController,
            slivers: [
              // Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.screenPadding,
                    AppSpacing.headerTop,
                    AppSpacing.screenPadding,
                    AppSpacing.lg,
                  ),
                  child: _BudgetHeader(
                    userName: userName,
                    screenTitle: 'Budget Overview',
                  ),
                ),
              ),
              // Content
              SliverToBoxAdapter(
                child: _buildMainContent(
                  isDark,
                  categories,
                  monthlyBudget,
                  totalSpent,
                ),
              ),
              // Bottom spacing for FAB and nav
              const SliverPadding(
                padding: EdgeInsets.only(bottom: AppSpacing.navClearance),
              ),
            ],
          ),
          // Floating Add Button
          Positioned(
            bottom: AppSpacing.fabOffset,
            left: 0,
            right: 0,
            child: Center(
              child: FloatingAddButton(onPressed: _onAddTransactionTap),
            ),
          ),
          // Bottom Navigation
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: ModernBottomNavBar(
              selectedIndex: _controller.selectedNavIndex,
              onTabChanged: _onNavTabChanged,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent(
    bool isDark,
    List<Map<String, dynamic>> categories,
    double monthlyBudget,
    double totalSpent,
  ) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          // Monthly Summary Card
          MonthlySummaryCard(
            totalBudget: monthlyBudget,
            amountSpent: totalSpent,
            monthYear: _getCurrentMonthYear(),
          ),

          // Categories Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Text(
              'Categories',
              style: AppTextStyles.bodyLarge.copyWith(
                fontWeight: FontWeight.bold,
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.lightTextPrimary,
              ),
            ),
          ),

          // Category Cards List
          ...List.generate(categories.length, (index) {
            final category = categories[index];
            return CategoryBudgetCard(
              categoryName: category['name'],
              amountSpent: category['spent'],
              budgetLimit: category['limit'],
              icon: category['icon'],
              accentColor: category['color'],
              animationDelay: 100 * (index + 1),
            );
          }),

          // Bottom spacing
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _buildCategoriesFromSurvey(
    List<String> spendingCategories,
    List<dynamic> transactions,
    double monthlyBudget,
  ) {
    final List<Map<String, dynamic>> result = [];

    // Default category allocation if no spending categories from survey
    if (spendingCategories.isEmpty) {
      return [];
    }

    // Calculate budget allocation per category
    final budgetPerCategory = monthlyBudget / spendingCategories.length;

    // Build categories from survey data with actual spending
    for (final categoryName in spendingCategories) {
      final definition = categoryDefinitions[categoryName];

      if (definition != null) {
        // Calculate actual spending for this category from transactions
        double spentAmount = 0.0;
        for (final tx in transactions) {
          if (tx.category == categoryName && tx.type == 'expense') {
            spentAmount += tx.amount;
          }
        }

        result.add({
          'name': categoryName,
          'spent': spentAmount,
          'limit': budgetPerCategory,
          'icon': definition['icon'] as IconData,
          'color': definition['color'] as Color,
        });
      }
    }

    return result;
  }
}

class _BudgetHeader extends StatelessWidget {
  const _BudgetHeader({required this.userName, required this.screenTitle});

  final String userName;
  final String screenTitle;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark
        ? AppColors.darkTextPrimary
        : AppColors.lightTextPrimary;
    final textSecondary = isDark
        ? AppColors.darkTextSecondary
        : AppColors.lightTextSecondary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: AppColors.primaryLight,
              child: Text(
                userName.isNotEmpty ? userName[0].toUpperCase() : 'B',
                style: const TextStyle(
                  color: AppColors.primaryDark,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome back,',
                    style: AppTextStyles.label.copyWith(color: textSecondary),
                  ),
                  Text(
                    userName,
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                      color: textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(AppRadius.input),
                    boxShadow: AppShadows.subtle,
                  ),
                  child: IconButton(
                    onPressed: () {},
                    icon: Icon(
                      Icons.notifications_outlined,
                      color: textPrimary,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(AppRadius.input),
                    boxShadow: AppShadows.subtle,
                  ),
                  child: IconButton(
                    onPressed: () =>
                        Navigator.of(context).pushNamed('/settings'),
                    icon: Icon(Icons.settings_outlined, color: textPrimary),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xl),
        Text(
          screenTitle,
          style: AppTextStyles.headlineMedium.copyWith(
            color: textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
