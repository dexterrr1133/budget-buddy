import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider extends ChangeNotifier {
  SettingsProvider() {
    _load();
  }

  static const _themeKey = 'settings_theme_mode';
  static const _currencyKey = 'settings_currency_code';
  static const _notificationsKey = 'settings_notifications';
  static const _budgetAlertsKey = 'settings_budget_alerts';
  static const _weeklySummaryKey = 'settings_weekly_summary';
  static const _biometricKey = 'settings_biometric';
  static const _showCentsKey = 'settings_show_cents';
  static const _startWeekMondayKey = 'settings_start_week_monday';

  ThemeMode _themeMode = ThemeMode.system;
  String _currencyCode = 'USD';
  bool _notificationsEnabled = true;
  bool _budgetAlerts = true;
  bool _weeklySummary = true;
  bool _biometricLock = false;
  bool _showCents = true;
  bool _startWeekOnMonday = true;

  ThemeMode get themeMode => _themeMode;
  String get currencyCode => _currencyCode;
  bool get notificationsEnabled => _notificationsEnabled;
  bool get budgetAlerts => _budgetAlerts;
  bool get weeklySummary => _weeklySummary;
  bool get biometricLock => _biometricLock;
  bool get showCents => _showCents;
  bool get startWeekOnMonday => _startWeekOnMonday;

  int get decimalDigits => _showCents ? 2 : 0;

  String get currencySymbol => _currencySymbols[_currencyCode] ?? '\$';

  Map<String, String> get supportedCurrencies => _currencySymbols;

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, mode.name);
  }

  Future<void> setCurrencyCode(String code) async {
    _currencyCode = code;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_currencyKey, code);
  }

  Future<void> setNotificationsEnabled(bool value) async {
    _notificationsEnabled = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notificationsKey, value);
  }

  Future<void> setBudgetAlerts(bool value) async {
    _budgetAlerts = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_budgetAlertsKey, value);
  }

  Future<void> setWeeklySummary(bool value) async {
    _weeklySummary = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_weeklySummaryKey, value);
  }

  Future<void> setBiometricLock(bool value) async {
    _biometricLock = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_biometricKey, value);
  }

  Future<void> setShowCents(bool value) async {
    _showCents = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_showCentsKey, value);
  }

  Future<void> setStartWeekOnMonday(bool value) async {
    _startWeekOnMonday = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_startWeekMondayKey, value);
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final themeString = prefs.getString(_themeKey);
    _themeMode = _parseThemeMode(themeString);
    _currencyCode = prefs.getString(_currencyKey) ?? 'USD';
    _notificationsEnabled = prefs.getBool(_notificationsKey) ?? true;
    _budgetAlerts = prefs.getBool(_budgetAlertsKey) ?? true;
    _weeklySummary = prefs.getBool(_weeklySummaryKey) ?? true;
    _biometricLock = prefs.getBool(_biometricKey) ?? false;
    _showCents = prefs.getBool(_showCentsKey) ?? true;
    _startWeekOnMonday = prefs.getBool(_startWeekMondayKey) ?? true;
    notifyListeners();
  }

  ThemeMode _parseThemeMode(String? value) {
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
      default:
        return ThemeMode.system;
    }
  }
}

const Map<String, String> _currencySymbols = {
  'USD': '\$',
  'EUR': '€',
  'GBP': '£',
  'PHP': '₱',
  'JPY': '¥',
  'AUD': 'A\$',
  'CAD': 'C\$',
  'SGD': 'S\$',
};
