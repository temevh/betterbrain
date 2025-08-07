import 'package:flutter/material.dart';

class FeedbackRow extends StatelessWidget {
  final void Function(int feedback) onFeedbackSelected;
  final int? selectedFeedback;

  const FeedbackRow({
    super.key,
    required this.onFeedbackSelected,
    required this.selectedFeedback,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          "How did the task feel?",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 30),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _FeedbackButton(
              emoji: '😓',
              label: 'Too hard',
              feedbackValue: -1,
              isSelected: selectedFeedback == -1,
              onPressed: onFeedbackSelected,
            ),
            SizedBox(width: 20),
            _FeedbackButton(
              emoji: '🙂',
              label: 'Just right',
              feedbackValue: 0,
              isSelected: selectedFeedback == 0,
              onPressed: onFeedbackSelected,
            ),
            SizedBox(width: 20),
            _FeedbackButton(
              emoji: '😴',
              label: 'Too easy',
              feedbackValue: 1,
              isSelected: selectedFeedback == 1,
              onPressed: onFeedbackSelected,
            ),
          ],
        ),
      ],
    );
  }
}

class _FeedbackButton extends StatelessWidget {
  final String emoji;
  final String label;
  final int feedbackValue;
  final bool isSelected;
  final void Function(int feedback) onPressed;

  const _FeedbackButton({
    required this.emoji,
    required this.label,
    required this.feedbackValue,
    required this.onPressed,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            onPressed(feedbackValue);
          },
          child: CircleAvatar(
            radius: 40,
            backgroundColor: isSelected ? Colors.white : Colors.grey[800],
            child: Text(
              emoji,
              style: TextStyle(
                fontSize: 36,
                color: isSelected ? Colors.green[800] : Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white70,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
