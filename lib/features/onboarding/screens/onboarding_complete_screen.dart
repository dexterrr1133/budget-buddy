import 'dart:math';
import 'package:flutter/material.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/text_styles.dart';
import '../models/user_profile_model.dart';

/// Onboarding completion celebration screen
class OnboardingCompleteScreen extends StatefulWidget {
  final UserProfileModel profile;

  const OnboardingCompleteScreen({required this.profile, super.key});

  @override
  State<OnboardingCompleteScreen> createState() =>
      _OnboardingCompleteScreenState();
}

class _OnboardingCompleteScreenState extends State<OnboardingCompleteScreen>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _floatController;
  late List<AnimationController> _confettiControllers;

  @override
  void initState() {
    super.initState();

    // Scale animation for the checkmark
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Float animation for the celebration icon
    _floatController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    // Confetti particle animations
    _confettiControllers = List.generate(
      8,
      (index) => AnimationController(
        duration: Duration(milliseconds: 1200 + (index * 100)),
        vsync: this,
      ),
    );

    _scaleController.forward();
    for (var controller in _confettiControllers) {
      controller.forward();
    }
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _floatController.dispose();
    for (var controller in _confettiControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // Main content
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 32,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Animated checkmark circle
                    Center(
                      child: ScaleTransition(
                        scale: Tween<double>(begin: 0.0, end: 1.0).animate(
                          CurvedAnimation(
                            parent: _scaleController,
                            curve: Curves.elasticOut,
                          ),
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [
                                AppColors.primary,
                                AppColors.primaryDark,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.3),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Icon(
                              Icons.check_rounded,
                              size: 64,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Floating celebration emoji
                    FloatingBuilder(
                      animation: _floatController,
                      child: Center(
                        child: Text('🎉', style: TextStyle(fontSize: 60)),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Main title
                    Text(
                      'Profile Complete!',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.headlineLarge.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Subtitle
                    Text(
                      'Your personalized financial journey starts now',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Profile summary cards
                    _buildProfileSummary(context),
                    const SizedBox(height: 40),

                    // Features highlight
                    _buildFeaturesHighlight(context),
                    const SizedBox(height: 40),

                    // CTA Button
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pushReplacementNamed('/home');
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Start Your Journey',
                        style: AppTextStyles.buttonText.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Secondary CTA
                    OutlinedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(color: AppColors.primary, width: 2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Review Profile',
                        style: AppTextStyles.buttonText.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Confetti particles
            ..._buildConfetti(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSummary(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        border: Border.all(
          color: AppColors.primary.withOpacity(0.2),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Profile Summary',
            style: AppTextStyles.sectionTitle.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _summaryItem('💰 Income', widget.profile.incomeRange ?? 'Not set'),
          _summaryItem(
            '💸 Advice Tone',
            widget.profile.preferredAdviceTone ?? 'Not set',
          ),
          _summaryItem(
            '📊 Risk Level',
            widget.profile.riskTolerance ?? 'Not set',
          ),
          _summaryItem('💪 Savings', widget.profile.savingsHabit ?? 'Not set'),
          _summaryItem(
            '🎯 Goals',
            widget.profile.financialGoals.isEmpty
                ? 'Not set'
                : '${widget.profile.financialGoals.length} selected',
          ),
        ],
      ),
    );
  }

  Widget _summaryItem(String label, String value) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
            ),
          ),
          Text(
            value,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesHighlight(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'What\'s Next?',
          style: AppTextStyles.sectionTitle.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ...[
          ('📱', 'Track Expenses', 'Log and categorize your daily spending'),
          ('🤖', 'AI Advisor', 'Get personalized financial recommendations'),
        ].map((item) {
          final (emoji, title, description) = item;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: AppColors.primary.withOpacity(0.08),
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.1),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Text(emoji, style: const TextStyle(fontSize: 24)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          description,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.lightTextSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  List<Widget> _buildConfetti() {
    return List.generate(8, (index) {
      return ConfettiParticle(
        animation: _confettiControllers[index],
        index: index,
      );
    });
  }
}

/// Floating animation builder for celebration emoji
class FloatingBuilder extends StatelessWidget {
  final Animation<double> animation;
  final Widget child;

  const FloatingBuilder({
    required this.animation,
    required this.child,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, -15 * (animation.value - 0.5).abs() * 2),
          child: child,
        );
      },
      child: child,
    );
  }
}

/// Confetti particle animation
class ConfettiParticle extends StatelessWidget {
  final Animation<double> animation;
  final int index;

  const ConfettiParticle({
    required this.animation,
    required this.index,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Calculate random positions for each particle
    final angle = (index / 8) * (2 * pi);
    final distance = 150.0;
    final endX = screenWidth / 2 + (distance * cos(angle));
    final endY = screenHeight / 2 + (distance * sin(angle));

    final colors = [
      AppColors.primary,
      AppColors.primaryLight,
      AppColors.income,
      AppColors.expense,
      AppColors.savings,
    ];

    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        return Positioned(
          left: screenWidth / 2 + (endX - screenWidth / 2) * animation.value,
          top: screenHeight / 2 + (endY - screenHeight / 2) * animation.value,
          child: Opacity(
            opacity: 1 - animation.value,
            child: Transform.rotate(
              angle: animation.value * 2 * 3.14159,
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colors[index % colors.length],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
