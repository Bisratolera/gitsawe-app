import 'package:flutter/material.dart';
import '../models/sinksar.dart';
import '../services/sinksar_service.dart';
import '../core/theme/app_theme.dart';
import '../core/utils/ethiopian_calendar.dart';

class SinksarSection extends StatefulWidget {
  final int day;
  final int month;

  const SinksarSection({super.key, required this.day, required this.month});

  @override
  State<SinksarSection> createState() => _SinksarSectionState();
}

class _SinksarSectionState extends State<SinksarSection> {
  List<SinksarEntry>? _entries;
  int? _openIndex = 0; // First one open by default as in image
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  @override
  void didUpdateWidget(SinksarSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.day != widget.day || oldWidget.month != widget.month) {
      _loadEntries();
    }
  }

  Future<void> _loadEntries() async {
    setState(() {
      _isLoading = true;
      _entries = null;
    });
    final entries = await SinksarService.instance.loadSinksarDay(widget.month, widget.day);
    if (mounted) {
      setState(() {
        _entries = entries;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLoading && (_entries == null || _entries!.isEmpty)) {
      return const SizedBox.shrink();
    }

    final monthName = SinksarService.instance.sinksarMonthName(widget.month);
    final dateLabel = '$monthName ${toGeezNumber(widget.day)}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'ስንክሳር ንባብ',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.maroon,
                fontFamily: 'NotoSansEthiopic',
              ),
            ),
            const Spacer(),
            Text(
              dateLabel,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.black54,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (_isLoading)
          const Center(child: CircularProgressIndicator())
        else
          ...List.generate(_entries!.length, (index) {
            final entry = _entries![index];
            final isOpen = _openIndex == index;

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.black.withOpacity(0.05)),
              ),
              color: Colors.white,
              child: Column(
                children: [
                  InkWell(
                    onTap: () {
                      setState(() {
                        _openIndex = isOpen ? null : index;
                      });
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${toGeezNumber(index + 1)}.',
                            style: const TextStyle(
                              color: AppColors.gold,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              entry.title,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.maroon,
                                fontFamily: 'NotoSansEthiopic',
                              ),
                            ),
                          ),
                          Icon(
                            isOpen ? Icons.remove : Icons.add,
                            size: 20,
                            color: Colors.black38,
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (isOpen)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Divider(height: 1),
                          const SizedBox(height: 16),
                          ...entry.text.split('\n\n').map((p) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: Text(
                                  p.trim(),
                                  style: const TextStyle(
                                    fontSize: 15,
                                    height: 1.7,
                                    color: Colors.black87,
                                  ),
                                ),
                              )),
                        ],
                      ),
                    ),
                ],
              ),
            );
          }),
      ],
    );
  }
}
