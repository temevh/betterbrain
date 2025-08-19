import 'package:flutter/material.dart';
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

  void _saveSelections(dynamic categories) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String? token = await user.getIdToken(); // JWT token
      print("Token: $token");
    }

    /*
    categories.containsValue(true)
        ? Navigator.pushNamed(context, ('/'), arguments: categories)
        : null;
        */
  }

  Widget _confidenceSelection(String category) {
    final value = confidence[category] ?? 1;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      child: Row(
        children: [
          Container(
            width: _chipWidth, // fixed width for all chips
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: getCategoryColor(category).withOpacity(0.25),
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
          const SizedBox(width: 12),
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
    final categories =
        ModalRoute.of(context)!.settings.arguments as Map<String, bool>;
    return Scaffold(
      backgroundColor: const Color(0xFF2B2726),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 28),
              child: Column(
                children: [
                  const Text(
                    "How confident from 1 to 10 do you feel in each category? 🤔",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 10),
                  Opacity(
                    opacity: 0.6,
                    child: const Text(
                      "Selections affect the difficulty of the tasks",
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            for (var category in categories.entries)
              if (category.value == true) _confidenceSelection(category.key),
            Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
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
