import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';

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
    print("################");
    print(widget.taskData);
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
    final category = widget.taskData?['category'] ?? '';

    return Column(
      children: [
        if (category.isNotEmpty)
          Image.asset('assets/images/$category.png', height: 280)
        else
          const SizedBox(height: 340),
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
                  style: const TextStyle(color: Colors.white, fontSize: 22),
                ),
              ),
              SizedBox(
                width: 340,
                child: Divider(
                  thickness: 3,
                  color: Colors.white.withOpacity(0.2),
                  indent: 50,
                  endIndent: 50,
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: 350,
                child: Text(
                  widget.taskData?['task'],
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Container(
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
            ],
          ),
        ),
      ],
    );
  }
}
