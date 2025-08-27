import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:namer_app/services/database_service.dart';

class StartScreen extends StatefulWidget {
  const StartScreen({super.key});

  @override
  State<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> {
  void _googleLogIn(BuildContext context) async {
    final user = await signInWithGoogle();

    if (user != null) {
      print("Logged in with Google: ${user.email}");

      if (!mounted) return;

      // ignore: use_build_context_synchronously
      final navigator = Navigator.of(context);

      final hasStats = await userHasStats(user);

      if (!mounted) return;

      if (hasStats) {
        navigator.pushReplacementNamed('/');
      } else {
        navigator.pushReplacementNamed('/categorySelection');
      }
    } else {
      print("Google login failed or cancelled");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2B2726),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 32,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // App Title
                        Text(
                          "Better Brain",
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Logo + Welcome
                        Column(
                          children: const [
                            SizedBox(height: 60),
                            Icon(
                              Icons.auto_awesome,
                              size: 80,
                              color: Colors.greenAccent,
                            ),
                            SizedBox(height: 16),
                            Text(
                              "Welcome",
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              "Sign up or continue as guest",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),

                        // Buttons
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _buildAuthButton(
                                label: "Continue with Google",
                                icon: const FaIcon(
                                  FontAwesomeIcons.google,
                                  color: Colors.red,
                                ),
                                onPressed: () => _googleLogIn(context),
                              ),
                              const SizedBox(height: 12),
                              _buildAuthButton(
                                label: "Sign in with email",
                                icon: const Icon(
                                  Icons.person_add,
                                  color: Colors.white,
                                ),
                                onPressed: () => Navigator.pushNamed(
                                  context,
                                  '/createAccount',
                                ),
                              ),
                              const SizedBox(height: 12),
                              _buildAuthButton(
                                label: "Continue as Guest",
                                icon: const Icon(
                                  Icons.person_outline,
                                  color: Colors.white,
                                ),
                                onPressed: () => Navigator.pushNamed(
                                  context,
                                  '/categorySelection',
                                ),
                              ),
                              const SizedBox(height: 32),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text(
                                    "Already a user? ",
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.white54,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () => Navigator.pushNamed(
                                      context,
                                      '/loginscreen',
                                    ),
                                    child: const Text(
                                      "Log in instead",
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.greenAccent,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // Footer
                        const SizedBox(height: 16),
                        const Text(
                          "By continuing you agree to our Terms & Privacy Policy",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 12, color: Colors.white54),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildAuthButton({
    required String label,
    required Widget icon,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: icon,
      label: Text(label),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 14),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        backgroundColor: Colors.white12,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
