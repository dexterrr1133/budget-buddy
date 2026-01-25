import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/transaction_provider.dart';
import '../widgets/transaction_form.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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
      appBar: AppBar(
        title: const Text('BudgetBuddy'),
        actions: [
          IconButton(
            icon: const Icon(Icons.chat_bubble_outline),
            tooltip: 'Chat coach',
            onPressed: () => Navigator.of(context).pushNamed('/chat'),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<TransactionProvider>().loadTransactions(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddTransactionSheet,
        icon: const Icon(Icons.add),
        label: const Text('Add'),
      ),
      body: Consumer<TransactionProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(provider.error!),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: () => provider.loadTransactions(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (provider.items.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.wallet_outlined, size: 64),
                  const SizedBox(height: 12),
                  const Text('No transactions yet.'),
                  const SizedBox(height: 8),
                  FilledButton(
                    onPressed: _openAddTransactionSheet,
                    child: const Text('Add your first one'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: provider.loadTransactions,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _SummaryRow(
                  balance: provider.balance,
                  income: provider.totalIncome,
                  expense: provider.totalExpense,
                ),
                const SizedBox(height: 16),
                ...provider.items.map((tx) => _TransactionCard(
                      title: tx.category,
                      note: tx.note,
                      amount: tx.amount,
                      type: tx.type,
                      date: tx.date,
                      onDelete: tx.id == null
                          ? null
                          : () => context.read<TransactionProvider>().deleteTransaction(tx.id!),
                    )),
                const SizedBox(height: 80),
              ],
            ),
          );
        },
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
