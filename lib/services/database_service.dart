import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:math';

final db = FirebaseFirestore.instance;
final FirebaseAuth _auth = FirebaseAuth.instance;

//Fetch all tasks from the firebase database
Future<List<Map<String, dynamic>>> getAllTasks() async {
  final taskSnapshot = await db.collection("tasks").get();
  return taskSnapshot.docs.map((doc) => doc.data()).toList();
}

//Get a task with the correct category
Future<Map<String, dynamic>> getRandomTask(String category) async {
  final taskSnapshot = await db
      .collection("tasks")
      .where("category", isEqualTo: category)
      .get();
  final allTasks = taskSnapshot.docs.map((doc) => doc.data()).toList();
  var random = Random();
  final randomTask = allTasks[random.nextInt(allTasks.length)];
  return randomTask;
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
  return stat.toInt() * 7;
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

Future<({bool success, User? user, String code, String message})> createAccount(
  String email,
  String password,
) async {
  try {
    UserCredential userCred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final usersRef = FirebaseFirestore.instance.collection("users");
    await usersRef.doc(userCred.user!.uid).set({
      'email': email,
      'createdAt': FieldValue.serverTimestamp(),
    });

    return (
      success: true,
      user: userCred.user,
      code: 'ok',
      message: 'Logged in successfully.',
    );
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
    return (
      success: false,
      user: null,
      code: 'error',
      message: 'FirebaseAuthException $msg',
    );
  } catch (e) {
    return (success: false, user: null, code: 'error', message: 'exception $e');
  }
}

Future<bool> saveStats(Map<String, double> selections) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return false;

  final userId = user.uid;

  try {
    final userRef = FirebaseFirestore.instance.collection("users").doc(userId);

    await userRef.set({'stats': selections}, SetOptions(merge: true));

    print("Stats saved for user $userId");
    return true;
  } catch (e) {
    print("Error saving stats $e");
    return false;
  }
}

Future<({bool success, User? user, String code, String message})>
loginWithEmail(String email, String password) async {
  final trimmedEmail = email.trim();
  print("TrimmedEmail $trimmedEmail");
  print("password $password");

  final emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
  if (!emailRegex.hasMatch(trimmedEmail)) {
    return (
      success: false,
      user: null,
      code: 'invalid-email-format',
      message: 'Please enter a valid email address.',
    );
  }

  try {
    final UserCredential userCredential = await FirebaseAuth.instance
        .signInWithEmailAndPassword(email: trimmedEmail, password: password);
    return (
      success: true,
      user: userCredential.user,
      code: 'ok',
      message: 'Logged in successfully.',
    );
  } on FirebaseAuthException catch (e) {
    String code = e.code;
    String message;

    switch (code) {
      case 'invalid-email':
        message = 'The email address is badly formatted.';
        break;
      case 'user-disabled':
        message = 'This user account has been disabled.';
        break;
      case 'user-not-found':
        message = 'No user found with this email.';
        break;
      case 'wrong-password': // old Firebase SDKs
        message = 'Invalid email or password.';
        break;
      case 'invalid-credential': // new Firebase SDKs
        message = 'Invalid email or password.';
        break;
      case 'too-many-requests':
        message = 'Too many attempts. Try again later.';
        break;
      case 'operation-not-allowed':
        message = 'Email/password accounts are not enabled.';
        break;
      case 'network-request-failed':
        message = 'Network error. Check your internet connection.';
        break;
      default:
        message = 'Error logging in';
    }

    return (success: false, user: null, code: code, message: message);
  } catch (e) {
    return (
      success: false,
      user: null,
      code: 'unexpected-error',
      message: 'Unexpected error: $e',
    );
  }
}

Future<User?> signInWithGoogle() async {
  try {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    if (googleUser == null) return (null);

    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final UserCredential userCredential = await FirebaseAuth.instance
        .signInWithCredential(credential);

    final User? user = userCredential.user;

    return user;
  } catch (e) {
    print("Error signing in with Google: $e");
    return (null);
  }
}

Future<bool> userHasStats(User user) async {
  final doc = await FirebaseFirestore.instance
      .collection("users")
      .doc(user.uid)
      .get();

  if (!doc.exists) {
    return false;
  }

  final data = doc.data();
  return data != null && data.containsKey('stats');
}

Future<Map<String, double>> getUserStats(User user) async {
  final doc = await FirebaseFirestore.instance
      .collection("users")
      .doc(user.uid)
      .get();
  if (!doc.exists) {
    return {};
  }

  final data = doc.data();
  if (data == null || !data.containsKey('stats')) {
    return {};
  }

  final stats = data['stats'];
  if (stats is Map<String, dynamic>) {
    return stats.map((key, value) => MapEntry(key, (value as num).toDouble()));
  }
  return {};
}
