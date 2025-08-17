import 'package:flutter/material.dart';

class CategorySelectionsScreen extends StatefulWidget {
  const CategorySelectionsScreen({super.key});

  @override
  State<CategorySelectionsScreen> createState() =>
      _CategorySelectionsScreenState();
}

class _CategorySelectionsScreenState extends State<CategorySelectionsScreen> {
  //Get categories from firebase

  Widget _categorySelection(dynamic category) {
    return Row(
      children: [
        Text(category),
        Checkbox(value: category.first, onChanged: (value) => {}),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2B2726),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Next, select the areas that you would like to improve in 📈",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 40),
              for (var c in categories.entries)
                _categorySelection(c.key, c.value),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.greenAccent,
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
      ),
    );
  }
}
