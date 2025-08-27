import 'package:flutter/material.dart';
import 'package:namer_app/widgets/category_pill.dart';
import 'package:namer_app/utils/category_utils.dart';

class StatsScreen extends StatelessWidget {
  final Map<String, double> userStats;

  const StatsScreen({super.key, required this.userStats});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Stats"),
        backgroundColor: const Color(0xFF2B2726),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20), // uniform padding
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "You are doing great! ⭐",
                style: TextStyle(
                  fontSize: screenWidth * 0.06,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              Opacity(
                opacity: 0.6,
                child: Text(
                  "Keep improving by completing a task every day!",
                  style: TextStyle(
                    fontSize: screenWidth * 0.04,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(height: screenWidth * 0.05),
              if (userStats.isEmpty)
                const Text(
                  "No stats available yet.",
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                )
              else
                ...userStats.entries.map(
                  (stat) => Padding(
                    padding: EdgeInsets.symmetric(vertical: screenWidth * 0.03),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CategoryPill(
                          category: stat.key,
                          size: screenWidth * 0.04,
                        ),
                        Text(
                          stat.value.toStringAsFixed(1),
                          style: TextStyle(
                            fontSize: screenWidth * 0.07,
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
      ),
    );
  }
}
