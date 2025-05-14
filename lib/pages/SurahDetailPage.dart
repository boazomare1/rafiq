import 'package:flutter/material.dart';
import '../api/quran_api.dart';

class SurahDetailPage extends StatefulWidget {
  final int surahNumber;
  final String surahName;

  const SurahDetailPage({
    required this.surahNumber,
    required this.surahName,
    Key? key,
  }) : super(key: key);

  @override
  _SurahDetailPageState createState() => _SurahDetailPageState();
}

class _SurahDetailPageState extends State<SurahDetailPage> {
  final QuranApi _api = QuranApi();

  late Future<List<Verse>> _versesFuture;
  bool _showTransliteration = true;

  @override
  void initState() {
    super.initState();
    _versesFuture = _loadAllEditions();
  }

  Future<List<Verse>> _loadAllEditions() async {
    // Fire off three API calls in parallel
    final arabicFut = _api.fetchSurahEdition(widget.surahNumber, 'ar.alafasy');
    final translationFut = _api.fetchSurahEdition(widget.surahNumber, 'en.asad');
    final translitFut = _api.fetchSurahEdition(widget.surahNumber, 'en.transliteration');

    final results = await Future.wait([arabicFut, translationFut, translitFut]);
    final arabicData      = results[0];
    final translationData = results[1];
    final translitData    = results[2];

    final List<dynamic> arabicAyahs      = arabicData['ayahs'];
    final List<dynamic> translationAyahs = translationData['ayahs'];
    final List<dynamic> translitAyahs    = translitData['ayahs'];

    // Zip them into Verse objects
    return List<Verse>.generate(arabicAyahs.length, (i) {
      return Verse(
        number: arabicAyahs[i]['numberInSurah'] as int,
        arabic: arabicAyahs[i]['text'] as String,
        translation: translationAyahs[i]['text'] as String,
        transliteration: translitAyahs[i]['text'] as String,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.surahName),
        actions: [
          // Toggle transliteration
          IconButton(
            icon: Icon(
              _showTransliteration ? Icons.text_fields : Icons.text_rotation_none,
            ),
            tooltip: 'Toggle Transliteration',
            onPressed: () => setState(() => _showTransliteration = !_showTransliteration),
          ),
        ],
      ),
      body: FutureBuilder<List<Verse>>(
        future: _versesFuture,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text('Error: ${snap.error}'));
          }
          final verses = snap.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: verses.length,
            itemBuilder: (_, i) {
              final v = verses[i];
              return Card(
                margin: EdgeInsets.symmetric(vertical: 8),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Arabic
                      Text(
                        '${v.arabic}  ﴿${v.number}﴾',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontSize: 24,
                          fontFamily: 'Amiri',
                          height: 1.8,
                        ),
                      ),
                      SizedBox(height: 8),
                      // Optional transliteration
                      if (_showTransliteration)
                        Text(
                          v.transliteration,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      if (_showTransliteration) SizedBox(height: 8),
                      // Translation
                      Text(
                        v.translation,
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
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

/// Simple data class representing one verse with all three texts.
class Verse {
  final int number;
  final String arabic;
  final String translation;
  final String transliteration;

  Verse({
    required this.number,
    required this.arabic,
    required this.translation,
    required this.transliteration,
  });
}
