import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hijri/hijri_calendar.dart';
import '../api/prayer_times_api.dart';

class PrayerTimesPage extends StatefulWidget {
  @override
  _PrayerTimesPageState createState() => _PrayerTimesPageState();
}

class _PrayerTimesPageState extends State<PrayerTimesPage> {
  // Map of calculation methods supported by AlAdhan
  final Map<int, String> _calculationMethods = {
    2: 'Karachi (University of Islamic Sciences)',
    3: 'ISNA (North America)',
    4: 'Muslim World League',
    5: 'Umm Al-Qura (Makkah)',
    7: 'Egyptian General Authority',
    8: 'Umm Al-Qura (Ramadan)',
    9: 'Tehran (Shia)',
    10: 'Jafari (Shia)'
  };

  // Currently selected method
  int _selectedMethod = 4; // default to MWL

  late HijriCalendar _hijriDate;
  late Future<Map<String, String>> _prayerTimesFuture;
  final PrayerTimesApi _api = PrayerTimesApi();

  final Map<String, Map<String, dynamic>> _prayerDetails = {
    
    'Fajr': {
      'Fard Rak‘ahs': '2',
      'Sunnah Mu’akkadah': '2 (before)',
      'Recommended Sūrahs': ['Al-Ikhlāṣ', 'Al Baqarah'],
    },
    'Dhuhr': {
      'Fard Rak‘ahs': '4',
      'Sunnah Mu’akkadah': '4 (before), 2 (after)',
      'Recommended Sūrahs': ['Al-Kāfirūn', 'Al-Ikhlāṣ', 'Al-Falaq', 'An-Nās'],
    },
    'Asr': {
      'Fard Rak‘ahs': '4',
      'Sunnah (Ghayr Mu’akkadah)': '4 (before)',
      'Recommended Sūrahs': ['Al-Kāfirūn', 'Al-Ikhlāṣ', 'Al-Falaq', 'An-Nās'],
    },
    'Maghrib': {
      'Fard Rak‘ahs': '3',
      'Sunnah Mu’akkadah': '2 (after)',
      'Recommended Sūrahs': ['Al-Kāfirūn', 'Al-Ikhlāṣ', 'Al-Falaq'],
    },
    'Isha': {
      'Fard Rak‘ahs': '4',
      'Sunnah Mu’akkadah': '2 (after)',
      'Witr Rak‘ahs': '3',
      'Recommended Sūrahs': ['Al-Mulk', 'Al-Ikhlāṣ', 'Al-Falaq', 'An-Nās'],
    },
  
  };

  final Map<String, bool> _done = {};
  final String _ayatulKursi = '''Allahu laaa ilaaha illaa huwal haiyul qai-yoom 
laa taakhuzuhoo sinatunw wa laa nawm; lahoo maa fissamaawaati wa maa fil ard 
man zallazee yashfa’u indahooo illaa be iznih
ya’lamu maa baina aideehim wa maa khalfahum
wa laa yuheetoona beshai ‘immin ‘ilmihee illa be maa shaaaa
wasi’a kursiyyuhus samaa waati wal arda wa la ya’ooduho hifzuhumaa
wa huwal aliyyul ‘azeem'''; // your Ayatul Kursi string

  @override
  void initState() {
    super.initState();
    HijriCalendar.setLocal('en');
    _hijriDate = HijriCalendar.now();
    _loadStatuses();
    _fetchPrayerTimes();
  }

  void _fetchPrayerTimes() {
    _prayerTimesFuture = _api.fetchPrayerTimes(
      latitude: -1.286389,
      longitude: 36.817223,
      method: _selectedMethod,
    );
  }

  Future<void> _loadStatuses() async {
  final prefs = await SharedPreferences.getInstance();
  final statuses = <String, bool>{};
  for (var prayer in ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha']) {
    statuses[prayer] = prefs.getBool(prayer) ?? false;
  }
  if (mounted) {
    setState(() {
      _done.addAll(statuses);
    });
  }
}


  Future<void> _onTickTapped(String prayer) async {
    _showVerse();
    if (_done[prayer] != true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(prayer, true);
      setState(() => _done[prayer] = true);
    }
  }

