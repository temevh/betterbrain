import 'package:flutter/material.dart';
import '../screens/main_screen.dart';

class SuccessBtn extends StatefulWidget {
  final Map<String, dynamic>? taskData;
  const SuccessBtn({super.key, this.taskData});

  @override
  State<SuccessBtn> createState() => _SuccessBtnState();
}

class _SuccessBtnState extends State<SuccessBtn> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 350,
      child: GestureDetector(
        onTapDown: (_) {
          setState(() => _isPressed = true);
        },
        onTapUp: (_) async {
          setState(() => _isPressed = false);

          final result = await Navigator.pushNamed(
            context,
            '/success',
            arguments: widget.taskData,
          );

          if (result == true) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => const MainScreen(isCompleted: true),
              ),
            );
          }
        },
        onTapCancel: () {
          setState(() => _isPressed = false);
          print(widget.taskData);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          padding: const EdgeInsets.all(8),
          transform: Matrix4.translationValues(
            _isPressed ? 4 : 0, // move down when pressed
            _isPressed ? 5 : 0,
            0,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.green,
                offset: _isPressed ? const Offset(2, 3) : const Offset(8, 10),
                blurRadius: 0,
              ),
            ],
          ),
          child: Center(
            child: Text(
              "Mark completed",
              style: const TextStyle(
                fontSize: 32,
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
