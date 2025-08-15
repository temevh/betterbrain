import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
    if (selectedTask == null) return;

    final userEmail = "john@example.com";
    final userData = await getUserByEmail(userEmail);
    if (userData == null) return;

    _userId = userData['id']; // store for later

    final taskCategory = selectedTask['category'];
    final userStats = Map<String, dynamic>.from(userData['stats']);
    final difficulty = applyStats(userStats, taskCategory);

    final templateTask = selectedTask['task'] ?? '';
    final compiledTask = templateTask.replaceAll('§', difficulty.toString());

    setState(() {
      _currentTask = {"task": compiledTask, "category": taskCategory};
    });
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
              onTap: () async {
                if (_userId != null) {
                  final events = await getUserEvents(_userId!);
                  Navigator.pushNamed(context, '/calendar', arguments: events);
                } else {
                  print("User ID not loaded yet");
                }
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
