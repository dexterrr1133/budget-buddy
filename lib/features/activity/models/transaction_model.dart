import 'package:flutter/material.dart';

class ActivityTransaction {
  const ActivityTransaction({
    required this.id,
    required this.title,
    required this.category,
    required this.date,
    required this.amount,
    required this.isIncome,
    required this.icon,
    required this.accentColor,
  });

  final int? id;
  final String title;
  final String category;
  final DateTime date;
  final double amount;
  final bool isIncome;
  final IconData icon;
  final Color accentColor;
}
