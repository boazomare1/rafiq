import 'package:flutter/material.dart';
import '../api/quran_api.dart';

class JuzDetailPage extends StatefulWidget {
  final int juzNumber;
  const JuzDetailPage({required this.juzNumber, Key? key}) : super(key: key);

  @override
  _JuzDetailPageState createState() => _JuzDetailPageState();
}

class _JuzDetailPageState extends State<JuzDetailPage> {
  final QuranApi _api = QuranApi();
  late Future<List<Verse>> _versesFuture;
  bool _showTransliteration = true;

  @override
  void initState() {
    super.initState();
    _versesFuture = _loadAllEditions();
  }

  Future<List<Verse>> _loadAllEditions() async {
    // Parallel fetch: Arabic, translation, translit
    final arabicFut = _api.fetchJuzEdition(widget.juzNumber, 'ar.alafasy');
    final translationFut = _api.fetchJuzEdition(widget.juzNumber, 'en.asad');
    final translitFut = _api.fetchJuzEdition(widget.juzNumber, 'en.transliteration');

    final results = await Future.wait([arabicFut, translationFut, translitFut]);
    final arabicData      = results[0];
    final translationData = results[1];
    final translitData    = results[2];

    final List<dynamic> arabicAyahs      = arabicData['ayahs'];
    final List<dynamic> translationAyahs = translationData['ayahs'];
    final List<dynamic> translitAyahs    = translitData['ayahs'];

    // Zip into Verse objects
    return List<Verse>.generate(arabicAyahs.length, (i) {
      return Verse(
        number: arabicAyahs[i]['number'] as int,
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
        title: Text('Juz ${widget.juzNumber}'),
        actions: [
          IconButton(
            icon: Icon(_showTransliteration 
                ? Icons.text_fields 
                : Icons.text_rotation_none),
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
                      // Arabic with verse number
                      Text(
                        '${v.arabic}  ﴿${v.number}﴾',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontSize: 22,
                          fontFamily: 'Amiri',
                          height: 1.7,
                        ),
                      ),
                      SizedBox(height: 8),
                      // Transliteration (optional)
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
