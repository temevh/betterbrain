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
    return Column(
      children: [
        const Text("Optional reflection", style: TextStyle(fontSize: 22)),

        Center(
          child: Container(
            width: 350,
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
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: "Write your reflection here...",
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
