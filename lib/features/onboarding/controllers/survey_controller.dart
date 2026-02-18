import 'package:flutter/material.dart';
import '../models/user_profile_model.dart';

/// Controller to manage survey state and navigation
class SurveyController extends ChangeNotifier {
  final PageController pageController = PageController();
  int _currentStep = 0;
  late UserProfileModel _profile = const UserProfileModel();

  int get currentStep => _currentStep;
  UserProfileModel get profile => _profile;
  double get progress => (_currentStep + 1) / 9; // 9 total steps

  final List<String> steps = [
    'Your Name',
    'Current Funds',
    'Financial Summary',
    'Income Range',
    'Expense Categories',
    'Spending Style',
    'Financial Goals',
    'Investment Risk',
    'Review',
  ];

  void nextStep() {
    if (_currentStep < steps.length - 1) {
      _currentStep++;
      _animateToPage(_currentStep);
      notifyListeners();
    }
  }

  void previousStep() {
    if (_currentStep > 0) {
      _currentStep--;
      _animateToPage(_currentStep);
      notifyListeners();
    }
  }

  void goToStep(int step) {
    if (step >= 0 && step < steps.length) {
      _currentStep = step;
      _animateToPage(step);
      notifyListeners();
    }
  }

  void _animateToPage(int page) {
    pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOutCubic,
    );
  }

  void updateIncomeRange(String range) {
    _profile = _profile.copyWith(incomeRange: range);
    notifyListeners();
  }

  void updateExpenseCategories(List<String> categories) {
    _profile = _profile.copyWith(spendingCategories: categories);
    notifyListeners();
  }

  void updatePreferredAdviceTone(String tone) {
    _profile = _profile.copyWith(preferredAdviceTone: tone);
    notifyListeners();
  }

  void updateFinancialGoals(List<String> goals) {
    _profile = _profile.copyWith(financialGoals: goals);
    notifyListeners();
  }

  void updateRiskTolerance(String risk) {
    _profile = _profile.copyWith(riskTolerance: risk);
    notifyListeners();
  }

  void updateSavingsHabit(String habit) {
    _profile = _profile.copyWith(savingsHabit: habit);
    notifyListeners();
  }

  void updateHasDebt(bool value) {
    _profile = _profile.copyWith(hasDebt: value);
    notifyListeners();
  }

  void updateUserName(String name) {
    _profile = _profile.copyWith(userName: name);
    notifyListeners();
  }

  void updateCurrentFunds(double amount) {
    _profile = _profile.copyWith(currentFunds: amount);
    notifyListeners();
  }

  void updateSavingsAmount(double amount) {
    _profile = _profile.copyWith(savingsAmount: amount);
    notifyListeners();
  }

  void updateInvestmentsAmount(double amount) {
    _profile = _profile.copyWith(investmentsAmount: amount);
    notifyListeners();
  }

  void updateDebtsAmount(double amount) {
    _profile = _profile.copyWith(debtsAmount: amount);
    notifyListeners();
  }

  void updateMonthlyBudget(double amount) {
    _profile = _profile.copyWith(monthlyBudget: amount);
    notifyListeners();
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }
}
