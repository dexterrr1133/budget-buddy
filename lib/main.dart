import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/chat_coach_provider.dart';
import 'providers/transaction_provider.dart';
import 'screens/chat_coach_screen.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
          appBarTheme: const AppBarTheme(centerTitle: false),
        ),
        home: const HomeScreen(),
        routes: {
          '/chat': (_) => const ChatCoachScreen(),
        },
      ),
    );
  }
}
