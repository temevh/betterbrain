import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:namer_app/widgets/category_pill.dart';

class TaskBox extends StatefulWidget {
  final Map<String, dynamic>? taskData;
  const TaskBox({super.key, this.taskData});

  @override
  State<TaskBox> createState() => _TaskBoxState();
}

class _TaskBoxState extends State<TaskBox> {
  String finalTask = "";
  List<Map<String, dynamic>> stats = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final category = widget.taskData?['category'] ?? '';
    final task = widget.taskData?['task'] ?? 'No task found :/';

    return Column(
      children: [
        if (category.isNotEmpty)
          Image.asset(
            'assets/images/$category.png',
            height: screenHeight * 0.25,
          )
        else
          SizedBox(height: screenHeight * 0.25),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          margin: const EdgeInsets.only(top: 30),
          decoration: BoxDecoration(
            color: const Color(0xFF3A3A3A),
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(color: Colors.black, offset: Offset(6, 8)),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Opacity(
                opacity: 0.5,
                child: Text(
                  DateFormat("dd.MM.yyyy").format(DateTime.now()),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: screenHeight * 0.02,
                  ),
                ),
              ),
              Opacity(
                opacity: 0.2,
                child: SizedBox(
                  width: 300,
                  child: Divider(
                    thickness: 3,
                    color: Colors.white,
                    indent: 50,
                    endIndent: 50,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: screenWidth * 0.8,
                child: Text(
                  task,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: screenHeight * 0.04,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              CategoryPill(category: category, size: screenHeight * 0.02),
            ],
          ),
        ),
      ],
    );
  }
}
