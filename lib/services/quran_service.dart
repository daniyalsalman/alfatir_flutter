// lib/services/quran_service.dart

import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../models/surah.dart';

class QuranService {
  // Helper to load any JSON file
  Future<List<Surah>> loadQuranFile(String path) async {
    final jsonString = await rootBundle.loadString(path);
    final List<dynamic> jsonList = json.decode(jsonString) as List<dynamic>;
    return jsonList.map((e) => Surah.fromJson(e as Map<String, dynamic>)).toList();
  }

  // Specific method to get the default Arabic Quran
  Future<List<Surah>> getAllSurahs() async {
    return loadQuranFile('assets/content/quran.json');
  }

  // Merge Arabic and Translation
  Surah mergeSurahs(Surah arabic, Surah translation) {
    final merged = <Verse>[];

    final int len = arabic.verses.length;
    for (int i = 0; i < len; i++) {
      final arabicVerse = arabic.verses[i];
      String? transText;
      
      if (i < translation.verses.length) {
        if (translation.verses[i].id == arabicVerse.id) {
          transText = translation.verses[i].translation ?? translation.verses[i].text;
        } else {
          final match = translation.verses.firstWhere(
            (v) => v.id == arabicVerse.id,
            orElse: () => Verse(id: -1, text: '', translation: null),
          );
          transText = (match.id != -1) ? (match.translation ?? match.text) : null;
        }
      }

      merged.add(
        Verse(
          id: arabicVerse.id,
          text: arabicVerse.text,
          translation: transText,
        ),
      );
    }

    return Surah(
      id: arabic.id,
      name: arabic.name,
      transliteration: arabic.transliteration,
      type: arabic.type,
      totalVerses: arabic.totalVerses,
      verses: merged,
    );
  }
}