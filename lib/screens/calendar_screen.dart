import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class Event {
  final String title;
  final bool isCompleted;
  Event({required this.title, required this.isCompleted});
}

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  DateTime _normalizeDate(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  late final Map<DateTime, List<Event>> _events;

  @override
  void initState() {
    super.initState();

    _events = {
      _normalizeDate(DateTime.now()): [
        Event(title: 'Morning Run', isCompleted: true),
      ],
      _normalizeDate(DateTime.now().add(const Duration(days: 1))): [
        Event(title: 'Gym Session', isCompleted: true),
      ],
    };
  }

  List<Event> _getEventsForDay(DateTime day) {
    return _events[_normalizeDate(day)] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Calendar')),
      body: Column(
        children: [
          TableCalendar<Event>(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            eventLoader: _getEventsForDay,
            calendarFormat: CalendarFormat.month,

            calendarBuilders: CalendarBuilders(
              defaultBuilder: (context, day, focusedDay) {
                final events = _getEventsForDay(day);

                if (events.isEmpty) {
                  // No events → default text
                  return Center(child: Text('${day.day}'));
                }

                // Check if ANY event for the day is incomplete or complete
                bool allCompleted = events.every((event) => event.isCompleted);
                bool allNotCompleted = events.every(
                  (event) => !event.isCompleted,
                );

                // Decide background color
                Color bgColor;
                if (allCompleted) {
                  bgColor = Colors.green;
                } else if (allNotCompleted) {
                  bgColor = Colors.red;
                } else {
                  bgColor = Colors.orange; // mixed events
                }

                return Container(
                  decoration: BoxDecoration(
                    color: bgColor,
                    shape: BoxShape.circle,
                  ),
                  margin: const EdgeInsets.all(6),
                  alignment: Alignment.center,
                  child: Text(
                    '${day.day}',
                    style: const TextStyle(color: Colors.white),
                  ),
                );
              },

              // Selected day styling
              selectedBuilder: (context, day, focusedDay) {
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.blueAccent,
                    shape: BoxShape.circle,
                  ),
                  margin: const EdgeInsets.all(6),
                  alignment: Alignment.center,
                  child: Text(
                    '${day.day}',
                    style: const TextStyle(color: Colors.white),
                  ),
                );
              },

              // Today styling
              todayBuilder: (context, day, focusedDay) {
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.purple,
                    shape: BoxShape.circle,
                  ),
                  margin: const EdgeInsets.all(6),
                  alignment: Alignment.center,
                  child: Text(
                    '${day.day}',
                    style: const TextStyle(color: Colors.white),
                  ),
                );
              },
            ),
          ),

          /// List of events for the selected day
          Expanded(
            child: ListView(
              children: _getEventsForDay(_selectedDay ?? _focusedDay)
                  .map(
                    (event) => ListTile(
                      title: Text(event.title),
                      trailing: Icon(
                        event.isCompleted ? Icons.check_circle : Icons.cancel,
                        color: event.isCompleted ? Colors.green : Colors.red,
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}
