import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:namer_app/widgets/calendar_box.dart';
import 'package:namer_app/widgets/event_card.dart';

class Event {
  final String title;
  final bool isCompleted;
  final String category;
  Event({
    required this.title,
    required this.isCompleted,
    required this.category,
  });
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
      _normalizeDate(DateTime.now().add(const Duration(days: 2))): [
        Event(
          title: 'Read a book for 12 minutes',
          category: "focus",
          isCompleted: false,
        ),
      ],
      _normalizeDate(DateTime.now().add(const Duration(days: 3))): [
        Event(title: 'Gym Session', category: "health", isCompleted: true),
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
                  return Center(child: Text('${day.day}'));
                }

                // Check if ANY event for the day is incomplete or complete
                bool allCompleted = events.every((event) => event.isCompleted);
                bool allNotCompleted = events.every(
                  (event) => !event.isCompleted,
                );

                Color bgColor = Colors.green;
                if (allCompleted) {
                  bgColor = Colors.green;
                } else if (allNotCompleted) {
                  bgColor = Colors.red;
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
                final events = _getEventsForDay(day);

                // Default color for days without events
                Color bgColor = Colors.transparent;

                if (events.isNotEmpty) {
                  // Apply same color logic as defaultBuilder
                  bool allCompleted = events.every(
                    (event) => event.isCompleted,
                  );
                  bool allNotCompleted = events.every(
                    (event) => !event.isCompleted,
                  );

                  if (allCompleted) {
                    bgColor = Colors.green;
                  } else if (allNotCompleted) {
                    bgColor = Colors.red;
                  } else {
                    bgColor = Colors.green; // Default for mixed states
                  }
                }

                return Container(
                  decoration: BoxDecoration(
                    color: bgColor,
                    shape: BoxShape.circle,
                    border: Border.all(width: 3, color: Colors.white),
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

          Expanded(
            child: ListView(
              children: _getEventsForDay(_selectedDay ?? _focusedDay).map((
                event,
              ) {
                final dayEvents = _getEventsForDay(_selectedDay ?? _focusedDay);
                return EventCard(
                  event: event,
                  selectedDate: _selectedDay ?? _focusedDay,
                  dayEvents: dayEvents,
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
