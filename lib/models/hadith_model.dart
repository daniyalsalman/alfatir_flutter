// lib/models/hadith_model.dart

class Hadith {
  final int id;
  final int? idInBook;
  final int? chapterId;
  final int? bookId;
  final String arabic;
  final String englishText;
  final String? narrator;
  final String? reference; // Added to show reference like "Book 1, Hadith 1"

  Hadith({
    required this.id,
    this.idInBook,
    this.chapterId,
    this.bookId,
    required this.arabic,
    required this.englishText,
    this.narrator,
    this.reference,
  });

  factory Hadith.fromJson(dynamic json) {
    // Helper to safely get string
    String getString(List<String> keys) {
      for (var key in keys) {
        if (json[key] != null) return json[key].toString();
      }
      return '';
    }

    // Handle English text which can be a String or a Map
    String englishText = '';
    String? narrator;

    if (json['english'] != null) {
      if (json['english'] is String) {
        englishText = json['english'];
      } else if (json['english'] is Map) {
        englishText = json['english']['text'] ?? '';
        narrator = json['english']['narrator'];
      }
    } else if (json['English_Text'] != null) {
      englishText = json['English_Text'];
    }

    // Parse IDs flexibly
    int parsedId = int.tryParse(json['id']?.toString() ?? json['Hadith_ID']?.toString() ?? '-1') ?? -1;
    int? parsedChapterId = int.tryParse(json['chapterId']?.toString() ?? json['Chapter_Number']?.toString() ?? '');

    return Hadith(
      id: parsedId,
      idInBook: int.tryParse(json['idInBook']?.toString() ?? ''),
      chapterId: parsedChapterId,
      bookId: int.tryParse(json['bookId']?.toString() ?? ''),
      arabic: getString(['arabic', 'Arabic_Text', 'text']),
      englishText: englishText,
      narrator: narrator,
      reference: getString(['Reference', 'In-book reference']),
    );
  }
}