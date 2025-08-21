import 'package:flutter/material.dart';
import 'package:namer_app/utils/category_utils.dart';

class CategorySelectionsScreen extends StatefulWidget {
  const CategorySelectionsScreen({super.key});

  @override
  State<CategorySelectionsScreen> createState() =>
      _CategorySelectionsScreenState();
}

class _CategorySelectionsScreenState extends State<CategorySelectionsScreen> {
  //Get categories from firebase s
  final categories = {
    "health": false,
    "learning": false,
    "productivity": false,
    "selfcare": false,
    "social": false,
  };

  Widget _categorySelection(String category, bool value) {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              categories.update(category, (v) => !v);
            });
          },
          child: Opacity(
            opacity: value == true ? 1 : 0.3,
            child: Container(
              height: 60,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                // ignore: deprecated_member_use
                color: getCategoryColor(category).withOpacity(0.3),
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
                          fontSize: 18,
                          fontWeight: value == true
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
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
              Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    categories.containsValue(true)
                        ? Navigator.pushNamed(
                            context,
                            ('/confidence'),
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
                    "Next",
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
