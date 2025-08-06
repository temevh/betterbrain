import 'package:flutter/material.dart';

class FeedbackRow extends StatelessWidget {
  final void Function(String feedback) onFeedbackSelected;

  const FeedbackRow({super.key, required this.onFeedbackSelected});

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
          children: const [
            _FeedbackButton(
              emoji: '😓',
              label: 'Too hard',
              feedbackValue: 'too_hard',
            ),
            SizedBox(width: 20),
            _FeedbackButton(
              emoji: '🙂',
              label: 'Just right',
              feedbackValue: 'just_right',
            ),
            SizedBox(width: 20),
            _FeedbackButton(
              emoji: '😴',
              label: 'Too easy',
              feedbackValue: 'too_easy',
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
  final String feedbackValue;

  const _FeedbackButton({
    required this.emoji,
    required this.label,
    required this.feedbackValue,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Feedback: $label')));
          },
          child: CircleAvatar(
            radius: 40,
            backgroundColor: Colors.grey[800],
            child: Text(emoji, style: const TextStyle(fontSize: 36)),
          ),
        ),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(color: Colors.white)),
      ],
    );
  }
}
