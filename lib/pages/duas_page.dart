import 'package:flutter/material.dart';

class DuasPage extends StatelessWidget {
  final List<Map<String, String>> _duas = [
    {
      'title': 'Morning Duā',
      'arabic': 'اللّهـمَّ أَنْتَ رَبِّـي لا إلهَ إلاّ أَنْتَ...',
      'translation': 'O Allah, You are my Lord, there is no deity except You...',
    },
    {
      'title': 'Evening Duā',
      'arabic': 'أَمْسَيْنا وَأَمْسَى الْمُلْكُ لِلَّهِ...',
      'translation': 'We have entered evening and so has the dominion of Allah...',
    },
    {
      'title': 'Before Sleep',
      'arabic': 'بِاسْمِكَ اللّهُـمَّ أَمـوتُ وَأَحْـيا',
      'translation': 'In Your name O Allah, I live and die.',
    },
    {
      'title': 'Entering the Home',
      'arabic': 'بِسْمِ اللَّهِ وَلَجْنَا، وَبِسْمِ اللَّهِ خَرَجْنَا...',
      'translation': 'In the name of Allah we enter, and in the name of Allah we leave...',
    },
    {
      'title': 'Morning Duā',
      'arabic': 'اللّهـمَّ أَنْتَ رَبِّـي لا إلهَ إلاّ أَنْتَ...',
      'translation': 'O Allah, You are my Lord, there is no deity except You...',
    },
    {
      'title': 'Evening Duā',
      'arabic': 'أَمْسَيْنا وَأَمْسَى الْمُلْكُ لِلَّهِ...',
      'translation': 'We have entered evening and so has the dominion of Allah...',
    },
    {
      'title': 'Before Sleep',
      'arabic': 'بِاسْمِكَ اللّهُـمَّ أَمـوتُ وَأَحْـيا',
      'translation': 'In Your name O Allah, I live and die.',
    },
    {
      'title': 'Entering the Home',
      'arabic': 'بِسْمِ اللَّهِ وَلَجْنَا، وَبِسْمِ اللَّهِ خَرَجْنَا...',
      'translation': 'In the name of Allah we enter, and in the name of Allah we leave...',
    },
    {
      'title': 'Morning Duā',
      'arabic': 'اللّهـمَّ أَنْتَ رَبِّـي لا إلهَ إلاّ أَنْتَ...',
      'translation': 'O Allah, You are my Lord, there is no deity except You...',
    },
    {
      'title': 'Evening Duā',
      'arabic': 'أَمْسَيْنا وَأَمْسَى الْمُلْكُ لِلَّهِ...',
      'translation': 'We have entered evening and so has the dominion of Allah...',
    },
    {
      'title': 'Before Sleep',
      'arabic': 'بِاسْمِكَ اللّهُـمَّ أَمـوتُ وَأَحْـيا',
      'translation': 'In Your name O Allah, I live and die.',
    },
    {
      'title': 'Entering the Home',
      'arabic': 'بِسْمِ اللَّهِ وَلَجْنَا، وَبِسْمِ اللَّهِ خَرَجْنَا...',
      'translation': 'In the name of Allah we enter, and in the name of Allah we leave...',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Daily Duas')),
      body: ListView.separated(
        padding: const EdgeInsets.all(12.0),
        itemCount: _duas.length,
        separatorBuilder: (_, __) => Divider(),
        itemBuilder: (context, index) {
          final dua = _duas[index];
          return ListTile(
            title: Text(dua['title']!, style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 6),
                Text(
                  dua['arabic']!,
                  style: TextStyle(fontSize: 18, fontFamily: 'Scheherazade', height: 1.5),
                  textAlign: TextAlign.right,
                ),
                SizedBox(height: 6),
                Text(
                  dua['translation']!,
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade800),
                ),
              ],
            ),
            isThreeLine: true,
          );
        },
      ),
    );
  }
}
