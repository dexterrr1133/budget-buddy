import 'package:flutter/material.dart';

import '../../../core/theme/spacing.dart';
import '../models/transaction_model.dart';
import 'transaction_tile.dart';

class TransactionGroup extends StatelessWidget {
  const TransactionGroup({
    required this.title,
    required this.transactions,
    required this.currencySymbol,
    required this.decimalDigits,
    super.key,
  });

  final String title;
  final List<ActivityTransaction> transactions;
  final String currencySymbol;
  final int decimalDigits;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sectionSpacing),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.labelSmall),
          const SizedBox(height: AppSpacing.sm),
          ...transactions.map(
            (transaction) => TransactionTile(
              transaction: transaction,
              currencySymbol: currencySymbol,
              decimalDigits: decimalDigits,
            ),
          ),
        ],
      ),
    );
  }
}
