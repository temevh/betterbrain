import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:namer_app/widgets/event_card.dart';

class Event {
  final String category;
  final DateTime date;
  final int difficulty;
  final bool isCompleted;
  final String title;
  Event({
    required this.category,
    required this.date,
    required this.difficulty,
    required this.isCompleted,
    required this.title,
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
  dynamic _events;

  DateTime _normalizeDate(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final userEvents = ModalRoute.of(context)!.settings.arguments as List?;
    _setEvents(userEvents ?? []);
  }

  Future<void> _setEvents(List userEvents) async {
    // Temporary map to hold events grouped by normalized date
    final Map<DateTime, List<Event>> eventsMap = {};

    for (var e in userEvents) {
      final data = e['event'] as Map<String, dynamic>;

      final event = Event(
        category: data['category'] ?? '',
        date: (data['date'] as Timestamp).toDate(),
        difficulty: data['difficulty'] ?? 0,
        isCompleted: data['isCompleted'] ?? false,
        title: data['title'] ?? '',
      );

      final dayKey = _normalizeDate(event.date);
      eventsMap.putIfAbsent(dayKey, () => []).add(event);
    }

    setState(() {
      _events = eventsMap; // Map<DateTime, List<Event>>
    });
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
            headerStyle: HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
              titleTextStyle: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            calendarBuilders: CalendarBuilders(
              markerBuilder: (context, day, events) {
                return const SizedBox();
              },
              defaultBuilder: (context, day, focusedDay) {
                final events = _getEventsForDay(day);
                if (events.isEmpty) {
                  return Center(child: Text('${day.day}'));
                }

                bool allCompleted = events.every((event) => event.isCompleted);
                bool allNotCompleted = events.every(
                  (event) => !event.isCompleted,
                );
                Color bgColor = allCompleted
                    ? Colors.green
                    : allNotCompleted
                    ? Colors.red
                    : Colors.orange;

                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: bgColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: bgColor.withOpacity(0.4),
                        blurRadius: 6,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  margin: const EdgeInsets.all(6),
                  alignment: Alignment.center,
                  child: Text(
                    '${day.day}',
                    style: const TextStyle(color: Colors.white),
                  ),
                );
              },

              selectedBuilder: (context, day, focusedDay) {
                // Detect if it's today
                bool isToday = isSameDay(day, DateTime.now());

                final events = _getEventsForDay(day);
                Color bgColor;

                if (isToday) {
                  bgColor = Colors.purple; // today color
                } else if (events.isNotEmpty) {
                  bool allCompleted = events.every((e) => e.isCompleted);
                  bool allNotCompleted = events.every((e) => !e.isCompleted);

                  if (allCompleted) {
                    bgColor = Colors.green;
                  } else if (allNotCompleted) {
                    bgColor = Colors.red;
                  } else {
                    bgColor = Colors.orange; // mixed state
                  }
                } else {
                  bgColor = Colors.transparent;
                }

                return Container(
                  decoration: BoxDecoration(
                    color: bgColor,
                    shape: BoxShape.circle,
                    border: Border.all(
                      width: 3,
                      color: Colors.white,
                    ), // white border
                  ),
                  margin: const EdgeInsets.all(6),
                  alignment: Alignment.center,
                  child: Text(
                    '${day.day}',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                );
              },

              todayBuilder: (context, day, focusedDay) {
                return Opacity(
                  opacity: 0.6,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.purple,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.purple,
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    margin: const EdgeInsets.all(6),
                    alignment: Alignment.center,
                    child: Text(
                      '${day.day}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
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
