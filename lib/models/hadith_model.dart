class Hadith {
  final int id;
  final int? idInBook;
  final int? chapterId;
  final int? bookId;
  final String arabic;
  final String englishText;
  final String? narrator;

  Hadith({
    required this.id,
    this.idInBook,
    this.chapterId,
    this.bookId,
    required this.arabic,
    required this.englishText,
    this.narrator,
  });

  factory Hadith.fromJson(Map<String, dynamic> json) {
    // English can be string or map
    String englishText = '';
    String? narrator;

    if (json['english'] != null) {
      if (json['english'] is String) {
        englishText = json['english'];
      } else if (json['english'] is Map) {
        englishText = json['english']['text'] ?? '';
        narrator = json['english']['narrator'];
      }
    }

    return Hadith(
      id: json['id'] ?? -1,
      idInBook: json['idInBook'],
      chapterId: json['chapterId'],
      bookId: json['bookId'],
      arabic: json['arabic'] ?? '',
      englishText: englishText,
      narrator: narrator,
    );
  }
}
