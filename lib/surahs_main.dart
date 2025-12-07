import 'package:flutter/material.dart';
import '../models/surah.dart';
import '../services/quran_service.dart';
import 'surah_detail_screen.dart';

class SurahListScreen extends StatelessWidget {
  const SurahListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Quran Surahs")),
      body: FutureBuilder<List<Surah>>(
        future: loadQuranFile("assets/content/quran.json"), // ARABIC ONLY
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                "Error loading Quran: ${snapshot.error}",
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          final surahs = snapshot.data ?? [];

          return ListView.builder(
            itemCount: surahs.length,
            itemBuilder: (context, index) {
              final surah = surahs[index];

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(14),
                  title: Text(
                    "${surah.id}. ${surah.name}",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  subtitle: Text(
                      "${surah.transliteration} • ${surah.type.toUpperCase()} • Verses: ${surah.totalVerses}"
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            SurahDetailScreen(arabicSurah: surah),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
