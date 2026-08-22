import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../models/audio.dart';
import '../services/audio_player_service.dart';

/// Small pill button — drop this next to any reading, track, or
/// folder listing. Tapping it replaces the current queue and starts
/// playback immediately.
class AudioPlayButton extends StatelessWidget {
  final List<AudioTrack> tracks;
  final int startIndex;
  final String label;

  const AudioPlayButton({
    super.key,
    required this.tracks,
    this.startIndex = 0,
    this.label = 'አድምጥ',
  });

  @override
  Widget build(BuildContext context) {
    if (tracks.isEmpty) return const SizedBox.shrink();

    return ListenableBuilder(
      listenable: AudioPlayerService.instance,
      builder: (context, _) {
        final player = AudioPlayerService.instance;
        final isThisPlaying = player.isPlaying &&
            player.currentTrack?.id == tracks[startIndex].id;

        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => isThisPlaying
                ? player.togglePlayPause()
                : player.playTracks(tracks, startIndex: startIndex),
            borderRadius: BorderRadius.circular(12),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isThisPlaying ? AppColors.gold : AppColors.maroon.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isThisPlaying ? AppColors.gold : AppColors.maroon.withOpacity(0.1),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isThisPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                    size: 18,
                    color: isThisPlaying ? Colors.white : AppColors.maroon,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    isThisPlaying ? 'አቁም' : label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: isThisPlaying ? Colors.white : AppColors.maroon,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}