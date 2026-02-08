import 'package:flutter/material.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/text_styles.dart';
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

  // Mock data - replace with real data from provider/controller
  final String userName = 'Lance';
  final double totalBalance = 45250.50;
  final double totalIncome = 120000.00;
  final double totalExpenses = 28420.75;
  final int notificationCount = 2;

  // Mock transactions
  final List<Map<String, dynamic>> recentTransactions = [
    {
      'title': 'Salary Deposit',
      'category': 'Income',
      'date': 'Today',
      'amount': 45000.0,
      'isIncome': true,
      'icon': Icons.trending_up,
    },
    {
      'title': 'Grocery Shopping',
      'category': 'Food',
      'date': 'Yesterday',
      'amount': 1250.50,
      'isIncome': false,
      'icon': Icons.shopping_cart,
    },
    {
      'title': 'Netflix Subscription',
      'category': 'Entertainment',
      'date': '2 days ago',
      'amount': 549.00,
      'isIncome': false,
      'icon': Icons.play_circle_outline,
    },
    {
      'title': 'Electric Bill',
      'category': 'Utilities',
      'date': '3 days ago',
      'amount': 2150.00,
      'isIncome': false,
      'icon': Icons.bolt,
    },
    {
      'title': 'Freelance Project',
      'category': 'Income',
      'date': '5 days ago',
      'amount': 5500.0,
      'isIncome': true,
      'icon': Icons.trending_up,
    },
  ];

  @override
  void initState() {
    super.initState();
    _controller = HomeController();
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
                      background: HomeHeaderWidget(
                        userName: userName,
                        notificationCount: notificationCount,
                        onNotificationTap: _onNotificationTap,
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
                child: ModernBottomNavBar(
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
        // Skeleton loader for balance card
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          height: 220,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            color: isDark
                ? AppColors.darkCard.withOpacity(0.5)
                : Colors.grey.withOpacity(0.1),
          ),
        ),
        const SizedBox(height: 16),
        // Skeleton loaders for transaction items
        ...List.generate(
          3,
          (index) => Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            height: 60,
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
          // Balance Summary Card
          BalanceSummaryCard(
            totalBalance: totalBalance,
            totalIncome: totalIncome,
            totalExpenses: totalExpenses,
          ),

          // Alert and Insight Cards
          AlertInsightCards(
            alertMessage: 'You\'ve spent 34% of your monthly budget',
            insightMessage: 'Your spending is 12% lower than last month!',
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

          // Recent Activity Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
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
          ...recentTransactions.map(
            (transaction) => TransactionItemWidget(
              title: transaction['title'],
              category: transaction['category'],
              date: transaction['date'],
              amount: transaction['amount'],
              isIncome: transaction['isIncome'],
              icon: transaction['icon'],
            ),
          ),

          // Bottom spacing
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
