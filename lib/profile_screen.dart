import 'package:flutter/material.dart';
import 'app_routes.dart';
import 'auth_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isDarkMode = false;

  void _logout() async {
    await authService.value.signOut();
    Navigator.pushReplacementNamed(context, AppRoutes.initialAuth);
  }

  @override
  Widget build(BuildContext context) {
    final userEmail = authService.value.currentUser?.email ?? 'No Email';

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Email: $userEmail', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Dark Mode'),
              value: _isDarkMode,
              onChanged: (value) {
                setState(() {
                  _isDarkMode = value;
                });
              },
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _logout,
              child: const Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}