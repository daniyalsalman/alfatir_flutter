import 'package:flutter/material.dart';
import 'auth_service.dart'; // your AuthService file

class AuthTest extends StatefulWidget {
  const AuthTest({super.key});

  @override
  State<AuthTest> createState() => _AuthTestState();
}

class _AuthTestState extends State<AuthTest> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Auth Test")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: "Email"),
            ),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: "Password"),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await _authService.createAccount(e: _emailController.text.trim(),p: _passwordController.text.trim());
                  
              },
              child: const Text("Sign Up"),
            ),
            ElevatedButton(
              onPressed: () async {
                await _authService.signIn(
                 e: _emailController.text.trim(),
                 p: _passwordController.text.trim(),
                );
              },
              child: const Text("Sign In"),
            ),
            ElevatedButton(
              onPressed: () async {
                await _authService.signOut();
              },
              child: const Text("Sign Out"),
            ),
            ElevatedButton(
              onPressed: () async {
                await _authService.resetPassword(
                e:  _emailController.text.trim(),
                );
              },
              child: const Text("Reset Password"),
            ),
          ],
        ),
      ),
    );
  }
}
