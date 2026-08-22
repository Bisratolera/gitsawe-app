import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../models/daily_gitsawe.dart';
import '../models/verse.dart';
import '../models/audio.dart';
import '../services/audio_library_service.dart';
import '../services/gitsawe_service.dart';
import 'audio_play_button.dart';
import 'sinksar_section.dart';

const Map<String, String> _partLabels = {
  'msbak': 'ምስባክ',
  'firstDeacon': 'ቀዳማይ ንባብ (፩ኛ ዲያቆን)',
  'secondDeacon': 'ካልዓይ ንባብ (፪ኛ ዲያቆን)',
  'secondKahn': 'የ፪ኛው ካህን ንባብ',
  'wengel': 'ወንጌል',
};

class ManuscriptCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;

  const ManuscriptCard({super.key, required this.child, this.padding});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cream,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
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
    final ref = _formatReference(reading.verse);
    final t = reading.text;
    final audioTrack = AudioLibraryService.instance.findReadingTrack(reading.verse.bookTitle, reading.verse.chapter);

    return ManuscriptCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.only(bottom: 10),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.black12)),
            ),
            child: Row(
              children: [
                if (label != null)
                  Expanded(
                    child: Text(label!,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.maroon)),
                  )
                else
                  const Spacer(),
                if (audioTrack != null)
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: AudioPlayButton(tracks: [audioTrack], label: 'አድምጥ'),
                  ),
                if (ref.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.maroon.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(ref, style: const TextStyle(fontSize: 12, color: AppColors.maroon)),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          if (t.geez.isNotEmpty) _TaggedText(tag: 'ግዕዝ', text: t.geez),
          if (t.amharic.isNotEmpty) ...[
            const SizedBox(height: 12),
            _TaggedText(tag: 'አማርኛ', text: t.amharic),
          ],
          if (t.english.isNotEmpty) ...[
            const SizedBox(height: 12),
            _TaggedText(tag: 'English', text: t.english, italic: true, muted: true),
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
    return RichText(
      text: TextSpan(
        style: const TextStyle(fontFamily: 'NotoSansEthiopic'),
        children: [
          TextSpan(
            text: '$tag  ',
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.maroon),
          ),
          TextSpan(
            text: text,
            style: TextStyle(
              fontSize: 15, 
              height: 1.7, 
              fontStyle: italic ? FontStyle.italic : FontStyle.normal, 
              color: muted ? Colors.black54 : Colors.black87,
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

  const SectionBlock({super.key, required this.title, required this.section});

  @override
  Widget build(BuildContext context) {
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
        final label = '${_partLabels[key]}${readings.length > 1 ? ' ${i + 1}' : ''}';
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
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.maroon,
                fontFamily: 'NotoSansEthiopic',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(child: Divider(color: AppColors.maroon.withOpacity(0.2))),
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
                  decoration: const BoxDecoration(
                    border: Border(bottom: BorderSide(color: Colors.black12)),
                  ),
                  child: const Text('ቅዳሴ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.maroon)),
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
    final label = k.text.amharic.isNotEmpty ? k.text.amharic : k.text.geez;
    final folder = AudioLibraryService.instance.findKidassieFolder(label);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.maroon.withOpacity(0.06),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.maroon.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: const TextStyle(fontSize: 14.0)),
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

class GitsaweView extends StatelessWidget {
  final DailyGitsawe entry;
  final String? dateLabel;

  const GitsaweView({super.key, required this.entry, this.dateLabel});

  @override
  Widget build(BuildContext context) {
    final sinksarDate = entry.date.split('-');
    final day = int.tryParse(sinksarDate[0]) ?? 0;
    final month = int.tryParse(sinksarDate.length > 1 ? sinksarDate[1] : '0') ?? 0;

    // Build queue for "Play all" button
    final List<AudioTrack> playAllQueue = [];
    void addToQueue(ReadingGroup group) {
      final List<List<Verse>> allReadings = [
        group.msbak, group.firstDeacon, group.secondDeacon, group.secondKahn, group.wengel
      ];
      for (final list in allReadings) {
        for (final v in list) {
          final track = AudioLibraryService.instance.findReadingTrack(v.verse.bookTitle, v.verse.chapter);
          if (track != null) playAllQueue.add(track);
        }
      }
    }
    addToQueue(entry.negh);
    addToQueue(entry.kidassie);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _StatsHeader(),
        const SizedBox(height: 24),
        ManuscriptCard(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (dateLabel != null && dateLabel!.isNotEmpty)
                Text(
                  dateLabel!, 
                  textAlign: TextAlign.center, 
                  style: const TextStyle(fontSize: 12, color: Colors.black54, letterSpacing: 2),
                ),
              const SizedBox(height: 12),
              Text(
                entry.title, 
                textAlign: TextAlign.center, 
                style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: AppColors.maroon, height: 1.4),
              ),
              const SizedBox(height: 24),
              if (playAllQueue.isNotEmpty)
                AudioPlayButton(
                  tracks: playAllQueue,
                  label: 'ንባባቱን በተራ አድምጥ (${playAllQueue.length})',
                ),
            ],
          ),
        ),
        if (entry.snksar.isNotEmpty) ...[
          const SizedBox(height: 40),
          Row(
            children: [
              const Text(
                'ስንክሳር',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.maroon, fontFamily: 'NotoSansEthiopic'),
              ),
              const SizedBox(width: 12),
              Expanded(child: Divider(color: AppColors.maroon.withOpacity(0.2))),
            ],
          ),
          const SizedBox(height: 16),
          ManuscriptCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var i = 0; i < entry.snksar.length; i++)
                  Padding(
                    padding: EdgeInsets.only(bottom: i == entry.snksar.length - 1 ? 0 : 16),
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
                            entry.snksar[i].amharic, 
                            style: const TextStyle(fontSize: 15, height: 1.7, color: Colors.black87),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
        if (!entry.negh.isEmpty) ...[
          const SizedBox(height: 40),
          SectionBlock(title: 'ንባባተ ነግህ', section: entry.negh),
        ],
        if (!entry.kidassie.isEmpty) ...[
          const SizedBox(height: 40),
          SectionBlock(title: 'ንባባተ ቅዳሴ', section: entry.kidassie),
        ],
        if (month >= 1 && month <= 13) ...[
          const SizedBox(height: 40),
          SinksarSection(day: day, month: month),
        ],
      ],
    );
  }
}

class _StatsHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final service = GitsaweService.instance;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _StatCard(count: service.allDaily.length, label: 'የዕለት ግጻዌ'),
          _StatCard(count: service.monthlyGitsawe.length, label: 'የወር ግጻዌ'),
          _StatCard(count: service.seasonalGitsawe.length, label: 'የዘመን ግጻዌ'),
          _StatCard(count: service.feastsForMonth('').length, label: 'በዓላት'), // Note: empty month matches all if not loaded? Service filters.
          _StatCard(count: service.mahlets.length, label: 'ማኅሌት'),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final int count;
  final String label;

  const _StatCard({required this.count, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          Text(
            count.toString(),
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.maroon),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: Colors.black54),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
