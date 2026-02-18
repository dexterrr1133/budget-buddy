import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/radius.dart';
import '../../../core/theme/shadows.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/theme/text_styles.dart';
import '../../../providers/settings_provider.dart';
import '../../onboarding/providers/user_profile_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final profile = context.watch<UserProfileProvider>().profile;
    final settings = context.watch<SettingsProvider>();
    final userName = profile?.userName ?? 'Friend';

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.darkBackground
          : AppColors.lightBackground,
      body: SafeArea(
        child: ListView(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenPadding,
                AppSpacing.headerTop,
                AppSpacing.screenPadding,
                AppSpacing.lg,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: AppColors.primaryLight,
                        child: Text(
                          userName.isNotEmpty ? userName[0].toUpperCase() : 'B',
                          style: const TextStyle(
                            color: AppColors.primaryDark,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome back,',
                              style: AppTextStyles.label.copyWith(
                                color: isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.lightTextSecondary,
                              ),
                            ),
                            Text(
                              userName,
                              style: AppTextStyles.bodyLarge.copyWith(
                                fontWeight: FontWeight.w600,
                                color: isDark
                                    ? AppColors.darkTextPrimary
                                    : AppColors.lightTextPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            borderRadius: BorderRadius.circular(
                              AppRadius.input,
                            ),
                            boxShadow: AppShadows.subtle,
                          ),
                          child: Icon(
                            Icons.close,
                            color: isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.lightTextPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Text(
                    'Settings',
                    style: AppTextStyles.headlineMedium.copyWith(
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.lightTextPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // Display Settings Section
            _buildSectionHeader('Display', isDark),
            _buildThemeOption(isDark, settings),
            _buildDivider(isDark),

            // Notifications Section
            _buildSectionHeader('Notifications & Alerts', isDark),
            _buildToggleSetting(
              isDark,
              'Notifications',
              'Receive app notifications',
              settings.notificationsEnabled,
              (value) => context
                  .read<SettingsProvider>()
                  .setNotificationsEnabled(value),
            ),
            _buildDivider(isDark),
            _buildToggleSetting(
              isDark,
              'Budget Alerts',
              'Get notified when near budget limit',
              settings.budgetAlerts,
              (value) =>
                  context.read<SettingsProvider>().setBudgetAlerts(value),
            ),
            _buildDivider(isDark),
            _buildToggleSetting(
              isDark,
              'Weekly Summary',
              'Receive weekly spending summary',
              settings.weeklySummary,
              (value) =>
                  context.read<SettingsProvider>().setWeeklySummary(value),
            ),
            _buildDivider(isDark),

            // Financial Settings Section
            _buildSectionHeader('Financial', isDark),
            _buildCurrencyOption(isDark, settings),
            _buildDivider(isDark),
            _buildToggleSetting(
              isDark,
              'Show Cents',
              'Display decimal cents in amounts',
              settings.showCents,
              (value) => context.read<SettingsProvider>().setShowCents(value),
            ),
            _buildDivider(isDark),

            // Calendar Settings Section
            _buildSectionHeader('Calendar', isDark),
            _buildToggleSetting(
              isDark,
              'Start Week on Monday',
              'Begin week calendar on Monday',
              settings.startWeekOnMonday,
              (value) =>
                  context.read<SettingsProvider>().setStartWeekOnMonday(value),
            ),
            _buildDivider(isDark),

            // Security Section
            _buildSectionHeader('Security', isDark),
            _buildToggleSetting(
              isDark,
              'Biometric Lock',
              'Use fingerprint/face recognition',
              settings.biometricLock,
              (value) =>
                  context.read<SettingsProvider>().setBiometricLock(value),
            ),
            _buildDivider(isDark),

            // About Section
            _buildSectionHeader('About', isDark),
            _buildInfoTile(isDark, 'Version', '1.0.0'),
            _buildDivider(isDark),
            _buildInfoTile(isDark, 'Build', '42'),
            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenPadding,
        AppSpacing.lg,
        AppSpacing.screenPadding,
        AppSpacing.md,
      ),
      child: Text(
        title,
        style: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildThemeOption(bool isDark, SettingsProvider settings) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenPadding,
        vertical: AppSpacing.md,
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.card),
          color: isDark ? AppColors.darkCard : AppColors.lightCard,
          boxShadow: AppShadows.subtle,
        ),
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Theme',
              style: AppTextStyles.label.copyWith(
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.lightTextPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Choose your preferred theme',
              style: AppTextStyles.captionSmall.copyWith(
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: _buildThemeButton(
                    'Light',
                    ThemeMode.light,
                    settings.themeMode,
                    isDark,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: _buildThemeButton(
                    'Dark',
                    ThemeMode.dark,
                    settings.themeMode,
                    isDark,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: _buildThemeButton(
                    'System',
                    ThemeMode.system,
                    settings.themeMode,
                    isDark,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeButton(
    String label,
    ThemeMode mode,
    ThemeMode currentMode,
    bool isDark,
  ) {
    final isSelected = mode == currentMode;
    return GestureDetector(
      onTap: () => context.read<SettingsProvider>().setThemeMode(mode),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          color: isSelected
              ? AppColors.primary.withOpacity(0.2)
              : Colors.transparent,
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey.shade400,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: AppTextStyles.label.copyWith(
            color: isSelected ? AppColors.primary : Colors.grey.shade700,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildCurrencyOption(bool isDark, SettingsProvider settings) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenPadding,
        vertical: AppSpacing.md,
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.card),
          color: isDark ? AppColors.darkCard : AppColors.lightCard,
          boxShadow: AppShadows.subtle,
        ),
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Currency',
              style: AppTextStyles.label.copyWith(
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.lightTextPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Select your preferred currency',
              style: AppTextStyles.captionSmall.copyWith(
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            DropdownButton<String>(
              value: settings.currencyCode,
              isExpanded: true,
              items: settings.supportedCurrencies.entries
                  .map(
                    (entry) => DropdownMenuItem(
                      value: entry.key,
                      child: Text('${entry.key} - ${entry.value}'),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  context.read<SettingsProvider>().setCurrencyCode(value);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleSetting(
    bool isDark,
    String title,
    String subtitle,
    bool value,
    Function(bool) onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenPadding,
        vertical: AppSpacing.md,
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.card),
          color: isDark ? AppColors.darkCard : AppColors.lightCard,
          boxShadow: AppShadows.subtle,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.label.copyWith(
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.lightTextPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    subtitle,
                    style: AppTextStyles.captionSmall.copyWith(
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              value: value,
              onChanged: onChanged,
              activeColor: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile(bool isDark, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenPadding,
        vertical: AppSpacing.md,
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.card),
          color: isDark ? AppColors.darkCard : AppColors.lightCard,
          boxShadow: AppShadows.subtle,
        ),
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: AppTextStyles.label.copyWith(
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.lightTextPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              value,
              style: AppTextStyles.label.copyWith(
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider(bool isDark) {
    return Divider(
      color: isDark
          ? AppColors.darkTextSecondary.withOpacity(0.1)
          : AppColors.lightTextSecondary.withOpacity(0.1),
      indent: AppSpacing.screenPadding,
      endIndent: AppSpacing.screenPadding,
    );
  }
}
