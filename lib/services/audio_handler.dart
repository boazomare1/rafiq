// lib/services/audio_handler.dart
import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';

Future<AudioHandler> initAudioHandler() async {
  return await AudioService.init(
    builder: () => MyAudioHandler(),
    config: AudioServiceConfig(
      androidNotificationChannelId: 'com.yourapp.audio.channel',
      androidNotificationChannelName: 'Adhan Playback',
      androidNotificationOngoing: true,
    ),
  );
}

class MyAudioHandler extends BaseAudioHandler with SeekHandler {
  final _player = AudioPlayer();

  MyAudioHandler() {
    // Broadcast state changes
    _player.playbackEventStream.listen((event) {
      // Build new PlaybackState
      final processingState = {
        ProcessingState.idle: AudioProcessingState.idle,
        ProcessingState.loading: AudioProcessingState.loading,
        ProcessingState.buffering: AudioProcessingState.loading,
        ProcessingState.ready: AudioProcessingState.ready,
        ProcessingState.completed: AudioProcessingState.completed,
      }[_player.processingState]!;

      playbackState.add(playbackState.value.copyWith(
        controls: [MediaControl.play, MediaControl.pause],
        systemActions: {MediaAction.seek},
        processingState: processingState,
        playing: _player.playing,
        updatePosition: _player.position,
      ));
    });
  }

  @override
  Future<void> playMediaItem(MediaItem item) async {
    // Publish the media item to clients
    this.mediaItem.add(item);

    // Load and play
    final url = item.extras?['url'] as String;
    await _player.setUrl(url);
    play();
  }

  @override
  Future<void> play()   => _player.play();
  @override
  Future<void> pause()  => _player.pause();
  @override
  Future<void> stop()   => _player.stop();
  @override
  Future<void> seek(Duration position) => _player.seek(position);
}
