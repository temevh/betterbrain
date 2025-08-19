import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:math';

final db = FirebaseFirestore.instance;
final FirebaseAuth _auth = FirebaseAuth.instance;

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
  try {
    // Create account in Firebase Auth
    UserCredential userCred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    // Save extra info in Firestore (not password!)
    final usersRef = FirebaseFirestore.instance.collection("users");
    await usersRef.doc(userCred.user!.uid).set({
      'email': email,
      'createdAt': FieldValue.serverTimestamp(),
    });

    return {true: "User created successfully!"};
  } on FirebaseAuthException catch (e) {
    String msg;
    if (e.code == 'email-already-in-use') {
      msg = "Email already in use";
    } else if (e.code == 'weak-password') {
      msg = "Password is too weak";
    } else if (e.code == 'invalid-email') {
      msg = "Invalid email format";
    } else {
      msg = "Auth error: ${e.message}";
    }
    return {false: msg};
  } catch (e) {
    return {false: "Unexpected error: $e"};
  }
}

Future<bool> saveStats(Map<String, double> selections) async {
  return true;
}
