// lib/surah_detail_screen.dart

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
  final QuranService _quranService = QuranService();
  String selectedLang = 'en';
  Surah? mergedSurah;
  bool loading = false;

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
    _loadTranslation();
  }

  Future<void> _loadTranslation() async {
    setState(() {
      loading = true;
      mergedSurah = null;
    });

    final path = 'assets/content/quran_$selectedLang.json';

    try {
      final translations = await _quranService.loadQuranFile(path);
      
      final translatedSurah = translations.firstWhere(
        (s) => s.id == widget.arabicSurah.id,
        orElse: () => widget.arabicSurah,
      );

      final merged = _quranService.mergeSurahs(widget.arabicSurah, translatedSurah);

      setState(() {
        mergedSurah = merged;
        loading = false;
      });
    } catch (e) {
      print("Error loading translation: $e");
      setState(() {
        mergedSurah = widget.arabicSurah;
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Determine if we are in dark mode to adjust card colors if needed
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.arabicSurah.name} • ${widget.arabicSurah.transliteration}'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: DropdownButton<String>(
              value: selectedLang,
              dropdownColor: Theme.of(context).primaryColor,
              style: const TextStyle(color: Colors.white),
              iconEnabledColor: Colors.white,
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
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: (mergedSurah ?? widget.arabicSurah).verses.length,
              itemBuilder: (context, index) {
                final v = (mergedSurah ?? widget.arabicSurah).verses[index];
                return Card(
                  // In dark mode, Flutter cards are dark grey by default. 
                  // We ensure elevation helps separate them.
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Arabic Text
                        Text(
                          v.text,
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Amiri',
                            // Use standard title color (adapts to mode)
                            color: Theme.of(context).textTheme.titleLarge?.color, 
                          ),
                        ),
                        
                        if (v.translation != null) ...[
                          const SizedBox(height: 12),
                          const Divider(),
                          const SizedBox(height: 8),
                          // Translation Text
                          Text(
                            v.translation!,
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              fontSize: 16,
                              height: 1.4,
                              // FIX: Removed Colors.black87
                              // Use body color (adapts to mode)
                              color: Theme.of(context).textTheme.bodyMedium?.color, 
                            ),
                          ),
                        ]
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}