class UserProfileModel {
  const UserProfileModel({
    this.userName,
    this.currentFunds,
    this.savingsAmount,
    this.investmentsAmount,
    this.debtsAmount,
    this.incomeRange,
    this.monthlyBudget,
    this.spendingCategories = const [],
    this.financialGoals = const [],
    this.riskTolerance,
    this.preferredAdviceTone,
    this.savingsHabit,
    this.hasDebt = false,
  });

  final String? userName;
  final double? currentFunds;
  final double? savingsAmount;
  final double? investmentsAmount;
  final double? debtsAmount;
  final String? incomeRange;
  final double? monthlyBudget;
  final List<String> spendingCategories;
  final List<String> financialGoals;
  final String? riskTolerance;
  final String? preferredAdviceTone;
  final String? savingsHabit;
  final bool hasDebt;

  UserProfileModel copyWith({
    String? userName,
    double? currentFunds,
    double? savingsAmount,
    double? investmentsAmount,
    double? debtsAmount,
    String? incomeRange,
    double? monthlyBudget,
    List<String>? spendingCategories,
    List<String>? financialGoals,
    String? riskTolerance,
    String? preferredAdviceTone,
    String? savingsHabit,
    bool? hasDebt,
  }) {
    return UserProfileModel(
      userName: userName ?? this.userName,
      currentFunds: currentFunds ?? this.currentFunds,
      savingsAmount: savingsAmount ?? this.savingsAmount,
      investmentsAmount: investmentsAmount ?? this.investmentsAmount,
      debtsAmount: debtsAmount ?? this.debtsAmount,
      incomeRange: incomeRange ?? this.incomeRange,
      monthlyBudget: monthlyBudget ?? this.monthlyBudget,
      spendingCategories: spendingCategories ?? this.spendingCategories,
      financialGoals: financialGoals ?? this.financialGoals,
      riskTolerance: riskTolerance ?? this.riskTolerance,
      preferredAdviceTone: preferredAdviceTone ?? this.preferredAdviceTone,
      savingsHabit: savingsHabit ?? this.savingsHabit,
      hasDebt: hasDebt ?? this.hasDebt,
    );
  }

  bool get isComplete =>
      incomeRange != null &&
      monthlyBudget != null &&
      spendingCategories.isNotEmpty &&
      financialGoals.isNotEmpty &&
      riskTolerance != null &&
      preferredAdviceTone != null;

  Map<String, dynamic> toJson() => {
    'userName': userName,
    'currentFunds': currentFunds,
    'savingsAmount': savingsAmount,
    'investmentsAmount': investmentsAmount,
    'debtsAmount': debtsAmount,
    'incomeRange': incomeRange,
    'monthlyBudget': monthlyBudget,
    'spendingCategories': spendingCategories,
    'financialGoals': financialGoals,
    'riskTolerance': riskTolerance,
    'preferredAdviceTone': preferredAdviceTone,
    'savingsHabit': savingsHabit,
    'hasDebt': hasDebt,
  };

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      userName: json['userName'] as String?,
      currentFunds: (json['currentFunds'] as num?)?.toDouble(),
      savingsAmount: (json['savingsAmount'] as num?)?.toDouble(),
      investmentsAmount: (json['investmentsAmount'] as num?)?.toDouble(),
      debtsAmount: (json['debtsAmount'] as num?)?.toDouble(),
      incomeRange: json['incomeRange'] as String?,
      monthlyBudget: (json['monthlyBudget'] as num?)?.toDouble(),
      spendingCategories: (json['spendingCategories'] as List<dynamic>? ?? [])
          .map((item) => item.toString())
          .toList(),
      financialGoals: (json['financialGoals'] as List<dynamic>? ?? [])
          .map((item) => item.toString())
          .toList(),
      riskTolerance: json['riskTolerance'] as String?,
      preferredAdviceTone: json['preferredAdviceTone'] as String?,
      savingsHabit: json['savingsHabit'] as String?,
      hasDebt: json['hasDebt'] as bool? ?? false,
    );
  }
}
