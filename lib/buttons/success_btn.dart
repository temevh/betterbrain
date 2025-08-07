import 'package:flutter/material.dart';
import '../screens/main_screen.dart';

class SuccessBtn extends StatelessWidget {
  const SuccessBtn({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 350,
      child: ElevatedButton(
        onPressed: () async {
          final result = await Navigator.pushNamed(context, '/success');

          if (result == true) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => const MainScreen(showGreenBackground: true),
              ),
            );
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          minimumSize: Size(200, 60),
          textStyle: TextStyle(fontSize: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Colors.grey, width: 4),
          ),
        ),
        child: Text("Yes!", style: TextStyle(fontSize: 40)),
      ),
    );
  }
}
