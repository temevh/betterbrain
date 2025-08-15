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
        Opacity(
          opacity: 0.8,
          child: const Text(
            "How did the task feel?",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
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
          onTap: () => onPressed(feedbackValue),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutBack,
            transform: Matrix4.identity()..scale(isSelected ? 1.1 : 1.0),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected
                  ? Colors.greenAccent.withOpacity(0.2)
                  : Colors.grey[900],
              border: isSelected
                  ? Border.all(color: Colors.greenAccent, width: 3)
                  : null,
            ),
            padding: const EdgeInsets.all(10),
            child: Text(emoji, style: const TextStyle(fontSize: 36)),
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
