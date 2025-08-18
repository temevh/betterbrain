import 'package:flutter/material.dart';
import 'screens/success_screen.dart';
import 'screens/main_screen.dart';
import 'screens/calendar_screen.dart';
import 'screens/start_screen.dart';
import 'screens/create_account_screen.dart';
import 'package:namer_app/screens/category_selections_screen.dart';
import 'package:namer_app/screens/confidence_screen.dart';
import 'package:namer_app/screens/login_screen.dart';

final Map<String, WidgetBuilder> appRoutes = {
  '/': (context) => const MainScreen(),
  '/success': (context) => const SuccessScreen(),
  '/calendar': (context) => const CalendarScreen(),
  '/start': (context) => const StartScreen(),
  '/createAccount': (context) => const CreateAccountScreen(),
  '/categorySelection': (context) => const CategorySelectionsScreen(),
  '/confidence': (context) => const ConfidenceScreen(),
  '/loginscreen': (context) => const LoginScreen(),
};
