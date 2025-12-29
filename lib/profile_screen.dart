import 'package:flutter/material.dart';
import 'package:alfatir_proj/auth_service.dart';
import 'package:alfatir_proj/app_routes.dart';
import 'package:alfatir_proj/main.dart'; // <--- IMPORT MAIN.DART

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Determine current user details (placeholder or from Auth)
    final user = authService.value.currentUser;
    final email = user?.email ?? "Guest User";

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const CircleAvatar(
            radius: 50,
            child: Icon(Icons.person, size: 50),
          ),
          const SizedBox(height: 20),
          Center(
            child: Text(
              email,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 30),
          const Divider(),
          
          // --- THEME SWITCH ---
          // Use ValueListenableBuilder so the switch updates visually when pressed
          ValueListenableBuilder<ThemeMode>(
            valueListenable: themeNotifier, // Accessing the global variable
            builder: (context, mode, child) {
              return SwitchListTile(
                title: const Text('Dark Mode'),
                // Check if current mode is Dark
                value: mode == ThemeMode.dark, 
                onChanged: (val) {
                  // Update the global notifier
                  themeNotifier.value = val ? ThemeMode.dark : ThemeMode.light;
                },
              );
            },
          ),
          
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout', style: TextStyle(color: Colors.red)),
            onTap: () async {
              await authService.value.signOut();
              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(
                    context, AppRoutes.initialAuth, (route) => false);
              }
            },
          ),
        ],
      ),
    );
  }
}