import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:namer_app/widgets/feedback_row.dart';
import 'package:namer_app/widgets/reflection.dart';
import 'package:namer_app/buttons/save_btn.dart';

class SuccessScreen extends StatefulWidget {
  final Map<String, dynamic>? taskData;
  const SuccessScreen({super.key, this.taskData});

  @override
  State<SuccessScreen> createState() => _SuccessScreenState();
}

class _SuccessScreenState extends State<SuccessScreen> {
  int? selectedFeedback;
  String reflectionText = "";
  dynamic task = {};

  @override
  void initState() {
    super.initState();
  }

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

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'social':
        return Icons.people;
      case 'health':
        return Icons.favorite;
      case 'productivity':
        return Icons.work;
      case 'selfcare':
        return Icons.bathtub;
      case 'learning':
        return Icons.psychology;
      default:
        return Icons.help_outline;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'social':
        return Colors.blueAccent;
      case 'health':
        return Colors.green;
      case 'productivity':
        return Colors.orangeAccent;
      case 'selfcare':
        return Colors.red;
      case 'learning':
        return Colors.indigo;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
    final task = args?['task'] ?? 'Unknown task';
    final category = args?['category'] ?? 'Unknown category';

    return Scaffold(
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
                        fontSize: 44,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    /* 
                    Opacity(
                      opacity: 0.6,
                      child: const Text(
                        "Todays task was:",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 20),
                      ),
                    ),*/
                    SizedBox(height: 20),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blueGrey,
                            offset: const Offset(8, 10),
                            blurRadius: 0,
                          ),
                        ],
                      ),
                      width: 350,
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Text(
                              task,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),
                    Opacity(
                      opacity: 0.8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: _getCategoryColor(category).withOpacity(0.25),
                          borderRadius: BorderRadius.circular(50),
                          border: Border.all(
                            color: _getCategoryColor(category).withOpacity(0.4),
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _getCategoryIcon(category),
                              size: 20,
                              color: _getCategoryColor(category),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              category,
                              style: TextStyle(
                                color: _getCategoryColor(category),
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    FeedbackRow(
                      selectedFeedback: selectedFeedback,
                      onFeedbackSelected: _onFeedbackSelected,
                    ),
                    const SizedBox(height: 20),
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
