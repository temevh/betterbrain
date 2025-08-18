import 'package:flutter/material.dart';

Widget buildInputField(
  String hint,
  IconData icon,
  void Function(String) onChanged, {
  bool obscure = false,
}) {
  return TextField(
    obscureText: obscure,
    style: const TextStyle(color: Colors.white),
    onChanged: onChanged,
    decoration: InputDecoration(
      filled: true,
      fillColor: Colors.white10,
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.white54),
      prefixIcon: Icon(icon, color: Colors.white70),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.greenAccent, width: 2),
      ),
    ),
  );
}
