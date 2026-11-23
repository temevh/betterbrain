import 'package:flutter/material.dart';
import 'package:namer_app/config.dart';
import 'package:namer_app/services/database_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!AppConfig.isConfigured) {
    runApp(const _MissingConfigApp());
    return;
  }

  await Supabase.initialize(
    url: AppConfig.supabaseUrl,
    anonKey: AppConfig.supabaseAnonKey,
  );

  // Guests from the Firebase version only had local selections; move them to
  // an anonymous Supabase user so they start getting daily tasks.
  await migrateLegacyGuest();

  String initialRoute = '/start';
  if (currentUser != null) {
    try {
      initialRoute = await userHasStats() ? '/' : '/categorySelection';
    } catch (e) {
      debugPrint('Could not load profile: $e');
      initialRoute = '/';
    }
  }

  runApp(MyApp(initialRoute: initialRoute));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.initialRoute});

  final String initialRoute;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Better brain',
      theme: ThemeData(
        fontFamily: 'RobotoMono',
        scaffoldBackgroundColor: const Color(0xFF2B2726),
        textTheme: ThemeData.dark().textTheme.apply(
          bodyColor: Colors.white,
          displayColor: Colors.white,
          fontFamily: 'RobotoMono',
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF2B2726),
          iconTheme: IconThemeData(color: Colors.white),
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontFamily: 'RobotoMono',
          ),
        ),
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: initialRoute,
      routes: appRoutes,
    );
  }
}

/// Shown when the app was built without SUPABASE_URL / SUPABASE_ANON_KEY.
class _MissingConfigApp extends StatelessWidget {
  const _MissingConfigApp();

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Color(0xFF2B2726),
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(32),
            child: Text(
              'Supabase is not configured.\n\n'
              'Copy config/app_config.example.json to config/app_config.json, '
              'fill in your project URL and anon key, and run:\n\n'
              'flutter run --dart-define-from-file=config/app_config.json',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ),
      ),
    );
  }
}
