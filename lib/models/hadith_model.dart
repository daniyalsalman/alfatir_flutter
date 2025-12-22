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
        narrator = json['english']['narrator'] ?? '';
      }
    }

    return Hadith(
      id: int.tryParse(json['id']?.toString() ?? json['number']?.toString() ?? '-1') ?? -1,
      idInBook: int.tryParse(json['idInBook']?.toString() ?? json['In-book reference']?.toString() ?? ''),
      chapterId: int.tryParse(json['chapterId']?.toString() ?? ''),
      bookId: int.tryParse(json['bookId']?.toString() ?? ''),
      arabic: json['arabic'] ?? json['text'] ?? '',
      englishText: englishText,
      narrator: narrator,
    );
  }
}
