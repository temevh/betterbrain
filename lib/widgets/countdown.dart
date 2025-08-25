import 'dart:async';
import 'package:flutter/material.dart';

class CountDown extends StatefulWidget {
  final VoidCallback? onFinished;

  const CountDown({super.key, this.onFinished});
  @override
  State<CountDown> createState() => _CountDownState();
}

class _CountDownState extends State<CountDown> {
  late Timer _timer;
  Duration _timeLeft = Duration.zero;

  @override
  void initState() {
    super.initState();
    _calculateTimeLeft();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _calculateTimeLeft();
    });
  }

  void _calculateTimeLeft() {
    final now = DateTime.now();
    final midnight = DateTime(now.year, now.month, now.day + 1);
    final difference = midnight.difference(now);

    setState(() {
      _timeLeft = difference;
    });

    if (difference.inSeconds <= 0) {
      _timer.cancel();
      if (widget.onFinished != null) {
        widget.onFinished!();
      }
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hours = _timeLeft.inHours;
    final minutes = _timeLeft.inMinutes.remainder(60);
    final seconds = _timeLeft.inSeconds.remainder(60);

    return Text(
      "${hours.toString().padLeft(2, '0')}:"
      "${minutes.toString().padLeft(2, '0')}:"
      "${seconds.toString().padLeft(2, '0')}",
      style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
    );
  }
}
