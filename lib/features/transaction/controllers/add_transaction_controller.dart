import 'package:flutter/material.dart';
import '../models/transaction_model.dart';

/// Controller for managing add transaction form state
class AddTransactionController extends ChangeNotifier {
  String _title = '';
  String _category = '';
  double _amount = 0;
  bool _isIncome = false;
  DateTime _selectedDate = DateTime.now();
  String _description = '';

  String get title => _title;
  String get category => _category;
  double get amount => _amount;
  bool get isIncome => _isIncome;
  DateTime get selectedDate => _selectedDate;
  String get description => _description;

  void setTitle(String value) {
    _title = value;
    notifyListeners();
  }

  void setCategory(String value) {
    _category = value;
    notifyListeners();
  }

  void setAmount(double value) {
    _amount = value;
    notifyListeners();
  }

  void setIsIncome(bool value) {
    _isIncome = value;
    notifyListeners();
  }

  void setSelectedDate(DateTime value) {
    _selectedDate = value;
    notifyListeners();
  }

  void setDescription(String value) {
    _description = value;
    notifyListeners();
  }

  bool get isValid {
    return _title.isNotEmpty &&
        _category.isNotEmpty &&
      _amount > 0;
  }

  Transaction createTransaction() {
    return Transaction(
      title: _title,
      category: _category,
      amount: _amount,
      isIncome: _isIncome,
      date: _selectedDate,
      description: _description.isEmpty ? null : _description,
    );
  }

  void reset() {
    _title = '';
    _category = '';
    _amount = 0;
    _isIncome = false;
    _selectedDate = DateTime.now();
    _description = '';
    notifyListeners();
  }
}
