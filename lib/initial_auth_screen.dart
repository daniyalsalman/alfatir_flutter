import 'package:flutter/material.dart';
import 'app_routes.dart';
import 'auth_service.dart';

class InitialAuthScreen extends StatefulWidget {
  const InitialAuthScreen({Key? key}) : super(key: key);

  @override
  State<InitialAuthScreen> createState() => _InitialAuthScreenState();
}

class _InitialAuthScreenState extends State<InitialAuthScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

 void _signUp() async {
  if (_formKey.currentState!.validate()) {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    try {
      await authService.value.createAccount(email: email, password: password);
      Navigator.pushReplacementNamed(context, AppRoutes.home); // works now
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