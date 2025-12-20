import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:alfatir_proj/models/hadith_model.dart';

class HadithListScreen extends StatefulWidget {
  final String bookName;
  final String jsonPath;

  const HadithListScreen({
    super.key,
    required this.bookName,
    required this.jsonPath,
  });

  @override
  State<HadithListScreen> createState() => _HadithListScreenState();
}

class _HadithListScreenState extends State<HadithListScreen> {
  List<Hadith> hadiths = [];

  @override
  void initState() {
    super.initState();
    loadHadiths();
  }

 Future<void> loadHadiths() async {
  String jsonString = await rootBundle.loadString(widget.jsonPath);
  final data = json.decode(jsonString);

  List<dynamic> hadithList = [];

  if (data is List) {
    // Flat list (Sahih Bukhari, Muslim, Sunan)
    hadithList = data;
  } else if (data is Map) {
    // Nested books (Riyad/Shamā’il)
    if (data.containsKey("hadiths") && data["hadiths"] is List) {
      hadithList = data["hadiths"];
    } else if (data.containsKey("chapters") && data["chapters"] is List) {
      for (var chapter in data["chapters"]) {
        if (chapter.containsKey("hadiths") && chapter["hadiths"] is List) {
          hadithList.addAll(chapter["hadiths"]);
        }
      }
    }
  }

  // Make sure we actually have a list
  if (hadithList.isEmpty) {
    print("Warning: No hadiths found in JSON file ${widget.jsonPath}");
  }

  setState(() {
    hadiths = hadithList.map((e) {
      if (e is Map<String, dynamic>) return Hadith.fromJson(e);
      // fallback for any unexpected format
      return Hadith(
        id: -1,
        arabic: e.toString(),
        englishText: '',
      );
    }).toList();
  });
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.bookName)),
      body: hadiths.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: hadiths.length,
              itemBuilder: (context, index) {
                final h = hadiths[index];
                return Card(
                  margin: const EdgeInsets.all(8),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          h.chapterId.toString(),
                          textDirection: TextDirection.rtl,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 6),

                        Text(
                          h.arabic,
                          textDirection: TextDirection.rtl,
                          style: const TextStyle(fontSize: 18),
                        ),

                        const Divider(),

                        Text(
                          h.englishText,
                          style: const TextStyle(fontSize: 16),
                        ),

                        const SizedBox(height: 6),
                        Text(
                          "Ref: ${h.narrator}",
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
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
