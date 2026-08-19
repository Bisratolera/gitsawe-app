import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../models/daily_gitsawe.dart';
import '../models/verse.dart';

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
            style: TextStyle(fontSize: 15, height: 1.7, fontStyle: italic ? FontStyle.italic : FontStyle.normal, color: muted ? Colors.black54 : Colors.black87),
          ),
        ],
      ),
    );
  }
}

const List<String> _partOrder = ['msbak', 'firstDeacon', 'secondDeacon', 'secondKahn', 'wengel'];

class SectionBlock extends StatelessWidget {
  final String title;
  final ReadingGroup? section;

  const SectionBlock({super.key, required this.title, required this.section});

  @override
  Widget build(BuildContext context) {
    final s = section;
    if (s == null) return const SizedBox.shrink();

    final byKey = {
      'msbak': s.msbak,
      'firstDeacon': s.firstDeacon,
      'secondDeacon': s.secondDeacon,
      'secondKahn': s.secondKahn,
      'wengel': s.wengel,
    };

    final cards = <Widget>[];
    for (final key in _partOrder) {
      final readings = byKey[key] ?? const <Verse>[];
      for (var i = 0; i < readings.length; i++) {
        final label = '${_partLabels[key]}${readings.length > 1 ? ' ${i + 1}' : ''}';
        cards.add(ReadingCard(reading: readings[i], label: label));
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
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
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.maroon.withOpacity(0.06),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.maroon.withOpacity(0.2)),
                        ),
                        child: Text(k.text.amharic.isNotEmpty ? k.text.amharic : k.text.geez,
                            style: const TextStyle(fontSize: 14.0)),
                      ),
                  ],
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class GitsaweView extends StatelessWidget {
  final DailyGitsawe entry;
  final String? dateLabel;

  const GitsaweView({super.key, required this.entry, this.dateLabel});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ManuscriptCard(
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (dateLabel != null && dateLabel!.isNotEmpty)
                Text(dateLabel!, textAlign: TextAlign.center, style: const TextStyle(fontSize: 11, color: Colors.black54, letterSpacing: 2)),
              const SizedBox(height: 8),
              Text(entry.title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
              if (!entry.negh.isEmpty) const SizedBox(height: 12),
            ],
          ),
        ),
        if (entry.snksar.isNotEmpty) ...[
          const SizedBox(height: 36),
          const Text('ስንክሳር', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 16),
          ManuscriptCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var i = 0; i < entry.snksar.length; i++)
                  Padding(
                    padding: EdgeInsets.only(bottom: i == entry.snksar.length - 1 ? 0 : 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 3),
                          child: Text('${i + 1}.', style: const TextStyle(fontSize: 13, color: AppColors.maroon, fontWeight: FontWeight.w600)),
                        ),
                        const SizedBox(width: 10),
                        Expanded(child: Text(entry.snksar[i].amharic, style: const TextStyle(fontSize: 14.5, height: 1.7))),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
        if (!entry.negh.isEmpty) ...[
          const SizedBox(height: 36),
          SectionBlock(title: 'ንባባተ ነግህ', section: entry.negh),
        ],
        if (!entry.kidassie.isEmpty) ...[
          const SizedBox(height: 36),
          SectionBlock(title: 'ንባባተ ቅዳሴ', section: entry.kidassie),
        ],
      ],
    );
  }
}
