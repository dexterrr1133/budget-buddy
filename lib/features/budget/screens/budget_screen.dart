import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/text_styles.dart';
import '../controllers/budget_controller.dart';
import '../widgets/budget_header_widget.dart';
import '../widgets/monthly_summary_card.dart';
import '../widgets/category_budget_card.dart';
import '../widgets/budget_bottom_nav_bar.dart';
import '../../home/widgets/floating_add_button.dart';

/// Modern budget tracking screen
class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  late BudgetController _controller;
  final ScrollController _scrollController = ScrollController();

  // Mock data
  final String userName = 'Lance';
  final double totalBudget = 50000.00;
  final double amountSpent = 28420.75;

  // Mock categories
  final List<Map<String, dynamic>> categories = [
    {
      'name': 'Food & Dining',
      'spent': 8500.00,
      'limit': 10000.00,
      'icon': Icons.restaurant,
      'color': const Color(0xFFFF6B6B),
    },
    {
      'name': 'Transportation',
      'spent': 3200.00,
      'limit': 5000.00,
      'icon': Icons.directions_car,
      'color': const Color(0xFF4ECDC4),
    },
    {
      'name': 'Entertainment',
      'spent': 4100.00,
      'limit': 5000.00,
      'icon': Icons.movie,
      'color': const Color(0xFFFFE66D),
    },
    {
      'name': 'Shopping',
      'spent': 5620.75,
      'limit': 8000.00,
      'icon': Icons.shopping_bag,
      'color': const Color(0xFFC44569),
    },
    {
      'name': 'Utilities',
      'spent': 3000.00,
      'limit': 4000.00,
      'icon': Icons.bolt,
      'color': const Color(0xFF95E1D3),
    },
    {
      'name': 'Education',
      'spent': 2000.00,
      'limit': 8000.00,
      'icon': Icons.school,
      'color': const Color(0xFF6C5CE7),
    },
  ];

  @override
  void initState() {
    super.initState();
    _controller = BudgetController();
    _simulateDataLoading();
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

  String _getCurrentMonthYear() {
    return DateFormat('MMMM yyyy').format(DateTime.now());
  }

  void _onNotificationTap() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Notifications feature coming soon'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _onFilterTap() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Filter options coming soon'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _onAddTransactionTap() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Add transaction feature coming soon'),
        duration: Duration(seconds: 2),
      ),
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Activity feature coming soon'),
            duration: Duration(seconds: 1),
          ),
        );
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

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.darkBackground
          : AppColors.lightBackground,
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) {
          return Stack(
            children: [
              // Main scrollable content
              CustomScrollView(
                controller: _scrollController,
                slivers: [
                  // Header
                  SliverAppBar(
                    floating: true,
                    elevation: 0,
                    backgroundColor: isDark
                        ? AppColors.darkBackground
                        : AppColors.lightBackground,
                    automaticallyImplyLeading: false,
                    flexibleSpace: FlexibleSpaceBar(
                      background: BudgetHeaderWidget(
                        userName: userName,
                        onNotificationTap: _onNotificationTap,
                        onFilterTap: _onFilterTap,
                      ),
                    ),
                  ),
                  // Content
                  SliverToBoxAdapter(
                    child: _controller.isLoading
                        ? _buildLoadingState(isDark)
                        : _buildMainContent(isDark),
                  ),
                  // Bottom spacing for FAB and nav
                  const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
                ],
              ),
              // Floating Add Button
              Positioned(
                bottom: 120,
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
                child: BudgetBottomNavBar(
                  selectedIndex: _controller.selectedNavIndex,
                  onTabChanged: _onNavTabChanged,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildLoadingState(bool isDark) {
    return Column(
      children: [
        // Skeleton for summary card
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          height: 180,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            color: isDark
                ? AppColors.darkCard.withOpacity(0.5)
                : Colors.grey.withOpacity(0.1),
          ),
        ),
        const SizedBox(height: 16),
        // Skeleton loaders for category cards
        ...List.generate(
          4,
          (index) => Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            height: 100,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: isDark
                  ? AppColors.darkCard.withOpacity(0.5)
                  : Colors.grey.withOpacity(0.1),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMainContent(bool isDark) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          // Monthly Budget Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Monthly Budget',
                  style: AppTextStyles.headlineLarge.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.lightTextPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _getCurrentMonthYear(),
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                  ),
                ),
              ],
            ),
          ),
          // Monthly Summary Card
          MonthlySummaryCard(
            totalBudget: totalBudget,
            amountSpent: amountSpent,
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
}
