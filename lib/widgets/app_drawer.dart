import 'package:flutter/material.dart';

class AppDrawer extends StatefulWidget {
  /// callback to change the bottom-nav tab
  final ValueChanged<int> onTabSelected;
  /// current theme mode flag
  final bool isDarkMode;
  /// toggle theme callback
  final ValueChanged<bool> onDarkModeChanged;
  AppDrawer({
    required this.onTabSelected,
    required this.isDarkMode,
    required this.onDarkModeChanged,
  });
  @override
  _AppDrawerState createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  // Language options
  final _languages = ['English', 'العربية'];
  String _selectedLanguage = 'English';

  // Calculation methods (quick-switch)
  final Map<int, String> _calcMethods = {
    2: 'Karachi',
    3: 'ISNA',
    4: 'MWL',
    5: 'Umm Al-Qura',
    7: 'Egyptian',
    8: 'Umm Al-Qura (Ram.)',
    9: 'Tehran',
    10: 'Jafari',
  };
  int _selectedMethod = 4;

  // Prayer reminders toggle
  bool _remindersOn = true;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // ----- User header -----
            UserAccountsDrawerHeader(
              accountName: Text('John Doe'),
              accountEmail: Text('john.doe@example.com'),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.person, size: 40, color: Colors.teal),
              ),
              decoration: BoxDecoration(color: Colors.teal),
            ),
            Divider(),

            // ----- Profile & Sign Out -----
            ListTile(
              leading: Icon(Icons.person_outline),
              title: Text('Profile'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/profile');
              },
            ),
            ListTile(
              leading: Icon(Icons.exit_to_app, color: Colors.red),
              title: Text('Sign Out', style: TextStyle(color: Colors.red)),
              onTap: () {
                // TODO: sign-out logic
              },
            ),

            Divider(),

            // ----- Extras section -----
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text('Preferences', style: TextStyle(fontWeight: FontWeight.bold)),
            ),

            // Dark mode toggle
            SwitchListTile(
              secondary: Icon(Icons.brightness_6),
              title: Text('Dark Mode'),
              value: widget.isDarkMode,
              onChanged: widget.onDarkModeChanged,
            ),

            // Language selector
            ListTile(
              leading: Icon(Icons.language),
              title: Text('Language'),
              trailing: DropdownButton<String>(
                value: _selectedLanguage,
                underline: SizedBox(),
                items: _languages
                    .map((lang) => DropdownMenuItem(value: lang, child: Text(lang)))
                    .toList(),
                onChanged: (lang) {
                  if (lang != null) setState(() => _selectedLanguage = lang);
                  // TODO: apply localization change
                },
              ),
            ),

            // Calculation method quick-switch
            ListTile(
              leading: Icon(Icons.calculate),
              title: Text('Calculation Method'),
              trailing: DropdownButton<int>(
                value: _selectedMethod,
                underline: SizedBox(),
                items: _calcMethods.entries
                    .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
                    .toList(),
                onChanged: (m) {
                  if (m != null) setState(() => _selectedMethod = m);
                  // TODO: trigger prayer-times refresh with new method
                },
              ),
            ),

            // Prayer reminders
            SwitchListTile(
              secondary: Icon(Icons.notifications_active),
              title: Text('Prayer Reminders'),
              value: _remindersOn,
              onChanged: (v) => setState(() => _remindersOn = v),
            ),

            // Qibla direction
            ListTile(
              leading: Icon(Icons.explore),
              title: Text('Qibla Direction'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/qibla');
              },
            ),

            // Share app
            ListTile(
              leading: Icon(Icons.share),
              title: Text('Share App'),
              onTap: () {
                // TODO: share intent
              },
            ),

            Divider(),

            // About
            ListTile(
              leading: Icon(Icons.info_outline),
              title: Text('About'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/about');
              },
            ),
          ],
        ),
      ),
    );
  }
}
