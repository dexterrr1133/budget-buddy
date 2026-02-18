import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'features/activity/providers/activity_provider.dart';
import 'features/activity/screens/activity_screen.dart';
import 'providers/chat_coach_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/transaction_provider.dart';
import 'features/chatbot/chat_coach_screen.dart';
import 'features/home/screens/home_screen.dart';
import 'features/budget/screens/budget_screen.dart';
import 'features/settings/screens/settings_screen.dart';
import 'features/onboarding/screens/welcome_screen.dart';
import 'features/onboarding/providers/user_profile_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TransactionProvider()),
        ChangeNotifierProvider(create: (_) => ChatCoachProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => UserProfileProvider()),
        ChangeNotifierProvider(create: (_) => ActivityProvider()),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settings, _) {
          return MaterialApp(
            title: 'BudgetBuddy',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: settings.themeMode,
            home: const WelcomeScreen(),
            routes: {
              '/chat': (_) => const ChatCoachScreen(),
              '/home': (_) => const HomeScreen(),
              '/budget': (_) => const BudgetScreen(),
              '/activity': (_) => const ActivityScreen(),
              '/settings': (_) => const SettingsScreen(),
            },
          );
        },
      ),
    );
  }
}
