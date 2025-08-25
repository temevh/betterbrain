import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:namer_app/screens/calendar_screen.dart';
import 'package:namer_app/widgets/category_pill.dart';

class EventCard extends StatelessWidget {
  final Event event;
  final DateTime selectedDate;

  const EventCard({super.key, required this.event, required this.selectedDate});

  Color _getContainerColor() {
    if (event.isCompleted) {
      return Colors.green;
    } else {
      return Colors.red;
    }
  }

  String getDifficultyEmoji(int difficulty) {
    switch (difficulty) {
      case -1:
        return "😓 Too hard";
      case 0:
        return "🙂 Just right";
      case 1:
        return "😴 Too easy";
      case 404:
        return "❓ unknown";
      default:
        return "❓ unknown";
    }
  }

  @override
  Widget build(BuildContext context) {
    final containerColor = _getContainerColor();
    final category = event.category.toUpperCase();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      child: Center(
        child: Container(
          width: 350,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(20),
            color: Colors.white,
            boxShadow: [
              BoxShadow(color: containerColor, offset: const Offset(8, 10)),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                event.title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: containerColor,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              CategoryPill(category: category, size: 14),
              const SizedBox(height: 10),
              Text(
                getDifficultyEmoji(event.difficulty),
                style: TextStyle(color: Colors.black, fontSize: 20),
              ),
              SizedBox(height: 10),
              Text(
                event.reflection,
                style: TextStyle(color: Colors.black, fontSize: 20),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10),
              Opacity(
                opacity: 0.7,
                child: Text(
                  DateFormat('yyyy-MM-dd').format(selectedDate),
                  style: TextStyle(
                    color: containerColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