  void _showVerse() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Ayatul Kursi'),
        content: SingleChildScrollView(
          child: Text(_ayatulKursi, textAlign: TextAlign.center),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('OK')),
        ],
      ),
    );
  }

  void _showDetails(String prayer) {
    final details = _prayerDetails[prayer]!;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('$prayer Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: details.entries.expand((entry) {
              final key = entry.key;
              final value = entry.value;
              if (value is List) {
                return [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Text('• $key:', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  ...value.asMap().entries.map((e) => Padding(
                        padding: const EdgeInsets.only(left: 16.0, top: 2.0),
                        child: Text('${e.key + 1}. ${e.value}', style: TextStyle(fontSize: 16)),
                      ))
                ];
              } else {
                return [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2.0),
                    child: Text('• $key: $value', style: TextStyle(fontSize: 16)),
                  )
                ];
              }
            }).toList(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Close')),
        ],
      ),
    );
  }

  Future<void> _resetAll() async {
    final prefs = await SharedPreferences.getInstance();
    for (var prayer in ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha']) {
      await prefs.setBool(prayer, false);
    }
    _loadStatuses();
  }

  @override
    @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Prayer Times (Nairobi)'),
        actions: [
          IconButton(icon: Icon(Icons.refresh), onPressed: _resetAll),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(6.0),
        child: Column(
          children: [
            // Hijri date
            Text(
              '${_hijriDate.hDay} ${_hijriDate.longMonthName} ${_hijriDate.hYear} AH',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),

            SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Flexible(
                  flex: 1,
                  child: Text(
                    'Calculation method:',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  flex: 3,
                  child: DropdownButtonFormField<int>(
                    isExpanded: true,
                    value: _selectedMethod,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    items: _calculationMethods.entries.map((e) {
                      return DropdownMenuItem(
                        value: e.key,
                        child: Text(e.value, overflow: TextOverflow.visible),
                      );
                    }).toList(),
                    onChanged: (method) {
                      if (method != null) {
                        setState(() {
                          _selectedMethod = method;
                          _fetchPrayerTimes();
                        });
                      }
                    },
                  ),
                ),
              ],
            ),

            SizedBox(height: 16),

            // Prayer times table
            Expanded(
              child: FutureBuilder<Map<String, String>>(
                future: _prayerTimesFuture,
                builder: (context, snap) {
                  if (snap.connectionState != ConnectionState.done) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (snap.hasError) {
                    return Center(child: Text('Error: ${snap.error}'));
                  }
                  final prayerTimes = snap.data!;

                  return Table(
                    border: TableBorder.all(color: Colors.grey.shade300, width: 1),
                    columnWidths: {
                      0: FlexColumnWidth(2),
                      1: FlexColumnWidth(1.5),
                      2: FlexColumnWidth(1),
                      3: FlexColumnWidth(1),
                    },
                    defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                    children: [
                      // Header row
                      TableRow(
                        decoration: BoxDecoration(color: Colors.teal.shade100),
                        children: [
                          _headerCell('Prayer'),
                          _headerCell('Time'),
                          _headerCell('Info'),
                          _headerCell('Done'),
                        ],
                      ),
                      // Data rows
                      ...prayerTimes.entries.map((e) {
                        final prayer = e.key;
                        final time   = e.value;
                        final done   = _done[prayer] ?? false;
                        return TableRow(
                          decoration: BoxDecoration(
                            color: done ? Colors.green.shade50 : Colors.white,
                          ),
                          children: [
                            _dataCell(prayer),
                            _dataCell(time),
                            Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: IconButton(
                                icon: Icon(Icons.info_outline, color: Colors.teal),
                                onPressed: () => _showDetails(prayer),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: IconButton(
                                icon: Icon(
                                  done ? Icons.check_circle : Icons.check_circle_outline,
                                  color: done ? Colors.green : Colors.grey,
                                  size: 28,
                                ),
                                onPressed: () => _onTickTapped(prayer),
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _headerCell(String text) => Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(text, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      );

  Widget _dataCell(String text) => Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(text, style: TextStyle(fontSize: 16)),
      );
}
