import 'package:flutter/material.dart';

class Reflection extends StatefulWidget {
  final void Function(String) onChanged;

  const Reflection({super.key, required this.onChanged});

  @override
  State<Reflection> createState() => _ReflectionState();
}

class _ReflectionState extends State<Reflection> {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Column(
      children: [
        Opacity(
          opacity: 0.8,
          child: Text(
            "Optional reflection",
            style: TextStyle(fontSize: screenWidth * 0.04),
          ),
        ),
        SizedBox(height: screenWidth * 0.02),
        Center(
          child: Container(
            width: screenWidth * 0.9,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 6,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              maxLines: 4,
              style: TextStyle(color: Colors.black),
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: "📝 Write your reflection here...",
                contentPadding: EdgeInsets.all(12),
              ),
              onChanged: widget.onChanged,
            ),
          ),
        ),
      ],
    );
  }
}
