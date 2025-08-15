import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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

  Future<void> _loadRandomTask() async {
    final taskSnapshot = await db.collection("tasks").get();
    final tasks = taskSnapshot.docs.map((doc) => doc.data()).toList();

    if (tasks.isEmpty) return;

    final selectedTask = tasks[Random().nextInt(tasks.length)];
    print("selected task $selectedTask");
    final taskCategory = selectedTask['category'];
    print("task category $taskCategory");

    final userEmail = "john@example.com"; // TODO: replace with auth
    final userQuery = await db
        .collection("users")
        .where("email", isEqualTo: userEmail)
        .limit(1)
        .get();

    if (userQuery.docs.isEmpty) return;

    final userDoc = userQuery.docs.first;
    final userData = userDoc.data();

    final Map<String, dynamic> userStats = Map<String, dynamic>.from(
      userData['stats'],
    );
    final userStat = userStats[taskCategory] ?? 1;

    final String templateTask = selectedTask!['task'] ?? '';
    final String category = selectedTask!['category'];

    int minutes = userStat * 7; // Adjust multiplier as needed
    String compiledTask = templateTask.replaceAll('§', minutes.toString());

    setState(() {
      _currentTask = {"task": compiledTask, "category": category};
    });

    final eventsSnapshot = await db
        .collection("users")
        .doc(userDoc.id)
        .collection('calendar')
        .get();

    userEvents = eventsSnapshot.docs.map((doc) => doc.data()).toList();
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
        child: ListView(
          padding: EdgeInsets.fromLTRB(30, 50, 0, 0),
          children: [
            ListTile(
              title: const Text('Calendar'),
              onTap: () {
                Navigator.pushNamed(
                  context,
                  '/calendar',
                  arguments: userEvents,
                );
              },
            ),
          ],
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
