import 'package:flutter/material.dart';
import 'package:namer_app/widgets/Feedbackrow.dart';

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
      body: Center(
        child: SafeArea(
          child: Column(
            children: [
              SizedBox(height: 40),
              const Text(
                "🎉 Good job!",
                style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 40),
              Text(
                "Todays task was:",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20),
              ),
              Text(
                "Talk to 3 new people",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              Opacity(
                opacity: 0.5,
                child: Text(
                  'Social',
                  style: TextStyle(color: Colors.white, fontSize: 22),
                ),
              ),
              SizedBox(height: 60),
              Text(
                "How did the task feel?",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20),
              ),

              FeedbackRow(
                onFeedbackSelected: (feedback) {
                  // You can save or process the feedback here
                  print("User selected feedback: $feedback");
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
