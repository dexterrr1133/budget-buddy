import 'package:flutter/material.dart';

/// Controller to manage budget screen state
class BudgetController extends ChangeNotifier {
  int _selectedNavIndex = 1; // Budget tab is index 1
  bool _isLoading = true;

  int get selectedNavIndex => _selectedNavIndex;
  bool get isLoading => _isLoading;

  void setSelectedNavIndex(int index) {
    _selectedNavIndex = index;
    notifyListeners();
  }

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
