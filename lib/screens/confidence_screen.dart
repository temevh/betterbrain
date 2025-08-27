import 'package:flutter/material.dart';
import 'package:namer_app/services/database_service.dart';
import 'package:namer_app/utils/category_utils.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ConfidenceScreen extends StatefulWidget {
  const ConfidenceScreen({super.key});

  @override
  State<ConfidenceScreen> createState() => _ConfidenceScreenState();
}

class _ConfidenceScreenState extends State<ConfidenceScreen> {
  double _chipWidth = 160;

  Map<String, double> confidence = {};

  void _onChanged(String category, double value) {
    setState(() {
      confidence[category] = value;
    });
  }

  void _saveSelections(Map<String, bool> categories) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String? token = await user.getIdToken();
      print("Token: $token");
    }

    final selectedConfidence = {
      for (var entry in categories.entries)
        if (entry.value) entry.key: confidence[entry.key] ?? 1,
    };

    print("Selected confidence: $selectedConfidence");

    final bool ok = await saveStats(selectedConfidence);

    if (!mounted) return;

    if (ok) {
      Navigator.pushNamed(context, '/');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error saving stats"),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Widget _confidenceSelection(String category) {
    final value = confidence[category] ?? 1;
    final screenWidth = MediaQuery.of(context).size.width;
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 8,
        vertical: screenWidth * 0.01,
      ),
      child: Row(
        children: [
          Container(
            width: _chipWidth,
            height: screenWidth * 0.1,
            decoration: BoxDecoration(
              color: getCategoryColor(category).withAlpha((0.25 * 255).toInt()),
              borderRadius: BorderRadius.circular(50),
              border: Border.all(color: getCategoryColor(category), width: 1.5),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  getCategoryIcon(category),
                  size: 20,
                  color: getCategoryColor(category),
                ),
                const SizedBox(width: 6),
                Text(
                  category.toUpperCase(),
                  style: TextStyle(
                    color: getCategoryColor(category),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 2),
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: Slider(
                value: value.toDouble(),
                onChanged: (newValue) => _onChanged(category, newValue),
                divisions: 9,
                max: 10,
                min: 1,
                activeColor: getCategoryColor(category),
              ),
            ),
          ),
          Text(value.toInt().toString(), style: TextStyle(fontSize: 16)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final categories =
        ModalRoute.of(context)!.settings.arguments as Map<String, bool>;
    return Scaffold(
      backgroundColor: const Color(0xFF2B2726),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
              child: Column(
                children: [
                  Text(
                    "How confident from 1 to 10 do you feel in each category? 🤔",
                    style: TextStyle(
                      fontSize: screenWidth * 0.05,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 10),
                  Opacity(
                    opacity: 0.6,
                    child: Text(
                      "Selections affect the difficulty of the tasks",
                      style: TextStyle(
                        fontSize: screenWidth * 0.04,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    for (var category in categories.entries)
                      if (category.value == true)
                        _confidenceSelection(category.key),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    _saveSelections(categories);
                  },

                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: categories.containsValue(true)
                        ? Colors.greenAccent
                        : Colors.grey,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Save",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
