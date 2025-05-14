import 'dart:convert';
import 'package:http/http.dart' as http;

class PrayerTimesApi {
  /// Fetches today's prayer times for the given coordinates.
  /// Uses the AlAdhan API (no key required).
  Future<Map<String, String>> fetchPrayerTimes({
    required double latitude,
    required double longitude,
    int method = 2,    // 2 = University of Islamic Sciences, Karachi
  }) async {
    final uri = Uri.https('api.aladhan.com', '/v1/timings', {
      'latitude': latitude.toString(),
      'longitude': longitude.toString(),
      'method': method.toString(),
    });

    final response = await http.get(uri);
    if (response.statusCode != 200) {
      throw Exception('Failed to load prayer times (${response.statusCode})');
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final data = json['data'] as Map<String, dynamic>;
    final timings = data['timings'] as Map<String, dynamic>;

    // Extract only the five obligatory prayers
    return {
      'Fajr': timings['Fajr'] as String,
      'Dhuhr': timings['Dhuhr'] as String,
      'Asr': timings['Asr'] as String,
      'Maghrib': timings['Maghrib'] as String,
      'Isha': timings['Isha'] as String,
    };
  }
}
