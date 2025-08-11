import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:namer_app/screens/calendar_screen.dart';

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
      return Colors.green; // Default for mixed states
    }
  }

  @override
  Widget build(BuildContext context) {
    final containerColor = _getContainerColor();

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 20, 8, 20),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(20),
            color: containerColor,
            border: Border.all(width: 2, color: Colors.white),
            boxShadow: [
              BoxShadow(color: Colors.black, offset: const Offset(6, 8)),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                event.title,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Opacity(
                opacity: 0.7,
                child: Text(
                  event.category.toUpperCase(),
                  style: const TextStyle(fontSize: 18),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                DateFormat('yyyy-MM-dd').format(selectedDate),
                style: const TextStyle(fontSize: 18),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
