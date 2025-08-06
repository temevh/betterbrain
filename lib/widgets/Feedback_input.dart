import 'package:flutter/material.dart';

class FeedbackInput extends StatefulWidget {
  const FeedbackInput({super.key});

  @override
  State<FeedbackInput> createState() => _FeedbackInputState();
}

class _FeedbackInputState extends State<FeedbackInput> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text("Optional feedback", style: TextStyle(fontSize: 22)),

        Center(
          child: SizedBox(
            width: 300, // adjust width to make it narrower
            child: TextField(
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.all(16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16), // rounded corners
                ),
                hintText: 'Write your feedback here...',
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
