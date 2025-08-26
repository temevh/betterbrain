import 'package:flutter/material.dart';
import 'package:namer_app/widgets/category_pill.dart';
import 'package:namer_app/utils/category_utils.dart';

class StatsScreen extends StatelessWidget {
  final Map<String, double> userStats;

  const StatsScreen({super.key, required this.userStats});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Stats"),
        backgroundColor: const Color(0xFF2B2726),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20), // uniform padding
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "You are doing great! ⭐",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            const Opacity(
              opacity: 0.6,
              child: Text(
                "Keep improving by completing a task every day!",
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
            const SizedBox(height: 24),
            if (userStats.isEmpty)
              const Text(
                "No stats available yet.",
                style: TextStyle(fontSize: 18, color: Colors.grey),
              )
            else
              ...userStats.entries.map(
                (stat) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CategoryPill(category: stat.key, size: 18),
                      Text(
                        stat.value.toStringAsFixed(1),
                        style: TextStyle(
                          fontSize: 24,
                          color: getCategoryColor(stat.key),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
