// lib/services/quran_service.dart

import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../models/surah.dart';

/// Load ANY quran JSON file (arabic or translation) from assets
Future<List<Surah>> loadQuranFile(String path) async {
  final jsonString = await rootBundle.loadString(path);
  final List<dynamic> jsonList = json.decode(jsonString) as List<dynamic>;
  return jsonList.map((e) => Surah.fromJson(e as Map<String, dynamic>)).toList();
}

/// Merge an Arabic Surah and a translated Surah into one Surah
/// The returned Surah has Arabic text from [arabic] and translation text
/// from [translation] placed into Verse.translation.
Surah mergeSurahs(Surah arabic, Surah translation) {
  final merged = <Verse>[];

  final int len = arabic.verses.length;
  for (int i = 0; i < len; i++) {
    final arabicVerse = arabic.verses[i];
    // Find matching translated verse by index or id. Prefer id-safe approach:
    String? transText;
    if (i < translation.verses.length) {
      // prefer matching by id if available
      if (translation.verses[i].id == arabicVerse.id) {
        transText = translation.verses[i].translation ?? translation.verses[i].text;
      } else {
        // fallback: try to find by id
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
