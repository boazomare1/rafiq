import 'package:flutter/material.dart';
import 'package:salatul_tracker/pages/juz_detail_page.dart';
import '../api/quran_api.dart';
import 'SurahDetailPage.dart';

class SurahListPage extends StatefulWidget {
  @override
  _SurahListPageState createState() => _SurahListPageState();
}

class _SurahListPageState extends State<SurahListPage> {
  final QuranApi _api = QuranApi();
  late Future<List<dynamic>> _surahsFuture;
  List<dynamic> _allSurahs = [];
  List<dynamic> _filteredSurahs = [];
  final _searchController = TextEditingController();

  /// Common “titles” for each of the 30 Juz, based on their opening words
  final List<String> _juzNames = [
    'Alif Lam Meem', // Juz 1
    'Sad', // Juz 2
    'Tilka Rusul', // Juz 3 (opening 'Tilka Ar-Rusul')
    'Lan Yakana', // Juz 4 (opening 'Lan Yakuna')
    'Walmudaththir', // Juz 5 (opening 'Ya Ayyuhal Mudaththir')
    'Al An’am', // Juz 6 (opening 'Alhamdu Lillahi')
    'Lam Yakun', // Juz 7 (opening 'Lam Yakun As-habon')
    'Qal Mawala', // Juz 8 (opening 'Qal Mawala')
    'Qal Hu', // Juz 9 (opening 'Qal Huwal Haqq')
    'Wa Ala', // Juz 10 (opening 'Wa ALA Haqqin')
    'Ya Sin', // Juz 11
    'Amma', // Juz 12 (opening 'Amma Yatasa’alun')
    'Tabarak', // Juz 13 (opening 'Tabaraka')
    'Amin', // Juz 14 (opening 'Amin')
    'Subhana', // Juz 15 (opening 'Subhana Alladhi')
    'Qad Aflaha', // Juz 16 (opening 'Qad Aflaha Man')
    'Qala Ta', // Juz 17 (opening 'Qala Ta’thu')
    'Hamim', // Juz 18 (opening 'Alhamim')
    'Kaf Ha Ya Ain Sad', // Juz 19
    'Ha Meem', // Juz 20
    'Ha Meem', // Juz 21 (continuation, identical opener)
    'Ya Ayuhalla', // Juz 22
    'Wa Mathaluhu', // Juz 23
    'Ana Anzalnahu', // Juz 24
    'Wa Ma Ubrikum', // Juz 25
    'Tabarak', // Juz 26 (second occurrence)
    'Bali', // Juz 27
    'Ha Meem', // Juz 28 (third occurrence)
    'Tilha', // Juz 29
    'Amma', // Juz 30 (common name)
  ];

  @override
  void initState() {
    super.initState();
    _surahsFuture = _api.fetchSurahs();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredSurahs =
          _allSurahs.where((surah) {
            final name = (surah['englishName'] as String).toLowerCase();
            final arabic = (surah['name'] as String).toLowerCase();
            final num = surah['number'].toString();
            return name.contains(query) ||
                arabic.contains(query) ||
                num.contains(query);
          }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Al‑Quran'),
          bottom: TabBar(tabs: [Tab(text: 'Surahs'), Tab(text: 'Juz')]),
        ),
        body: TabBarView(
          children: [
            // —— SURAH TAB ——
            FutureBuilder<List<dynamic>>(
              future: _surahsFuture,
              builder: (context, snap) {
                if (snap.connectionState != ConnectionState.done) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snap.hasError) {
                  return Center(child: Text('Error: ${snap.error}'));
                }
                // initialize lists once
                if (_allSurahs.isEmpty) {
                  _allSurahs = snap.data!;
                  _filteredSurahs = _allSurahs;
                }
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.search),
                          hintText: 'Search Surah by name or number',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListView.separated(
                        itemCount: _filteredSurahs.length,
                        separatorBuilder: (_, __) => Divider(height: 1),
                        itemBuilder: (_, i) {
                          final s = _filteredSurahs[i];
                          return ListTile(
                            title: Text('${s['englishName']} (${s['name']})'),
                            subtitle: Text('${s['numberOfAyahs']} verses'),
                            trailing: Icon(Icons.chevron_right),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (_) => SurahDetailPage(
                                        surahNumber: s['number'],
                                        surahName: s['englishName'],
                                      ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),

            // —— JUZ TAB ——
            ListView.separated(
              padding: EdgeInsets.all(8),
              itemCount: 30,
              separatorBuilder: (_, __) => Divider(height: 1),
              itemBuilder: (_, idx) {
                final juzNum = idx + 1;
                final title = _juzNames[idx]; // get the name
                return ListTile(
                  title: Text('Juz $juzNum: $title'),
                  trailing: Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => JuzDetailPage(juzNumber: juzNum),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
