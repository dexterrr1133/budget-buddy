class TransactionModel {
  TransactionModel({
    this.id,
    required this.amount,
    required this.category,
    required this.date,
    required this.type,
    this.note,
  }) : assert(amount.isFinite, 'Amount must be a finite number');

  final int? id;
  final double amount;
  final String category;
  final DateTime date;
  final String type;
  final String? note;

  TransactionModel copyWith({
    int? id,
    double? amount,
    String? category,
    DateTime? date,
    String? type,
    String? note,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      date: date ?? this.date,
      type: type ?? this.type,
      note: note ?? this.note,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'amount': double.parse(amount.toStringAsFixed(2)),
      'category': category,
      'date': date.toIso8601String(),
      'type': type,
      'note': note,
    };
  }

  factory TransactionModel.fromMap(Map<String, Object?> map) {
    return TransactionModel(
      id: map['id'] as int?,
      amount: (map['amount'] as num).toDouble(),
      category: map['category'] as String,
      date: DateTime.parse(map['date'] as String),
      type: map['type'] as String,
      note: map['note'] as String?,
    );
  }
}
