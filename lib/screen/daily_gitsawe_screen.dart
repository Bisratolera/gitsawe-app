import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../models/daily_gitsawe.dart';
import '../services/gitsawe_service.dart';
import '../widgets/gitsawe_view.dart';
import '../widgets/screen_wrapper.dart';

class DailyGitsaweScreen extends StatelessWidget {
  const DailyGitsaweScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final entries = GitsaweService.instance.allDaily;

    return ScreenWrapper(
      currentIndex: 1,
      title: 'የየእለቱ ግጻዌ ማውጫ',
      body: entries.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text('No daily Gitsawe entries available yet.'),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: entries.length,
              itemBuilder: (context, index) {
                final entry = entries[index];

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => DailyGitsaweDetailScreen(entry: entry),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: colors.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.maroon.withOpacity(0.12)),
                        boxShadow: [
                          BoxShadow(
                            color: colors.shadow.withOpacity(0.15),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 72,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: AppColors.maroon.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  _dayNumber(entry.date),
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.maroon,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _monthName(entry.date),
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: colors.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  entry.title,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: colors.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                if (entry.snksar.isNotEmpty)
                                  Text(
                                    entry.snksar.first.amharic,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: colors.onSurfaceVariant,
                                      height: 1.5,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right, color: AppColors.maroon),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }

  String _dayNumber(String date) {
    final parts = date.split('-');
    if (parts.isEmpty) return '1';
    final day = int.tryParse(parts.first) ?? 1;
    return day.toString();
  }

  String _monthName(String date) {
    final parts = date.split('-');
    if (parts.length < 2) return 'Month';
    final monthNumber = int.tryParse(parts[1]) ?? 1;
    const months = [
      'Meskerem', 'Tikimt', 'Hidar', 'Tahsas', 'Tir', 'Yekatit', 'Megabit', 'Miazia',
      'Ginbot', 'Sene', 'Hamle', 'Nehase', 'Pagume'
    ];
    return months[(monthNumber - 1).clamp(0, months.length - 1)];
  }
}

class DailyGitsaweDetailScreen extends StatelessWidget {
  final DailyGitsawe entry;

  const DailyGitsaweDetailScreen({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
    return ScreenWrapper(
      currentIndex: 1,
      title: 'Daily Details',
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: GitsaweView(
          entry: entry,
          dateLabel: entry.date,
        ),
      ),
    );
  }
}
