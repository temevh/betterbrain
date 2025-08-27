import 'package:flutter/material.dart';

class ShadowBtn extends StatelessWidget {
  final VoidCallback onPressed;
  final String btnText;

  const ShadowBtn({super.key, required this.onPressed, required this.btnText});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return SizedBox(
      width: screenWidth * 0.9,
      height: screenWidth * 0.15,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(20),
        splashColor: Colors.green.withValues(alpha: 0.2), // light ripple
        highlightColor: Colors.transparent,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(
                color: Colors.green,
                offset: Offset(6, 8), // consistent shadow
                blurRadius: 0,
              ),
            ],
          ),
          child: Center(
            child: Text(
              btnText,
              style: TextStyle(
                fontSize: screenWidth * 0.07,
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
