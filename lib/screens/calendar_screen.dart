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
  final String reflection;

  Event({
    required this.category,
    required this.date,
    required this.difficulty,
    required this.isCompleted,
    required this.title,
    required this.reflection,
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
  final Map<DateTime, Event> _events = {};

  DateTime _normalizeDate(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final userTasks = ModalRoute.of(context)!.settings.arguments as List<Task>;
    _setEvents(userTasks);
  }

  void _setEvents(List<Task> userTasks) {
    final Map<DateTime, Event> eventsMap = {};
    for (var task in userTasks) {
      final dateTime = task.date.toDate();
      eventsMap[_normalizeDate(dateTime)] = Event(
        category: task.category,
        date: dateTime,
        difficulty: task.difficulty,
        isCompleted: task.isCompleted,
        title: task.taskText,
        reflection: task.reflection,
      );
    }
    setState(() {
      _events.clear();
      _events.addAll(eventsMap);
    });
  }

  Event? _getEventForDay(DateTime day) => _events[_normalizeDate(day)];

  Color _bgForDay(DateTime day) {
    final event = _getEventForDay(day);
    if (event == null) return Colors.transparent;
    return event.isCompleted ? Colors.green : Colors.red;
  }

  Widget _buildDayCell(DateTime day, bool isSelected) {
    final bg = _bgForDay(day);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.all(4),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: bg,
        shape: BoxShape.circle,
        border: isSelected ? Border.all(width: 2, color: Colors.white) : null,
        boxShadow: bg != Colors.transparent
            ? [BoxShadow(color: bg, blurRadius: 6, spreadRadius: 1)]
            : [],
      ),
      child: Text(
        '${day.day}',
        style: const TextStyle(fontSize: 18, color: Colors.white),
      ),
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
            eventLoader: (day) {
              final event = _getEventForDay(day);
              return event != null ? [event] : [];
            },
            calendarFormat: CalendarFormat.month,
            calendarStyle: const CalendarStyle(isTodayHighlighted: false),
            headerStyle: const HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
              titleTextStyle: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            calendarBuilders: CalendarBuilders(
              markerBuilder: (context, day, events) => const SizedBox(),
              defaultBuilder: (context, day, focusedDay) =>
                  _buildDayCell(day, false),
              todayBuilder: (context, day, focusedDay) =>
                  _buildDayCell(day, false),
              selectedBuilder: (context, day, focusedDay) =>
                  _buildDayCell(day, true),
            ),
          ),

          Expanded(
            child: ListView(
              children: _getEventForDay(_selectedDay ?? _focusedDay) != null
                  ? [
                      EventCard(
                        event: _getEventForDay(_selectedDay ?? _focusedDay)!,
                        selectedDate: _selectedDay ?? _focusedDay,
                      ),
                    ]
                  : [],
            ),
          ),
        ],
      ),
    );
  }
}
