import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:alfatir_proj/theme/app_theme.dart';
import 'package:alfatir_proj/route_generator.dart';
import 'package:alfatir_proj/app_routes.dart';
import 'firebase_options.dart'; // <--- 1. Import this file

// Global Notifier
final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.system);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Use the generated options
  // This tells Flutter: "If I am on Web, use the Web keys. If Android, use Android keys."
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, currentMode, child) {
        return MaterialApp(
          title: 'Al-Fatir',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: currentMode,
          initialRoute: AppRoutes.splash,
          onGenerateRoute: RouteGenerator.onGenerateRoute,
        );
      },
    );
  }
}