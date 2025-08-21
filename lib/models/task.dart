import 'package:cloud_firestore/cloud_firestore.dart';

class Task {
  String taskText;
  String category;
  String reflection;
  bool isCompleted;
  int difficulty;
  int day;
  int month;
  int year;
  Timestamp createdAt;
  Timestamp date;

  Task({
    required this.taskText,
    required this.category,
    required this.reflection,
    required this.isCompleted,
    required this.difficulty,
    required this.day,
    required this.month,
    required this.year,
    required this.createdAt,
    required this.date,
  });
}
