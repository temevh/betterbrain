import 'package:flutter/material.dart';

class TaskBox extends StatelessWidget {
  const TaskBox({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      margin: const EdgeInsets.only(top: 30),
      decoration: BoxDecoration(
        color: const Color(0xFF3A3A3A),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: const [
          Opacity(
            opacity: 0.5,
            child: Text(
              '1.8.2025',
              style: TextStyle(color: Colors.white, fontSize: 22),
            ),
          ),
          SizedBox(height: 10),
          SizedBox(
            width: 350,
            child: Text(
              'Talk to 3 new people',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 40,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          SizedBox(height: 10),
          Opacity(
            opacity: 0.5,
            child: Text(
              'Social',
              style: TextStyle(color: Colors.white, fontSize: 22),
            ),
          ),
        ],
      ),
    );
  }
}
