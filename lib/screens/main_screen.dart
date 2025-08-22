import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:namer_app/services/database_service.dart';
import '../widgets/task_box.dart';
import '../buttons/shadow_btn.dart';
import 'dart:math';
import 'package:namer_app/widgets/countdown.dart';
import 'package:namer_app/models/task.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:namer_app/widgets/drawer_widget.dart';
//import '../buttons/failure_btn.dart';

class MainScreen extends StatefulWidget {
  final bool isCompleted;

  const MainScreen({super.key, this.isCompleted = false});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  Task? _todayTask;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      final task = await getDailyTask(DateTime.now());
      if (task != null) {
        setState(() {
          _todayTask = task;
          _loading = false;
        });
      } else {
        await _setDailyTask();
      }
    } catch (e) {
      print("Error initializing main screen: $e");
      setState(() => _loading = false);
    }
  }

  Future<void> _setDailyTask() async {
    final User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null || currentUser.email == null) {
      setState(() => _loading = false);
      return;
    }

    final userStats = await getUserStats(currentUser);
    var random = Random();
    var entriesList = userStats.entries.toList();
    String randomStat = entriesList[random.nextInt(entriesList.length)].key;
    double? statValue = userStats[randomStat];
    final randomTask = await getRandomTask(randomStat);
    String compiledTask = randomTask["task"].replaceAll(
      '§',
      (statValue ?? 0).toInt().toString(),
    );

    setState(() {
      _todayTask = Task(
        taskText: compiledTask,
        category: randomStat,
        reflection: "",
        isCompleted: false,
        difficulty: 1,
        day: DateTime.now().day,
        month: DateTime.now().month,
        year: DateTime.now().year,
        createdAt: Timestamp.now(),
        date: Timestamp.fromDate(DateTime.now()),
      );
      _loading = false;
    });
  }

  void resetTask() async {
    print("resetting task");
    setState(() {
      _loading = true;
    });

    // ✅ Only save the task if it has NOT been completed yet
    if (_todayTask != null && !_todayTask!.isCompleted) {
      await saveUserTask(_todayTask!, -1, "", false);
    }

    await _setDailyTask();
  }

  @override
  Widget build(BuildContext context) {
    final isCompleted = _todayTask?.isCompleted ?? false;

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
      drawer: DrawerWidget(),
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
                      },
                    ),
                    const SizedBox(height: 20),

                    if (!isCompleted)
                      ShadowBtn(
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            '/success',
                            arguments: _todayTask!,
                          );
                        },
                        btnText: "Mark completed",
                      )
                    else ...[
                      const Text(
                        "Well done! 👍",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 30),
                      const Text(
                        "New task in",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Visibility(
                        visible: isCompleted,
                        child: CountDown(onFinished: resetTask),
                      ),
                    ],
                  ],
                )
              : const Text("No task available"),
        ),
      ),
    );
  }
}
