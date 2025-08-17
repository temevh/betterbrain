import 'package:flutter/material.dart';

class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({super.key});

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  String firstName = "";
  String email = "";
  String password = "";
  String passwordVerify = "";

  Widget _buildInputField(
    String hint,
    IconData icon,
    void Function(String) onChanged, {
    bool obscure = false,
  }) {
    return TextField(
      obscureText: obscure,
      style: const TextStyle(color: Colors.white),
      onChanged: onChanged,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white10,
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white54),
        prefixIcon: Icon(icon, color: Colors.white70),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.greenAccent, width: 2),
        ),
      ),
    );
  }

  bool checkPasswordMatch() {
    if (password == passwordVerify) {
      return true;
    } else {
      return false;
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
                "Create Account✨",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 40),

              // Name
              const Text("Name", style: TextStyle(color: Colors.white70)),
              const SizedBox(height: 8),
              _buildInputField(
                "Enter your first name",
                Icons.person,
                (value) => setState(() => firstName = value),
              ),

              const SizedBox(height: 24),

              // Email
              const Text("Email", style: TextStyle(color: Colors.white70)),
              const SizedBox(height: 8),
              _buildInputField(
                "Enter email",
                Icons.email,
                (value) => setState(() => email = value),
              ),

              const SizedBox(height: 24),

              // Password
              const Text("Password", style: TextStyle(color: Colors.white70)),
              const SizedBox(height: 8),
              _buildInputField(
                "Enter password",
                Icons.lock,
                (value) => setState(() => password = value),
                obscure: true,
              ),

              const SizedBox(height: 24),

              // Verify Password
              const Text(
                "Verify password",
                style: TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 8),
              _buildInputField(
                "Re-enter password",
                Icons.lock_outline,
                (value) => setState(() => passwordVerify = value),
                obscure: true,
              ),

              const Spacer(),

              // Submit button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // TODO: Handle sign-up
                    Navigator.pushNamed(context, '/categorySelection');
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.greenAccent,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Create Account",
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
