import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/transaction.dart';
import '../providers/settings_provider.dart';
import '../providers/transaction_provider.dart';
import '../widgets/transaction_form.dart';

class ActivityScreen extends StatefulWidget {
  const ActivityScreen({super.key});

  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  int _currentIndex = 2;
  String _query = '';

  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<TransactionProvider>().loadTransactions());
  }

  void _openAddTransactionSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => TransactionForm(
        onSubmit: ({
          required double amount,
          required String category,
          required DateTime date,
          required String type,
          String? note,
        }) {
          return context.read<TransactionProvider>().addTransaction(
                amount: amount,
                category: category,
                date: date,
                type: type,
                note: note,
              );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FB),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddTransactionSheet,
        backgroundColor: const Color(0xFF0D1B2A),
        foregroundColor: Colors.white,
        child: const Icon(Icons.add, size: 28),
      ),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        child: SizedBox(
          height: 64,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavItem(
                  label: 'Home',
                  icon: Icons.home_outlined,
                  isActive: _currentIndex == 0,
                  onTap: () => Navigator.of(context).popUntil((route) => route.isFirst),
                ),
                _NavItem(
                  label: 'Budget',
                  icon: Icons.pie_chart_outline,
                  isActive: _currentIndex == 1,
                  onTap: () => Navigator.of(context).pushNamed('/budget'),
                ),
                const SizedBox(width: 48),
                _NavItem(
                  label: 'Activity',
                  icon: Icons.list_alt,
                  isActive: _currentIndex == 2,
                  onTap: () {
                    setState(() => _currentIndex = 2);
                  },
                ),
                _NavItem(
                  label: 'Advisor',
                  icon: Icons.chat_bubble_outline,
                  isActive: _currentIndex == 3,
                  onTap: () => Navigator.of(context).pushNamed('/chat'),
                ),
              ],
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Consumer<TransactionProvider>(
          builder: (context, provider, _) {
            final settings = context.watch<SettingsProvider>();
            final items = _filterTransactions(provider.items);
            final grouped = _groupTransactions(items);

            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
              children: [
                _buildHeader(),
                const SizedBox(height: 20),
                Text(
                  'All Transactions',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1F2A37),
                  ),
                ),
                const SizedBox(height: 12),
                _buildSearchRow(theme),
                const SizedBox(height: 20),
                if (provider.isLoading)
                  const Center(child: CircularProgressIndicator())
                else if (provider.error != null)
                  _buildError(provider.error!, theme)
                else if (items.isEmpty)
                  _buildEmptyState(theme)
                else ...[
                  _Section(
                    title: 'Today',
                    children: grouped.today
                        .map(
                          (tx) => _TransactionTile(
                            tx,
                            currencySymbol: settings.currencySymbol,
                            decimalDigits: settings.decimalDigits,
                          ),
                        )
                        .toList(),
                  ),
                  _Section(
                    title: 'Yesterday',
                    children: grouped.yesterday
                        .map(
                          (tx) => _TransactionTile(
                            tx,
                            currencySymbol: settings.currencySymbol,
                            decimalDigits: settings.decimalDigits,
                          ),
                        )
                        .toList(),
                  ),
                  _Section(
                    title: 'Previous',
                    children: grouped.previous
                        .map(
                          (tx) => _TransactionTile(
                            tx,
                            currencySymbol: settings.currencySymbol,
                            decimalDigits: settings.decimalDigits,
                          ),
                        )
                        .toList(),
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            InkWell(
              onTap: () => Navigator.of(context).pushNamed('/settings'),
              borderRadius: BorderRadius.circular(24),
              child: const CircleAvatar(
                radius: 22,
                backgroundColor: Color(0xFFE4E8FF),
                child: Text(
                  'B',
                  style: TextStyle(
                    color: Color(0xFF4C5BFF),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Welcome back,',
                  style: TextStyle(
                    color: Color(0xFF8A94A6),
                    fontSize: 12,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Alex Student',
                  style: TextStyle(
                    color: Color(0xFF1F2A37),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(Icons.notifications_none, color: Color(0xFF1F2A37)),
        ),
      ],
    );
  }

  Widget _buildSearchRow(ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: TextField(
              onChanged: (value) => setState(() => _query = value),
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: 'Search transactions...',
                icon: Icon(Icons.search, color: Color(0xFF9AA3B2)),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Container(
          height: 48,
          width: 48,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: const Icon(Icons.tune, color: Color(0xFF6B7280)),
        ),
      ],
    );
  }

  Widget _buildError(String message, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: theme.colorScheme.error),
          const SizedBox(width: 8),
          Expanded(child: Text(message)),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        children: [
          Icon(Icons.inbox_outlined, size: 48, color: theme.colorScheme.outline),
          const SizedBox(height: 12),
          Text(
            'No transactions yet',
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            'Add your first transaction to see activity here.',
            style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.outline),
          ),
        ],
      ),
    );
  }

  List<TransactionModel> _filterTransactions(List<TransactionModel> items) {
    final trimmed = _query.trim().toLowerCase();
    final sorted = [...items]..sort((a, b) => b.date.compareTo(a.date));

    if (trimmed.isEmpty) return sorted;

    return sorted.where((tx) {
      final matchCategory = tx.category.toLowerCase().contains(trimmed);
      final matchNote = (tx.note ?? '').toLowerCase().contains(trimmed);
      final matchType = tx.type.toLowerCase().contains(trimmed);
      return matchCategory || matchNote || matchType;
    }).toList();
  }

  _GroupedTransactions _groupTransactions(List<TransactionModel> items) {
    final now = DateTime.now();
    final today = <TransactionModel>[];
    final yesterday = <TransactionModel>[];
    final previous = <TransactionModel>[];

    for (final tx in items) {
      if (DateUtils.isSameDay(tx.date, now)) {
        today.add(tx);
      } else if (DateUtils.isSameDay(tx.date, now.subtract(const Duration(days: 1)))) {
        yesterday.add(tx);
      } else {
        previous.add(tx);
      }
    }

    return _GroupedTransactions(today: today, yesterday: yesterday, previous: previous);
  }
}

