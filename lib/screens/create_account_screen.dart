import 'package:flutter/material.dart';
import 'package:namer_app/services/database_service.dart';
import 'package:namer_app/widgets/build_input_field.dart';
import 'package:namer_app/buttons/flat_btn.dart';

class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({super.key});

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  String email = "";
  String password = "";
  String passwordVerify = "";
  Map<String, bool> passwordValidity = {
    "Be more than 6 characters": false,
    "Have an uppercase letter": false,
    "Include a number": false,
    "Passwords must match": false,
  };
  bool errorCreating = false;
  String message = "";

  bool checkPasswordMatch() {
    if (password == passwordVerify) {
      return true;
    } else {
      return false;
    }
  }

  Widget _passwordValidity(String prompt, bool validity) {
    return Row(
      children: [
        Text(
          prompt,
          style: TextStyle(
            color: validity ? Colors.greenAccent : Colors.redAccent,
          ),
        ),
        Icon(
          validity ? Icons.check : Icons.close,
          color: validity ? Colors.greenAccent : Colors.redAccent,
        ),
      ],
    );
  }

  void _savePressed() async {
    final result = await createAccount(email, password);

    if (!mounted) return;
    if (result.success && result.user != null) {
      errorCreating = false;
      // Success → navigate
      Navigator.pushReplacementNamed(context, '/categorySelection');
    } else {
      setState(() {
        errorCreating = true;
      });
    }
    message = result.message;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: errorCreating ? Colors.redAccent : Colors.green,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void updatePassword(String value) {
    setState(() {
      passwordVerify = value;
      _checkPasswordRules();
    });
  }

  void updateMainPassword(String value) {
    setState(() {
      password = value;
      _checkPasswordRules();
    });
  }

  void _checkPasswordRules() {
    setState(() {
      passwordValidity["Be more than 6 characters"] = password.length > 6;
      passwordValidity["Have an uppercase letter"] = password.contains(
        RegExp(r'[A-Z]'),
      );
      passwordValidity["Include a number"] = password.contains(
        RegExp(r'[0-9]'),
      );
      passwordValidity["Passwords must match"] =
          password == passwordVerify && password.isNotEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFF2B2726),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
          child: Column(
            children: [
              // Scrollable form
              Expanded(
                child: SingleChildScrollView(
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
                      SizedBox(height: screenHeight * 0.01),
                      Opacity(
                        opacity: 0.6,
                        child: const Text(
                          "Account will be used to save tasks and settings across devices",
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.04),

                      // Email
                      const Text(
                        "Email",
                        style: TextStyle(color: Colors.white70),
                      ),
                      SizedBox(height: screenHeight * 0.01),
                      buildInputField(
                        "Enter email",
                        Icons.email,
                        (value) => setState(() => email = value),
                      ),
                      SizedBox(height: screenHeight * 0.03),

                      // Password
                      const Text(
                        "Password",
                        style: TextStyle(color: Colors.white70),
                      ),
                      SizedBox(height: screenHeight * 0.01),
                      buildInputField(
                        "Enter password",
                        Icons.lock,
                        (value) => updateMainPassword(value),
                        obscure: true,
                      ),
                      SizedBox(height: screenHeight * 0.03),

                      // Verify Password
                      const Text(
                        "Verify password",
                        style: TextStyle(color: Colors.white70),
                      ),
                      SizedBox(height: screenHeight * 0.01),
                      buildInputField(
                        "Re-enter password",
                        Icons.lock_outline,
                        (value) => updatePassword(value),
                        obscure: true,
                      ),
                      SizedBox(height: screenHeight * 0.01),
                      Opacity(
                        opacity: 0.6,
                        child: const Text(
                          "Password should:",
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ),
                      ...passwordValidity.entries.map(
                        (element) =>
                            _passwordValidity(element.key, element.value),
                      ),

                      SizedBox(height: screenHeight * 0.03),
                    ],
                  ),
                ),
              ),

              // Fixed button at the bottom
              SafeArea(
                child: FlatButton(
                  isEnabled: !passwordValidity.containsValue(false),
                  onPressed: _savePressed,
                  btnText: "Create account",
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
