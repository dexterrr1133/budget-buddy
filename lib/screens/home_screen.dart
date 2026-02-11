import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/reminder.dart';
import '../models/transaction.dart';
import '../providers/chat_coach_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/transaction_provider.dart';
import '../widgets/transaction_form.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  bool _showBalance = true;

  // Mock data for reminders
  final List<ReminderModel> _reminders = [
    ReminderModel(
      id: 1,
      title: 'Baysid Kay Aling Puring',
      amount: 1000.00,
      dueDate: DateTime(2025, 12, 7),
    ),
    ReminderModel(
      id: 2,
      title: 'SPay Later',
      amount: 3000.00,
      dueDate: DateTime(2025, 12, 5),
    ),
  ];

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
                  icon: Icons.home_filled,
                  isActive: _currentIndex == 0,
                  onTap: () => setState(() => _currentIndex = 0),
                ),
                _NavItem(
                  label: 'Budget',
                  icon: Icons.pie_chart_outline,
                  isActive: _currentIndex == 1,
                  onTap: () {
                    setState(() => _currentIndex = 1);
                    Navigator.of(context).pushNamed('/budget');
                  },
                ),
                const SizedBox(width: 48),
                _NavItem(
                  label: 'Activity',
                  icon: Icons.list_alt,
                  isActive: _currentIndex == 2,
                  onTap: () {
                    setState(() => _currentIndex = 2);
                    Navigator.of(context).pushNamed('/activity');
                  },
                ),
                _NavItem(
                  label: 'Advisor',
                  icon: Icons.chat_bubble_outline,
                  isActive: _currentIndex == 3,
                  onTap: () {
                    setState(() => _currentIndex = 3);
                    Navigator.of(context).pushNamed('/chat');
                  },
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
            final coach = context.watch<ChatCoachProvider>();
            final recent = [...provider.items]..sort((a, b) => b.date.compareTo(a.date));
            final recentItems = recent.take(4).toList();
            final balance = provider.balance;
            final income = provider.totalIncome;
            final expense = provider.totalExpense;
            final assessment = _latestAssessment(coach);
            final insightText = assessment?.insight ??
              'Ask your advisor for personalized insights based on your spending.';
            final alertText = assessment?.alert ??
              'No alerts yet. Add transactions to receive budget warnings.';

            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
              children: [
                _HomeHeader(
                  onTapProfile: () => Navigator.of(context).pushNamed('/settings'),
                  onTapStats: () {},
                  onTapInfo: () {},
                ),
                const SizedBox(height: 18),
                _BalanceCard(
                  balance: balance,
                  income: income,
                  expense: expense,
                  currencySymbol: settings.currencySymbol,
                  decimalDigits: settings.decimalDigits,
                  showBalance: _showBalance,
                  onToggleVisibility: () => setState(() => _showBalance = !_showBalance),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _InfoCard(
                        title: 'Alert',
                        message: alertText,
                        icon: Icons.notifications_none,
                        accent: const Color(0xFFF59E0B),
                        background: const Color(0xFFFFF7E6),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _InfoCard(
                        title: 'Insight',
                        message: insightText,
                        icon: Icons.trending_up,
                        accent: const Color(0xFF22C55E),
                        background: const Color(0xFFEFFDF3),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Recent Activity',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2A37),
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pushNamed('/activity'),
                      child: const Text('See All'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (provider.isLoading)
                  const Center(child: CircularProgressIndicator())
                else if (recentItems.isEmpty)
                  const _EmptyActivity()
                else
                  ...recentItems
                      .map(
                        (tx) => _HomeTransactionTile(
                          tx,
                          currencySymbol: settings.currencySymbol,
                          decimalDigits: settings.decimalDigits,
                        ),
                      )
                      .toList(),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({
    required this.onTapProfile,
    required this.onTapStats,
    required this.onTapInfo,
  });

  final VoidCallback onTapProfile;
  final VoidCallback onTapStats;
  final VoidCallback onTapInfo;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            InkWell(
              onTap: onTapProfile,
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
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.bar_chart, color: Color(0xFF16A34A)),
              onPressed: onTapStats,
            ),
            IconButton(
              icon: const Icon(Icons.info_outline, color: Color(0xFF16A34A)),
              onPressed: onTapInfo,
            ),
          ],
        ),
      ],
    );
  }
}

