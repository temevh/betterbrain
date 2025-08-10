import 'package:flutter/material.dart';

class TaskReflection extends StatelessWidget {
  const TaskReflection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          "Todays task was:",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 20),
        ),
        const Text(
          "Talk to 3 new people",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        const Opacity(
          opacity: 0.5,
          child: Text(
            'Social',
            style: TextStyle(color: Colors.white, fontSize: 22),
          ),
        ),
      ],
    );
  }
}
