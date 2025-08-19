import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:namer_app/services/database_service.dart';
import '../widgets/task_box.dart';
import '../buttons/success_btn.dart';
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
    _loadRandomTask();

    if (_completed) {
      Future.delayed(const Duration(seconds: 10), () {
        setState(() {
          _completed = false;
        });
      });
    }
  }

  String? _userId;

  Future<void> _loadRandomTask() async {
    final tasks = await getAllTasks();
    final selectedTask = getRandomTask(tasks);
    print("SelectedTask: $selectedTask");
    if (selectedTask == null) return;

    final User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null || currentUser.email == null) {
      //Change to use local storage if user is guest
      print("No logged-in user or user has no email");
      return;
    }

    final userData = await getUserByEmail(currentUser.email!);
    print("userData: $userData");
    if (userData == null) return;

    _userId = userData['id']; // store for later

    final taskCategory = selectedTask['category'];
    print("taskCategory: $taskCategory");

    // If stats don’t exist yet, provide defaults
    final userStats = Map<String, dynamic>.from(userData['stats'] ?? {});
    final difficulty = applyStats(userStats, taskCategory);

    final templateTask = selectedTask['task'] ?? '';
    final compiledTask = templateTask.replaceAll('§', difficulty.toString());
    print("compiledTask: $compiledTask");

    setState(() {
      _currentTask = {"task": compiledTask, "category": taskCategory};
    });
  }

  void _logOutPressed() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushNamed(context, '/start');
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
