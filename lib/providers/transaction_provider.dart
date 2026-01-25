import 'package:flutter/foundation.dart';

import '../models/transaction.dart';
import '../services/database_helper.dart';

class TransactionProvider extends ChangeNotifier {
  TransactionProvider({DatabaseHelper? database})
      : _databaseHelper = database ?? DatabaseHelper.instance;

  final DatabaseHelper _databaseHelper;

  List<TransactionModel> _items = [];
  bool _loading = false;
  String? _error;

  List<TransactionModel> get items => List.unmodifiable(_items);
  bool get isLoading => _loading;
  String? get error => _error;

  double get totalIncome => _items
      .where((tx) => tx.type == 'income')
      .fold(0, (sum, tx) => sum + tx.amount);

  double get totalExpense => _items
      .where((tx) => tx.type == 'expense')
      .fold(0, (sum, tx) => sum + tx.amount);

  double get balance => totalIncome - totalExpense;

  Future<void> loadTransactions() async {
    _setLoading(true);
    try {
      final data = await _databaseHelper.fetchTransactions();
      _items = data;
      _error = null;
    } catch (e) {
      _error = 'Failed to load transactions: $e';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> addTransaction({
    required double amount,
    required String category,
    required DateTime date,
    required String type,
    String? note,
  }) async {
    final newTx = TransactionModel(
      amount: amount,
      category: category.trim(),
      date: date,
      type: type,
      note: note?.trim().isEmpty == true ? null : note?.trim(),
    );

    try {
      final id = await _databaseHelper.insertTransaction(newTx);
      _items = [newTx.copyWith(id: id), ..._items];
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to add transaction: $e';
      rethrow;
    }
  }

  Future<void> deleteTransaction(int id) async {
    try {
      await _databaseHelper.deleteTransaction(id);
      _items = _items.where((tx) => tx.id != id).toList();
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to delete transaction: $e';
      rethrow;
    }
  }

  void _setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }
}
