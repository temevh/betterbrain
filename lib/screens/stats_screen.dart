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
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (userStats.isEmpty)
              const Text(
                "No stats available yet.",
                style: TextStyle(fontSize: 18, color: Colors.grey),
              )
            else
              ...userStats.entries.map(
                (stat) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CategoryPill(category: stat.key, size: 14),
                      Text(
                        stat.value.toStringAsFixed(1),
                        style: TextStyle(
                          fontSize: 18,
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
