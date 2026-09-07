import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:namer_app/services/database_service.dart';
import 'routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  String initialRoute = '/start';

  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final String? guestExists = prefs.getString('selections');

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  final User? currentUser = FirebaseAuth.instance.currentUser;

  print("CurrentUser: $currentUser");
  print("Guest stats exist: ${guestExists != null}");

  if (currentUser != null) {
    if (await userHasStats(currentUser)) {
      initialRoute = '/';
    } else {
      initialRoute = '/categorySelection';
    }
  } else if (guestExists != null) {
    initialRoute = '/';
  } else {
    initialRoute = '/start';
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
