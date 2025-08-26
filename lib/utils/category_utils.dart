import 'package:flutter/material.dart';

IconData getCategoryIcon(String category) {
  switch (category.toLowerCase()) {
    case 'fitness':
      return Icons.fitness_center;
    case 'learning':
      return Icons.psychology;
    case 'productivity':
      return Icons.work;
    case 'selfcare':
      return Icons.spa;
    case 'social':
      return Icons.people;
    case 'focus':
      return Icons.center_focus_strong;
    case 'creativity':
      return Icons.brush;
    default:
      return Icons.help_outline;
  }
}

Color getCategoryColor(String category) {
  switch (category.toLowerCase()) {
    case 'fitness':
      return Colors.redAccent;
    case 'learning':
      return Colors.blueAccent;
    case 'productivity':
      return Colors.orangeAccent;
    case 'selfcare':
      return Colors.purpleAccent;
    case 'social':
      return Colors.teal;
    case 'focus':
      return Colors.indigo;
    case 'creativity':
      return Colors.pinkAccent;
    default:
      return Colors.grey;
  }
}
