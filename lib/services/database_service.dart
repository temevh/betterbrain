import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';

final db = FirebaseFirestore.instance;

//Fetch all tasks from the firebase database
Future<List<Map<String, dynamic>>> getAllTasks() async {
  final taskSnapshot = await db.collection("tasks").get();
  return taskSnapshot.docs.map((doc) => doc.data()).toList();
}

//Select a random task from the fetched list
Map<String, dynamic>? getRandomTask(List<Map<String, dynamic>> tasks) {
  if (tasks.isEmpty) return null;
  return tasks[Random().nextInt(tasks.length)];
}

//Fetch user data by email (change to auth later)
Future<Map<String, dynamic>?> getUserByEmail(String email) async {
  final userQuery = await db
      .collection("users")
      .where("email", isEqualTo: email)
      .limit(1)
      .get();

  if (userQuery.docs.isEmpty) return null;

  return {"id": userQuery.docs.first.id, ...userQuery.docs.first.data()};
}

//Apply users stats to the task
int applyStats(Map<String, dynamic> stats, String category) {
  final stat = stats[category] ?? 3;
  return stat * 7;
}

//Fetch all past events for user
Future<List<Map<String, dynamic>>> getUserEvents(String userId) async {
  final eventSnapshot = await db
      .collection("users")
      .doc(userId)
      .collection("calendar")
      .get();
  return eventSnapshot.docs.map((doc) => doc.data()).toList();
}

//Save completed task for user
Future<bool> saveTask(
  Map<String, dynamic>? event,
  String userId,
  int? difficultyArg,
  String feedbackArg,
) async {
  try {
    final eventObject = {
      'category': event?['category'],
      'title': event?['task'],
      'isCompleted': true,
      'difficulty': difficultyArg,
      'feedback': feedbackArg,
      'date': DateTime.now(),
    };

    await db
        .collection("users")
        .doc(userId)
        .collection("calendar")
        .add(eventObject);
    print("Saved event for $userId");
    return true;
  } catch (e) {
    print("Error saving event: $e");
    return false;
  }
}

Future<Map<bool, String>> createAccount(String email, String password) async {
  print("Email $email password $password");
  try {
    final usersRef = FirebaseFirestore.instance.collection("users");

    //Check db is user exists
    final userExists = await usersRef
        .where('email', isEqualTo: email)
        .limit(1)
        .get();

    if (userExists.docs.isNotEmpty) {
      return {false: "Email already in use"}; //user exists, can create user
    }

    await usersRef.add({
      'email': email,
      'password': password, //add hashing
      'createdAt': FieldValue.serverTimestamp(),
    });
    return {true: "User created succesfully!"};
  } catch (e) {
    print("Error adding user $e");
    return {false: "Error $e"}; //Remove error message in prod
  }
}

Future<bool> saveStats(Map<String, double> selections) async {
  return true;
}
