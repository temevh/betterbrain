import 'package:flutter/material.dart';
import 'screens/success_screen.dart';
import 'screens/main_screen.dart';
import 'screens/calendar_screen.dart';
import 'screens/start_screen.dart';
import 'screens/create_account_screen.dart';

final Map<String, WidgetBuilder> appRoutes = {
  '/': (context) => const MainScreen(),
  '/success': (context) => const SuccessScreen(),
  '/calendar': (context) => const CalendarScreen(),
  '/start': (context) => const StartScreen(),
  '/createAccount': (context) => const CreateAccountScreen(),
};
