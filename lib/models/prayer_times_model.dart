class PrayerTimes {
  final String fajr;
  final String dhuhr;
  final String asr;
  final String maghrib;
  final String isha;

  PrayerTimes({
    required this.fajr,
    required this.dhuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
  });

  factory PrayerTimes.fromJson(Map<String, dynamic> json) {
    final timings = json['data']['timings'];

    String clean(String time) {
      // Removes timezone junk like "(+05)"
      return time.split(' ').first.trim();
    }

    return PrayerTimes(
      fajr: clean(timings['Fajr']),
      dhuhr: clean(timings['Dhuhr']),
      asr: clean(timings['Asr']),
      maghrib: clean(timings['Maghrib']),
      isha: clean(timings['Isha']),
    );
  }
}
