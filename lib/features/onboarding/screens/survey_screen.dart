import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/theme/radius.dart';
import '../controllers/survey_controller.dart';
import '../providers/user_profile_provider.dart';
import '../widgets/animated_progress_indicator.dart';
import '../widgets/selection_card.dart';
import '../widgets/selectable_chip.dart';
import 'onboarding_complete_screen.dart';

/// Custom formatter to add commas to numbers
class ThousandsSeparatorInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    // Remove all non-digit characters except decimal point
    String newText = newValue.text.replaceAll(RegExp(r'[^0-9.]'), '');
    if (newText.isEmpty) {
      return newValue.copyWith(text: '');
    }

    // Split by decimal point
    final parts = newText.split('.');
    String integerPart = parts[0];
    String decimalPart = parts.length > 1 ? '.${parts[1]}' : '';

    // Add commas to integer part
    final buffer = StringBuffer();
    for (int i = 0; i < integerPart.length; i++) {
      if (i > 0 && (integerPart.length - i) % 3 == 0) {
        buffer.write(',');
      }
      buffer.write(integerPart[i]);
    }

    final formattedText = buffer.toString() + decimalPart;
    return newValue.copyWith(
      text: formattedText,
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
  }
}

/// Main survey screen with multi-step onboarding
class SurveyScreen extends StatefulWidget {
  const SurveyScreen({super.key});

  @override
  State<SurveyScreen> createState() => _SurveyScreenState();
}

class _SurveyScreenState extends State<SurveyScreen> {
  late SurveyController _controller;

