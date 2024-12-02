import 'package:flutter/material.dart';
import 'package:socialmediaf/features/auth/presentation/pages/login_page.dart';
import 'package:socialmediaf/features/auth/presentation/pages/register_page.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool showLoginPage = true; // Correctly renamed to lowercase

  void togglePages() {
    setState(() {
      showLoginPage = !showLoginPage; // Use consistent casing
    });
  }

  @override
  Widget build(BuildContext context) {
    if (showLoginPage) {
      return LoginPage(
        togglePage: togglePages,
      );
    } else {
      return RegisterPage(
        togglePage: togglePages,
      );
    }
  }
}
