import 'package:flutter/material.dart';

class FailureBtn extends StatelessWidget {
  const FailureBtn({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 180,
      child: ElevatedButton(
        onPressed: () => {},
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          minimumSize: Size(120, 48),
          textStyle: TextStyle(fontSize: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Colors.grey, width: 2),
          ),
        ),
        child: Text("Not yet..."),
      ),
    );
  }
}
