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

    if (tasks.isNotEmpty) {
      final randomTask = tasks[Random().nextInt(tasks.length)];
      setState(() {
        _currentTask = randomTask;
      });
    }
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
                Navigator.pushNamed(context, '/calendar');
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

              /*
              Text(
                _completed ? "Well done!" : "Did you do it?",
                style: TextStyle(color: Colors.white, fontSize: 28),
              ),*/
              const SizedBox(height: 20),
              if (!_completed) ...[
                const SuccessBtn(),
                //const SizedBox(height: 10),
                //const FailureBtn(),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
