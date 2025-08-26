import 'package:flutter/material.dart';
import 'package:namer_app/utils/category_utils.dart';

class CategoryPill extends StatelessWidget {
  final String category;
  final double size;

  const CategoryPill({super.key, required this.category, required this.size});

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
            size: size,
            color: getCategoryColor(category),
          ),
          const SizedBox(width: 6),
          Text(
            category.toUpperCase(),
            style: TextStyle(
              color: getCategoryColor(category),
              fontSize: size,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
