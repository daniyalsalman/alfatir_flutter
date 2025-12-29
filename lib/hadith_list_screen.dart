import 'package:flutter/material.dart';
import 'package:alfatir_proj/models/hadith_model.dart';
import 'package:alfatir_proj/services/hadith_service.dart';
import 'package:alfatir_proj/theme/app_theme.dart';

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
  final HadithService _hadithService = HadithService();
  List<Hadith> hadiths = [];
  bool isLoading = true;

  // For Chapter Grouping
  Map<int, List<Hadith>> hadithsByChapter = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final data = await _hadithService.loadHadithBook(widget.jsonPath);
    
    // Group by Chapter ID
    final Map<int, List<Hadith>> grouped = {};
    for (var h in data) {
      final chapId = h.chapterId ?? 0; 
      if (!grouped.containsKey(chapId)) {
        grouped[chapId] = [];
      }
      grouped[chapId]!.add(h);
    }

    final sortedKeys = grouped.keys.toList()..sort();
    final Map<int, List<Hadith>> sortedGrouped = {
      for (var k in sortedKeys) k: grouped[k]!
    };

    if (mounted) {
      setState(() {
        hadiths = data;
        hadithsByChapter = sortedGrouped;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Check theme brightness to adjust specific colors if needed
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.bookName),
          actions: [
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                showSearch(
                  context: context,
                  delegate: HadithSearchDelegate(hadiths),
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
              Tab(text: "All Hadiths"),
              Tab(text: "Chapters"),
            ],
          ),
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : hadiths.isEmpty
                ? const Center(child: Text("No Hadiths found."))
                : TabBarView(
                    children: [
                      // Tab 1: All Hadiths
                      HadithListView(hadiths: hadiths),
                      
                      // Tab 2: Chapter View
                      ListView.builder(
                        itemCount: hadithsByChapter.length,
                        itemBuilder: (context, index) {
                          final chapterId = hadithsByChapter.keys.elementAt(index);
                          final chapterHadiths = hadithsByChapter[chapterId]!;
                          
                          String chapterTitle = chapterId == 0 
                              ? "General / Introduction" 
                              : "Chapter $chapterId";

                          return ExpansionTile(
                            // FIX: Use theme colors instead of hardcoded black
                            textColor: isDarkMode ? AppTheme.accentGold : AppTheme.primaryGreen,
                            iconColor: isDarkMode ? AppTheme.accentGold : AppTheme.primaryGreen,
                            collapsedTextColor: Theme.of(context).textTheme.bodyLarge?.color,
                            collapsedIconColor: Theme.of(context).iconTheme.color,
                            
                            title: Text(
                              chapterTitle,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text("${chapterHadiths.length} Hadiths"),
                            children: chapterHadiths.map((h) {
                              return Padding(
                                padding: const EdgeInsets.only(left: 16.0),
                                child: HadithCard(hadith: h),
                              );
                            }).toList(),
                          );
                        },
                      ),
                    ],
                  ),
      ),
    );
  }
}

class HadithListView extends StatelessWidget {
  final List<Hadith> hadiths;
  const HadithListView({super.key, required this.hadiths});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: hadiths.length,
      itemBuilder: (context, index) {
        return HadithCard(hadith: hadiths[index]);
      },
    );
  }
}

class HadithCard extends StatelessWidget {
  final Hadith hadith;
  const HadithCard({super.key, required this.hadith});

  @override
  Widget build(BuildContext context) {
    // Helper to get correct colors
    final titleColor = Theme.of(context).textTheme.titleMedium?.color;
    final bodyColor = Theme.of(context).textTheme.bodyMedium?.color;
    final captionColor = Theme.of(context).textTheme.bodySmall?.color;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Chip(
                  label: Text("#${hadith.id}"),
                  visualDensity: VisualDensity.compact,
                  // Adaptive Chip Colors
                  backgroundColor: Theme.of(context).brightness == Brightness.dark 
                      ? Colors.grey[800] 
                      : Theme.of(context).primaryColor.withOpacity(0.1),
                  labelStyle: TextStyle(
                    color: Theme.of(context).brightness == Brightness.dark 
                        ? Colors.white 
                        : Theme.of(context).primaryColor,
                  ),
                ),
                if (hadith.chapterId != null)
                  Text(
                    "Chap ${hadith.chapterId}",
                    style: TextStyle(fontSize: 12, color: captionColor),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            
            // Arabic Text
            if (hadith.arabic.isNotEmpty)
              SizedBox(
                width: double.infinity,
                child: Text(
                  hadith.arabic,
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: 20,
                    fontFamily: 'Amiri', 
                    height: 1.6,
                    fontWeight: FontWeight.w600,
                    color: titleColor, // Adapts to Dark Mode
                  ),
                ),
              ),
            
            if (hadith.arabic.isNotEmpty) const Divider(height: 24),
            
            // English Text
            if (hadith.englishText.isNotEmpty)
              Text(
                hadith.englishText,
                style: TextStyle(
                  fontSize: 16, 
                  height: 1.4,
                  color: bodyColor, // Adapts to Dark Mode
                ),
              ),
            
            // Narrator Reference
            if (hadith.narrator != null && hadith.narrator!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                "- ${hadith.narrator}",
                style: TextStyle(
                  fontSize: 13,
                  fontStyle: FontStyle.italic,
                  color: captionColor?.withOpacity(0.7), // Adaptive Grey
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class HadithSearchDelegate extends SearchDelegate {
  final List<Hadith> allHadiths;

  HadithSearchDelegate(this.allHadiths);

  // Fix Search Bar Colors for Dark Mode
  @override
  ThemeData appBarTheme(BuildContext context) {
    final theme = Theme.of(context);
    return theme.copyWith(
      inputDecorationTheme: const InputDecorationTheme(
        border: InputBorder.none,
        hintStyle: TextStyle(color: Colors.white70),
      ),
      textTheme: theme.textTheme.copyWith(
        titleLarge: const TextStyle(color: Colors.white, fontSize: 18),
      ),
    );
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () => query = '',
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildList(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildList(context);
  }

  Widget _buildList(BuildContext context) {
    final cleanQuery = query.toLowerCase().trim();
    
    if (cleanQuery.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search, size: 64, color: Theme.of(context).hintColor),
            const SizedBox(height: 16),
            const Text("Search for keywords..."),
          ],
        ),
      );
    }

    final results = allHadiths.where((h) {
      final eng = h.englishText.toLowerCase();
      final nar = (h.narrator ?? '').toLowerCase();
      final id = h.id.toString();
      
      return eng.contains(cleanQuery) || 
             nar.contains(cleanQuery) || 
             id == cleanQuery; 
    }).toList();

    if (results.isEmpty) {
      return const Center(child: Text("No matches found."));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: results.length,
      itemBuilder: (context, index) {
        return HadithCard(hadith: results[index]);
      },
    );
  }
}