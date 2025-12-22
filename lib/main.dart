// import 'package:alfatir_proj/hadith_main.dart';
// import 'package:alfatir_proj/sign_in_screen.dart';
// import 'package:alfatir_proj/auth_test.dart';
// import 'package:alfatir_proj/splash_screen.dart';
import 'package:alfatir_proj/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'app_routes.dart';
import 'route_generator.dart';
// import 'home_screen.dart';
// import 'initial_auth_screen.dart';
// import 'login_screen.dart';
// import 'profile_screen.dart';
// import 'package:alfatir_proj/prayer_times_screen.dart';
// import 'package:alfatir_proj/tasbeeh_counter.dart';
// import 'auth_test.dart';
// import 'splash_screen.dart';
// import 'tasbeeh_counter.dart';
// import 'package:alfatir_proj/surahs_main.dart';
// import 'package:alfatir_proj/hadith_main.dart';

final ValueNotifier<ThemeMode> themeNotifier =
ValueNotifier(ThemeMode.light);

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
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, mode, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: ThemeData.dark(),
          themeMode: mode,
          initialRoute: AppRoutes.home,
          onGenerateRoute: RouteGenerator.onGenerateRoute,
        );
      },
    );
  }
}
