import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:namer_app/config.dart';
import 'package:namer_app/models/task.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

SupabaseClient get supabase => Supabase.instance.client;

User? get currentUser => supabase.auth.currentUser;

bool get isGuest => currentUser?.isAnonymous ?? false;

typedef AuthResult = ({bool success, User? user, String code, String message});

/// Minutes east of UTC, so the server can work out the user's local day.
int _utcOffsetMinutes() => DateTime.now().timeZoneOffset.inMinutes;

/// Turns a Postgres `raise exception '<code>'` from an RPC into its code.
String _rpcErrorCode(Object e) =>
    e is PostgrestException ? e.message : e.toString();

// ---------------------------------------------------------------------------
// Daily task
// ---------------------------------------------------------------------------

/// Today's task. The server assigns and saves it on the first call of the
/// day, so reopening the app always shows the same task.
Future<Task?> getDailyTask() async {
  if (currentUser == null) return null;
  try {
    final result = await supabase.rpc(
      'get_or_assign_daily_task',
      params: {'p_utc_offset_minutes': _utcOffsetMinutes()},
    );
    return Task.fromJson(Map<String, dynamic>.from(result as Map));
  } catch (e) {
    debugPrint('Error fetching daily task: ${_rpcErrorCode(e)}');
    return null;
  }
}

/// Uses the one free swap of the day. Throws a readable message on failure.
Future<Task> swapDailyTask() async {
  try {
    final result = await supabase.rpc('swap_daily_task');
    return Task.fromJson(Map<String, dynamic>.from(result as Map));
  } catch (e) {
    switch (_rpcErrorCode(e)) {
      case 'swap_already_used':
        throw 'You have already swapped today\'s task.';
      case 'task_already_finished':
        throw 'Today\'s task is already done.';
      default:
        debugPrint('Error swapping task: $e');
        throw 'Could not swap the task. Try again.';
    }
  }
}

/// Marks today's task completed. [feedback] is -1 too hard, 0 just right,
/// 1 too easy, or null; the server raises or lowers the category level.
Future<Task?> completeDailyTask(int? feedback, String reflection) async {
  try {
    final result = await supabase.rpc(
      'complete_daily_task',
      params: {'p_feedback': feedback, 'p_reflection': reflection},
    );
    return Task.fromJson(Map<String, dynamic>.from(result as Map));
  } catch (e) {
    debugPrint('Error completing task: ${_rpcErrorCode(e)}');
    return null;
  }
}

/// All past and present tasks for the calendar.
Future<List<Task>> getUserEvents() async {
  if (currentUser == null) return [];
  try {
    final rows = await supabase
        .from('daily_assignments')
        .select()
        .order('assigned_date');
    return rows.map(Task.fromJson).toList();
  } catch (e) {
    debugPrint('Error fetching user tasks: $e');
    return [];
  }
}

// ---------------------------------------------------------------------------
// Categories and levels
// ---------------------------------------------------------------------------

/// Saves the onboarding choices: category -> starting level (1 to 10).
Future<bool> saveStats(Map<String, double> selections) async {
  if (currentUser == null) return false;
  try {
    await supabase.rpc(
      'save_onboarding',
      params: {
        'p_levels': selections,
        'p_utc_offset_minutes': _utcOffsetMinutes(),
      },
    );
    return true;
  } catch (e) {
    debugPrint('Error saving stats: ${_rpcErrorCode(e)}');
    return false;
  }
}

Future<bool> userHasStats() async {
  if (currentUser == null) return false;
  final rows = await supabase
      .from('user_category_levels')
      .select('category')
      .eq('enabled', true)
      .limit(1);
  return rows.isNotEmpty;
}

Future<Map<String, double>> getUserStats() async {
  if (currentUser == null) return {};
  try {
    final rows = await supabase
        .from('user_category_levels')
        .select('category, level')
        .eq('enabled', true)
        .order('category');
    return {
      for (final row in rows)
        row['category'] as String: (row['level'] as num).toDouble(),
    };
  } catch (e) {
    debugPrint('Error fetching stats: $e');
    return {};
  }
}

// ---------------------------------------------------------------------------
// Auth
// ---------------------------------------------------------------------------

String _authMessage(AuthException e) {
  switch (e.code) {
    case 'user_already_exists':
    case 'email_exists':
      return 'Email already in use';
    case 'weak_password':
      return 'Password is too weak';
    case 'email_address_invalid':
    case 'validation_failed':
      return 'Invalid email format';
    case 'invalid_credentials':
      return 'Invalid email or password.';
    case 'email_not_confirmed':
      return 'Confirm your email address first, then log in.';
    case 'over_request_rate_limit':
    case 'over_email_send_rate_limit':
      return 'Too many attempts. Try again later.';
    default:
      return e.message;
  }
}

