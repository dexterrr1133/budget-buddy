import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../providers/settings_provider.dart';
import '../providers/transaction_provider.dart';
import '../widgets/transaction_form.dart';

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  int _currentIndex = 1;
  double? _safeToSpend;
  double? _totalBudget;
  List<_BudgetCategory> _categories = [];

  static const _budgetPrefsKey = 'budget_screen_state_v1';

  @override
  void initState() {
    super.initState();
    _loadBudget();
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

  Future<void> _loadBudget() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_budgetPrefsKey);
    if (raw == null) return;
    try {
      final data = jsonDecode(raw) as Map<String, dynamic>;
      setState(() {
        _safeToSpend = (data['safeToSpend'] as num?)?.toDouble();
        _totalBudget = (data['totalBudget'] as num?)?.toDouble();
        final list = (data['categories'] as List<dynamic>? ?? []);
        _categories = list
            .map((item) => _BudgetCategory.fromMap(item as Map<String, dynamic>))
            .toList();
      });
    } catch (_) {
      // Ignore corrupted cache
    }
  }

  Future<void> _saveBudget() async {
    final prefs = await SharedPreferences.getInstance();
    final payload = {
      'safeToSpend': _safeToSpend,
      'totalBudget': _totalBudget,
      'categories': _categories.map((c) => c.toMap()).toList(),
    };
    await prefs.setString(_budgetPrefsKey, jsonEncode(payload));
  }

  Future<void> _editMonthlyBudget(BuildContext context) async {
    final safeController = TextEditingController(
      text: _safeToSpend?.toStringAsFixed(0) ?? '',
    );
    final totalController = TextEditingController(
      text: _totalBudget?.toStringAsFixed(0) ?? '',
    );

    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit monthly budget'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: safeController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Safe to spend'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: totalController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Total budget'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    if (result != true) return;

    setState(() {
      _safeToSpend = double.tryParse(safeController.text.trim());
      _totalBudget = double.tryParse(totalController.text.trim());
    });
    await _saveBudget();
  }

  Future<void> _addOrEditCategory({int? index}) async {
    final existing = index != null ? _categories[index] : null;
    final nameController = TextEditingController(text: existing?.title ?? '');
    final spentController = TextEditingController(
      text: existing != null ? existing.spent.toStringAsFixed(0) : '',
    );
    final limitController = TextEditingController(
      text: existing != null ? existing.limit.toStringAsFixed(0) : '',
    );

    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(index == null ? 'Add category' : 'Edit category'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Category name'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: spentController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Spent'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: limitController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Limit'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    if (result != true) return;

    final title = nameController.text.trim();
    if (title.isEmpty) return;

    final spent = double.tryParse(spentController.text.trim()) ?? 0;
    final limit = double.tryParse(limitController.text.trim()) ?? 0;
    final updated = _BudgetCategory(
      title: title,
      spent: spent,
      limit: limit,
      color: existing?.color ?? _BudgetCategory.pickColor(title),
      icon: existing?.icon ?? _BudgetCategory.pickIcon(title),
    );

    setState(() {
      if (index == null) {
        _categories.add(updated);
      } else {
        _categories[index] = updated;
      }
    });
    await _saveBudget();
  }

  Future<void> _deleteCategory(int index) async {
    setState(() {
      _categories.removeAt(index);
    });
    await _saveBudget();
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
                  icon: Icons.home_outlined,
                  isActive: _currentIndex == 0,
                  onTap: () => Navigator.of(context).popUntil((route) => route.isFirst),
                ),
                _NavItem(
                  label: 'Budget',
                  icon: Icons.pie_chart_outline,
                  isActive: _currentIndex == 1,
                  onTap: () => setState(() => _currentIndex = 1),
                ),
                const SizedBox(width: 48),
                _NavItem(
                  label: 'Activity',
                  icon: Icons.list_alt,
                  isActive: _currentIndex == 2,
                  onTap: () => Navigator.of(context).pushNamed('/activity'),
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
        child: Consumer<SettingsProvider>(
          builder: (context, settings, _) {
            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
              children: [
                _buildHeader(),
                const SizedBox(height: 20),
                const Text(
                  'Monthly Budget',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1F2A37),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'October 2023',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const SizedBox(height: 16),
                _BudgetSummaryCard(
                  safeToSpend: _safeToSpend,
                  totalBudget: _totalBudget,
                  currencySymbol: settings.currencySymbol,
                  decimalDigits: settings.decimalDigits,
                  onEdit: () => _editMonthlyBudget(context),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Categories',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1F2A37),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: _addOrEditCategory,
                      icon: const Icon(Icons.add),
                      label: const Text('Add'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (_categories.isEmpty)
                  _EmptyCategories(onAdd: _addOrEditCategory)
                else
                  ..._categories.asMap().entries.map(
                        (entry) => _CategoryBudgetTile(
                          title: entry.value.title,
                          spent: entry.value.spent,
                          limit: entry.value.limit,
                          color: entry.value.color,
                          icon: entry.value.icon,
                          currencySymbol: settings.currencySymbol,
                          decimalDigits: settings.decimalDigits,
                          onEdit: () => _addOrEditCategory(index: entry.key),
                          onDelete: () => _deleteCategory(entry.key),
                        ),
                      ),
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
}

class _BudgetSummaryCard extends StatelessWidget {
  const _BudgetSummaryCard({
    required this.safeToSpend,
    required this.totalBudget,
    required this.currencySymbol,
    required this.decimalDigits,
    required this.onEdit,
  });

  final double? safeToSpend;
  final double? totalBudget;
  final String currencySymbol;
  final int decimalDigits;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Monthly Budget',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              IconButton(
                icon: const Icon(Icons.edit, size: 18),
                onPressed: onEdit,
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: _SummaryMetric(
                  label: 'Safe to Spend',
                  value: safeToSpend == null ? 'None' : _formatAmount(safeToSpend!),
                  valueColor: safeToSpend == null
                      ? const Color(0xFF9AA3B2)
                      : const Color(0xFF16A34A),
                ),
              ),
              Expanded(
                child: _SummaryMetric(
                  label: 'Total Budget',
                  value: totalBudget == null ? 'None' : _formatAmount(totalBudget!),
                  valueColor: const Color(0xFF111827),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _BudgetProgress(
            totalBudget: totalBudget,
            safeToSpend: safeToSpend,
          ),
        ],
      ),
    );
  }

  String _formatAmount(double value) {
    return '${currencySymbol}${value.toStringAsFixed(decimalDigits)}';
  }
}

class _SummaryMetric extends StatelessWidget {
  const _SummaryMetric({
    required this.label,
    required this.value,
    required this.valueColor,
  });

  final String label;
  final String value;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Color(0xFF9AA3B2), fontSize: 12),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            color: valueColor,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _CategoryBudgetTile extends StatelessWidget {
  const _CategoryBudgetTile({
    required this.title,
    required this.spent,
    required this.limit,
    required this.color,
    required this.icon,
    required this.currencySymbol,
    required this.decimalDigits,
    this.onEdit,
    this.onDelete,
  });

  final String title;
  final double spent;
  final double limit;
  final Color color;
  final IconData icon;
  final String currencySymbol;
  final int decimalDigits;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final ratio = limit == 0 ? 0.0 : (spent / limit).clamp(0.0, 1.0);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 14,
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
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color),
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
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${_formatAmount(spent)} spent',
                      style: const TextStyle(color: Color(0xFF9AA3B2), fontSize: 12),
                    ),
                    Text(
                      '${_formatAmount(limit)} limit',
                      style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: ratio,
                    minHeight: 6,
                    backgroundColor: const Color(0xFFF1F5F9),
                    valueColor: AlwaysStoppedAnimation(color),
                  ),
                ),
              ],
            ),
          ),
          if (onEdit != null)
            IconButton(
              icon: const Icon(Icons.edit, size: 18),
              onPressed: onEdit,
            ),
          if (onDelete != null)
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 18),
              onPressed: onDelete,
            ),
        ],
      ),
    );
  }

  String _formatAmount(double value) {
    return '${currencySymbol}${value.toStringAsFixed(decimalDigits)}';
  }
}

