import 'package:flutter/material.dart';
import 'package:namer_app/utils/category_utils.dart';

class CategorySelectionsScreen extends StatefulWidget {
  final bool isGuest;
  const CategorySelectionsScreen({super.key, this.isGuest = false});

  @override
  State<CategorySelectionsScreen> createState() =>
      _CategorySelectionsScreenState();
}

class _CategorySelectionsScreenState extends State<CategorySelectionsScreen> {
  final categories = {
    "fitness": false,
    "learning": false,
    "productivity": false,
    "selfcare": false,
    "social": false,
    "focus": false,
    "creativity": false,
  };

  Widget _categorySelection(String category, bool value) {
    final screenWidth = MediaQuery.of(context).size.width;

    final pillHeight = screenWidth * 0.14;
    final horizontalPadding = screenWidth * 0.03;
    final verticalPadding = screenWidth * 0.01;
    final fontSize = screenWidth * 0.045;
    final iconSize = screenWidth * 0.05;

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
              height: pillHeight,
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: verticalPadding,
              ),
              decoration: BoxDecoration(
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
                        size: iconSize,
                        color: getCategoryColor(category),
                      ),
                      SizedBox(width: screenWidth * 0.015),
                      Text(
                        category.toUpperCase(),
                        style: TextStyle(
                          color: getCategoryColor(category),
                          fontSize: fontSize,
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
        SizedBox(height: screenWidth * 0.03), // spacing between pills
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFF2B2726),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Next, select the areas that you would like to improve in 📈",
                style: TextStyle(
                  fontSize: screenWidth * 0.05,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                widget.isGuest ? "Guest Mode: ON" : "Guest Mode: OFF",
                style: const TextStyle(color: Colors.white),
              ),
              SizedBox(height: screenHeight * 0.02),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      for (var c in categories.entries)
                        _categorySelection(c.key, c.value),
                    ],
                  ),
                ),
              ),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    categories.containsValue(true)
                        ? Navigator.pushNamed(
                            context,
                            ('/confidence'),
                            arguments: {
                              "categories": categories,
                              "isGuest": widget.isGuest,
                            },
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
