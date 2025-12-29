import 'package:alfatir_proj/rag_chat_sreen.dart';
import 'package:alfatir_proj/splash_screen.dart';
import 'package:flutter/material.dart';

import 'app_routes.dart';

import 'initial_auth_screen.dart';
import 'login_screen.dart';
import 'home_screen.dart';
import 'profile_screen.dart';
import 'forgot_passwrod_screen.dart';
import 'hadith_main.dart';      // HadithBooksScreen
import 'surahs_main.dart';     // SurahListScreen
import 'prayer_times_screen.dart';
import 'tasbeeh_counter.dart';
import 'qibla_compass.dart';
import 'zakat_calculator.dart';
import 'names_of_allah.dart';
import 'hijri_calendar_screen.dart';

class RouteGenerator {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {

      case AppRoutes.initialAuth:
        return MaterialPageRoute(builder: (_) => InitialAuthScreen());

      case AppRoutes.login:
        return MaterialPageRoute(builder: (_) => LoginScreen());
      case AppRoutes.ragChat:
        return MaterialPageRoute(builder: (_) => RagChatScreen());
      case AppRoutes.home:
        return MaterialPageRoute(builder: (_) => HomeScreen());
      case AppRoutes.namesOfAllah:
        return MaterialPageRoute(builder: (_) => NamesOfAllahScreen());
      case AppRoutes.hadith:
        return MaterialPageRoute(builder: (_) => HadithBooksScreen());
      case AppRoutes.hijriCalendar:
        return MaterialPageRoute(builder: (_) => HijriCalendarScreen());
      case AppRoutes.quran:
        return MaterialPageRoute(builder: (_) => SurahsMainScreen());
      case AppRoutes.forgotPassword:
        return MaterialPageRoute(builder: (_) => ForgotPasswordScreen());
      case AppRoutes.prayerTimes:
        return MaterialPageRoute(builder: (_) => PrayerTimesScreen());

      case AppRoutes.tasbeehCounter:
        return MaterialPageRoute(builder: (_) => TasbeehCounter());

      case AppRoutes.profile:
        return MaterialPageRoute(builder: (_) => ProfileScreen());
      case AppRoutes.qibla:
        return MaterialPageRoute(builder: (_) => QiblaCompassScreen());
      case AppRoutes.zakat:
        return MaterialPageRoute(builder: (_) => ZakatCalculatorScreen());
      case AppRoutes.splash:
        return MaterialPageRoute(builder: (_) => SplashScreen());

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}
