import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:namer_app/widgets/event_card_calendar.dart';
import 'package:namer_app/models/task.dart';

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

  Map<DateTime, List<Event>> _events = {};

  // Normalize DateTime to remove time
  DateTime _normalizeDate(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final userTasks = ModalRoute.of(context)!.settings.arguments as List<Task>;
    _setEvents(userTasks);
  }

  void _setEvents(List<Task> userTasks) {
    final Map<DateTime, List<Event>> eventsMap = {};

    for (var task in userTasks) {
      final dateTime = task.date.toDate();
      final dayKey = _normalizeDate(dateTime);

      final event = Event(
        category: task.category,
        date: dateTime,
        difficulty: task.difficulty,
        isCompleted: task.isCompleted,
        title: task.taskText,
      );

      eventsMap.putIfAbsent(dayKey, () => []).add(event);
    }

    setState(() {
      _events = eventsMap;
    });
  }

  List<Event> _getEventsForDay(DateTime day) {
    return _events[_normalizeDate(day)] ?? [];
  }

  Color _bgForDay(DateTime day) {
    final events = _getEventsForDay(day);
    if (events.isEmpty) return Colors.transparent;

    final allCompleted = events.every((e) => e.isCompleted);
    final allNotCompleted = events.every((e) => !e.isCompleted);

    if (allCompleted) return Colors.green;
    if (allNotCompleted) return Colors.red;
    return Colors.orange; // mixed
  }

  Widget _buildDayCell(DateTime day, DateTime focusedDay, bool isSelected) {
    final bg = _bgForDay(day);
    final text = Text(
      '${day.day}',
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 18,
        color: bg == Colors.transparent ? Colors.black : Colors.white,
      ),
    );

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.all(6),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: bg,
        shape: BoxShape.circle,
        border: isSelected ? Border.all(width: 2, color: Colors.white) : null,
        boxShadow: bg != Colors.transparent
            ? [
                BoxShadow(
                  color: bg.withOpacity(0.4),
                  blurRadius: 6,
                  spreadRadius: 1,
                ),
              ]
            : [],
      ),
      child: text,
    );
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
            calendarStyle: const CalendarStyle(isTodayHighlighted: false),
            headerStyle: const HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
              titleTextStyle: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            calendarBuilders: CalendarBuilders(
              defaultBuilder: (context, day, focusedDay) =>
                  _buildDayCell(day, focusedDay, false),
              todayBuilder: (context, day, focusedDay) =>
                  _buildDayCell(day, focusedDay, false),
              selectedBuilder: (context, day, focusedDay) =>
                  _buildDayCell(day, focusedDay, true),
            ),
          ),

          // Event List
          Expanded(
            child: ListView(
              children: _getEventsForDay(_selectedDay ?? _focusedDay)
                  .map(
                    (event) => EventCard(
                      event: event,
                      selectedDate: _selectedDay ?? _focusedDay,
                      dayEvents: _getEventsForDay(_selectedDay ?? _focusedDay),
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
