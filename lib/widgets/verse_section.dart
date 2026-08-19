import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../models/verse.dart';

class VerseSection extends StatelessWidget {
  final String headerLabel; // e.g. "ምስባክ", "ወንጌል"
  final List<Verse> verses;

  const VerseSection({super.key, required this.headerLabel, required this.verses});

  @override
  Widget build(BuildContext context) {
    if (verses.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(headerLabel,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 6),
          ...verses.map((v) => _VerseTile(verse: v)),
        ],
      ),
    );
  }
}

class _VerseTile extends StatefulWidget {
  final Verse verse;
  const _VerseTile({required this.verse});

  @override
  State<_VerseTile> createState() => _VerseTileState();
}

class _VerseTileState extends State<_VerseTile> {
  bool _showGeez = false;
  bool _showEnglish = false;

  @override
  Widget build(BuildContext context) {
    final v = widget.verse;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cream,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Reference, right-aligned italic — matches "መዝሙረ ዳዊት 47:11-12"
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '${v.verse.bookTitle} ${v.verse.display}',
              style: const TextStyle(
                  fontStyle: FontStyle.italic, fontSize: 12, color: Colors.grey),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _showGeez ? v.text.geez : v.text.amharic,
            style: const TextStyle(fontSize: 16, height: 1.4, color: Colors.black87),
          ),
          if (_showEnglish && v.text.english.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(v.text.english,
                style: const TextStyle(
                    fontSize: 15, fontStyle: FontStyle.italic, color: Colors.black87)),
          ],
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              if (v.text.geez.isNotEmpty)
                _ToggleChip(
                  label: 'ግዕዝ',
                  color: AppColors.gold,
                  active: _showGeez,
                  onTap: () => setState(() => _showGeez = !_showGeez),
                ),
              if (v.text.english.isNotEmpty)
                _ToggleChip(
                  label: 'English',
                  color: AppColors.green,
                  active: _showEnglish,
                  onTap: () => setState(() => _showEnglish = !_showEnglish),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ToggleChip extends StatelessWidget {
  final String label;
  final Color color;
  final bool active;
  final VoidCallback onTap;

  const _ToggleChip({
    required this.label,
    required this.color,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: active ? color : color.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(label,
            style: const TextStyle(
                color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
      ),
    );
  }
}