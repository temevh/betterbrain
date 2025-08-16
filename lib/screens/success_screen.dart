import 'package:flutter/material.dart';
import 'package:namer_app/widgets/feedback_row.dart';
import 'package:namer_app/widgets/reflection.dart';
import 'package:namer_app/buttons/save_btn.dart';
import 'package:namer_app/utils/category_utils.dart';
import 'package:namer_app/services/database_service.dart';

class SuccessScreen extends StatefulWidget {
  final Map<String, dynamic>? taskData;
  const SuccessScreen({super.key, this.taskData});

  @override
  State<SuccessScreen> createState() => _SuccessScreenState();
}

class _SuccessScreenState extends State<SuccessScreen> {
  int? selectedFeedback;
  String reflectionText = "";
  Map<String, dynamic>? args;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        args =
            ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      });
    });
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
    if (args != null) {
      saveTask(
        args,
        "5QY7xynBreMil6jwDd9h",
        selectedFeedback ?? 0,
        reflectionText,
      );
    } else {
      print("No task data to save");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (args == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

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
                    const SizedBox(height: 20),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: const BorderRadius.all(
                          Radius.circular(12),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black,
                            offset: const Offset(8, 10),
                            blurRadius: 0,
                          ),
                        ],
                      ),
                      width: 350,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Text(
                          task,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 32,
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Opacity(
                      opacity: 0.8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: getCategoryColor(category).withOpacity(0.25),
                          borderRadius: BorderRadius.circular(50),
                          border: Border.all(
                            color: getCategoryColor(category).withOpacity(0.4),
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              getCategoryIcon(category),
                              size: 20,
                              color: getCategoryColor(category),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              category,
                              style: TextStyle(
                                color: getCategoryColor(category),
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
