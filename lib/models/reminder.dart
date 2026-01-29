class ReminderModel {
  ReminderModel({
    this.id,
    required this.title,
    required this.amount,
    required this.dueDate,
    this.isCompleted = false,
  });

  final int? id;
  final String title;
  final double amount;
  final DateTime dueDate;
  final bool isCompleted;

  ReminderModel copyWith({
    int? id,
    String? title,
    double? amount,
    DateTime? dueDate,
    bool? isCompleted,
  }) {
    return ReminderModel(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      dueDate: dueDate ?? this.dueDate,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'dueDate': dueDate.toIso8601String(),
      'isCompleted': isCompleted ? 1 : 0,
    };
  }

  factory ReminderModel.fromMap(Map<String, Object?> map) {
    return ReminderModel(
      id: map['id'] as int?,
      title: map['title'] as String,
      amount: (map['amount'] as num).toDouble(),
      dueDate: DateTime.parse(map['dueDate'] as String),
      isCompleted: (map['isCompleted'] as int) == 1,
    );
  }
}
