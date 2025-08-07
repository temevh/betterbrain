import 'package:flutter/material.dart';
import '../widgets/task_box.dart';
import '../buttons/success_btn.dart';
import '../buttons/failure_btn.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Scaffold(
          backgroundColor: const Color(0xFF2B2726),
          body: Center(
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),
                  Image.asset('assets/images/talking.png', height: 340),
                  const TaskBox(),
                  const SizedBox(height: 10),
                  const Text(
                    "Did you do it?",
                    style: TextStyle(color: Colors.white, fontSize: 28),
                  ),
                  const SizedBox(height: 20),
                  const SuccessBtn(),
                  const SizedBox(height: 10),
                  const FailureBtn(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
