import 'package:flutter/material.dart';
import 'package:namer_app/models/task.dart';
import 'package:namer_app/screens/stats_screen.dart';
import 'screens/success_screen.dart';
import 'screens/main_screen.dart';
import 'screens/calendar_screen.dart';
import 'screens/start_screen.dart';
import 'screens/create_account_screen.dart';
import 'package:namer_app/screens/category_selections_screen.dart';
import 'package:namer_app/screens/confidence_screen.dart';
import 'package:namer_app/screens/login_screen.dart';
import 'package:namer_app/screens/info_screen.dart';

final Map<String, WidgetBuilder> appRoutes = {
  '/': (context) {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final isCompleted = args?['isCompleted'] ?? false;
    return MainScreen(isCompleted: isCompleted);
  },
  '/success': (context) {
    final args = ModalRoute.of(context)?.settings.arguments as Task;
    return SuccessScreen(taskData: args);
  },
  '/calendar': (context) => const CalendarScreen(),
  '/start': (context) => const StartScreen(),
  '/createAccount': (context) => const CreateAccountScreen(),
  '/categorySelection': (context) {
    final args = ModalRoute.of(context)?.settings.arguments as bool?;
    return CategorySelectionsScreen(isGuest: args ?? false);
  },
  '/confidence': (context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    return ConfidenceScreen(isGuest: args['isGuest'] ?? false);
  },
  '/loginscreen': (context) => const LoginScreen(),
  '/stats': (context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, double>;
    return StatsScreen(userStats: args);
  },
  '/info': (context) => const InfoScreen(),
};
