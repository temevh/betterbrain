import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:namer_app/services/database_service.dart';
import '../widgets/task_box.dart';
import '../buttons/success_btn.dart';
import 'dart:math';
//import '../buttons/failure_btn.dart';

class MainScreen extends StatefulWidget {
  final bool isCompleted;

  const MainScreen({super.key, this.isCompleted = false});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late bool _completed;
  final db = FirebaseFirestore.instance;
  late dynamic pastEvents;
  dynamic userData;

  Map<String, dynamic>? _currentTask;
  String randomTask = "";
  dynamic userEvents;

  @override
  void initState() {
    super.initState();
    _completed = widget.isCompleted;
    _setDailyTask();

    if (_completed) {
      Future.delayed(const Duration(seconds: 10), () {
        setState(() {
          _completed = false;
        });
      });
    }
  }

  String? _userId;

  Future<void> _setDailyTask() async {
    final User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null || currentUser.email == null) {
      //Change to use local storage if user is guest
      print("No logged-in user or user has no email");
      return;
    }
    // select random user category/stat
    final userTasks = await getUserStats(currentUser);
    print("userTasks $userTasks");

    var random = Random();
    var entriesList = userTasks.entries.toList();

    //Select a random stat to be used
    String randomStat = entriesList[random.nextInt(entriesList.length)].key;
    double? statValue = userTasks[randomStat];
    print("randomStat $randomStat, value $statValue");

    //Select a random task from the category/stat
    Map<String, dynamic> task = await getRandomTask(randomStat);
    String taskText = task["task"];
    print("taskText $taskText");
    // Replace the § with the digit
    String compiledTask = taskText.replaceAll(
      '§',
      (statValue ?? 0).toInt().toString(),
    );
    print("compiledTask: $compiledTask");
    //save and serve task
  }

  void _logOutPressed() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacementNamed(context, '/start');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF2B2726),
        leading: Builder(
          builder: (context) {
            return IconButton(
              onPressed: Scaffold.of(context).openDrawer,
              icon: const Icon(Icons.menu, color: Colors.white, size: 30),
            );
          },
        ),
      ),
      drawer: Drawer(
        child: Container(
          color: const Color(0xFF2B2726),
          child: Column(
            children: [
              // Main content scrollable
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(
                    vertical: 50,
                    horizontal: 20,
                  ),
                  children: [
                    // Optional header
                    Row(
                      children: [
                        const CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.green,
                          child: Icon(
                            Icons.person,
                            size: 30,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
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

                    // Menu items
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
                        if (_userId != null) {
                          final events = await getUserEvents(_userId!);
                          Navigator.pushNamed(
                            context,
                            '/calendar',
                            arguments: events,
                          );
                        } else {
                          print("User ID not loaded yet");
                        }
                      },
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      tileColor: Colors.white10,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                      ),
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
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                      ),
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
                  onTap: () {
                    // Handle logout
                    _logOutPressed();
                  },
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
      ),

      backgroundColor: _completed ? Colors.green : const Color(0xFF2B2726),
      body: Center(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (_currentTask != null && _currentTask!.isNotEmpty) ...[
                TaskBox(taskData: _currentTask),
              ],
              const SizedBox(height: 10),
              const SizedBox(height: 20),
              if (!_completed) ...[SuccessBtn(taskData: _currentTask)],
            ],
          ),
        ),
      ),
    );
  }
}
