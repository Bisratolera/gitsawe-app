import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import '../core/l10n/strings.dart';
import '../services/gitsawe_service.dart';
import 'calendar_detail_screen.dart';

import '../widgets/screen_wrapper.dart';

/// Lists the monthly Gitsawe readings, or — with [seasonal] — the seasonal
/// ones (Nenewe, the Great Lent weeks, Easter season…).
class CalendarScreen extends StatelessWidget {
  final bool seasonal;

  const CalendarScreen({super.key, this.seasonal = false});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final entries =
        seasonal ? GitsaweService.instance.seasonalGitsawe : GitsaweService.instance.monthlyGitsawe;

    return ScreenWrapper(
      currentIndex: seasonal ? -1 : 3,
      title: tr(context, seasonal ? 'title_seasonal' : 'title_monthly'),
      body: entries.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(tr(context, seasonal ? 'no_seasonal' : 'no_monthly')),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: entries.length,
              itemBuilder: (context, i) {
                final e = entries[i];
                final title = e is Map ? (e['title'] ?? '').toString() : '';
                final mezmur = e is Map ? (e['mezmur'] ?? '').toString() : '';
                // Monthly entries carry a descriptive "date" (e.g. "ዘመስከረም ዮሐንስ");
                // seasonal ones carry an internal key ("01-abiyTsom"), so show the title.
                final rawDate = e is Map ? (e['date'] ?? '').toString() : '';
                final heading = seasonal ? title : rawDate;
                final subtitle = seasonal ? '' : title;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: InkWell(
                    onTap: () {
                      if (e is Map<String, dynamic>) {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => CalendarDetailScreen(entry: e, seasonal: seasonal),
                          ),
                        );
                      }
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: colors.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.45)),
                        boxShadow: [
                          BoxShadow(
                            color: colors.shadow.withValues(alpha: 0.15),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  heading,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: colors.primary,
                                  ),
                                ),
                              ),
                              Icon(IconsaxPlusLinear.arrow_right_3, color: colors.onSurfaceVariant),
                            ],
                          ),
                          if (subtitle.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Text(subtitle, style: const TextStyle(fontSize: 14)),
                          ],
                          if (mezmur.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text(
                              '${tr(context, 'hymn')}፦ $mezmur',
                              style: TextStyle(fontSize: 12, color: colors.onSurfaceVariant),
                            ),
                          ],
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
