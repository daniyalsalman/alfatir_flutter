import 'package:flutter/material.dart';
import 'app_routes.dart';
import 'auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'main.dart';


class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  void _logout() async {
    await authService.value.signOut();
    Navigator.pushReplacementNamed(context, AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: user == null
          ? const Center(child: Text('No user logged in'))
          : StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Users')
            .doc(user.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Profile data not found'));
          }

          final data =
          snapshot.data!.data() as Map<String, dynamic>;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'First Name: ${data['firstName']}',
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 8),

                Text(
                  'Last Name: ${data['lastName']}',
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 8),

                Text(
                  'Age: ${data['age']}',
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 16),

                Text(
                  'Email: ${user.email}',
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 16),


                SwitchListTile(
                  title: const Text('Dark Mode'),
                  value: themeNotifier.value == ThemeMode.dark,
                  onChanged: (value) {
                    themeNotifier.value =
                    value ? ThemeMode.dark : ThemeMode.light;
                  },
                ),


                const SizedBox(height: 32),

                ElevatedButton(
                  onPressed: _logout,
                  child: const Text('Logout'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}