import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import '../core/l10n/strings.dart';
import '../core/theme/app_theme.dart';
import '../core/utils/ethiopian_calendar.dart';
import '../models/daily_gitsawe.dart';
import '../services/gitsawe_service.dart';
import '../widgets/gitsawe_view.dart';
import '../widgets/screen_wrapper.dart';

class DailyGitsaweScreen extends StatelessWidget {
  const DailyGitsaweScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final english = LangScope.of(context) == 'en';
    final entries = GitsaweService.instance.allDaily;

    return ScreenWrapper(
      currentIndex: 1,
      title: tr(context, 'title_daily'),
      body: entries.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(tr(context, 'no_daily')),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: entries.length,
              itemBuilder: (context, index) {
                final entry = entries[index];
                final parts = entry.date.split('-');
                final dayNumber = parts.isNotEmpty ? (int.tryParse(parts.first) ?? 1) : 1;
                final monthNumber = parts.length > 1 ? (int.tryParse(parts[1]) ?? 1) : 1;

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
                        color: colors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.maroon.withValues(alpha: 0.12)),
                        boxShadow: [
                          BoxShadow(
                            color: colors.shadow.withValues(alpha: 0.15),
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
                              color: AppColors.maroon.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  '$dayNumber',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: colors.primary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  ethiopianMonthName(monthNumber, english: english),
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
                          Icon(IconsaxPlusLinear.arrow_right_3, color: colors.primary),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class DailyGitsaweDetailScreen extends StatelessWidget {
  final DailyGitsawe entry;

  const DailyGitsaweDetailScreen({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
    final english = LangScope.of(context) == 'en';
    return ScreenWrapper(
      currentIndex: 1,
      title: tr(context, 'title_daily_detail'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: GitsaweView(
          entry: entry,
          dateLabel: formatDateKey(entry.date, english: english),
        ),
      ),
    );
  }
}
