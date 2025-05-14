import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Parses the /surah response body and returns the "data" list
List<dynamic> _parseSurahList(String body) {
  final Map<String, dynamic> json = jsonDecode(body);
  return json['data'] as List<dynamic>;
}

/// Parses a single‐surah response into its "data" map
Map<String, dynamic> _parseSurahDetail(String body) {
  final Map<String, dynamic> json = jsonDecode(body);
  return json['data'] as Map<String, dynamic>;
}

/// Parses a single‐juz response into its "data" map
Map<String, dynamic> _parseJuzDetail(String body) {
  final Map<String, dynamic> json = jsonDecode(body);
  return json['data'] as Map<String, dynamic>;
}

class QuranApi {
  static const _base = 'https://api.alquran.cloud/v1';

  /// Fetches the list of all 114 surahs (metadata only)
  Future<List<dynamic>> fetchSurahs() async {
    final uri = Uri.parse('$_base/surah');
    final res = await http.get(uri);
    if (res.statusCode != 200) {
      throw Exception('Failed to load surah list');
    }
    return compute(_parseSurahList, res.body);
  }

  /// Fetches any Surah edition (e.g. 'ar.alafasy', 'en.asad', 'en.transliteration')
  Future<Map<String, dynamic>> fetchSurahEdition(int surahNumber, String edition) async {
    final uri = Uri.parse('$_base/surah/$surahNumber/$edition');
    final res = await http.get(uri);
    if (res.statusCode != 200) {
      throw Exception('Failed to load $edition for surah $surahNumber');
    }
    return compute(_parseSurahDetail, res.body);
  }

  /// Fetches a Juz (1–30), returning its data map
  Future<Map<String, dynamic>> fetchJuz(int juzNumber) async {
    final uri = Uri.parse('$_base/juz/$juzNumber');
    final res = await http.get(uri);
    if (res.statusCode != 200) {
      throw Exception('Failed to load Juz $juzNumber');
    }
    return compute(_parseJuzDetail, res.body);
  }

  Future<Map<String, dynamic>> fetchJuzEdition(int juzNumber, String edition) async {
    final uri = Uri.parse('$_base/juz/$juzNumber/$edition');
    final res = await http.get(uri);
    if (res.statusCode != 200) {
      throw Exception('Failed to load Juz $juzNumber ($edition)');
    }
    return compute(_parseJuzDetail, res.body);
  }
}
