/// Transaction model for storing transaction data
class Transaction {
  final String? id;
  final String title;
  final String category;
  final double amount;
  final bool isIncome;
  final DateTime date;
  final String? description;

  Transaction({
    this.id,
    required this.title,
    required this.category,
    required this.amount,
    required this.isIncome,
    required this.date,
    this.description,
  });

  /// Create a copy with updated fields
  Transaction copyWith({
    String? id,
    String? title,
    String? category,
    double? amount,
    bool? isIncome,
    DateTime? date,
    String? description,
  }) {
    return Transaction(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      isIncome: isIncome ?? this.isIncome,
      date: date ?? this.date,
      description: description ?? this.description,
    );
  }

  /// Convert to JSON for storage
  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'category': category,
    'amount': amount,
    'isIncome': isIncome,
    'date': date.toIso8601String(),
    'description': description,
  };

  /// Create from JSON
  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'],
      title: json['title'],
      category: json['category'],
      amount: json['amount'],
      isIncome: json['isIncome'],
      date: DateTime.parse(json['date']),
      description: json['description'],
    );
  }
}
