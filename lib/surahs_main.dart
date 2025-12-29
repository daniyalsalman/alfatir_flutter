// lib/surahs_main.dart

import 'package:flutter/material.dart';
import 'package:alfatir_proj/models/surah.dart';
import 'package:alfatir_proj/services/quran_service.dart';
import 'package:alfatir_proj/surah_detail_screen.dart';
import 'package:alfatir_proj/theme/app_theme.dart';

class SurahsMainScreen extends StatefulWidget {
  const SurahsMainScreen({super.key});

  @override
  State<SurahsMainScreen> createState() => _SurahsMainScreenState();
}

class _SurahsMainScreenState extends State<SurahsMainScreen> {
  final QuranService _quranService = QuranService(); // Now works because QuranService is a class
  List<Surah> _allSurahs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSurahs();
  }

  Future<void> _loadSurahs() async {
    final surahs = await _quranService.getAllSurahs();
    if (mounted) {
      setState(() {
        _allSurahs = surahs;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Holy Quran'),
          actions: [
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                showSearch(
                  context: context,
                  delegate: QuranSearchDelegate(_allSurahs),
                );
              },
            ),
          ],
          bottom: TabBar(
            labelColor: Colors.white,
            labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            unselectedLabelColor: Colors.white.withOpacity(0.85),
            indicatorColor: AppTheme.accentGold,
            indicatorWeight: 4.0,
            tabs: const [
              Tab(text: "Parahs (Juz)"),
              Tab(text: "Surahs"),
            ],
          ),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
                children: [
                  ParahListView(allSurahs: _allSurahs),
                  SurahListView(surahs: _allSurahs),
                ],
              ),
      ),
    );
  }
}

class SurahListView extends StatelessWidget {
  final List<Surah> surahs;
  const SurahListView({super.key, required this.surahs});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: surahs.length,
      itemBuilder: (context, index) {
        final surah = surahs[index];
        return SurahCard(surah: surah);
      },
    );
  }
}

class ParahListView extends StatelessWidget {
  final List<Surah> allSurahs;
  const ParahListView({super.key, required this.allSurahs});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 30,
      padding: const EdgeInsets.all(8),
      itemBuilder: (context, index) {
        final parahNumber = index + 1;
        final surahsInParah = JuzUtils.getSurahsForParah(parahNumber, allSurahs);

        return Card(
          elevation: 2,
          margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
          child: ExpansionTile(
            textColor: Colors.black,
            iconColor: AppTheme.primaryGreen,
            leading: CircleAvatar(
              backgroundColor: AppTheme.primaryGreen,
              foregroundColor: Colors.white,
              child: Text('$parahNumber', style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
            title: Text("Parah $parahNumber", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            subtitle: Text("${surahsInParah.length} Surahs"),
            children: surahsInParah.map((surah) {
              return ListTile(
                leading: const Icon(Icons.book, size: 20, color: Colors.grey),
                title: Text("${surah.id}. ${surah.transliteration}"),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      // FIXED LINE: passing 'arabicSurah' instead of 'surah'
                      builder: (_) => SurahDetailScreen(arabicSurah: surah),
                    ),
                  );
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }
}

class SurahCard extends StatelessWidget {
  final Surah surah;
  const SurahCard({super.key, required this.surah});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.black,
          child: Text('${surah.id}'),
        ),
        title: Text(surah.transliteration, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        subtitle: Text('${surah.type} • ${surah.totalVerses} Verses'),
        trailing: Text(surah.name, style: const TextStyle(fontFamily: 'Amiri', fontSize: 20, color: AppTheme.primaryGreen)),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              // FIXED LINE: passing 'arabicSurah' instead of 'surah'
              builder: (_) => SurahDetailScreen(arabicSurah: surah),
            ),
          );
        },
      ),
    );
  }
}

class QuranSearchDelegate extends SearchDelegate {
  final List<Surah> allSurahs;
  QuranSearchDelegate(this.allSurahs);

  @override
  List<Widget>? buildActions(BuildContext context) => [IconButton(icon: const Icon(Icons.clear), onPressed: () => query = '')];

  @override
  Widget? buildLeading(BuildContext context) => IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => close(context, null));

  @override
  Widget buildResults(BuildContext context) => _buildList(context);
  @override
  Widget buildSuggestions(BuildContext context) => _buildList(context);

  Widget _buildList(BuildContext context) {
    final cleanQuery = query.toLowerCase().trim();
    if (cleanQuery.isEmpty) return const SizedBox();

    final results = allSurahs.where((s) => s.transliteration.toLowerCase().contains(cleanQuery) || s.name.contains(cleanQuery)).toList();

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) => SurahCard(surah: results[index]),
    );
  }
}

class JuzUtils {
  static List<Surah> getSurahsForParah(int parah, List<Surah> allSurahs) {
    final surahIds = _juzToSurahMap[parah];
    if (surahIds == null) return [];
    return allSurahs.where((s) => surahIds.contains(s.id)).toList();
  }

  static final Map<int, List<int>> _juzToSurahMap = {
    1: [1, 2], 2: [2], 3: [2, 3], 4: [3, 4], 5: [4], 6: [4, 5], 7: [5, 6], 8: [6, 7], 9: [7, 8], 10: [8, 9],
    11: [9, 10, 11], 12: [11, 12], 13: [12, 13, 14], 14: [15, 16], 15: [17, 18], 16: [18, 19, 20], 17: [21, 22],
    18: [23, 24, 25], 19: [25, 26, 27], 20: [27, 28, 29], 21: [29, 30, 31, 32, 33], 22: [33, 34, 35, 36],
    23: [36, 37, 38, 39], 24: [39, 40, 41], 25: [41, 42, 43, 44, 45], 26: [46, 47, 48, 49, 50, 51],
    27: [51, 52, 53, 54, 55, 56, 57], 28: [58, 59, 60, 61, 62, 63, 64, 65, 66],
    29: [67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77], 30: List.generate(37, (i) => 78 + i),
  };
}