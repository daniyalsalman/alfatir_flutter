import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'auth_service.dart';

class AuthTest extends StatelessWidget {
  AuthTest({super.key});
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Auth Test'),
      ),
      body: StreamBuilder<User?>(
        stream: _authService.authStateChanges,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasData) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Signed in as: ${snapshot.data!.email}'),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () async {
                      await _authService.signOut();
                    },
                    child: Text('Sign Out'),
                  ),
                ],
              ),
            );
          } else {
            return Center(
              child: Text('Not signed in'),
            );
          }
        },
      ),
    );
  }
}
