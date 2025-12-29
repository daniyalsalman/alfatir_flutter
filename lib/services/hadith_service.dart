// lib/services/hadith_service.dart

import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/hadith_model.dart';

class HadithService {
  /// Entry function to load a hadith book
  Future<List<Hadith>> loadHadithBook(String jsonPath) async {
    try {
      // 1. Load the JSON string
      // Note: jsonPath coming from main screen includes 'assets/content/', 
      // but if it doesn't, we add it. 
      final fullPath = jsonPath.startsWith('assets/') ? jsonPath : 'assets/content/$jsonPath';
      final String jsonString = await rootBundle.loadString(fullPath);
      
      // 2. Decode JSON
      final dynamic data = json.decode(jsonString);

      List<Hadith> hadiths = [];

      // 3. Determine Structure
      if (data is List) {
        // CASE A: Flat List (e.g. Sahih Bukhari, Sunan Abi Dawud)
        hadiths = data.map((item) => Hadith.fromJson(item)).toList();
      } else if (data is Map<String, dynamic>) {
        // CASE B: Nested Object (e.g. Riyad as-Salihin, Musnad Ahmed)
        
        // Check for 'hadiths' array
        if (data.containsKey('hadiths') && data['hadiths'] is List) {
          hadiths = (data['hadiths'] as List)
              .map((item) => Hadith.fromJson(item))
              .toList();
        } 
        // Check for 'chapters' array (sometimes hadiths are inside chapters)
        else if (data.containsKey('chapters') && data['chapters'] is List) {
          for (var chapter in data['chapters']) {
            if (chapter is Map && chapter.containsKey('hadiths')) {
              var chapterHadiths = (chapter['hadiths'] as List)
                  .map((item) => Hadith.fromJson(item))
                  .toList();
              hadiths.addAll(chapterHadiths);
            }
          }
        }
      }

      return hadiths;
    } catch (e) {
      print('Error loading hadith book ($jsonPath): $e');
      return [];
    }
  }
}