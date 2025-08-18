import 'package:flutter/material.dart';

IconData getCategoryIcon(String category) {
  switch (category.toLowerCase()) {
    case 'social':
      return Icons.people;
    case 'health':
      return Icons.favorite;
    case 'productivity':
      return Icons.work;
    case 'selfcare':
      return Icons.bathtub;
    case 'learning':
      return Icons.psychology;
    default:
      return Icons.help_outline;
  }
}

Color getCategoryColor(String category) {
  switch (category.toLowerCase()) {
    case 'social':
      return Colors.blueAccent;
    case 'health':
      return Colors.green;
    case 'productivity':
      return Colors.orangeAccent;
    case 'selfcare':
      return Colors.red;
    case 'learning':
      return Colors.cyanAccent;
    default:
      return Colors.grey;
  }
}
