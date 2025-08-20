// success_btn.dart
import 'package:flutter/material.dart';

class SuccessBtn extends StatefulWidget {
  final VoidCallback onPressed;
  const SuccessBtn({super.key, required this.onPressed});

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
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) {
          setState(() => _isPressed = false);
          widget.onPressed();
        },
        onTapCancel: () => setState(() => _isPressed = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          padding: const EdgeInsets.all(8),
          transform: Matrix4.translationValues(
            _isPressed ? 4 : 0,
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
          child: const Center(
            child: Text(
              "Mark completed",
              style: TextStyle(
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
