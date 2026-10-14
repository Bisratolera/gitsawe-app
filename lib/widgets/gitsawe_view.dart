import 'package:flutter/material.dart';
import '../core/l10n/strings.dart';
import '../core/theme/app_theme.dart';
import '../models/daily_gitsawe.dart';
import '../models/verse.dart';
import '../models/audio.dart';
import '../services/audio_library_service.dart';
import '../services/gitsawe_service.dart';
import '../services/bookmark_service.dart';
import '../services/share_service.dart';
import 'audio_play_button.dart';
import 'sinksar_section.dart';

const Map<String, String> _partLabelKeys = {
  'msbak': 'part_msbak',
  'firstDeacon': 'part_first',
  'secondDeacon': 'part_second',
  'secondKahn': 'part_kahn',
  'wengel': 'part_wengel',
};

class ManuscriptCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;

  const ManuscriptCard({super.key, required this.child, this.padding});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: padding ?? const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.45)),
      ),
      child: child,
    );
  }
}

String _formatReference(VerseReference vr) {
  if (vr.bookTitle.isEmpty) return '';
  if (vr.end.isEmpty) return '${vr.bookTitle} ${vr.chapter}:${vr.start}';
  return '${vr.bookTitle} ${vr.chapter}:${vr.start}-${vr.end}';
}

class ReadingCard extends StatelessWidget {
  final Verse reading;
  final String? label;

  const ReadingCard({super.key, required this.reading, this.label});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final ref = _formatReference(reading.verse);
    final t = reading.text;
    final audioTrack = AudioLibraryService.instance.findReadingTrack(reading.verse.bookTitle, reading.verse.chapter);

    return ManuscriptCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: colors.outlineVariant)),
            ),
            child: Row(
              children: [
                if (label != null)
                  Expanded(
                    child: Text(label!,
                        style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600, color: colors.primary)),
                  )
                else
                  const Spacer(),
                if (audioTrack != null)
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: AudioPlayButton(tracks: [audioTrack]),
                  ),
                if (ref.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.maroon.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(ref, style: TextStyle(fontSize: 12, color: colors.primary)),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          if (t.geez.isNotEmpty) _TaggedText(tag: tr(context, 'tag_geez'), text: t.geez),
          if (t.amharic.isNotEmpty) ...[
            const SizedBox(height: 12),
            _TaggedText(tag: tr(context, 'tag_amharic'), text: t.amharic),
          ],
          if (t.english.isNotEmpty) ...[
            const SizedBox(height: 12),
            _TaggedText(tag: tr(context, 'tag_english'), text: t.english, italic: true, muted: true),
          ],
        ],
      ),
    );
  }
}

class _TaggedText extends StatelessWidget {
  final String tag;
  final String text;
  final bool italic;
  final bool muted;

  const _TaggedText({required this.tag, required this.text, this.italic = false, this.muted = false});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return RichText(
      text: TextSpan(
        style: TextStyle(fontFamily: 'NotoSansEthiopic', color: colors.onSurface),
        children: [
          TextSpan(
            text: '$tag  ',
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: colors.primary),
          ),
          TextSpan(
            text: text,
            style: TextStyle(
              fontSize: 15, 
              height: 1.7, 
              fontStyle: italic ? FontStyle.italic : FontStyle.normal, 
              color: muted ? colors.onSurfaceVariant : colors.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

class SectionBlock extends StatelessWidget {
  final String title;
  final ReadingGroup? section;

  const SectionBlock({
    super.key,
    required this.title,
    required this.section,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final s = section;
    if (s == null || s.isEmpty) return const SizedBox.shrink();

    final List<String> partOrder = ['msbak', 'firstDeacon', 'secondDeacon', 'secondKahn', 'wengel'];
    final byKey = {
      'msbak': s.msbak,
      'firstDeacon': s.firstDeacon,
      'secondDeacon': s.secondDeacon,
      'secondKahn': s.secondKahn,
      'wengel': s.wengel,
    };

    final cards = <Widget>[];
    for (final key in partOrder) {
      final readings = byKey[key] ?? const <Verse>[];
      for (var i = 0; i < readings.length; i++) {
        final label = '${tr(context, _partLabelKeys[key]!)}${readings.length > 1 ? ' ${i + 1}' : ''}';
        cards.add(ReadingCard(reading: readings[i], label: label));
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: colors.primary,
                fontFamily: 'NotoSansEthiopic',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(child: Divider(color: AppColors.maroon.withValues(alpha: 0.2))),
          ],
        ),
        const SizedBox(height: 16),
        for (final c in cards) ...[c, const SizedBox(height: 14)],
        if (s.kidassie.isNotEmpty)
          ManuscriptCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(color: colors.outlineVariant)),
                  ),
                  child: Text(tr(context, 'kidassie'), style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: colors.primary)),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final k in s.kidassie)
                      _KidassieChip(k: k),
                  ],
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _KidassieChip extends StatelessWidget {
  final Verse k;
  const _KidassieChip({required this.k});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final label = k.text.amharic.isNotEmpty ? k.text.amharic : k.text.geez;
    final folder = AudioLibraryService.instance.findKidassieFolder(label);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.maroon.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.maroon.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: TextStyle(fontSize: 14.0, color: colors.onSurface)),
          if (folder != null) ...[
            const SizedBox(width: 8),
            AudioPlayButton(
              tracks: AudioLibraryService.instance.tracksOfFolder(folder.id),
              label: '',
            ),
          ],
        ],
      ),
    );
  }
}

