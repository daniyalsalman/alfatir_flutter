import 'package:alfatir_proj/hadith_main.dart';
import 'package:alfatir_proj/sign_in_screen.dart';
import 'package:alfatir_proj/auth_test.dart';
// import 'package:alfatir_proj/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
// import 'auth_test.dart';
// import 'splash_screen.dart';
// import 'tasbeeh_counter.dart';
// import 'package:alfatir_proj/surahs_main.dart';
// import 'package:alfatir_proj/hadith_main.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp( MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => SignInScreen(),
        '/auth-test': (context) => AuthTest(),
      },
    );
  }
}
