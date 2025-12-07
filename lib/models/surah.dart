// lib/models/surah.dart

class Verse {
  final int id;
  final String text;            // Arabic (or translation if that file is translation)
  final String? translation;    // optional translation text (nullable)

  Verse({
    required this.id,
    required this.text,
    this.translation,
  });

  factory Verse.fromJson(Map<String, dynamic> json) {
    return Verse(
      id: json['id'] as int,
      text: json['text'] as String? ?? '',
      translation: json['translation'] as String?,
    );
  }
}

class Surah {
  final int id;
  final String name;
  final String transliteration;
  final String type;
  final int totalVerses;
  final List<Verse> verses;

  Surah({
    required this.id,
    required this.name,
    required this.transliteration,
    required this.type,
    required this.totalVerses,
    required this.verses,
  });

  factory Surah.fromJson(Map<String, dynamic> json) {
    return Surah(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      transliteration: json['transliteration'] as String? ?? '',
      type: json['type'] as String? ?? '',
      totalVerses: json['total_verses'] as int? ?? 0,
      verses: (json['verses'] as List<dynamic>? ?? [])
          .map((e) => Verse.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
