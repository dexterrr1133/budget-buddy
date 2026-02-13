import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/settings_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FB),
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
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
                      DropdownMenuItem(value: ThemeMode.system, child: Text('System')),
                      DropdownMenuItem(value: ThemeMode.light, child: Text('Light')),
                      DropdownMenuItem(value: ThemeMode.dark, child: Text('Dark')),
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
              subtitle: Text('Current: ${settings.currencyCode} ${settings.currencySymbol}'),
              trailing: DropdownButton<String>(
                value: settings.currencyCode,
                items: settings.supportedCurrencies.keys
                    .map(
                      (code) => DropdownMenuItem(
                        value: code,
                        child: Text(code),
                      ),
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
      default:
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
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }
}
