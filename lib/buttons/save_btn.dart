import 'package:flutter/material.dart';

class SaveBtn extends StatelessWidget {
  const SaveBtn({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity, // Full width inside the padding
      child: ElevatedButton(
        onPressed: () {
          Navigator.pushNamed(context, '/');
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
