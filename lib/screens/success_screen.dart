import 'package:flutter/material.dart';
import 'package:namer_app/widgets/Feedbackrow.dart';
import 'package:namer_app/widgets/Reflection.dart';
import 'package:namer_app/buttons/save_btn.dart';
import 'package:namer_app/widgets/task_reflection.dart';

class SuccessScreen extends StatefulWidget {
  const SuccessScreen({super.key});

  @override
  State<SuccessScreen> createState() => _SuccessScreenState();
}

class _SuccessScreenState extends State<SuccessScreen> {
  int? selectedFeedback;
  String reflectionText = "";

  void _onFeedbackSelected(int feedback) {
    setState(() {
      selectedFeedback = feedback;
    });
  }

  void _onReflectionTextChanged(String text) {
    setState(() {
      reflectionText = text;
    });
  }

  void _onSavePressed() {
    print("User feedback selection: $selectedFeedback");
    print("User reflection text: $reflectionText");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const Text(
                      "🎉 Good job!",
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 40),
                    TaskReflection(),
                    const SizedBox(height: 40),

                    FeedbackRow(
                      selectedFeedback: selectedFeedback,
                      onFeedbackSelected: _onFeedbackSelected,
                    ),
                    const SizedBox(height: 40),
                    Reflection(onChanged: _onReflectionTextChanged),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SaveBtn(onPressed: _onSavePressed),
            ),
          ],
        ),
      ),
    );
  }
}
