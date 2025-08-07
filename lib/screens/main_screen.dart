import 'package:flutter/material.dart';
import '../widgets/task_box.dart';
import '../buttons/success_btn.dart';
import '../buttons/failure_btn.dart';

class MainScreen extends StatefulWidget {
  final bool showGreenBackground;

  const MainScreen({super.key, this.showGreenBackground = false});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late bool _showGreen;

  @override
  void initState() {
    super.initState();
    _showGreen = widget.showGreenBackground;

    if (_showGreen) {
      Future.delayed(const Duration(seconds: 10), () {
        setState(() {
          _showGreen = false;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _showGreen ? Colors.green : const Color(0xFF2B2726),
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
  }
}
