import 'package:flutter/material.dart';
import 'task_box.dart';
import 'buttons/success_btn.dart';
import 'buttons/failure_btn.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Namer App',
      theme: ThemeData(
        fontFamily: 'RobotoMono',
        scaffoldBackgroundColor: const Color(0xFF2B2726),
        textTheme: ThemeData.dark().textTheme.apply(
          bodyColor: Colors.white,
          displayColor: Colors.white,
        ),
      ),
      home: MyHomePage(),
    );
  }
}

class MyAppState extends ChangeNotifier {}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Scaffold(
          backgroundColor: Color(0xFF2B2726),
          body: Center(
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 40),
                  Image.asset('assets/images/talking.png', height: 340),
                  TaskBox(),
                  SizedBox(height: 10),
                  Text(
                    "Did you do it?",
                    style: TextStyle(color: Colors.white, fontSize: 28),
                  ),
                  SizedBox(height: 20),
                  SuccessBtn(),
                  SizedBox(height: 10),
                  FailureBtn(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
