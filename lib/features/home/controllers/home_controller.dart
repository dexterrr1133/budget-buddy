import 'package:flutter/material.dart';

/// Controller to manage home screen state and navigation
class HomeController extends ChangeNotifier {
  int _selectedNavIndex = 0;
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
