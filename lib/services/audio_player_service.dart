import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import '../models/audio.dart';

class AudioPlayerService extends ChangeNotifier {
  AudioPlayerService._internal();
  static final AudioPlayerService instance = AudioPlayerService._internal();

  final AudioPlayer _player = AudioPlayer();
  List<AudioTrack> _queue = [];

  List<AudioTrack> get queue => _queue;
  Stream<Duration> get positionStream => _player.positionStream;
  Stream<Duration?> get durationStream => _player.durationStream;
  Stream<PlayerState> get playerStateStream => _player.playerStateStream;
  Stream<int?> get currentIndexStream => _player.currentIndexStream;

  bool get isPlaying => _player.playing;
  int? get currentIndex => _player.currentIndex;
  AudioTrack? get currentTrack {
    final i = currentIndex;
    if (i == null || i < 0 || i >= _queue.length) return null;
    return _queue[i];
  }

  /// Streams the given tracks directly from their URLs (nothing is
  /// downloaded to disk first — `just_audio` buffers as it plays).
  Future<void> playTracks(List<AudioTrack> tracks, {int startIndex = 0}) async {
    if (tracks.isEmpty) return;
    _queue = tracks;

    try {
      final playlist = ConcatenatingAudioSource(
        children: tracks
            .map((t) => AudioSource.uri(Uri.parse(t.url), tag: t))
            .toList(),
      );

      await _player.setAudioSource(playlist, initialIndex: startIndex);
      await _player.play();
    } catch (e) {
      debugPrint("Error playing tracks: $e");
    }
    notifyListeners();
  }

  /// Convenience for a single track (e.g. one reading's audio).
  Future<void> playSingle(AudioTrack track) => playTracks([track]);

  Future<void> togglePlayPause() async {
    if (_player.playing) {
      await _player.pause();
    } else {
      await _player.play();
    }
    notifyListeners();
  }

  Future<void> next() async {
    if (_player.hasNext) await _player.seekToNext();
  }

  Future<void> previous() async {
    if (_player.hasPrevious) await _player.seekToPrevious();
  }

  Future<void> seek(Duration position) => _player.seek(position);

  Future<void> stop() async {
    await _player.stop();
    _queue = [];
    notifyListeners();
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }
}