class _BudgetProgress extends StatelessWidget {
  const _BudgetProgress({required this.totalBudget, required this.safeToSpend});

  final double? totalBudget;
  final double? safeToSpend;

  @override
  Widget build(BuildContext context) {
    if (totalBudget == null || totalBudget == 0) {
      return const Text(
        'Set a budget to see progress',
        style: TextStyle(color: Color(0xFF9AA3B2)),
      );
    }

    final remaining = safeToSpend ?? 0;
    final used = (totalBudget! - remaining).clamp(0, totalBudget!);
    final progress = (used / totalBudget!).clamp(0.0, 1.0);

    return Row(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: const Color(0xFFE5E7EB),
              valueColor: const AlwaysStoppedAnimation(Color(0xFF16A34A)),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          '${(progress * 100).round()}% Used',
          style: const TextStyle(
            color: Color(0xFF16A34A),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _EmptyCategories extends StatelessWidget {
  const _EmptyCategories({required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Column(
        children: [
          const Icon(Icons.list_alt, color: Color(0xFF9AA3B2)),
          const SizedBox(height: 8),
          const Text(
            'No categories yet',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          Text(
            'Add your first budget category.',
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: onAdd,
            child: const Text('Add Category'),
          ),
        ],
      ),
    );
  }
}

class _BudgetCategory {
  const _BudgetCategory({
    required this.title,
    required this.spent,
    required this.limit,
    required this.color,
    required this.icon,
  });

  final String title;
  final double spent;
  final double limit;
  final Color color;
  final IconData icon;

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'spent': spent,
      'limit': limit,
      'color': color.value,
      'icon': icon.codePoint,
    };
  }

  factory _BudgetCategory.fromMap(Map<String, dynamic> map) {
    return _BudgetCategory(
      title: map['title'] as String? ?? 'Category',
      spent: (map['spent'] as num?)?.toDouble() ?? 0,
      limit: (map['limit'] as num?)?.toDouble() ?? 0,
      color: Color((map['color'] as int?) ?? 0xFF16A34A),
      icon: IconData(
        (map['icon'] as int?) ?? Icons.list_alt.codePoint,
        fontFamily: 'MaterialIcons',
      ),
    );
  }

  static Color pickColor(String title) {
    final lower = title.toLowerCase();
    if (lower.contains('food')) return const Color(0xFFF97316);
    if (lower.contains('transport')) return const Color(0xFFF59E0B);
    if (lower.contains('housing') || lower.contains('rent')) return const Color(0xFFEF4444);
    if (lower.contains('health')) return const Color(0xFF06B6D4);
    return const Color(0xFF22C55E);
  }

  static IconData pickIcon(String title) {
    final lower = title.toLowerCase();
    if (lower.contains('food')) return Icons.restaurant;
    if (lower.contains('transport')) return Icons.directions_car;
    if (lower.contains('housing') || lower.contains('rent')) return Icons.home_outlined;
    if (lower.contains('health')) return Icons.favorite_border;
    return Icons.list_alt;
  }
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
