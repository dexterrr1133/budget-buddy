import 'package:flutter/material.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/text_styles.dart';

/// Alert and Insight cards side by side
class AlertInsightCards extends StatefulWidget {
  final String alertMessage;
  final String insightMessage;
  final VoidCallback? onAlertTap;
  final VoidCallback? onInsightTap;

  const AlertInsightCards({
    required this.alertMessage,
    required this.insightMessage,
    this.onAlertTap,
    this.onInsightTap,
    super.key,
  });

  @override
  State<AlertInsightCards> createState() => _AlertInsightCardsState();
}

class _AlertInsightCardsState extends State<AlertInsightCards>
    with TickerProviderStateMixin {
  late AnimationController _alertController;
  late AnimationController _insightController;

  @override
  void initState() {
    super.initState();
    _alertController = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );
    _insightController = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );

    // Stagger animations
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _alertController.forward();
    });
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) _insightController.forward();
    });
  }

  @override
  void dispose() {
    _alertController.dispose();
    _insightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          // Alert Card
          Expanded(
            child: SlideTransition(
              position:
                  Tween<Offset>(
                    begin: const Offset(-0.3, 0),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(
                      parent: _alertController,
                      curve: Curves.easeOutCubic,
                    ),
                  ),
              child: FadeTransition(
                opacity: _alertController,
                child: _buildCard(
                  context,
                  isDark,
                  icon: Icons.warning_amber_rounded,
                  title: 'Alert',
                  message: widget.alertMessage,
                  backgroundColor: AppColors.expense.withOpacity(0.1),
                  borderColor: AppColors.expense.withOpacity(0.3),
                  iconColor: AppColors.expense,
                  onTap: widget.onAlertTap,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Insight Card
          Expanded(
            child: SlideTransition(
              position:
                  Tween<Offset>(
                    begin: const Offset(0.3, 0),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(
                      parent: _insightController,
                      curve: Curves.easeOutCubic,
                    ),
                  ),
              child: FadeTransition(
                opacity: _insightController,
                child: _buildCard(
                  context,
                  isDark,
                  icon: Icons.lightbulb_outline,
                  title: 'Insight',
                  message: widget.insightMessage,
                  backgroundColor: AppColors.savings.withOpacity(0.1),
                  borderColor: AppColors.savings.withOpacity(0.3),
                  iconColor: AppColors.savings,
                  onTap: widget.onInsightTap,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(
    BuildContext context,
    bool isDark, {
    required IconData icon,
    required String title,
    required String message,
    required Color backgroundColor,
    required Color borderColor,
    required Color iconColor,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: backgroundColor,
          border: Border.all(color: borderColor, width: 1.5),
          boxShadow: isDark
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon and title
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: iconColor.withOpacity(0.2),
                  ),
                  child: Icon(icon, color: iconColor, size: 16),
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: AppTextStyles.label.copyWith(
                    fontWeight: FontWeight.bold,
                    color: iconColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Message
            Text(
              message,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.label.copyWith(
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
