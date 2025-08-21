import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:namer_app/services/database_service.dart';
import '../widgets/task_box.dart';
import '../buttons/success_btn.dart';
import 'dart:math';
import 'package:namer_app/widgets/countdown.dart';
import 'package:namer_app/models/task.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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

  void _logOutPressed() async {
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/start');
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
      drawer: _buildDrawer(),

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
                    const SizedBox(height: 30),
                    if (!_todayTask!.isCompleted)
                      SuccessBtn(
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            '/success',
                            arguments: {
                              "task": _todayTask!.taskText,
                              "category": _todayTask!.category,
                            },
                          );
                        },
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
                      CountDown(), // Only shows if task is completed
                    ],
                  ],
                )
              : const Text("No task available"),
        ),
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: Container(
        color: const Color(0xFF2B2726),
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  vertical: 50,
                  horizontal: 20,
                ),
                children: [
                  Row(
                    children: const [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.green,
                        child: Icon(
                          Icons.person,
                          size: 30,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "John Doe",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "john@example.com",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                  ListTile(
                    leading: const Icon(
                      Icons.calendar_today,
                      color: Colors.green,
                    ),
                    title: const Text(
                      'Calendar',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                    onTap: () async {
                      final events = await getUserEvents();
                      if (!mounted) return;
                      Navigator.pushNamed(
                        context,
                        '/calendar',
                        arguments: events,
                      );
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    tileColor: Colors.white10,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                  ),
                  const SizedBox(height: 10),
                  ListTile(
                    leading: const Icon(Icons.settings, color: Colors.green),
                    title: const Text(
                      'Settings',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                    onTap: () {},
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    tileColor: Colors.white10,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListTile(
                leading: const Icon(Icons.logout, color: Colors.redAccent),
                title: const Text(
                  'Logout',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
                onTap: _logOutPressed,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                tileColor: Colors.white10,
                contentPadding: const EdgeInsets.symmetric(horizontal: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
