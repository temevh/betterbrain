import 'package:flutter/material.dart';
import 'package:namer_app/utils/category_utils.dart';

class ConfidenceScreen extends StatefulWidget {
  const ConfidenceScreen({super.key});

  @override
  State<ConfidenceScreen> createState() => _ConfidenceScreenState();
}

class _ConfidenceScreenState extends State<ConfidenceScreen> {
  double _sliderValue = 5;
  double _chipWidth = 0;

  @override
  void initState() {
    super.initState();
    _chipWidth = 140;
  }

  Widget _confidenceSelection(String category) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          child: Row(
            children: [
              Container(
                width: _chipWidth,
                height: 40,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: getCategoryColor(category).withOpacity(0.25),
                  borderRadius: BorderRadius.circular(50),
                  border: Border.all(
                    color: getCategoryColor(category),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
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
                  ],
                ),
              ),
              Expanded(
                child: Slider(
                  value: 5,
                  onChanged: (value) => {},
                  max: 10,
                  min: 1,
                  activeColor: getCategoryColor(category),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 20),
      ],
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
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
              child: const Text(
                "How confident from 1 to 10 do you feel in each category?",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(height: 40),
            for (var category in categories.entries)
              if (category.value == true) _confidenceSelection(category.key),
            Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  categories.containsValue(true)
                      ? Navigator.pushNamed(
                          context,
                          ('/'),
                          arguments: categories,
                        )
                      : null;
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
          ],
        ),
      ),
    );
  }
}
