import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:math';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';

class TaskBox extends StatefulWidget {
  const TaskBox({super.key});

  @override
  State<TaskBox> createState() => _TaskBoxState();
}

class _TaskBoxState extends State<TaskBox> {
  String randomTask = "";
  String category = "";
  String finalTask = "";
  List<Map<String, dynamic>> stats = [];
  List<Map<String, dynamic>> allTasks = [];

  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<void> _initData() async {
    await Future.wait([_loadTasks(), _loadStats()]);

    if (randomTask.isNotEmpty && stats.isNotEmpty) {
      _compileTask();
    }
  }

  Future<void> _loadTasks() async {
    final String jsonString = await rootBundle.loadString('assets/tasks.json');
    final Map<String, dynamic> jsonData = json.decode(jsonString);

    jsonData.forEach((category, tasks) {
      for (var task in tasks) {
        allTasks.add({"task": task["task"], "category": category});
      }
    });

    final random = Random();
    final chosen = allTasks[random.nextInt(allTasks.length)];

    setState(() {
      randomTask = chosen["task"]; //Set a task to be used
      category =
          chosen["category"] ??
          "Could not set category"; //set the category of the randomly selected task accordingly
    });
  }

  Future<void> _loadStats() async {
    final String jsonString = await rootBundle.loadString(
      'assets/userdata.json',
    );
    final Map<String, dynamic> jsonData = json.decode(jsonString);
    final List<dynamic> statsList = jsonData["stats"];
    stats = statsList.map((stat) => Map<String, dynamic>.from(stat)).toList();
  }

  int getStatValue(String desiredStat) {
    for (final stat in stats) {
      if (stat.containsKey(desiredStat)) {
        return stat[desiredStat];
      }
    }
    return 1;
  }

  //Create the final task description/text
  _compileTask() {
    int statValue = getStatValue(category);
    int minutes =
        statValue *
        7; //Use a user provided "dedication" etc number instead of 7?
    String task = randomTask.replaceAll('§', minutes.toString());
    setState(() {
      finalTask = task;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Image.asset('assets/images/$category.png', height: 340),
        Container(
          padding: const EdgeInsets.all(8),
          margin: const EdgeInsets.only(top: 30),
          decoration: BoxDecoration(
            color: const Color(0xFF3A3A3A),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Opacity(
                opacity: 0.5,
                child: Text(
                  DateFormat("dd.MM.yyyy").format(DateTime.now()),
                  style: TextStyle(color: Colors.white, fontSize: 22),
                ),
              ),
              SizedBox(height: 10),
              SizedBox(
                width: 350,
                child: Text(
                  finalTask.isNotEmpty ? finalTask : "Loading task...",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 40,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              SizedBox(height: 10),
              Opacity(
                opacity: 0.5,
                child: Text(
                  category.isNotEmpty
                      ? category.toUpperCase()
                      : "Loading category...",
                  style: TextStyle(color: Colors.white, fontSize: 22),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
