import 'package:flutter/material.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:alfatir_proj/theme/app_theme.dart';

class HijriCalendarScreen extends StatefulWidget {
  const HijriCalendarScreen({super.key});

  @override
  State<HijriCalendarScreen> createState() => _HijriCalendarScreenState();
}

class _HijriCalendarScreenState extends State<HijriCalendarScreen> {
  late HijriCalendar _today;

  @override
  void initState() {
    super.initState();
    _today = HijriCalendar.now();
    // Optional: Adjust by +/- 1 or 2 days if moon sighting differs
    // HijriCalendar.setLocal(assess); 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Hijri Calendar")),
      body: Column(
        children: [
          // 1. Header: Today's Date
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Column(
              children: [
                Text(
                  _today.toFormat("MMMM"), // Month Name
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  _today.toFormat("dd, yyyy"), // Day and Year
                  style: const TextStyle(
                    fontSize: 64,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.accentGold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "Today (Gregorian: ${DateTime.now().year}-${DateTime.now().month}-${DateTime.now().day})",
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),
          
          // 2. Upcoming Events List
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text("Key Islamic Events", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ),
          ),
          
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: const [
                EventCard(date: "1 Muharram", event: "Islamic New Year"),
                EventCard(date: "10 Muharram", event: "Ashura"),
                EventCard(date: "12 Rabi Al-Awwal", event: "Mawlid al-Nabi"),
                EventCard(date: "27 Rajab", event: "Isra and Mi'raj"),
                EventCard(date: "15 Shaban", event: "Shab-e-Barat"),
                EventCard(date: "1 Ramadan", event: "Start of Fasting"),
                EventCard(date: "27 Ramadan", event: "Laylat al-Qadr (Probable)"),
                EventCard(date: "1 Shawwal", event: "Eid al-Fitr"),
                EventCard(date: "9 Dhul-Hijjah", event: "Day of Arafah"),
                EventCard(date: "10 Dhul-Hijjah", event: "Eid al-Adha"),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class EventCard extends StatelessWidget {
  final String date;
  final String event;

  const EventCard({super.key, required this.date, required this.event});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.primaryGreen.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.event, color: AppTheme.primaryGreen),
        ),
        title: Text(event, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(date),
      ),
    );
  }
}