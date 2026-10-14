import 'package:flutter/material.dart';

import '../core/l10n/strings.dart';
import '../core/theme/app_theme.dart';
import '../core/utils/ethiopian_calendar.dart';
import '../services/app_settings.dart';
import '../services/gitsawe_service.dart';
import '../widgets/screen_wrapper.dart';

/// Lists the feasts bundled with the app together with their sub-feasts
/// (e.g. the weeks of Tsige).
class FeastsScreen extends StatelessWidget {
  const FeastsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final feasts = GitsaweService.instance.feasts;
    final colors = Theme.of(context).colorScheme;
    final english = LangScope.of(context) == 'en';

    return ScreenWrapper(
      currentIndex: -1,
      title: tr(context, 'title_feasts'),
      body: feasts.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(tr(context, 'no_feasts')),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: feasts.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, i) {
                final feast = feasts[i];
                final subs = GitsaweService.instance.subFeastsFor(feast.key);
                final name = english && feast.name.isNotEmpty ? feast.name : feast.amharicName;
                final date = feast.date == null
                    ? null
                    : formatDateKey(feast.date!, english: AppSettings.instance.isEnglish);

                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.6)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name.isEmpty ? feast.key : name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: colors.primary,
                        ),
                      ),
                      if (date != null) ...[
                        const SizedBox(height: 4),
                        Text(date, style: TextStyle(fontSize: 12, color: colors.onSurfaceVariant)),
                      ],
                      if (subs.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [for (final s in subs) _SubFeastChip(label: english && s.name.isNotEmpty ? s.name : s.amharicName)],
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
    );
  }
}

class _SubFeastChip extends StatelessWidget {
  final String label;
  const _SubFeastChip({required this.label});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.maroon.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(label, style: TextStyle(fontSize: 12, color: colors.onSurface)),
    );
  }
}
