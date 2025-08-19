import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'package:flutter/material.dart';
import 'routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  final User? currentUser = FirebaseAuth.instance.currentUser;
  final String initialRoute = currentUser == null ? '/start' : '/';
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
