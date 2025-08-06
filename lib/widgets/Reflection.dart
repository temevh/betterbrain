import 'package:flutter/material.dart';

class Reflection extends StatefulWidget {
  const Reflection({super.key});

  @override
  State<Reflection> createState() => _ReflectionState();
}

class _ReflectionState extends State<Reflection> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text("Optional reflection", style: TextStyle(fontSize: 22)),

        Center(
          child: SizedBox(
            width: 300, // adjust width to make it narrower
            child: TextField(
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.all(16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16), // rounded corners
                ),
                hintText: 'Write your reflection here...',
                filled: true,
                fillColor: Colors.white,
              ),
              maxLines: 4,
            ),
          ),
        ),
      ],
    );
  }
}
