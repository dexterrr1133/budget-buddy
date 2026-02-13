import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/colors.dart';
import '../../../models/transaction.dart';
import '../models/transaction_model.dart';

class ActivityProvider extends ChangeNotifier {
  ActivityProvider({DateTime Function()? now}) : _now = now ?? DateTime.now;

  final DateTime Function() _now;

  List<ActivityTransaction> _transactions = [];
  String _query = '';

  String get query => _query;

  void updateTransactions(List<TransactionModel> transactions) {
    _transactions = transactions.map(_mapTransaction).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    notifyListeners();
  }

  void setQuery(String value) {
    _query = value.trim();
    notifyListeners();
  }

  Map<String, List<ActivityTransaction>> get groupedTransactions {
    final filtered = _filteredTransactions();
    final groups = <String, List<ActivityTransaction>>{
      'Today': [],
      'Yesterday': [],
      'Previous': [],
    };

    for (final tx in filtered) {
      final label = _bucketLabel(tx.date);
      groups[label]?.add(tx);
    }

    return Map.fromEntries(
      groups.entries.where((entry) => entry.value.isNotEmpty),
    );
  }

  List<ActivityTransaction> _filteredTransactions() {
    if (_query.isEmpty) return _transactions;
    final lower = _query.toLowerCase();
    return _transactions.where((tx) {
      return tx.title.toLowerCase().contains(lower) ||
          tx.category.toLowerCase().contains(lower);
    }).toList();
  }

  String _bucketLabel(DateTime date) {
    final now = _now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);
    final diff = today.difference(target).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    return 'Previous';
  }

  ActivityTransaction _mapTransaction(TransactionModel tx) {
    final isIncome = tx.type == 'income';
    final title = tx.note?.isNotEmpty == true ? tx.note! : tx.category;
    final accent = _categoryColor(tx.category, isIncome);
    return ActivityTransaction(
      id: tx.id,
      title: title,
      category: tx.category,
      date: tx.date,
      amount: tx.amount,
      isIncome: isIncome,
      icon: _categoryIcon(tx.category, isIncome),
      accentColor: accent,
    );
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

  Color _categoryColor(String category, bool isIncome) {
    if (isIncome) return AppColors.income;
    final label = category.toLowerCase();
    if (label.contains('food')) return AppColors.warning;
    if (label.contains('transport')) return AppColors.savings;
    if (label.contains('rent') || label.contains('housing')) {
      return AppColors.expense;
    }
    if (label.contains('health')) return AppColors.primaryLight;
    return AppColors.primary;
  }
}
