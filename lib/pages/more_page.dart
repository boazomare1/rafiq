import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
class MorePage extends StatefulWidget {
  @override
  _MorePageState createState() => _MorePageState();
}

class _MorePageState extends State<MorePage> {
  late AudioPlayer _player;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Future<void> _playAdhan() async {
    try {
      // Example Adhan audio stream (replace with yours if needed)
      await _player.setUrl('https://www.islamcan.com/audio/adhan/azan2.mp3');
      await _player.play();
    } catch (e) {
      print('Error playing Adhan: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("More")),
      body: Center(
        child: ElevatedButton.icon(
          icon: Icon(Icons.volume_up),
          label: Text("Play Adhan"),
          onPressed: _playAdhan,
        ),
      ),
    );
  }
}

