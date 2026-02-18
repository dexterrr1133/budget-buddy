import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/colors.dart';
import '../../../core/theme/radius.dart';
import '../../../core/theme/shadows.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/theme/text_styles.dart';
import '../../../features/home/widgets/modern_bottom_nav_bar.dart';
import '../../../features/home/widgets/floating_add_button.dart';
import '../../../providers/settings_provider.dart';
import '../../../providers/transaction_provider.dart';
import '../../onboarding/providers/user_profile_provider.dart';
import '../providers/activity_provider.dart';
import '../widgets/activity_filter_button.dart';
import '../widgets/activity_search_bar.dart';
import '../widgets/transaction_group.dart';
import '../../transaction/screens/add_transaction_modal.dart';

class ActivityScreen extends StatefulWidget {
  const ActivityScreen({super.key});

  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  final TextEditingController _searchController = TextEditingController();
  late TransactionProvider _transactionProvider;
  int _currentIndex = 2;

  @override
  void initState() {
    super.initState();
    _transactionProvider = context.read<TransactionProvider>();
    _transactionProvider.addListener(_syncTransactions);
    Future.microtask(() {
      _transactionProvider.loadTransactions();
      _syncTransactions();
    });
  }

  @override
  void dispose() {
    _transactionProvider.removeListener(_syncTransactions);
    _searchController.dispose();
    super.dispose();
  }

  void _syncTransactions() {
    context.read<ActivityProvider>().updateTransactions(
      _transactionProvider.items,
    );
  }

  void _onNavTabChanged(int index) {
    setState(() => _currentIndex = index);
    switch (index) {
      case 0:
        Navigator.of(context).pushNamed('/home');
        break;
      case 1:
        Navigator.of(context).pushNamed('/budget');
        break;
      case 2:
        break;
      case 3:
        Navigator.of(context).pushNamed('/chat');
        break;
      default:
        break;
    }
  }

  void _showFilterDialog(
    BuildContext context,
    ActivityProvider activityProvider,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Filter Transactions',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            Text(
              'Type',
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip(
                    'All',
                    activityProvider.typeFilter == 'all',
                    () => activityProvider.setTypeFilter('all'),
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    'Income',
                    activityProvider.typeFilter == 'income',
                    () => activityProvider.setTypeFilter('income'),
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    'Expense',
                    activityProvider.typeFilter == 'expense',
                    () => activityProvider.setTypeFilter('expense'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Time Range',
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip(
                    'All Time',
                    activityProvider.daysFilter == 0,
                    () => activityProvider.setDaysFilter(0),
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    'Last 7 days',
                    activityProvider.daysFilter == 7,
                    () => activityProvider.setDaysFilter(7),
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    'Last 30 days',
                    activityProvider.daysFilter == 30,
                    () => activityProvider.setDaysFilter(30),
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    'Last 90 days',
                    activityProvider.daysFilter == 90,
                    () => activityProvider.setDaysFilter(90),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Done'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.grey[300],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<UserProfileProvider>().profile;
    final userName = profile?.userName ?? 'Friend';
    final settings = context.watch<SettingsProvider>();
    final activityProvider = context.watch<ActivityProvider>();
    final groups = activityProvider.groupedTransactions;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.screenPadding,
                      AppSpacing.headerTop,
                      AppSpacing.screenPadding,
                      AppSpacing.lg,
                    ),
                    child: _ActivityHeader(userName: userName),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.screenPadding,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: ActivitySearchBar(
                            controller: _searchController,
                            onChanged: activityProvider.setQuery,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        ActivityFilterButton(
                          onTap: () {
                            _showFilterDialog(context, activityProvider);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.screenPadding,
                      AppSpacing.xl,
                      AppSpacing.screenPadding,
                      AppSpacing.navClearance,
                    ),
                    child: groups.isEmpty
                        ? Text(
                            'No transactions yet.',
                            style: Theme.of(context).textTheme.bodyMedium,
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: groups.entries
                                .map(
                                  (entry) => TransactionGroup(
                                    title: entry.key,
                                    transactions: entry.value,
                                    currencySymbol: settings.currencySymbol,
                                    decimalDigits: settings.decimalDigits,
                                  ),
                                )
                                .toList(),
                          ),
                  ),
                ),
              ],
            ),
            Positioned(
              bottom: AppSpacing.fabOffset,
              left: 0,
              right: 0,
              child: Center(
                child: FloatingAddButton(
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (context) => const AddTransactionModal(),
                    );
                  },
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: ModernBottomNavBar(
                selectedIndex: _currentIndex,
                onTabChanged: _onNavTabChanged,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActivityHeader extends StatelessWidget {
  const _ActivityHeader({required this.userName});

  final String userName;

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
          'All Transactions',
          style: AppTextStyles.headlineMedium.copyWith(
            color: textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
