import 'package:flutter/material.dart';
import '../core/l10n/strings.dart';
import '../core/theme/app_theme.dart';
import '../models/audio.dart';
import '../services/audio_player_service.dart';

/// Small pill button — drop this next to any reading, track, or
/// folder listing. Tapping it replaces the current queue and starts
/// playback immediately.
class AudioPlayButton extends StatelessWidget {
  final List<AudioTrack> tracks;
  final int startIndex;

  /// Text shown next to the icon. Null → the localized "Listen".
  final String? label;

  const AudioPlayButton({
    super.key,
    required this.tracks,
    this.startIndex = 0,
    this.label,
  });

  Future<void> _onTap(BuildContext context, bool isThisPlaying) async {
    final player = AudioPlayerService.instance;
    if (isThisPlaying) {
      await player.togglePlayPause();
      return;
    }
    final messenger = ScaffoldMessenger.maybeOf(context);
    final message = tr(context, 'audio_error');
    final ok = await player.playTracks(tracks, startIndex: startIndex);
    if (!ok) {
      messenger?.showSnackBar(SnackBar(content: Text(message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (tracks.isEmpty) return const SizedBox.shrink();

    return ListenableBuilder(
      listenable: AudioPlayerService.instance,
      builder: (context, _) {
        final player = AudioPlayerService.instance;
        final isThisPlaying = player.isPlaying &&
            player.currentTrack?.id == tracks[startIndex].id;
        final text = isThisPlaying ? tr(context, 'stop') : (label ?? tr(context, 'listen'));

        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _onTap(context, isThisPlaying),
            borderRadius: BorderRadius.circular(12),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isThisPlaying ? AppColors.gold : AppColors.maroon.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isThisPlaying ? AppColors.gold : AppColors.maroon.withValues(alpha: 0.1),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isThisPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                    size: 18,
                    color: isThisPlaying ? Colors.white : Theme.of(context).colorScheme.primary,
                  ),
                  if (text.isNotEmpty) ...[
                    const SizedBox(width: 6),
                    Text(
                      text,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: isThisPlaying ? Colors.white : Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
