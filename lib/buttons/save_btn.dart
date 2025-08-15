import 'package:flutter/material.dart';

class SaveBtn extends StatefulWidget {
  final VoidCallback onPressed;

  const SaveBtn({super.key, required this.onPressed});

  @override
  State<SaveBtn> createState() => _SaveBtnState();
}

class _SaveBtnState extends State<SaveBtn> {
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
          widget.onPressed();
          Navigator.pop(context, true);
        },
        onTapCancel: () {
          setState(() => _isPressed = false);
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
                color: Colors.blueGrey,
                offset: _isPressed ? const Offset(2, 3) : const Offset(8, 10),
                blurRadius: 0,
              ),
            ],
          ),
          child: Center(
            child: Text(
              "Save",
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
