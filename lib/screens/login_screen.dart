import 'package:flutter/material.dart';
import 'package:namer_app/services/database_service.dart';
import 'package:namer_app/widgets/build_input_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String email = "";
  String password = "";

  bool _loading = false;
  String? _error;

  Future<void> _handleLogin() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final user = await loginWithEmail(email, password);

    setState(() => _loading = false);

    if (user != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Welcome ${user.email}!")));
      Navigator.pushNamed(context, ('/'));
    } else {
      setState(() {
        _error = "Login failed. Please check email/password.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2B2726),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Log in✨",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 50),
              // Email
              const Text("Email", style: TextStyle(color: Colors.white70)),
              const SizedBox(height: 8),
              buildInputField(
                "Enter email",
                Icons.email,
                (value) => setState(() => email = value),
              ),

              const SizedBox(height: 24),

              // Password
              const Text("Password", style: TextStyle(color: Colors.white70)),
              const SizedBox(height: 8),
              buildInputField(
                "Enter password",
                Icons.lock,
                (value) => setState(() => password = value),
                obscure: true,
              ),

              const Spacer(),

              // Submit button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _handleLogin,

                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.greenAccent,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),

                  child: const Text(
                    "Log in",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