/// Creates an email account. A guest (anonymous) user is upgraded in place, so
/// their tasks and levels carry over.
Future<AuthResult> createAccount(String email, String password) async {
  final trimmedEmail = email.trim();
  try {
    final user = currentUser;
    if (user != null && user.isAnonymous) {
      final res = await supabase.auth.updateUser(
        UserAttributes(email: trimmedEmail, password: password),
      );
      return (
        success: true,
        user: res.user,
        code: 'upgraded',
        message: 'Account created. Your progress has been kept.',
      );
    }

    final res = await supabase.auth.signUp(
      email: trimmedEmail,
      password: password,
    );
    if (res.session == null) {
      // "Confirm email" is on in Supabase: the user must click the link first.
      return (
        success: true,
        user: res.user,
        code: 'confirm-email',
        message: 'Check your email to confirm your account, then log in.',
      );
    }
    return (
      success: true,
      user: res.user,
      code: 'ok',
      message: 'Signed up successfully.',
    );
  } on AuthException catch (e) {
    return (
      success: false,
      user: null,
      code: e.code ?? 'error',
      message: _authMessage(e),
    );
  } catch (e) {
    return (success: false, user: null, code: 'error', message: 'Error: $e');
  }
}

Future<AuthResult> loginWithEmail(String email, String password) async {
  final trimmedEmail = email.trim();

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
    final res = await supabase.auth.signInWithPassword(
      email: trimmedEmail,
      password: password,
    );
    return (
      success: true,
      user: res.user,
      code: 'ok',
      message: 'Logged in successfully.',
    );
  } on AuthException catch (e) {
    return (
      success: false,
      user: null,
      code: e.code ?? 'error',
      message: _authMessage(e),
    );
  } catch (e) {
    return (
      success: false,
      user: null,
      code: 'unexpected-error',
      message: 'Network error. Check your internet connection.',
    );
  }
}

/// Sends a password reset email. Users moved over from Firebase need this
/// once, because Firebase password hashes can't be imported into Supabase.
Future<String> sendPasswordReset(String email) async {
  try {
    await supabase.auth.resetPasswordForEmail(email.trim());
    return 'If an account exists for that email, a reset link is on its way.';
  } on AuthException catch (e) {
    return _authMessage(e);
  } catch (_) {
    return 'Could not send the email. Try again.';
  }
}

/// Google sign-in. On mobile and desktop this uses the native Google flow and
/// hands the ID token to Supabase. On web it redirects through Supabase OAuth,
/// so it returns null and the session arrives after the redirect.
Future<User?> signInWithGoogle() async {
  try {
    if (kIsWeb) {
      await supabase.auth.signInWithOAuth(OAuthProvider.google);
      return null;
    }

    final googleSignIn = GoogleSignIn(
      clientId: AppConfig.googleIosClientId.isEmpty
          ? null
          : AppConfig.googleIosClientId,
      serverClientId: AppConfig.googleWebClientId.isEmpty
          ? null
          : AppConfig.googleWebClientId,
    );
    final googleUser = await googleSignIn.signIn();
    if (googleUser == null) return null;

    final googleAuth = await googleUser.authentication;
    final idToken = googleAuth.idToken;
    if (idToken == null) {
      debugPrint('Google sign-in returned no ID token. Check GOOGLE_WEB_CLIENT_ID.');
      return null;
    }

    final res = await supabase.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: idToken,
      accessToken: googleAuth.accessToken,
    );
    return res.user;
  } catch (e) {
    debugPrint('Error signing in with Google: $e');
    return null;
  }
}

/// Guest mode: a Supabase anonymous user, so guests get the same server-side
/// tasks as everyone else and can later upgrade to an email account.
Future<User?> continueAsGuest() async {
  final existing = currentUser;
  if (existing != null) return existing;
  try {
    final res = await supabase.auth.signInAnonymously();
    return res.user;
  } catch (e) {
    debugPrint('Error starting guest session: $e');
    return null;
  }
}

/// Older versions kept guest choices only in SharedPreferences. Move them to
/// an anonymous Supabase user once. Returns true if a guest was migrated.
Future<bool> migrateLegacyGuest() async {
  final prefs = await SharedPreferences.getInstance();
  final raw = prefs.getString('selections');
  if (raw == null || currentUser != null) return false;

  try {
    final decoded = Map<String, dynamic>.from(jsonDecode(raw) as Map);
    final selections = {
      for (final e in decoded.entries) e.key: (e.value as num).toDouble(),
    };
    if (await continueAsGuest() == null) return false;
    if (selections.isNotEmpty && !await saveStats(selections)) return false;
    await prefs.remove('selections');
    return true;
  } catch (e) {
    debugPrint('Error migrating guest data: $e');
    return false;
  }
}

Future<void> signOut() async {
  if (!kIsWeb) {
    try {
      await GoogleSignIn().signOut();
    } catch (_) {
      // Not signed in with Google.
    }
  }
  await supabase.auth.signOut();
}
