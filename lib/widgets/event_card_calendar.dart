import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:namer_app/screens/calendar_screen.dart';
import 'package:namer_app/utils/category_utils.dart';

class EventCard extends StatelessWidget {
  final Event event;
  final DateTime selectedDate;
  final List<Event> dayEvents;

  const EventCard({
    super.key,
    required this.event,
    required this.selectedDate,
    required this.dayEvents,
  });

  Color _getContainerColor() {
    bool allCompleted = dayEvents.every((e) => e.isCompleted);
    bool allNotCompleted = dayEvents.every((e) => !e.isCompleted);

    if (allCompleted) {
      return Colors.green;
    } else if (allNotCompleted) {
      return Colors.red;
    } else {
      return Colors.green;
    }
  }

  String difficultyEmoji(int difficulty) {
    switch (difficulty) {
      case -1:
        return "😓";
      case 0:
        return "🙂";
      case 1:
        return "😴";
      default:
        return "❓";
    }
  }

  @override
  Widget build(BuildContext context) {
    final containerColor = _getContainerColor();
    final category = event.category.toUpperCase();

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 20, 8, 20),
      child: Center(
        child: Container(
          width: 320,
          padding: const EdgeInsets.all(16),
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
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
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
                        size: 16,
                        color: getCategoryColor(category),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        category,
                        style: TextStyle(
                          color: getCategoryColor(category),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const SizedBox(height: 8),
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
