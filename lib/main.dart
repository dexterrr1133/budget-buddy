import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'providers/chat_coach_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/transaction_provider.dart';
<<<<<<< HEAD
import 'screens/activity_screen.dart';
import 'screens/budget_screen.dart';
import 'screens/chat_coach_screen.dart';
import 'screens/home_screen.dart';
import 'screens/settings_screen.dart';
=======
import 'features/chatbot/chat_coach_screen.dart';
import 'features/home/screens/home_screen.dart';
import 'features/budget/screens/budget_screen.dart';
import 'features/onboarding/screens/welcome_screen.dart';
>>>>>>> f3b7ff9d8ac2bdb0bf0b9c8869a026e647622e82

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.system;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TransactionProvider()),
        ChangeNotifierProvider(create: (_) => ChatCoachProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
      ],
<<<<<<< HEAD
      child: Consumer<SettingsProvider>(
        builder: (context, settings, _) {
          return MaterialApp(
            title: 'BudgetBuddy',
            debugShowCheckedModeBanner: false,
            themeMode: settings.themeMode,
            theme: ThemeData(
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
              appBarTheme: const AppBarTheme(centerTitle: false),
            ),
            darkTheme: ThemeData(
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.teal,
                brightness: Brightness.dark,
              ),
              appBarTheme: const AppBarTheme(centerTitle: false),
            ),
            home: const HomeScreen(),
            routes: {
              '/activity': (_) => const ActivityScreen(),
              '/budget': (_) => const BudgetScreen(),
              '/chat': (_) => const ChatCoachScreen(),
              '/settings': (_) => const SettingsScreen(),
            },
          );
=======
      child: MaterialApp(
        title: 'BudgetBuddy',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: _themeMode,
        home: const WelcomeScreen(),
        routes: {
          '/chat': (_) => const ChatCoachScreen(),
          '/home': (_) => const HomeScreen(),
          '/budget': (_) => const BudgetScreen(),
>>>>>>> f3b7ff9d8ac2bdb0bf0b9c8869a026e647622e82
        },
      ),
    );
  }
}
