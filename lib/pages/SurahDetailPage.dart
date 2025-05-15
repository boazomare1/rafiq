import 'package:flutter/material.dart';
import '../api/quran_api.dart';
import 'package:salatul_tracker/services/surah_audio.dart';
import 'package:just_audio/just_audio.dart'; // For audio playback

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
  final AudioPlayer _audioPlayer = AudioPlayer();

  late Future<List<Verse>> _versesFuture;
  bool _showTransliteration = true;

  bool _isPlaying = false;
  bool _isPaused = false;

  @override
  void initState() {
    super.initState();
    _versesFuture = _loadAllEditions();
  }

  Future<void> _handleAudioPlayback() async {
    final url = surahAudioUrls[widget.surahNumber];

    if (url == null) return;

    if (!_isPlaying) {
      try {
        await _audioPlayer.setUrl(url);
        await _audioPlayer.play();
        setState(() {
          _isPlaying = true;
          _isPaused = false;
        });
      } catch (e) {
        print("Audio error: $e");
      }
    } else if (_isPaused) {
      await _audioPlayer.play();
      setState(() {
        _isPaused = false;
      });
    } else {
      await _audioPlayer.pause();
      setState(() {
        _isPaused = true;
      });
    }
  }

  Future<List<Verse>> _loadAllEditions() async {
    final arabicFut = _api.fetchSurahEdition(widget.surahNumber, 'ar.alafasy');
    final translationFut = _api.fetchSurahEdition(widget.surahNumber, 'en.asad');
    final translitFut = _api.fetchSurahEdition(widget.surahNumber, 'en.transliteration');

    final results = await Future.wait([arabicFut, translationFut, translitFut]);
    final arabicData = results[0];
    final translationData = results[1];
    final translitData = results[2];

    final List<dynamic> arabicAyahs = arabicData['ayahs'];
    final List<dynamic> translationAyahs = translationData['ayahs'];
    final List<dynamic> translitAyahs = translitData['ayahs'];

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
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.surahName),
        actions: [
          IconButton(
            icon: Icon(
              !_isPlaying
                  ? Icons.play_arrow
                  : _isPaused
                      ? Icons.play_arrow
                      : Icons.pause,
            ),
            tooltip: !_isPlaying
                ? 'Play Surah'
                : _isPaused
                    ? 'Resume'
                    : 'Pause',
            onPressed: _handleAudioPlayback,
          ),
          IconButton(
            icon: Icon(_showTransliteration ? Icons.text_fields : Icons.text_rotation_none),
            tooltip: 'Toggle Transliteration',
            onPressed: () {
              setState(() {
                _showTransliteration = !_showTransliteration;
              });
            },
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
                      Text(v.translation, style: TextStyle(fontSize: 16)),
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
