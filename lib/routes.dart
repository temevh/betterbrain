import 'package:flutter/material.dart';
import 'screens/success_screen.dart';
import 'screens/main_screen.dart';

final Map<String, WidgetBuilder> appRoutes = {
  '/': (context) => const MainScreen(),
  '/success': (context) => const SuccessScreen(),
};
