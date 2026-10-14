import 'package:flutter/material.dart';
import '../core/l10n/strings.dart';
import '../core/theme/app_theme.dart';
import '../services/audio_player_service.dart';

/// Sits above AppBottomNav. Shows nothing when nothing is queued.
class MiniPlayerBar extends StatelessWidget {
  const MiniPlayerBar({super.key});

  @override
  Widget build(BuildContext context) {
    final player = AudioPlayerService.instance;
    return ListenableBuilder(
      listenable: player,
      builder: (context, _) {
        final track = player.currentTrack;
        if (track == null) return const SizedBox.shrink();

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.maroon,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.maroon.withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.skip_previous_rounded, color: Colors.white, size: 24),
                      onPressed: player.previous,
                      visualDensity: VisualDensity.compact,
                    ),
                    IconButton(
                      icon: Icon(
                        player.isPlaying
                            ? Icons.pause_circle_filled_rounded
                            : Icons.play_circle_filled_rounded,
                        color: Colors.white,
                        size: 40,
                      ),
                      onPressed: player.togglePlayPause,
                      visualDensity: VisualDensity.compact,
                    ),
                    IconButton(
                      icon: const Icon(Icons.skip_next_rounded, color: Colors.white, size: 24),
                      onPressed: player.next,
                      visualDensity: VisualDensity.compact,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            track.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            tr(context, 'now_playing'),
                            style: const TextStyle(color: Colors.white70, fontSize: 10),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: Colors.white70, size: 20),
                      onPressed: player.stop,
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ),
              ),
              _ProgressLine(player: player),
            ],
          ),
        );
      },
    );
  }
}

/// Slim playback progress bar along the bottom edge of the mini player.
class _ProgressLine extends StatelessWidget {
  final AudioPlayerService player;
  const _ProgressLine({required this.player});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Duration?>(
      stream: player.durationStream,
      builder: (context, durationSnap) {
        final total = durationSnap.data;
        return StreamBuilder<Duration>(
          stream: player.positionStream,
          builder: (context, positionSnap) {
            final position = positionSnap.data ?? Duration.zero;
            final value = (total == null || total.inMilliseconds == 0)
                ? null
                : (position.inMilliseconds / total.inMilliseconds).clamp(0.0, 1.0).toDouble();
            return LinearProgressIndicator(
              value: value,
              minHeight: 3,
              backgroundColor: Colors.white24,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.gold),
            );
          },
        );
      },
    );
  }
}
