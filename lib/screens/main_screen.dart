import 'package:flutter/material.dart';
import 'package:namer_app/services/database_service.dart';
import '../widgets/task_box.dart';
import '../buttons/shadow_btn.dart';
import 'package:namer_app/widgets/countdown.dart';
import 'package:namer_app/models/task.dart';
import 'package:namer_app/widgets/drawer_widget.dart';

class MainScreen extends StatefulWidget {
  final bool isCompleted;
  const MainScreen({super.key, this.isCompleted = false});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  Task? _todayTask;
  bool _loading = true;
  bool _swapping = false;

  @override
  void initState() {
    super.initState();
    _loadTask();
  }

  // The server assigns and stores today's task on first request, and records
  // missed days itself, so the app only has to ask for today's task.
  Future<void> _loadTask() async {
    setState(() => _loading = true);
    final task = await getDailyTask();
    if (!mounted) return;
    setState(() {
      _todayTask = task;
      _loading = false;
    });
  }

  Future<void> _swapTask() async {
    setState(() => _swapping = true);
    try {
      final task = await swapDailyTask();
      if (!mounted) return;
      setState(() => _todayTask = task);
    } catch (message) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message.toString())));
    } finally {
      if (mounted) setState(() => _swapping = false);
    }
  }

  void resetTask() {
    _loadTask();
  }

  @override
  Widget build(BuildContext context) {
    final isCompleted = _todayTask?.isCompleted ?? false;
    final screenWidth = MediaQuery.of(context).size.width;
    bool isSmallScreen(double width) => width < 400;
    bool isMediumScreen(double width) => width >= 400 && width < 800;

    double congratsFontSize;
    double countdownFontSize;

    if (isSmallScreen(screenWidth)) {
      congratsFontSize = 18;
      countdownFontSize = 18;
    } else if (isMediumScreen(screenWidth)) {
      congratsFontSize = 28;
      countdownFontSize = 28;
    } else {
      congratsFontSize = 36;
      countdownFontSize = 36;
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: isCompleted ? Colors.green : const Color(0xFF2B2726),
        leading: Builder(
          builder: (context) {
            return IconButton(
              onPressed: Scaffold.of(context).openDrawer,
              icon: const Icon(Icons.menu, color: Colors.white, size: 30),
            );
          },
        ),
      ),
      drawer: currentUser != null
          ? DrawerWidget(user: currentUser!)
          : const SizedBox.shrink(),
      backgroundColor: isCompleted ? Colors.green : const Color(0xFF2B2726),
      body: Center(
        child: SafeArea(
          child: _loading
              ? const Padding(
                  padding: EdgeInsets.all(50.0),
                  child: CircularProgressIndicator(),
                )
              : _todayTask != null
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    TaskBox(
                      taskData: {
                        "task": _todayTask!.taskText,
                        "category": _todayTask!.category,
                        "tip": _todayTask!.tip,
                        "date": _todayTask!.date,
                      },
                    ),
                    SizedBox(height: screenWidth * 0.1),
                    Visibility(
                      visible: !isCompleted,
                      maintainSize: true,
                      maintainAnimation: true,
                      maintainState: true,
                      child: Column(
                        children: [
                          ShadowBtn(
                            onPressed: () {
                              Navigator.pushNamed(
                                context,
                                '/success',
                                arguments: _todayTask!,
                              );
                            },
                            btnText: "Mark completed",
                          ),
                          const SizedBox(height: 8),
                          if (_todayTask!.canSwap)
                            TextButton.icon(
                              onPressed: _swapping ? null : _swapTask,
                              icon: const Icon(
                                Icons.swap_horiz,
                                color: Colors.white70,
                              ),
                              label: Text(
                                _swapping
                                    ? "Swapping..."
                                    : "Not today? Swap task (1 free swap per day)",
                                style: const TextStyle(color: Colors.white70),
                              ),
                            ),
                        ],
                      ),
                    ),

                    // Congratulatory message, only visible if completed
                    Visibility(
                      visible: isCompleted,
                      maintainSize: true,
                      maintainAnimation: true,
                      maintainState: true,
                      child: Column(
                        children: [
                          Text(
                            "Well done! 👍",
                            style: TextStyle(
                              fontSize: congratsFontSize,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      "New task in",
                      style: TextStyle(
                        fontSize: screenWidth * 0.05,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    CountDown(
                      fontSize: countdownFontSize,
                      onFinished: resetTask,
                    ),
                  ],
                )
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text("Could not load today's task."),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: _loadTask,
                      child: const Text("Try again"),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
