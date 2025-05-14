import 'package:flutter/material.dart';
// import 'pages/home_page.dart';
import 'pages/prayer_times_page.dart';
import 'pages/settings_page.dart';
import 'pages/duas_page.dart';
import 'pages/more_page.dart';
import 'widgets/app_drawer.dart';
import 'pages/SurahListPage.dart';
import 'package:google_fonts/google_fonts.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Prayer App',
      theme: ThemeData(
        primarySwatch: Colors.green,
        textTheme: GoogleFonts.amiriTextTheme(), // all text uses Amiri
        primaryTextTheme: GoogleFonts.amiriTextTheme(),
       ),
      home: MainPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;
  bool _isDarkMode = false;

  final List<Widget> _pages = [
    SurahListPage(),
    PrayerTimesPage(),
    DuasPage(),
    SettingsPage(),
    MorePage(),
  ];

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 1) Add the AppBar here
      appBar: AppBar(title: Text('Prayer App')),

      // 2) Keep your drawer
      drawer: AppDrawer(
        isDarkMode: _isDarkMode,
        onDarkModeChanged: (v) => setState(() => _isDarkMode = v),
        onTabSelected: (index) {
          setState(() => _selectedIndex = index);
          Navigator.pop(context);
        },
      ),

      // 3) Body is just the page content
      body: _pages[_selectedIndex],

      // 4) Bottom nav as before
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.green,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.menu_book), label: 'Al Quran'),
          BottomNavigationBarItem(
            icon: Icon(Icons.access_time),
            label: 'Prayer Times',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.menu_book), label: 'Duas'),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.more_horiz), label: 'More'),
        ],
      ),
    );
  }
}
