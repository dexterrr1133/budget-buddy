import 'package:flutter/material.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/text_styles.dart';

/// Multi-select chip widget for selecting multiple items
class SelectableChip extends StatefulWidget {
  final String label;
  final IconData? icon;
  final bool isSelected;
  final VoidCallback onTap;
  final String? emoji;

  const SelectableChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.icon,
    this.emoji,
    super.key,
  });

  @override
  State<SelectableChip> createState() => _SelectableChipState();
}

class _SelectableChipState extends State<SelectableChip>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void didUpdateWidget(SelectableChip oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isSelected != widget.isSelected) {
      if (widget.isSelected) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return GestureDetector(
          onTap: widget.onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              color: widget.isSelected
                  ? AppColors.primary.withOpacity(0.15)
                  : (isDark ? AppColors.darkCard : AppColors.lightDivider),
              border: Border.all(
                color: widget.isSelected
                    ? AppColors.primary
                    : (isDark ? AppColors.darkDivider : AppColors.lightDivider),
                width: widget.isSelected ? 2 : 1.5,
              ),
              boxShadow: widget.isSelected
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.2),
                        blurRadius: 8,
                      ),
                    ]
                  : [],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.emoji != null) ...[
                  Text(widget.emoji!, style: const TextStyle(fontSize: 18)),
                  const SizedBox(width: 8),
                ] else if (widget.icon != null) ...[
                  Icon(
                    widget.icon,
                    color: widget.isSelected
                        ? AppColors.primary
                        : AppColors.lightTextSecondary,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                ],
                Text(
                  widget.label,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: widget.isSelected ? AppColors.primary : null,
                  ),
                ),
                if (widget.isSelected) ...[
                  const SizedBox(width: 8),
                  Icon(Icons.check, color: AppColors.primary, size: 18),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
