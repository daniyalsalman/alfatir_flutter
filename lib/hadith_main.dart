import 'package:flutter/material.dart';
import 'hadith_list_screen.dart';

class HadithBooksScreen extends StatelessWidget {
  HadithBooksScreen({super.key});

  final List<Map<String, String>> books = [
    {"name": "Sahih al-Bukhari", "path": "assets/content/sahih_bukhari.json"},
    {"name": "Sahih Muslim", "path": "assets/content/sahih_muslim.json"},
    {"name": "Jami' at-Tirmidhi", "path": "assets/content/jami_tirmidhi.json"},
    {"name": "Sunan Ibn Majah", "path": "assets/content/sunan_ibn_majah.json"},
    {"name": "Sunan an-Nasa'i", "path": "assets/content/sunan_an_nasai.json"},
    {"name": "Sunan Abi Dawud", "path": "assets/content/sunan_abi_dawud.json"},
    {"name": "Riyad as-Salihin", "path": "assets/content/riyad_assalihin.json"},
    {
      "name": "Mishkat al-Masabih",
      "path": "assets/content/mishkat_almasabih.json"
    },
    {"name": "Shama'il Muhammadiyah", "path": "assets/content/shamail_muhammadiyah.json"},
    {"name": "Malik (Muwatta)", "path": "assets/content/malik.json"},
    {"name": "Musnad Ahmad", "path": "assets/content/ahmed.json"},
    {"name": "Bulugh al-Maram", "path": "assets/content/bulugh_almaram.json"},
    {"name": "Al-Adab Al-Mufrad", "path": "assets/content/aladab_almufrad.json"},
    {"name": "Sunan ad-Darimi", "path": "assets/content/darimi.json"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Hadith Books")),
      body: ListView.builder(
        itemCount: books.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(books[index]["name"]!),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => HadithListScreen(
                    bookName: books[index]["name"]!,
                    jsonPath: books[index]["path"]!,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
