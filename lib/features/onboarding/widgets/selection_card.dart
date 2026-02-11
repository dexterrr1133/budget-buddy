import 'package:flutter/material.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/theme/shadows.dart';

/// Animated selection card with icon, title, description, and risk indicator
class SelectionCard extends StatefulWidget {
  final String title;
  final String description;
  final IconData icon;
  final String? riskLevel; // 'Low', 'Medium', 'High'
  final String? learnMore;
  final bool isSelected;
  final VoidCallback onTap;

  const SelectionCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.isSelected,
    required this.onTap,
    this.riskLevel,
    this.learnMore,
    super.key,
  });

  @override
  State<SelectionCard> createState() => _SelectionCardState();
}

class _SelectionCardState extends State<SelectionCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void didUpdateWidget(SelectionCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isSelected != widget.isSelected) {
      if (widget.isSelected) {
        _scaleController.forward();
        // Collapse the card when it becomes selected
        setState(() => _isExpanded = false);
      } else {
        _scaleController.reverse();
        // Auto-collapse when deselected
        setState(() => _isExpanded = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ScaleTransition(
      scale: Tween<double>(begin: 1.0, end: 1.05).animate(
        CurvedAnimation(parent: _scaleController, curve: Curves.easeInOutCubic),
      ),
      child: GestureDetector(
        onTap: () {
          widget.onTap();
          if (widget.learnMore != null) {
            setState(() => _isExpanded = !_isExpanded);
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOutCubic,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: widget.isSelected ? AppColors.primary : Colors.transparent,
              width: 2,
            ),
            color: widget.isSelected
                ? (isDark
                      ? AppColors.primary.withOpacity(0.15)
                      : AppColors.primary.withOpacity(0.08))
                : (isDark ? AppColors.darkCard : AppColors.lightCard),
            boxShadow: widget.isSelected
                ? [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.2),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : isDark
                ? AppShadows.darkCard
                : AppShadows.lightCard,
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: widget.isSelected
                          ? AppColors.primary.withOpacity(0.2)
                          : (isDark
                                ? AppColors.darkCard
                                : AppColors.lightDivider),
                    ),
                    child: Icon(
                      widget.icon,
                      color: widget.isSelected
                          ? AppColors.primary
                          : (isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.lightTextSecondary),
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: AppTextStyles.bodyLarge.copyWith(
                            fontWeight: FontWeight.bold,
                            color: widget.isSelected ? AppColors.primary : null,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.description,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.lightTextSecondary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  if (widget.isSelected)
                    Icon(Icons.check_circle, color: AppColors.primary),
                ],
              ),
              if (widget.riskLevel != null) ...[
                const SizedBox(height: 12),
                _buildRiskChip(context, widget.riskLevel!),
              ],
              if (widget.learnMore != null && _isExpanded) ...[
                const SizedBox(height: 12),
                Divider(
                  color: isDark
                      ? AppColors.darkDivider
                      : AppColors.lightDivider,
                ),
                const SizedBox(height: 12),
                Text(
                  widget.learnMore!,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                    height: 1.5,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRiskChip(BuildContext context, String risk) {
    final colors = {
      'Low': AppColors.income,
      'Medium': Colors.orange,
      'High': AppColors.expense,
    };
    final color = colors[risk] ?? AppColors.lightTextSecondary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: color.withOpacity(0.2),
      ),
      child: Text(
        '$risk Risk',
        style: AppTextStyles.label.copyWith(
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }
}
