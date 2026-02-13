import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/colors.dart';
import '../../../core/theme/radius.dart';
import '../../../core/theme/shadows.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/theme/text_styles.dart';
import '../../budget/widgets/category_budget_card.dart';
import '../../budget/widgets/monthly_summary_card.dart';
import '../../onboarding/models/user_profile_model.dart';
import '../../onboarding/providers/user_profile_provider.dart';
import '../../../models/transaction.dart';
import '../../../providers/transaction_provider.dart';
import '../controllers/home_controller.dart';
import '../widgets/home_header_widget.dart';
import '../widgets/balance_summary_card.dart';
import '../widgets/alert_insight_cards.dart';
import '../widgets/transaction_item_widget.dart';
import '../widgets/floating_add_button.dart';
import '../widgets/modern_bottom_nav_bar.dart';

/// Modern financial dashboard home screen
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late HomeController _controller;
  final ScrollController _scrollController = ScrollController();

  final int notificationCount = 2;

  @override
  void initState() {
    super.initState();
    _controller = HomeController();
    _simulateDataLoading();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TransactionProvider>().loadTransactions();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _simulateDataLoading() {
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _controller.setLoading(false);
      }
    });
  }

  void _onNotificationTap() {
    // TODO: Navigate to notifications screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$notificationCount notifications'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _onAddTransactionTap() {
    // TODO: Navigate to add transaction screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Add transaction feature coming soon'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _onSeeAllTap() {
    // TODO: Navigate to full activity/transaction list
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('View all transactions feature coming soon'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _onNavTabChanged(int index) {
    _controller.setSelectedNavIndex(index);

    // Navigate to different screens based on tab index
    switch (index) {
      case 0:
        // Home tab - already on home screen
        break;
      case 1:
        // Budget tab
        Navigator.pushNamed(context, '/budget');
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
    final spendingRatio =
        profile?.monthlyBudget != null && profile!.monthlyBudget! > 0
        ? (txProvider.totalExpense / profile.monthlyBudget!)
              .clamp(0.0, 1.0)
              .toDouble()
        : 0.0;
    final greetingMessage = _buildPersonalizedGreeting(profile, spendingRatio);

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.darkBackground
          : AppColors.lightBackground,
      body: SafeArea(
        bottom: false,
        child: ListenableBuilder(
          listenable: _controller,
          builder: (context, _) {
            return Stack(
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
                        child: _buildStandardHeader(
                          userName,
                          'Dashboard',
                          isDark,
                        ),
                      ),
                    ),
                    // Content
                    SliverToBoxAdapter(
                      child: _controller.isLoading
                          ? _buildLoadingState(isDark)
                          : _buildMainContent(isDark, profile, txProvider),
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
            );
          },
        ),
      ),
    );
  }

  Widget _buildStandardHeader(
    String userName,
    String screenTitle,
    bool isDark,
  ) {
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

  Widget _buildLoadingState(bool isDark) {
    return Column(
      children: [
        // Skeleton loader for balance card
        Container(
          margin: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenPadding,
            vertical: AppSpacing.lg,
          ),
          height: 220,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.xxl),
            color: isDark
                ? AppColors.darkCard.withOpacity(0.5)
                : Colors.grey.withOpacity(0.1),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        // Skeleton loaders for transaction items
        ...List.generate(
          3,
          (index) => Container(
            margin: const EdgeInsets.symmetric(
              horizontal: AppSpacing.screenPadding,
              vertical: AppSpacing.sm,
            ),
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.card),
              color: isDark
                  ? AppColors.darkCard.withOpacity(0.5)
                  : Colors.grey.withOpacity(0.1),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMainContent(
    bool isDark,
    UserProfileModel? profile,
    TransactionProvider txProvider,
  ) {
    // Calculate balance from profile data
    final currentFunds = profile?.currentFunds ?? 0.0;
    final savingsAmount = profile?.savingsAmount ?? 0.0;
    final investmentsAmount = profile?.investmentsAmount ?? 0.0;
    final debtsAmount = profile?.debtsAmount ?? 0.0;

    // Total balance should be: cash + savings + investments - debts
    final totalBalance =
        currentFunds + savingsAmount + investmentsAmount - debtsAmount;
    final totalIncome = txProvider.totalIncome;
    final totalExpenses = txProvider.totalExpense;
    final monthlyBudget = profile?.monthlyBudget ?? 0.0;
    final spendingRatio = monthlyBudget > 0
        ? (totalExpenses / monthlyBudget).clamp(0.0, 1.0).toDouble()
        : 0.0;
    final alertMessage = _buildAlertMessage(
      profile,
      spendingRatio,
      monthlyBudget,
    );
    final insightMessage = _buildInsightMessage(profile, spendingRatio);
    final recentItems = _recentTransactions(txProvider.items);
    final categoryBudgets = _buildCategoryBudgets(profile, txProvider.items);

    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Balance Summary Card
          BalanceSummaryCard(
            totalBalance: totalBalance,
            totalIncome: totalIncome,
            totalExpenses: totalExpenses,
          ),

          // Financial Summary from Profile - Pie Chart
          if (currentFunds > 0 ||
              savingsAmount > 0 ||
              investmentsAmount > 0 ||
              debtsAmount > 0)
            _buildFinancialPieChart(
              isDark,
              currentFunds,
              savingsAmount,
              investmentsAmount,
              debtsAmount,
            ),

          // Alert and Insight Cards
          AlertInsightCards(
            alertMessage: alertMessage,
            insightMessage: insightMessage,
            onAlertTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('View detailed alert'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
            onInsightTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('View detailed insight'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
          ),

          // Budget Overview
          if (monthlyBudget > 0 && categoryBudgets.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenPadding,
                vertical: AppSpacing.lg,
              ),
              child: Text(
                'Budget Overview',
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.lightTextPrimary,
                ),
              ),
            ),
            MonthlySummaryCard(
              totalBudget: monthlyBudget,
              amountSpent: totalExpenses,
              monthYear: _currentMonthLabel(),
            ),
            ...categoryBudgets.map(
              (item) => CategoryBudgetCard(
                categoryName: item.name,
                amountSpent: item.spent,
                budgetLimit: item.limit,
                icon: item.icon,
                accentColor: item.color,
              ),
            ),
          ],

          // Recent Activity Header
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.screenPadding,
              vertical: AppSpacing.xl,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Activity',
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.lightTextPrimary,
                  ),
                ),
                GestureDetector(
                  onTap: _onSeeAllTap,
                  child: Text(
                    'See All',
                    style: AppTextStyles.label.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Transaction List
          ...recentItems.map(
            (transaction) => TransactionItemWidget(
              title: transaction.title,
              category: transaction.category,
              date: transaction.dateLabel,
              amount: transaction.amount,
              isIncome: transaction.isIncome,
              icon: transaction.icon,
            ),
          ),

          // Bottom spacing
          const SizedBox(height: AppSpacing.xxl),
        ],
      ),
    );
  }

  Widget _buildFinancialPieChart(
    bool isDark,
    double currentFunds,
    double savingsAmount,
    double investmentsAmount,
    double debtsAmount,
  ) {
    final total =
        currentFunds + savingsAmount + investmentsAmount + debtsAmount;
    if (total <= 0) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenPadding,
            vertical: AppSpacing.lg,
          ),
          child: Text(
            'Financial Breakdown',
            style: AppTextStyles.bodyLarge.copyWith(
              fontWeight: FontWeight.bold,
              color: isDark
                  ? AppColors.darkTextPrimary
                  : AppColors.lightTextPrimary,
            ),
          ),
        ),
        // Pie Chart with Legend
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenPadding,
            vertical: AppSpacing.lg,
          ),
          child: Column(
            children: [
              // Pie Chart
              Container(
                width: double.infinity,
                height: 200,
                color: isDark
                    ? AppColors.darkCard.withOpacity(0.5)
                    : Colors.grey.withOpacity(0.05),
                child: CustomPaint(
                  painter: _PieChartPainter(
                    values: [
                      currentFunds,
                      savingsAmount,
                      investmentsAmount,
                      debtsAmount,
                    ],
                    colors: [
                      AppColors.primary,
                      AppColors.savings,
                      AppColors.income,
                      AppColors.expense,
                    ],
                  ),
                  size: Size.infinite,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              // Legend
              _buildPieChartLegend(
                isDark,
                currentFunds,
                savingsAmount,
                investmentsAmount,
                debtsAmount,
                total,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPieChartLegend(
    bool isDark,
    double currentFunds,
    double savingsAmount,
    double investmentsAmount,
    double debtsAmount,
    double total,
  ) {
    final formatter = NumberFormat('#,##0.00', 'en_US');
    final textSecondary = isDark
        ? AppColors.darkTextSecondary
        : AppColors.lightTextSecondary;

    final items = [
      ('Cash', currentFunds, AppColors.primary),
      ('Savings', savingsAmount, AppColors.savings),
      ('Investments', investmentsAmount, AppColors.income),
      ('Debts', debtsAmount, AppColors.expense),
    ];

    return Column(
      children: items
          .map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: item.$3,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      item.$1,
                      style: AppTextStyles.label.copyWith(color: textSecondary),
                    ),
                  ),
                  Text(
                    '₱${formatter.format(item.$2)}',
                    style: AppTextStyles.label.copyWith(
                      fontWeight: FontWeight.bold,
                      color: item.$3,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    '${((item.$2 / total) * 100).round()}%',
                    style: AppTextStyles.captionSmall.copyWith(
                      color: textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }

  String _currentMonthLabel() {
    return DateFormat('MMMM yyyy').format(DateTime.now());
  }

  String? _buildPersonalizedGreeting(
    UserProfileModel? profile,
    double spendingRatio,
  ) {
    if (profile == null || profile.financialGoals.isEmpty) return null;
    if (spendingRatio >= 0.9) {
      return 'You are close to your budget limit.';
    }

    final goal = profile.financialGoals.first;
    return 'You are making progress toward your $goal goal.';
  }

  String _buildAlertMessage(
    UserProfileModel? profile,
    double spendingRatio,
    double monthlyBudget,
  ) {
    if (monthlyBudget <= 0) {
      return 'Set a monthly budget to track progress.';
    }

    final threshold = _alertThreshold(profile);
    final percent = (spendingRatio * 100).round();
    if (spendingRatio >= threshold) {
      return 'You have used $percent% of your monthly budget.';
    }
    return 'You are on track with $percent% of your budget used.';
  }

  String _buildInsightMessage(UserProfileModel? profile, double spendingRatio) {
    final percent = (spendingRatio * 100).round();
    final tone = profile?.preferredAdviceTone ?? 'Encouraging';
    final categories = profile?.spendingCategories ?? const [];

    switch (tone) {
      case 'Direct':
        return 'You are at $percent% of your budget. Cut non-essentials this week.';
      case 'Detailed':
        final focus = categories.isEmpty
            ? 'top categories'
            : categories.join(', ');
        return 'Budget use is at $percent%. Review $focus and rebalance limits.';
      case 'Encouraging':
      default:
        return 'Nice work! You are at $percent% of your budget so far.';
    }
  }

  double _alertThreshold(UserProfileModel? profile) {
    final goals = profile?.financialGoals ?? const [];
    final conservativeGoals = {
      'Savings',
      'Education',
      'Retirement',
      'House Fund',
    };
    final hasConservativeGoal = goals.any(conservativeGoals.contains);
    return hasConservativeGoal ? 0.7 : 0.85;
  }

  List<_RecentTransactionItem> _recentTransactions(
    List<TransactionModel> transactions,
  ) {
    final sorted = [...transactions]..sort((a, b) => b.date.compareTo(a.date));
    return sorted.take(4).map((tx) {
      final title = tx.note?.isNotEmpty == true ? tx.note! : tx.category;
      final isIncome = tx.type == 'income';
      return _RecentTransactionItem(
        title: title,
        category: tx.category,
        dateLabel: _formatDateLabel(tx.date),
        amount: tx.amount,
        isIncome: isIncome,
        icon: _categoryIcon(tx.category, isIncome),
      );
    }).toList();
  }

  List<_CategoryBudgetData> _buildCategoryBudgets(
    UserProfileModel? profile,
    List<TransactionModel> transactions,
  ) {
    if (profile == null || profile.spendingCategories.isEmpty) {
      return [];
    }

    final expenseMap = <String, double>{};
    for (final tx in transactions) {
      if (tx.type != 'expense') continue;
      expenseMap.update(
        tx.category,
        (value) => value + tx.amount,
        ifAbsent: () => tx.amount,
      );
    }

    final limit =
        (profile.monthlyBudget ?? 0) /
        profile.spendingCategories.length.clamp(1, 99);

    return profile.spendingCategories.map((category) {
      return _CategoryBudgetData(
        name: category,
        spent: expenseMap[category] ?? 0,
        limit: limit,
        icon: _categoryIcon(category, false),
        color: _categoryColor(category),
      );
    }).toList();
  }

  String _formatDateLabel(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);
    final diff = today.difference(target).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    return DateFormat('MMM d').format(date);
  }

  IconData _categoryIcon(String category, bool isIncome) {
    if (isIncome) return Icons.trending_up;
    final label = category.toLowerCase();
    if (label.contains('food')) return Icons.restaurant;
    if (label.contains('transport')) return Icons.directions_car;
    if (label.contains('rent') || label.contains('housing')) {
      return Icons.home_outlined;
    }
    if (label.contains('health')) return Icons.favorite_border;
    if (label.contains('shop')) return Icons.shopping_bag;
    if (label.contains('entertain')) return Icons.movie;
    return Icons.list_alt;
  }

  Color _categoryColor(String category) {
    final label = category.toLowerCase();
    if (label.contains('food')) return AppColors.warning;
    if (label.contains('transport')) return AppColors.savings;
    if (label.contains('rent') || label.contains('housing')) {
      return AppColors.expense;
    }
    if (label.contains('health')) return AppColors.primaryLight;
    return AppColors.income;
  }
}

class _RecentTransactionItem {
  const _RecentTransactionItem({
    required this.title,
    required this.category,
    required this.dateLabel,
    required this.amount,
    required this.isIncome,
    required this.icon,
  });

  final String title;
  final String category;
  final String dateLabel;
  final double amount;
  final bool isIncome;
  final IconData icon;
}

class _CategoryBudgetData {
  const _CategoryBudgetData({
    required this.name,
    required this.spent,
    required this.limit,
    required this.icon,
    required this.color,
  });

  final String name;
  final double spent;
  final double limit;
  final IconData icon;
  final Color color;
}

class _PieChartPainter extends CustomPainter {
  final List<double> values;
  final List<Color> colors;

  _PieChartPainter({required this.values, required this.colors});

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final radius =
        (size.width < size.height ? size.width : size.height) / 2 - 30;

    if (radius <= 0) return;

    final center = Offset(centerX, centerY);
    double startAngle = -90 * (3.14159265359 / 180);
    final total = values.fold<double>(0, (sum, val) => sum + val);

    if (total <= 0) return;

    for (int i = 0; i < values.length; i++) {
      final value = values[i];
      if (value <= 0) continue;

      final sweepAngle = (value / total) * 360 * (3.14159265359 / 180);

      final paint = Paint()
        ..color = colors[i]
        ..style = PaintingStyle.fill
        ..strokeWidth = 0;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        paint,
      );

      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(_PieChartPainter oldDelegate) {
    return oldDelegate.values != values || oldDelegate.colors != colors;
  }
}
