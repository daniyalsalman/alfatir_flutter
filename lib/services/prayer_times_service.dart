import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/prayer_times_model.dart';

class PrayerTimesService {
  static Future<PrayerTimes> fetchPrayerTimes({required String city, required String country}) async {
    final url = Uri.parse('https://api.aladhan.com/v1/timingsByCity?city=$city&country=$country&method=2');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      return PrayerTimes.fromJson(jsonData);
    } else {
      throw Exception('Failed to fetch prayer times');
    }
  }
}