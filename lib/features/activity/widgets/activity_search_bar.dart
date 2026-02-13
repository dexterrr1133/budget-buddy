import 'package:flutter/material.dart';

import '../../../core/theme/radius.dart';
import '../../../core/theme/shadows.dart';
import '../../../core/theme/spacing.dart';

class ActivitySearchBar extends StatelessWidget {
  const ActivitySearchBar({
    required this.controller,
    required this.onChanged,
    super.key,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.input),
        boxShadow: AppShadows.subtle,
      ),
      child: Row(
        children: [
          Icon(Icons.search, color: Theme.of(context).iconTheme.color),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: TextField(
              controller: controller,
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: 'Search transactions',
                isDense: true,
              ),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}
