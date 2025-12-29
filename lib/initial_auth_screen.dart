import 'package:flutter/material.dart';
import 'app_routes.dart';
import 'auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';



class InitialAuthScreen extends StatefulWidget {
  const InitialAuthScreen({super.key});

  @override
  State<InitialAuthScreen> createState() => _InitialAuthScreenState();
}

class _InitialAuthScreenState extends State<InitialAuthScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  void _signUp() async {
    if (_formKey.currentState!.validate()) {
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();
      final firstName = _firstNameController.text.trim();
      final lastName = _lastNameController.text.trim();
      final age = int.parse(_ageController.text.trim());

      try {
        // 1️⃣ Create account (AUTO login)
        final userCredential =
        await authService.value.createAccount(
          email: email,
          password: password,
        );


        final uid = userCredential.user!.uid;

        // 2️⃣ Save user info
        await FirebaseFirestore.instance
            .collection('Users')
            .doc(uid)
            .set({
          'firstName': firstName,
          'lastName': lastName,
          'age': age,
          'email': email,
          'createdAt': FieldValue.serverTimestamp(),
        });

        // 3️⃣ Go to Home
        Navigator.pushReplacementNamed(context, AppRoutes.home);

      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sign Up Failed: $e')),
        );
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign Up')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _firstNameController,
                decoration: const InputDecoration(labelText: 'First Name'),
                validator: (value) =>
                value!.isEmpty ? 'First name is required' : null,
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _lastNameController,
                decoration: const InputDecoration(labelText: 'Last Name'),
                validator: (value) =>
                value!.isEmpty ? 'Last name is required' : null,
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _ageController,
                decoration: const InputDecoration(labelText: 'Age'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Age is required';
                  if (int.tryParse(value) == null) return 'Enter a valid age';
                  return null;
                },
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) => value!.isEmpty ? 'Email cannot be empty' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) => value!.isEmpty ? 'Password cannot be empty' : null,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _signUp,
                child: const Text('Sign Up'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, AppRoutes.login);
                },
                child: const Text('Already have an account? Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}