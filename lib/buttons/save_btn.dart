import 'package:flutter/material.dart';

class SaveBtn extends StatelessWidget {
  final VoidCallback onPressed;

  const SaveBtn({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          onPressed();
          Navigator.pop(context, true);
        },
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 20),
          backgroundColor: Colors.white,
          foregroundColor: Colors.green[800],
          elevation: 8,
          shadowColor: Colors.black45,
          textStyle: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: const Text("Save"),
      ),
    );
  }
}
