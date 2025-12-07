// lib/screens/surah_detail_screen.dart

import 'package:flutter/material.dart';
import '../models/surah.dart';
import '../services/quran_service.dart';

class SurahDetailScreen extends StatefulWidget {
  final Surah arabicSurah;

  const SurahDetailScreen({super.key, required this.arabicSurah});

  @override
  State<SurahDetailScreen> createState() => _SurahDetailScreenState();
}

class _SurahDetailScreenState extends State<SurahDetailScreen> {
  String selectedLang = 'en';
  Surah? mergedSurah;
  bool loading = false;

  // All language options you listed
  final translationOptions = const [
    DropdownMenuItem(value: "en", child: Text("English")),
    DropdownMenuItem(value: "ur", child: Text("Urdu")),
    DropdownMenuItem(value: "tr", child: Text("Turkish")),
    DropdownMenuItem(value: "bn", child: Text("Bengali")),
    DropdownMenuItem(value: "es", child: Text("Spanish")),
    DropdownMenuItem(value: "fr", child: Text("French")),
    DropdownMenuItem(value: "id", child: Text("Indonesian")),
    DropdownMenuItem(value: "ru", child: Text("Russian")),
    DropdownMenuItem(value: "sv", child: Text("Swedish")),
    DropdownMenuItem(value: "zh", child: Text("Chinese")),
  ];

  @override
  void initState() {
    super.initState();
    _loadTranslation(); // load default translation on start
  }

  Future<void> _loadTranslation() async {
    setState(() {
      loading = true;
      mergedSurah = null;
    });

    // Arabic file path where your base Arabic is stored (adjust if different)
    // We already have the arabic Surah as widget.arabicSurah, so just load translation
    final path = 'assets/content/quran_$selectedLang.json';

    try {
      final translations = await loadQuranFile(path);
      final translatedSurah = translations.firstWhere(
        (s) => s.id == widget.arabicSurah.id,
        orElse: () => widget.arabicSurah, // fallback to arabic if missing
      );

      final merged = mergeSurahs(widget.arabicSurah, translatedSurah);

      setState(() {
        mergedSurah = merged;
        loading = false;
      });
    } catch (e) {
      // if anything fails (file missing, parse error) -> fallback to arabic only
      setState(() {
        mergedSurah = widget.arabicSurah;
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.arabicSurah.name} • ${widget.arabicSurah.transliteration}'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: DropdownButton<String>(
              value: selectedLang,
              underline: const SizedBox(),
              items: translationOptions,
              onChanged: (val) async {
                if (val == null) return;
                setState(() => selectedLang = val);
                await _loadTranslation();
              },
            ),
          ),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : mergedSurah == null
              ? const Center(child: Text('No data'))
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: mergedSurah!.verses.length,
                  itemBuilder: (context, index) {
                    final v = mergedSurah!.verses[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Arabic line (right aligned)
                            Text(
                              v.text,
                              textAlign: TextAlign.right,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w600,
                              ),
                            ),

                            const SizedBox(height: 10),

                            // Translation (left aligned)
                            Text(
                              v.translation ?? '',
                              textAlign: TextAlign.left,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