class GitsaweView extends StatefulWidget {
  final DailyGitsawe entry;
  final String? dateLabel;

  /// Show the Synaxarium archive section for this DD-MM date.
  final bool showSinksar;

  /// Show the row of shortcut counters (daily / monthly / seasonal / …).
  final bool showStats;

  const GitsaweView({
    super.key,
    required this.entry,
    this.dateLabel,
    this.showSinksar = true,
    this.showStats = true,
  });

  @override
  State<GitsaweView> createState() => _GitsaweViewState();
}

class _GitsaweViewState extends State<GitsaweView> {
  final GlobalKey _wholeKey = GlobalKey();
  final GlobalKey _sinksarKey = GlobalKey();
  final GlobalKey _misbakKey = GlobalKey();

  Future<void> _shareText(BuildContext context) async {
    final text = [
      widget.entry.title,
      if (widget.dateLabel != null && widget.dateLabel!.isNotEmpty) widget.dateLabel!,
      ...widget.entry.snksar.take(3).map((item) => item.amharic),
    ].join('\n');
    await ShareService.shareText(context, text);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final sinksarDate = widget.entry.date.split('-');
    final day = int.tryParse(sinksarDate[0]) ?? 0;
    final month = int.tryParse(sinksarDate.length > 1 ? sinksarDate[1] : '0') ?? 0;

    final List<AudioTrack> playAllQueue = [];
    void addToQueue(ReadingGroup group) {
      final List<List<Verse>> allReadings = [
        group.msbak, group.firstDeacon, group.secondDeacon, group.secondKahn, group.wengel,
      ];
      for (final list in allReadings) {
        for (final v in list) {
          final track = AudioLibraryService.instance.findReadingTrack(v.verse.bookTitle, v.verse.chapter);
          if (track != null) playAllQueue.add(track);
        }
      }
    }
    addToQueue(widget.entry.negh);
    addToQueue(widget.entry.kidassie);


    final wholeReading = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (widget.showStats) ...[
          const _StatsHeader(),
          const SizedBox(height: 24),
        ],
        ManuscriptCard(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (widget.dateLabel != null && widget.dateLabel!.isNotEmpty)
                Text(
                  widget.dateLabel!,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: colors.onSurfaceVariant, letterSpacing: 2),
                ),
              const SizedBox(height: 12),
              Text(
                widget.entry.title,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: colors.primary, height: 1.4),
              ),
              ListenableBuilder(
                listenable: BookmarkService.instance,
                builder: (context, child) {
                  final bookmarked = BookmarkService.instance.contains(widget.entry.date, widget.entry.title);
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        tooltip: tr(context, bookmarked ? 'remove_bookmark' : 'bookmark'),
                        icon: Icon(bookmarked ? Icons.bookmark : Icons.bookmark_border),
                        color: colors.primary,
                        onPressed: () => BookmarkService.instance.toggle(
                          Bookmark(date: widget.entry.date, title: widget.entry.title),
                        ),
                      ),
                      IconButton(
                        tooltip: tr(context, 'share_reading'),
                        icon: const Icon(Icons.share_outlined),
                        color: colors.primary,
                        onPressed: () => _shareText(context),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 24),
              if (playAllQueue.isNotEmpty)
                AudioPlayButton(
                  tracks: playAllQueue,
                  label: '${tr(context, 'play_all')} (${playAllQueue.length})',
                ),
            ],
          ),
        ),
        if (widget.entry.snksar.isNotEmpty) ...[
          const SizedBox(height: 40),
          Row(
            children: [
              Text(
                tr(context, 'sinksar'),
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: colors.primary, fontFamily: 'NotoSansEthiopic'),
              ),
              const SizedBox(width: 12),
              Expanded(child: Divider(color: AppColors.maroon.withValues(alpha: 0.2))),
            ],
          ),
          const SizedBox(height: 16),
          RepaintBoundary(
            key: _sinksarKey,
            child: ManuscriptCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (var i = 0; i < widget.entry.snksar.length; i++)
                    Padding(
                      padding: EdgeInsets.only(bottom: i == widget.entry.snksar.length - 1 ? 0 : 16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${i + 1}.',
                            style: const TextStyle(fontSize: 14, color: AppColors.gold, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              widget.entry.snksar[i].amharic,
                              style: TextStyle(fontSize: 15, height: 1.7, color: colors.onSurface),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: () => ShareService.shareWidgetAsImage(
                context,
                _sinksarKey,
                fileName: 'sinksar-${widget.entry.date}',
                shareText: '${tr(context, 'sinksar')} — ${widget.entry.title}',
              ),
              icon: const Icon(Icons.share_outlined, size: 16),
              label: Text(tr(context, 'share_sinksar')),
              style: TextButton.styleFrom(foregroundColor: colors.primary),
            ),
          ),
        ],
        if (!widget.entry.negh.isEmpty) ...[
          const SizedBox(height: 40),
          RepaintBoundary(
            key: _misbakKey,
            child: SectionBlock(
              title: tr(context, 'negh_readings'),
              section: widget.entry.negh,
            ),
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: () => ShareService.shareWidgetAsImage(
                context,
                _misbakKey,
                fileName: 'misbak-${widget.entry.date}',
                shareText: '${tr(context, 'negh_readings')} - ${widget.entry.title}',
              ),
              icon: const Icon(Icons.share_outlined, size: 16),
              label: Text(tr(context, 'share_negh')),
              style: TextButton.styleFrom(foregroundColor: colors.primary),
            ),
          ),
        ],
        if (!widget.entry.kidassie.isEmpty) ...[
          const SizedBox(height: 40),
          SectionBlock(title: tr(context, 'kidassie_readings'), section: widget.entry.kidassie),
        ],
        if (widget.showSinksar && month >= 1 && month <= 13) ...[
          const SizedBox(height: 40),
          SinksarSection(day: day, month: month),
        ],
      ],
    );

    return RepaintBoundary(
      key: _wholeKey,
      child: wholeReading,
    );
  }
}

