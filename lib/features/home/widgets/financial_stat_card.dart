import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/radius.dart';
import '../../../core/theme/shadows.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/theme/text_styles.dart';
import '../../../providers/settings_provider.dart';

/// Financial stat card showing income/expense values
class FinancialStatCard extends StatefulWidget {
  final String label;
  final double amount;
  final IconData icon;
  final Color accentColor;

  const FinancialStatCard({
    required this.label,
    required this.amount,
    required this.icon,
    required this.accentColor,
    super.key,
  });

  @override
  State<FinancialStatCard> createState() => _FinancialStatCardState();
}

class _FinancialStatCardState extends State<FinancialStatCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _slideController;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SlideTransition(
      position: Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero)
          .animate(
            CurvedAnimation(
              parent: _slideController,
              curve: Curves.easeOutCubic,
            ),
          ),
      child: FadeTransition(
        opacity: _slideController,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.cardPadding),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.card),
            color: isDark
                ? Colors.white.withAlpha(13)
                : Colors.white.withAlpha(153),
            border: Border.all(
              color: widget.accentColor.withAlpha(26),
              width: 1,
            ),
            boxShadow: AppShadows.card(isDark),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon with accent color
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.accentColor.withAlpha(38),
                ),
                child: Icon(widget.icon, color: widget.accentColor, size: 16),
              ),
              const SizedBox(height: AppSpacing.sm),
              // Label
              Text(
                widget.label,
                style: AppTextStyles.label.copyWith(
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              // Amount
              Text(
                settings.formatCompactAmount(
                  widget.amount,
                  decimalDigits: settings.decimalDigits,
                ),
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.bold,
                  color: widget.accentColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