class _BalanceCard extends StatelessWidget {
  const _BalanceCard({
    required this.balance,
    required this.income,
    required this.expense,
    required this.currencySymbol,
    required this.decimalDigits,
    required this.showBalance,
    required this.onToggleVisibility,
  });

  final double balance;
  final double income;
  final double expense;
  final String currencySymbol;
  final int decimalDigits;
  final bool showBalance;
  final VoidCallback onToggleVisibility;

  @override
  Widget build(BuildContext context) {
    final amount = NumberFormat.currency(
      symbol: currencySymbol,
      decimalDigits: decimalDigits,
    ).format(balance);
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1B8A65), Color(0xFF167E5B)],
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF16A34A).withOpacity(0.25),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Balance',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
              IconButton(
                icon: Icon(showBalance ? Icons.visibility : Icons.visibility_off, color: Colors.white),
                onPressed: onToggleVisibility,
              ),
            ],
          ),
          Text(
            showBalance ? amount : '\$ •••••',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 34,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _SmallStatCard(
                  title: 'Income',
                  amount: income,
                  subtitle: 'This month',
                  color: const Color(0xFF1D7D5E),
                  textColor: Colors.white,
                  currencySymbol: currencySymbol,
                  decimalDigits: decimalDigits,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _SmallStatCard(
                  title: 'Expenses',
                  amount: expense,
                  subtitle: 'This month',
                  color: const Color(0xFF1D7D5E),
                  textColor: Colors.white,
                  currencySymbol: currencySymbol,
                  decimalDigits: decimalDigits,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.title,
    required this.message,
    required this.icon,
    required this.accent,
    required this.background,
  });

  final String title;
  final String message;
  final IconData icon;
  final Color accent;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: accent, size: 18),
              const SizedBox(width: 6),
              Text(
                title,
                style: TextStyle(color: accent, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: const TextStyle(color: Color(0xFF4B5563), fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _HomeTransactionTile extends StatelessWidget {
  const _HomeTransactionTile(
    this.tx, {
    required this.currencySymbol,
    required this.decimalDigits,
  });

  final TransactionModel tx;
  final String currencySymbol;
  final int decimalDigits;

  @override
  Widget build(BuildContext context) {
    final isIncome = tx.type == 'income';
    final amount = NumberFormat.currency(
      symbol: currencySymbol,
      decimalDigits: decimalDigits,
    ).format(tx.amount);
    final title = (tx.note != null && tx.note!.trim().isNotEmpty) ? tx.note!.trim() : tx.category;
    final subtitle = '${_categoryLabel(tx.category)} · ${_relativeDate(tx.date)}';
    final style = _categoryStyle(tx.category);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
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
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: style.background,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(style.icon, color: style.foreground),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1F2A37),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Color(0xFF8A94A6),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${isIncome ? '+' : '-'}$amount',
            style: TextStyle(
              color: isIncome ? const Color(0xFF16A34A) : const Color(0xFFDC2626),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  String _relativeDate(DateTime date) {
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

class _EmptyActivity extends StatelessWidget {
  const _EmptyActivity();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        children: const [
          Icon(Icons.inbox_outlined, size: 40, color: Color(0xFF9AA3B2)),
          SizedBox(height: 8),
          Text(
            'No recent activity yet',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
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

_Assessment? _latestAssessment(ChatCoachProvider coach) {
  for (final msg in coach.messages.reversed) {
    if (msg.role == 'assistant' && msg.text.trim().isNotEmpty) {
      final text = msg.text.trim();
      final parts = _splitIntoSentences(text);
      final insight = parts.isNotEmpty ? parts.first : text;
      final alert = parts.length > 1 ? parts[1] : 'Review your spending for potential savings.';
      return _Assessment(alert: alert, insight: insight);
    }
  }
  return null;
}

List<String> _splitIntoSentences(String text) {
  final cleaned = text.replaceAll('\n', ' ').trim();
  final parts = cleaned.split(RegExp(r'(?<=[.!?])\s+'));
  return parts.where((part) => part.trim().isNotEmpty).toList();
}

class _Assessment {
  const _Assessment({required this.alert, required this.insight});

  final String alert;
  final String insight;
}

class _SmallStatCard extends StatelessWidget {
  const _SmallStatCard({
    required this.title,
    required this.amount,
    required this.subtitle,
    required this.color,
    this.textColor,
    this.currencySymbol = '\$',
    this.decimalDigits = 2,
  });

  final String title;
  final double amount;
  final String subtitle;
  final Color color;
  final Color? textColor;
  final String currencySymbol;
  final int decimalDigits;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: textColor ?? Colors.grey[800],
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            NumberFormat.currency(
              symbol: currencySymbol,
              decimalDigits: decimalDigits,
            ).format(amount),
            style: TextStyle(
              color: textColor ?? Colors.grey[900],
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              color: (textColor ?? Colors.grey[600])?.withOpacity(0.9),
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReminderCard extends StatelessWidget {
  const _ReminderCard({
    required this.reminder,
    required this.onToggle,
    required this.onMenu,
  });

  final ReminderModel reminder;
  final ValueChanged<bool?> onToggle;
  final VoidCallback onMenu;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Checkbox(
            value: reminder.isCompleted,
            onChanged: onToggle,
            activeColor: Colors.green,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Text(
                  reminder.dueDate.day.toString(),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  DateFormat('MMM yyyy').format(reminder.dueDate),
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  reminder.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'PHP ${reminder.amount.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.more_vert, color: Colors.grey[600]),
            onPressed: onMenu,
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.balance,
    required this.income,
    required this.expense,
  });

  final double balance;
  final double income;
  final double expense;

  @override
  Widget build(BuildContext context) {
    final balanceColor = balance >= 0
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context).colorScheme.error;

    return Row(
      children: [
        Expanded(
          child: _StatCard(
            label: 'Balance',
            value: balance,
            valueColor: balanceColor,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            label: 'Income',
            value: income,
            valueColor: Colors.green.shade700,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            label: 'Expense',
            value: expense,
            valueColor: Colors.red.shade700,
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.valueColor,
  });

  final String label;
  final double value;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: Theme.of(context).textTheme.labelMedium),
            const SizedBox(height: 6),
            Text(
              _formatAmount(value),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: valueColor,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TransactionCard extends StatelessWidget {
  const _TransactionCard({
    required this.title,
    required this.amount,
    required this.type,
    required this.date,
    this.note,
    this.onDelete,
  });

  final String title;
  final double amount;
  final String type;
  final DateTime date;
  final String? note;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final isIncome = type == 'income';
    final color = isIncome ? Colors.green.shade700 : Colors.red.shade700;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.15),
          child: Icon(isIncome ? Icons.trending_up : Icons.trending_down, color: color),
        ),
        title: Text(title),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_formatDate(date)),
            if (note != null) Text(note!),
          ],
        ),
        trailing: SizedBox(
          width: 100,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                child: Text(
                  (isIncome ? '+' : '-') + _formatAmount(amount),
                  style: TextStyle(color: color, fontWeight: FontWeight.w600),
                  textAlign: TextAlign.right,
                ),
              ),
              if (onDelete != null)
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 18),
                  color: Theme.of(context).colorScheme.error,
                  onPressed: onDelete,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

String _formatAmount(double value) => value.toStringAsFixed(2);
String _formatDate(DateTime date) => date.toIso8601String().split('T').first;
