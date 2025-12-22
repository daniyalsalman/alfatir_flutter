import 'package:alfatir_proj/rag_chat_sreen.dart';
import 'package:flutter/material.dart';

import 'app_routes.dart';

import 'initial_auth_screen.dart';
import 'login_screen.dart';
import 'home_screen.dart';
import 'profile_screen.dart';

import 'hadith_main.dart';      // HadithBooksScreen
import 'surahs_main.dart';     // SurahListScreen
import 'prayer_times_screen.dart';
import 'tasbeeh_counter.dart';




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

      case AppRoutes.hadith:
        return MaterialPageRoute(builder: (_) => HadithBooksScreen());

      case AppRoutes.quran:
        return MaterialPageRoute(builder: (_) => SurahListScreen());

      case AppRoutes.prayerTimes:
        return MaterialPageRoute(builder: (_) => PrayerTimesScreen());

      case AppRoutes.tasbeehCounter:
        return MaterialPageRoute(builder: (_) => TasbeehCounter());

      case AppRoutes.profile:
        return MaterialPageRoute(builder: (_) => ProfileScreen());

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