class _GroupedTransactions {
  const _GroupedTransactions({
    required this.today,
    required this.yesterday,
    required this.previous,
  });

  final List<TransactionModel> today;
  final List<TransactionModel> yesterday;
  final List<TransactionModel> previous;
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    if (children.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.toUpperCase(),
          style: const TextStyle(
            color: Color(0xFF9AA3B2),
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.1,
          ),
        ),
        const SizedBox(height: 12),
        ...children,
        const SizedBox(height: 20),
      ],
    );
  }
}

class _TransactionTile extends StatelessWidget {
  const _TransactionTile(
    this.tx, {
    required this.currencySymbol,
    required this.decimalDigits,
  });

  final TransactionModel tx;
  final String currencySymbol;
  final int decimalDigits;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isIncome = tx.type == 'income';
    final amount = NumberFormat.currency(
      symbol: currencySymbol,
      decimalDigits: decimalDigits,
    ).format(tx.amount);
    final title = (tx.note != null && tx.note!.trim().isNotEmpty) ? tx.note!.trim() : tx.category;
    final dateLabel = _dateLabel(tx.date);
    final leading = _categoryStyle(tx.category);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: leading.background,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(leading.icon, color: leading.foreground),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1F2A37),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_categoryLabel(tx.category)} · $dateLabel',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF8A94A6),
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${isIncome ? '+' : '-'}$amount',
            style: theme.textTheme.titleSmall?.copyWith(
              color: isIncome ? const Color(0xFF16A34A) : const Color(0xFFDC2626),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  String _dateLabel(DateTime date) {
    final now = DateTime.now();
    if (DateUtils.isSameDay(date, now)) return 'Today';
    if (DateUtils.isSameDay(date, now.subtract(const Duration(days: 1)))) return 'Yesterday';
    return DateFormat('MMM d').format(date);
  }

  String _categoryLabel(String category) {
    if (category.trim().isEmpty) return 'Other';
    return category[0].toUpperCase() + category.substring(1);
  }

  _CategoryStyle _categoryStyle(String category) {
    switch (category.toLowerCase()) {
      case 'salary':
      case 'income':
      case 'freelance':
        return const _CategoryStyle(Icons.trending_up, Color(0xFFE8FFF3), Color(0xFF10B981));
      case 'food':
      case 'groceries':
      case 'grocery':
      case 'dining':
        return const _CategoryStyle(Icons.restaurant, Color(0xFFFFF4E5), Color(0xFFF97316));
      case 'transport':
      case 'transportation':
      case 'uber':
        return const _CategoryStyle(Icons.directions_car, Color(0xFFEFF6FF), Color(0xFF3B82F6));
      case 'housing':
      case 'rent':
        return const _CategoryStyle(Icons.home_outlined, Color(0xFFEFFDF3), Color(0xFF22C55E));
      default:
        return const _CategoryStyle(Icons.receipt_long, Color(0xFFF1F5F9), Color(0xFF64748B));
    }
  }
}

class _CategoryStyle {
  const _CategoryStyle(this.icon, this.background, this.foreground);

  final IconData icon;
  final Color background;
  final Color foreground;
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.label,
    required this.icon,
    required this.isActive,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = isActive ? const Color(0xFF16A34A) : const Color(0xFF94A3B8);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 4),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