class _StatsHeader extends StatelessWidget {
  const _StatsHeader();

  @override
  Widget build(BuildContext context) {
    final service = GitsaweService.instance;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _StatCard(
            count: service.allDaily.length,
            label: tr(context, 'stat_daily'),
            onTap: () => Navigator.pushNamed(context, '/daily_gitsawe'),
          ),
          _StatCard(
            count: service.monthlyGitsawe.length,
            label: tr(context, 'stat_monthly'),
            onTap: () => Navigator.pushNamed(context, '/monthly_gitsawe'),
          ),
          _StatCard(
            count: service.seasonalGitsawe.length,
            label: tr(context, 'stat_seasonal'),
            onTap: () => Navigator.pushNamed(context, '/seasonal_gitsawe'),
          ),
          _StatCard(
            count: service.feasts.length,
            label: tr(context, 'stat_feasts'),
            onTap: () => Navigator.pushNamed(context, '/feasts'),
          ),
          _StatCard(
            count: service.mahlets.length,
            label: tr(context, 'stat_mahlet'),
            onTap: () => Navigator.pushNamed(context, '/mahlet'),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final int count;
  final String label;
  final VoidCallback onTap;

  const _StatCard({required this.count, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: Material(
        color: colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: 120,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.45)),
            ),
            child: Column(
              children: [
                Text(
                  count.toString(),
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: colors.primary),
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(fontSize: 11, color: colors.onSurfaceVariant),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
