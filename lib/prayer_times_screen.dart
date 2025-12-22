import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'services/prayer_times_service.dart';
import 'models/prayer_times_model.dart';

class PrayerTimesScreen extends StatefulWidget {
  const PrayerTimesScreen({super.key});

  @override
  State<PrayerTimesScreen> createState() => _PrayerTimesScreenState();
}

class _PrayerTimesScreenState extends State<PrayerTimesScreen> {
  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  final List<String> countries = [
    'Pakistan',
    'India',
    'Bangladesh',
    'Saudi Arabia',
    'USA',
    'UK',
    'Canada',
    'Australia',
    'UAE',
    'Egypt'
  ];

  final Map<String, List<String>> citiesByCountry = {
    'Pakistan': ['Karachi', 'Lahore', 'Islamabad', 'Rawalpindi'],
    'India': ['Delhi', 'Mumbai', 'Bangalore'],
    'Bangladesh': ['Dhaka', 'Chittagong'],
    'Saudi Arabia': ['Riyadh', 'Jeddah', 'Mecca'],
    'USA': ['New York', 'Chicago'],
    'UK': ['London', 'Manchester'],
    'Canada': ['Toronto', 'Vancouver'],
    'Australia': ['Sydney', 'Melbourne'],
    'UAE': ['Dubai', 'Abu Dhabi'],
    'Egypt': ['Cairo', 'Alexandria'],
  };

  String? selectedCountry;
  String? selectedCity;
  PrayerTimes? prayerTimes;
  bool isLoading = false;
  String? infoMessage;

  @override
  void initState() {
    super.initState();
    _initNotifications();
    _loadCachedData();
  }

  /* ---------------- INIT ---------------- */

  Future<void> _initNotifications() async {
    tz.initializeTimeZones();

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: androidInit);

    await _notifications.initialize(settings);
  }

  /* ---------------- CACHE ---------------- */

  Future<void> _loadCachedData() async {
    final prefs = await SharedPreferences.getInstance();

    final cachedCountry = prefs.getString('country');
    final cachedCity = prefs.getString('city');
    final cachedTimes = prefs.getString('prayerTimes');

    if (cachedCountry != null && cachedCity != null && cachedTimes != null) {
      setState(() {
        selectedCountry = cachedCountry;
        selectedCity = cachedCity;
        prayerTimes = PrayerTimes.fromJson(json.decode(cachedTimes));
        infoMessage = 'Showing cached prayer times (offline)';
      });
    }
  }

  Future<void> _cacheData(
      String country, String city, PrayerTimes times) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('country', country);
    await prefs.setString('city', city);

    await prefs.setString(
      'prayerTimes',
      json.encode({
        'data': {
          'timings': {
            'Fajr': times.fajr,
            'Dhuhr': times.dhuhr,
            'Asr': times.asr,
            'Maghrib': times.maghrib,
            'Isha': times.isha,
          }
        }
      }),
    );
  }

  /* ---------------- NOTIFICATIONS ---------------- */

  Future<void> _scheduleNotifications(PrayerTimes times) async {
    await _notifications.cancelAll();

    final now = DateTime.now();

    final prayers = {
      'Fajr': times.fajr,
      'Dhuhr': times.dhuhr,
      'Asr': times.asr,
      'Maghrib': times.maghrib,
      'Isha': times.isha,
    };

    int id = 0;

    for (final entry in prayers.entries) {
      final parts = entry.value.split(':');
      if (parts.length != 2) continue;

      DateTime scheduled = DateTime(
        now.year,
        now.month,
        now.day,
        int.parse(parts[0]),
        int.parse(parts[1]),
      );

      if (scheduled.isBefore(now)) {
        scheduled = scheduled.add(const Duration(days: 1));
      }

      await _notifications.zonedSchedule(
        id++,
        'Prayer Time',
        'It\'s time for ${entry.key}',
        tz.TZDateTime.from(scheduled, tz.local),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'prayer_channel',
            'Prayer Notifications',
            channelDescription: 'Prayer time reminders',
            importance: Importance.max,
            priority: Priority.high,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    }
  }

  /* ---------------- FETCH ---------------- */

  Future<void> fetchTimes() async {
    if (selectedCountry == null || selectedCity == null) {
      setState(() {
        infoMessage = 'Select country and city first';
      });
      return;
    }

    setState(() {
      isLoading = true;
      infoMessage = null;
    });

    try {
      final times = await PrayerTimesService.fetchPrayerTimes(
        city: selectedCity!,
        country: selectedCountry!,
      );

      setState(() {
        prayerTimes = times;
      });

      await _cacheData(selectedCountry!, selectedCity!, times);
      await _scheduleNotifications(times);
    } catch (_) {
      setState(() {
        infoMessage = 'Failed to fetch. Showing cached data if available.';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  /* ---------------- UI ---------------- */

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Prayer Times')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            DropdownButton<String>(
              value: selectedCountry,
              hint: const Text('Select Country'),
              isExpanded: true,
              onChanged: (v) {
                setState(() {
                  selectedCountry = v;
                  selectedCity = null;
                });
              },
              items: countries
                  .map((c) =>
                      DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
            ),

            if (selectedCountry != null)
              DropdownButton<String>(
                value: selectedCity,
                hint: const Text('Select City'),
                isExpanded: true,
                onChanged: (v) => setState(() => selectedCity = v),
                items: citiesByCountry[selectedCountry!]!
                    .map((c) =>
                        DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
              ),

            const SizedBox(height: 10),

            ElevatedButton(
              onPressed: fetchTimes,
              child: const Text('Fetch Prayer Times'),
            ),

            if (isLoading) const CircularProgressIndicator(),

            if (prayerTimes != null)
              Card(
                margin: const EdgeInsets.only(top: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$selectedCity, $selectedCountry',
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text('Fajr: ${prayerTimes!.fajr}'),
                      Text('Dhuhr: ${prayerTimes!.dhuhr}'),
                      Text('Asr: ${prayerTimes!.asr}'),
                      Text('Maghrib: ${prayerTimes!.maghrib}'),
                      Text('Isha: ${prayerTimes!.isha}'),
                    ],
                  ),
                ),
              ),

            if (infoMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  infoMessage!,
                  style: const TextStyle(color: Colors.orange),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
