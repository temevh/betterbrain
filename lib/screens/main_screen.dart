import 'package:flutter/material.dart';
import '../widgets/task_box.dart';
import '../buttons/success_btn.dart';
import '../buttons/failure_btn.dart';

class MainScreen extends StatefulWidget {
  final bool isCompleted;

  const MainScreen({super.key, this.isCompleted = false});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late bool _completed;

  @override
  void initState() {
    super.initState();
    _completed = widget.isCompleted;

    if (_completed) {
      Future.delayed(const Duration(seconds: 10), () {
        setState(() {
          _completed = false;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _completed ? Colors.green : const Color(0xFF2B2726),
      body: Center(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              Image.asset('assets/images/talking.png', height: 340),
              const TaskBox(),
              const SizedBox(height: 10),
              Text(
                _completed ? "Well done!" : "Did you do it?",
                style: TextStyle(color: Colors.white, fontSize: 28),
              ),
              const SizedBox(height: 20),
              if (!_completed) ...[
                const SuccessBtn(),
                const SizedBox(height: 10),
                const FailureBtn(),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
