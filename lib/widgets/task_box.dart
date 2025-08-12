import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart';

class TaskBox extends StatefulWidget {
  const TaskBox({super.key});

  @override
  State<TaskBox> createState() => _TaskBoxState();
}

class _TaskBoxState extends State<TaskBox> {
  String randomTask = "";
  String category = "";

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    final String jsonString = await rootBundle.loadString('assets/tasks.json');
    final Map<String, dynamic> jsonData = json.decode(jsonString);

    final List<Map<String, dynamic>> allTasks = [];
    jsonData.forEach((category, tasks) {
      for (var task in tasks) {
        allTasks.add({"task": task["task"], "category": category});
      }
    });

    final random = Random();
    final chosen = allTasks[random.nextInt(allTasks.length)];

    setState(() {
      randomTask = insertDigit(chosen["task"], random);
      category = chosen["category"] ?? "Could not set category";
    });
  }

  String insertDigit(String input, Random random) {
    String replaced = input.replaceAll('§', random.nextInt(26).toString());
    return replaced;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      margin: const EdgeInsets.only(top: 30),
      decoration: BoxDecoration(
        color: const Color(0xFF3A3A3A),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Opacity(
            opacity: 0.5,
            child: Text(
              '1.8.2025',
              style: TextStyle(color: Colors.white, fontSize: 22),
            ),
          ),
          SizedBox(height: 10),
          SizedBox(
            width: 350,
            child: Text(
              randomTask.isNotEmpty ? randomTask : "Loading task...",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 40,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          SizedBox(height: 10),
          Opacity(
            opacity: 0.5,
            child: Text(
              category.isNotEmpty
                  ? category.toUpperCase()
                  : "Loading category...",
              style: TextStyle(color: Colors.white, fontSize: 22),
            ),
          ),
        ],
      ),
    );
  }
}
