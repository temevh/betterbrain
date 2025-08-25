import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:namer_app/services/database_service.dart';

class DrawerWidget extends StatelessWidget {
  const DrawerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    void logOutPressed() async {
      await FirebaseAuth.instance.signOut();
      Navigator.pushReplacementNamed(context, '/start');
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
                  const SizedBox(height: 40),
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
