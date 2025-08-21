import 'package:flutter/material.dart';
import 'package:namer_app/utils/category_utils.dart';

class CategoryPill extends StatelessWidget {
  final String category;

  const CategoryPill({super.key, required this.category});

  final double backgroundOpacity = 0.25;
  final double borderOpacity = 0.4;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: getCategoryColor(category).withAlpha((0.25 * 255).toInt()),
        borderRadius: BorderRadius.circular(50),
        border: Border.all(
          color: getCategoryColor(category).withAlpha((0.4 * 255).toInt()),
          width: 2,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            getCategoryIcon(category),
            size: 20,
            color: getCategoryColor(category),
          ),
          const SizedBox(width: 6),
          Text(
            category,
            style: TextStyle(
              color: getCategoryColor(category),
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
