import 'package:flutter/material.dart';

class InfoScreen extends StatelessWidget {
  const InfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("App info"),
        backgroundColor: const Color(0xFF2B2726),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(children: [Text("This is a solo project lol")]),
      ),
    );
  }
}