  @override
  void initState() {
    super.initState();
    _controller = SurveyController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListenableBuilder(
          listenable: _controller,
          builder: (context, _) {
            return Column(
              children: [
                // Header with progress
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: AnimatedProgressIndicator(
                    progress: _controller.progress,
                  ),
                ),
                // Page view
                Expanded(
                  child: PageView(
                    controller: _controller.pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _buildUserNameStep(),
                      _buildCurrentFundsStep(),
                      _buildFinancialSummaryStep(),
                      _buildIncomeRangeStep(),
                      _buildExpenseCategoriesStep(),
                      _buildSpendingStyleStep(),
                      _buildFinancialGoalsStep(),
                      _buildInvestmentRiskStep(),
                      _buildReviewStep(),
                    ],
                  ),
                ),
                // Navigation buttons
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: _buildNavigationButtons(),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildUserNameStep() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            Text(
              'What\'s your name?',
              style: AppTextStyles.headlineMedium.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'We\'ll use this to personalize your financial journey',
              style: AppTextStyles.bodyMedium.copyWith(
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              ),
            ),
            const SizedBox(height: 32),
            TextField(
              decoration: InputDecoration(
                hintText: 'Enter your name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                filled: true,
                fillColor: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.darkCard
                    : AppColors.lightCard,
              ),
              onChanged: (value) {
                _controller.updateUserName(value);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentFundsStep() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            Text(
              'How much cash do you have on hand?',
              style: AppTextStyles.headlineMedium.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Include your wallet, checking account, or emergency fund',
              style: AppTextStyles.bodyMedium.copyWith(
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              ),
            ),
            const SizedBox(height: 32),
            TextField(
              decoration: InputDecoration(
                hintText: '₱ 0.00',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                filled: true,
                fillColor: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.darkCard
                    : AppColors.lightCard,
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [ThousandsSeparatorInputFormatter()],
              onChanged: (value) {
                final cleanValue = value.replaceAll(',', '');
                final amount = double.tryParse(cleanValue) ?? 0.0;
                _controller.updateCurrentFunds(amount);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFinancialSummaryStep() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            Text(
              'Tell us about your financial situation',
              style: AppTextStyles.headlineMedium.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Be honest - this helps us give better advice',
              style: AppTextStyles.bodyMedium.copyWith(
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              ),
            ),
            const SizedBox(height: 32),
            // Savings amount
            Text(
              'Savings Amount (₱)',
              style: AppTextStyles.bodyLarge.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              decoration: InputDecoration(
                hintText: '₱ 0.00',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                filled: true,
                fillColor: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.darkCard
                    : AppColors.lightCard,
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [ThousandsSeparatorInputFormatter()],
              onChanged: (value) {
                final cleanValue = value.replaceAll(',', '');
                final amount = double.tryParse(cleanValue) ?? 0.0;
                _controller.updateSavingsAmount(amount);
              },
            ),
            const SizedBox(height: 20),
            // Investments amount
            Text(
              'Investments Amount (₱)',
              style: AppTextStyles.bodyLarge.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              decoration: InputDecoration(
                hintText: '₱ 0.00',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                filled: true,
                fillColor: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.darkCard
                    : AppColors.lightCard,
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [ThousandsSeparatorInputFormatter()],
              onChanged: (value) {
                final cleanValue = value.replaceAll(',', '');
                final amount = double.tryParse(cleanValue) ?? 0.0;
                _controller.updateInvestmentsAmount(amount);
              },
            ),
            const SizedBox(height: 20),
            Text(
              'Do you currently have debt?',
              style: AppTextStyles.bodyLarge.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.darkCard
                    : AppColors.lightCard,
              ),
              child: SwitchListTile(
                title: Text(
                  _controller.profile.hasDebt ? 'Yes' : 'No',
                  style: AppTextStyles.bodyMedium,
                ),
                value: _controller.profile.hasDebt,
                onChanged: _controller.updateHasDebt,
                activeColor: AppColors.primary,
              ),
            ),
            if (_controller.profile.hasDebt) ...[
              const SizedBox(height: 20),
              // Debts amount
              Text(
                'Debts Amount (₱)',
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                decoration: InputDecoration(
                  hintText: '₱ 0.00',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  filled: true,
                  fillColor: Theme.of(context).brightness == Brightness.dark
                      ? AppColors.darkCard
                      : AppColors.lightCard,
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [ThousandsSeparatorInputFormatter()],
                onChanged: (value) {
                  final cleanValue = value.replaceAll(',', '');
                  final amount = double.tryParse(cleanValue) ?? 0.0;
                  _controller.updateDebtsAmount(amount);
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildIncomeRangeStep() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'What\'s your monthly income range?',
              style: AppTextStyles.headlineMedium.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'This helps us tailor advice for your situation',
              style: AppTextStyles.bodyMedium.copyWith(
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              ),
            ),
            const SizedBox(height: 32),
            ...[
              ('₱0 - ₱10,000', '💰'),
              ('₱10,000 - ₱25,000', '💵'),
              ('₱25,000 - ₱50,000', '💸'),
              ('₱50,000+', '🏦'),
            ].map((item) {
              final (range, emoji) = item;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: SelectionCard(
                  title: range,
                  description: 'Monthly income',
                  icon: Icons.attach_money,
                  isSelected: _controller.profile.incomeRange == range,
                  onTap: () => _controller.updateIncomeRange(range),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildExpenseCategoriesStep() {
    const categories = [
      ('🍔', 'Food'),
      ('🏠', 'Housing'),
      ('🚗', 'Transport'),
      ('🎮', 'Entertainment'),
      ('📚', 'Education'),
      ('💊', 'Health'),
      ('👗', 'Shopping'),
      ('📱', 'Subscriptions'),
    ];

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'What are your main expense categories?',
              style: AppTextStyles.headlineMedium.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Select all that apply',
              style: AppTextStyles.bodyMedium.copyWith(
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              ),
            ),
            const SizedBox(height: 32),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: categories.map((item) {
                final (emoji, label) = item;
                return SelectableChip(
                  label: label,
                  emoji: emoji,
                  isSelected: _controller.profile.spendingCategories.contains(
                    label,
                  ),
                  onTap: () {
                    final updated = List<String>.from(
                      _controller.profile.spendingCategories,
                    );
                    if (updated.contains(label)) {
                      updated.remove(label);
                    } else {
                      updated.add(label);
                    }
                    _controller.updateExpenseCategories(updated);
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpendingStyleStep() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'How should we tailor advice?',
              style: AppTextStyles.headlineMedium.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Choose the tone that feels most helpful',
              style: AppTextStyles.bodyMedium.copyWith(
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              ),
            ),
            const SizedBox(height: 32),
            ...[
              (
                'Direct',
                'Straight to the point with clear next steps',
                Icons.savings,
                'Focused',
              ),
              (
                'Encouraging',
                'Supportive and motivating guidance',
                Icons.scale,
                'Supportive',
              ),
              (
                'Detailed',
                'Deeper explanations with context',
                Icons.shopping_bag,
                'Insightful',
              ),
            ].map((item) {
              final (title, description, icon, risk) = item;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: SelectionCard(
                  title: title,
                  description: description,
                  icon: icon,
                  riskLevel: risk,
                  isSelected: _controller.profile.preferredAdviceTone == title,
                  onTap: () => _controller.updatePreferredAdviceTone(title),
                  learnMore: 'We will match recommendations to this style.',
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildFinancialGoalsStep() {
    const goals = [
      ('🎓', 'Education'),
      ('🏠', 'House Fund'),
      ('🚗', 'Car Fund'),
      ('🧳', 'Travel'),
      ('💼', 'Career'),
      ('🎮', 'Hobbies'),
      ('👨‍👩‍👧‍👦', 'Family'),
      ('🏖️', 'Retirement'),
    ];

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'What are your financial goals?',
              style: AppTextStyles.headlineMedium.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Pick at least 2 goals',
              style: AppTextStyles.bodyMedium.copyWith(
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              ),
            ),
            const SizedBox(height: 32),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: goals.map((item) {
                final (emoji, label) = item;
                return SelectableChip(
                  label: label,
                  emoji: emoji,
                  isSelected: _controller.profile.financialGoals.contains(
                    label,
                  ),
                  onTap: () {
                    final updated = List<String>.from(
                      _controller.profile.financialGoals,
                    );
                    if (updated.contains(label)) {
                      updated.remove(label);
                    } else {
                      updated.add(label);
                    }
                    _controller.updateFinancialGoals(updated);
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInvestmentRiskStep() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'What\'s your investment comfort level?',
              style: AppTextStyles.headlineMedium.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 32),
            ...[
              (
                'Conservative',
                'I prefer stable, low-risk investments',
                Icons.shield,
                'Low',
                'You prioritize safety and steady growth over potential high returns.',
              ),
              (
                'Moderate',
                'I\'m okay with some risk for better returns',
                Icons.trending_up,
                'Medium',
                'You\'re willing to take calculated risks to achieve your financial goals.',
              ),
              (
                'Aggressive',
                'I want higher returns and can handle volatility',
                Icons.rocket_launch,
                'High',
                'You\'re comfortable with significant market fluctuations for growth potential.',
              ),
            ].map((item) {
              final (title, description, icon, risk, learnMore) = item;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: SelectionCard(
                  title: title,
                  description: description,
                  icon: icon,
                  riskLevel: risk,
                  isSelected: _controller.profile.riskTolerance == title,
                  onTap: () => _controller.updateRiskTolerance(title),
                  learnMore: learnMore,
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewStep() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Review Your Profile',
              style: AppTextStyles.headlineMedium.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Make sure everything looks good',
              style: AppTextStyles.bodyMedium.copyWith(
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              ),
            ),
            const SizedBox(height: 24),
            _buildReviewItem(
              'Income Range',
              _controller.profile.incomeRange ?? 'Not set',
            ),
            _buildReviewItem(
              'Advice Tone',
              _controller.profile.preferredAdviceTone ?? 'Not set',
            ),
            _buildReviewItem(
              'Risk Tolerance',
              _controller.profile.riskTolerance ?? 'Not set',
            ),
            _buildReviewItem(
              'Expense Categories',
              _controller.profile.spendingCategories.join(', '),
            ),
            _buildReviewItem(
              'Financial Goals',
              _controller.profile.financialGoals.join(', '),
            ),
            _buildReviewItem(
              'Has Debt',
              _controller.profile.hasDebt ? 'Yes' : 'No',
            ),
            const SizedBox(height: 32),
            Center(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),

                child: Column(
                  children: [
                    const Icon(
                      Icons.celebration,
                      color: Colors.white,
                      size: 40,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Profile Complete!',
                      style: AppTextStyles.headlineMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Your personalized financial advisor is ready',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: Colors.white70,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.bold,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isLastStep = _controller.currentStep == _controller.steps.length - 1;

    return Row(
      children: [
        if (_controller.currentStep > 0)
          Expanded(
            child: OutlinedButton(
              onPressed: _controller.previousStep,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: BorderSide(color: AppColors.primary),
              ),
              child: const Text('Back'),
            ),
          ),
        if (_controller.currentStep > 0) const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: isLastStep
                ? () async {
                    await context.read<UserProfileProvider>().setProfile(
                      _controller.profile,
                    );
                    if (!context.mounted) return;
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => OnboardingCompleteScreen(
                          profile: _controller.profile,
                        ),
                      ),
                    );
                  }
                : _controller.nextStep,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              backgroundColor: AppColors.primary,
            ),
            child: Text(
              isLastStep ? 'Complete' : 'Next',
              style: AppTextStyles.buttonText.copyWith(color: Colors.white),
            ),
          ),
        ),
        if (!isLastStep && _controller.currentStep < 6) ...[
          const SizedBox(width: 12),
          OutlinedButton(
            onPressed: _controller.nextStep,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              side: BorderSide(
                color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
              ),
            ),
            child: const Text('Skip'),
          ),
        ],
      ],
    );
  }
}
