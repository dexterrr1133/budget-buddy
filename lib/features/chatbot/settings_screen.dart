import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/settings_provider.dart';
import '../../features/onboarding/providers/user_profile_provider.dart';
import '../../providers/transaction_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final profile = context.watch<UserProfileProvider>().profile;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FB),
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        children: [
          // Profile Section
          if (profile != null) ...[
            _SectionTitle(title: 'Profile'),
            _SettingsCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(
                    title: const Text('Name'),
                    subtitle: Text(profile.userName ?? 'Not set'),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    title: const Text('Monthly Budget'),
                    subtitle: Text(
                      profile.monthlyBudget != null
                          ? settings.formatAmount(
                              profile.monthlyBudget!,
                              decimalDigits: settings.decimalDigits,
                            )
                          : 'Not set',
                    ),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    title: const Text('Current Funds'),
                    subtitle: Text(
                      profile.currentFunds != null
                          ? settings.formatAmount(
                              profile.currentFunds!,
                              decimalDigits: settings.decimalDigits,
                            )
                          : 'Not set',
                    ),
                  ),
                  if (profile.savingsAmount != null) ...[
                    const Divider(height: 1),
                    ListTile(
                      title: const Text('Savings'),
                      subtitle: Text(
                        settings.formatAmount(
                          profile.savingsAmount!,
                          decimalDigits: settings.decimalDigits,
                        ),
                      ),
                    ),
                  ],
                  if (profile.investmentsAmount != null &&
                      profile.investmentsAmount! > 0) ...[
                    const Divider(height: 1),
                    ListTile(
                      title: const Text('Investments'),
                      subtitle: Text(
                        settings.formatAmount(
                          profile.investmentsAmount!,
                          decimalDigits: settings.decimalDigits,
                        ),
                      ),
                    ),
                  ],
                  if (profile.debtsAmount != null &&
                      profile.debtsAmount! > 0) ...[
                    const Divider(height: 1),
                    ListTile(
                      title: const Text('Debts'),
                      subtitle: Text(
                        settings.formatAmount(
                          profile.debtsAmount!,
                          decimalDigits: settings.decimalDigits,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
          _SectionTitle(title: 'Appearance'),
          _SettingsCard(
            child: Column(
              children: [
                ListTile(
                  title: const Text('Theme'),
                  subtitle: Text(_themeLabel(settings.themeMode)),
                  trailing: DropdownButton<ThemeMode>(
                    value: settings.themeMode,
                    items: const [
                      DropdownMenuItem(
                        value: ThemeMode.system,
                        child: Text('System'),
                      ),
                      DropdownMenuItem(
                        value: ThemeMode.light,
                        child: Text('Light'),
                      ),
                      DropdownMenuItem(
                        value: ThemeMode.dark,
                        child: Text('Dark'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) settings.setThemeMode(value);
                    },
                  ),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: const Text('Show cents'),
                  subtitle: const Text('Display cents in amounts'),
                  value: settings.showCents,
                  onChanged: settings.setShowCents,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _SectionTitle(title: 'Currency'),
          _SettingsCard(
            child: ListTile(
              title: const Text('Preferred currency'),
              subtitle: Text(
                'Current: ${settings.currencyCode} ${settings.currencySymbol}',
              ),
              trailing: DropdownButton<String>(
                value: settings.currencyCode,
                items: settings.supportedCurrencies.keys
                    .map(
                      (code) =>
                          DropdownMenuItem(value: code, child: Text(code)),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) settings.setCurrencyCode(value);
                },
              ),
            ),
          ),
          const SizedBox(height: 16),
          _SectionTitle(title: 'Notifications'),
          _SettingsCard(
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Push notifications'),
                  subtitle: const Text('Reminders and updates'),
                  value: settings.notificationsEnabled,
                  onChanged: settings.setNotificationsEnabled,
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: const Text('Budget alerts'),
                  subtitle: const Text('Warn when nearing limits'),
                  value: settings.budgetAlerts,
                  onChanged: settings.setBudgetAlerts,
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: const Text('Weekly summary'),
                  subtitle: const Text('Email a weekly report'),
                  value: settings.weeklySummary,
                  onChanged: settings.setWeeklySummary,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _SectionTitle(title: 'Security'),
          _SettingsCard(
            child: SwitchListTile(
              title: const Text('Biometric lock'),
              subtitle: const Text('Require Face ID / fingerprint'),
              value: settings.biometricLock,
              onChanged: settings.setBiometricLock,
            ),
          ),
          const SizedBox(height: 16),
          _SectionTitle(title: 'Preferences'),
          _SettingsCard(
            child: SwitchListTile(
              title: const Text('Start week on Monday'),
              subtitle: const Text('Calendar and summary views'),
              value: settings.startWeekOnMonday,
              onChanged: settings.setStartWeekOnMonday,
            ),
          ),
          const SizedBox(height: 16),
          _SectionTitle(title: 'Data & Privacy'),
          _SettingsCard(
            child: ListTile(
              title: const Text('Clear Profile'),
              subtitle: const Text('Remove all data and restart onboarding'),
              trailing: const Icon(Icons.delete_outline, color: Colors.red),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Clear All Data?'),
                    content: const Text(
                      'This will permanently delete your profile and transaction data. You\'ll need to complete onboarding again.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () async {
                          final userProfileProvider =
                              context.read<UserProfileProvider>();
                          final transactionProvider =
                              context.read<TransactionProvider>();
                          final navigator = Navigator.of(context);
                          Navigator.pop(context);
                          await userProfileProvider.clearProfile();
                          await transactionProvider.clearAllTransactions();
                          navigator.pushNamedAndRemoveUntil(
                            '/',
                            (route) => false,
                          );
                        },
                        child: const Text(
                          'Clear',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _themeLabel(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.system:
        return 'System';
    }
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: Color(0xFF1F2A37),
        ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }
}
