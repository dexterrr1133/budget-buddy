/// Financial profile model to store survey responses
class FinancialProfile {
  final String? userName;
  final double? currentFunds;
  final double? savingsAmount;
  final double? investmentsAmount;
  final double? debtsAmount;
  final String? incomeRange;
  final List<String> expenseCategories;
  final String? spendingStyle;
  final List<String> financialGoals;
  final String? investmentRisk;
  final String? savingsHabit;
  final bool hasDebt;

  FinancialProfile({
    this.userName,
    this.currentFunds,
    this.savingsAmount,
    this.investmentsAmount,
    this.debtsAmount,
    this.incomeRange,
    this.expenseCategories = const [],
    this.spendingStyle,
    this.financialGoals = const [],
    this.investmentRisk,
    this.savingsHabit,
    this.hasDebt = false,
  });

  /// Create a copy with updated fields
  FinancialProfile copyWith({
    String? userName,
    double? currentFunds,
    double? savingsAmount,
    double? investmentsAmount,
    double? debtsAmount,
    String? incomeRange,
    List<String>? expenseCategories,
    String? spendingStyle,
    List<String>? financialGoals,
    String? investmentRisk,
    String? savingsHabit,
    bool? hasDebt,
  }) {
    return FinancialProfile(
      userName: userName ?? this.userName,
      currentFunds: currentFunds ?? this.currentFunds,
      savingsAmount: savingsAmount ?? this.savingsAmount,
      investmentsAmount: investmentsAmount ?? this.investmentsAmount,
      debtsAmount: debtsAmount ?? this.debtsAmount,
      incomeRange: incomeRange ?? this.incomeRange,
      expenseCategories: expenseCategories ?? this.expenseCategories,
      spendingStyle: spendingStyle ?? this.spendingStyle,
      financialGoals: financialGoals ?? this.financialGoals,
      investmentRisk: investmentRisk ?? this.investmentRisk,
      savingsHabit: savingsHabit ?? this.savingsHabit,
      hasDebt: hasDebt ?? this.hasDebt,
    );
  }

  /// Check if profile is complete
  bool get isComplete =>
      userName != null &&
      currentFunds != null &&
      incomeRange != null &&
      expenseCategories.isNotEmpty &&
      spendingStyle != null &&
      financialGoals.isNotEmpty &&
      investmentRisk != null;

  /// Convert to JSON for storage
  Map<String, dynamic> toJson() => {
    'userName': userName,
    'currentFunds': currentFunds,
    'savingsAmount': savingsAmount,
    'investmentsAmount': investmentsAmount,
    'debtsAmount': debtsAmount,
    'incomeRange': incomeRange,
    'expenseCategories': expenseCategories,
    'spendingStyle': spendingStyle,
    'financialGoals': financialGoals,
    'investmentRisk': investmentRisk,
    'savingsHabit': savingsHabit,
    'hasDebt': hasDebt,
  };
}
