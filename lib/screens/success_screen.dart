import 'package:flutter/material.dart';
import 'package:namer_app/widgets/Feedbackrow.dart';
import 'package:namer_app/widgets/Feedback_input.dart';
import 'package:namer_app/buttons/save_btn.dart';

class SuccessScreen extends StatefulWidget {
  const SuccessScreen({super.key});

  @override
  State<SuccessScreen> createState() => _SuccessScreenState();
}

class _SuccessScreenState extends State<SuccessScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green,
      body: SafeArea(
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.spaceBetween, // 👈 Pushes SaveBtn to bottom
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 40),
                    const Text(
                      "🎉 Good job!",
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 40),
                    const Text(
                      "Todays task was:",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 20),
                    ),
                    const Text(
                      "Talk to 3 new people",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Opacity(
                      opacity: 0.5,
                      child: Text(
                        'Social',
                        style: TextStyle(color: Colors.white, fontSize: 22),
                      ),
                    ),
                    const SizedBox(height: 60),
                    const Text(
                      "How did the task feel?",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 20),
                    ),
                    FeedbackRow(
                      onFeedbackSelected: (feedback) {
                        print("User selected feedback: $feedback");
                      },
                    ),
                    const SizedBox(height: 10),
                    const FeedbackInput(),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0), // 👈 Optional padding
              child: SaveBtn(),
            ),
          ],
        ),
      ),
    );
  }
}
