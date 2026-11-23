import 'package:flutter/material.dart';
import 'package:namer_app/services/database_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show User;

class DrawerWidget extends StatelessWidget {
  final User user;
  const DrawerWidget({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    void logOutPressed() async {
      final navigator = Navigator.of(context);
      if (user.isAnonymous) {
        // A guest who logs out can't get back into the same account.
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Log out of guest mode?"),
            content: const Text(
              "Your guest progress will be lost. Create an account first to keep it.",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text("Log out"),
              ),
            ],
          ),
        );
        if (confirmed != true) return;
      }
      await signOut();
      navigator.pushNamedAndRemoveUntil('/start', (route) => false);
    }

    return Drawer(
      child: Container(
        color: const Color(0xFF2B2726),
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  vertical: 50,
                  horizontal: 20,
                ),
                children: [
                  const SizedBox(height: 20),
                  if (user.isAnonymous) ...[
                    ListTile(
                      leading: const Icon(
                        Icons.person_add,
                        color: Colors.greenAccent,
                      ),
                      title: const Text(
                        'Create account',
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                      subtitle: const Text(
                        'Keep your progress across devices',
                        style: TextStyle(color: Colors.white54),
                      ),
                      onTap: () =>
                          Navigator.pushNamed(context, '/createAccount'),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      tileColor: Colors.white10,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                      ),
                    ),
                    const SizedBox(height: 4),
                  ],
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
                      final events = await getUserEvents();
                      Navigator.pushNamed(
                        context,
                        '/calendar',
                        arguments: events,
                      );
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    tileColor: Colors.white10,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                  ),
                  const SizedBox(height: 4),
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
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                  ),
                  const SizedBox(height: 4),
                  ListTile(
                    leading: const Icon(Icons.leaderboard, color: Colors.green),
                    title: const Text(
                      'Stats',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                    onTap: () async {
                      final stats = await getUserStats();
                      Navigator.pushNamed(context, '/stats', arguments: stats);
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    tileColor: Colors.white10,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                  ),
                  const SizedBox(height: 4),
                  ListTile(
                    leading: const Icon(Icons.info, color: Colors.green),
                    title: const Text(
                      'Info',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                    onTap: () {
                      Navigator.pushNamed(context, '/info');
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    tileColor: Colors.white10,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20),
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
                onTap: logOutPressed,
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
    );
  }
}
