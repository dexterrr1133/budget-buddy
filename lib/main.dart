import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'providers/chat_coach_provider.dart';
import 'providers/transaction_provider.dart';
import 'features/chatbot/chat_coach_screen.dart';
import 'features/home/screens/home_screen.dart';
import 'features/budget/screens/budget_screen.dart';
import 'features/onboarding/screens/welcome_screen.dart';

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
      ],
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
        },
      ),
    );
  }
}
