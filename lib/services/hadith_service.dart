import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/hadith_model.dart';

class HadithService {
  // List of special books requiring custom parsing
  static const List<String> _specialBooks = [
    'jami_tirmidhi.json',
    'sunan_abi_dawud.json',
    'sunan_ibn_majah.json',
    'sunan_an_nasai.json',
    'sahih_bukhari.json',
    'sahih_muslim.json',
  ];

  /// Helper function to check if a book is special
  bool isSpecialBook(String bookName) {
    return _specialBooks.contains(bookName);
  }

  /// Parsing function for special books
  List<Hadith> parseSpecialBook(Map<String, dynamic> json) {
    final List<Hadith> hadiths = [];

    // Handle nested fields and alternative field names
    if (json.containsKey('chapters') && json['chapters'] is List) {
      for (var chapter in json['chapters']) {
        if (chapter.containsKey('hadiths') && chapter['hadiths'] is List) {
          for (var hadithJson in chapter['hadiths']) {
            hadiths.add(Hadith.fromJson(hadithJson));
          }
        }
      }
    } else if (json.containsKey('hadiths') && json['hadiths'] is List) {
      for (var hadithJson in json['hadiths']) {
        hadiths.add(Hadith.fromJson(hadithJson));
      }
    }

    return hadiths;
  }

  /// Parsing function for normal books
  List<Hadith> parseNormalBook(List<dynamic> json) {
    final List<Hadith> hadiths = [];

    for (var hadithJson in json) {
      if (hadithJson is Map<String, dynamic>) {
        hadiths.add(Hadith.fromJson(hadithJson));
      }
    }

    return hadiths;
  }

  /// Helper function to get the JSON path for a book
  String _getJsonPath(String bookName) {
    return 'assets/content/$bookName';
  }

  /// Entry function to load a hadith book
  Future<List<Hadith>> loadHadithBook(String bookName) async {
    try {
      // Load JSON file
      final String jsonString = await rootBundle.loadString(_getJsonPath(bookName));
      final dynamic jsonData = json.decode(jsonString);

      // Check if the book is special and parse accordingly
      if (isSpecialBook(bookName)) {
        return parseSpecialBook(jsonData);
      } else {
        return parseNormalBook(jsonData);
      }
    } catch (e) {
      print('Error loading hadith book: $e');
      return [];
    }
  }
}