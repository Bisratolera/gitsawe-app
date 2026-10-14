import 'package:flutter/material.dart';
import '../core/l10n/strings.dart';
import '../models/daily_gitsawe.dart';
import '../widgets/gitsawe_view.dart';
import '../widgets/screen_wrapper.dart';

class CalendarDetailScreen extends StatelessWidget {
  final Map<String, dynamic> entry;
  final bool seasonal;

  const CalendarDetailScreen({super.key, required this.entry, this.seasonal = false});

  @override
  Widget build(BuildContext context) {
    final title = (entry['title'] ?? tr(context, 'reading_fallback_title')).toString();
    // Seasonal entries use an internal key ("01-abiyTsom") as their date; it is
    // not meant for display, and monthly entries use a descriptive label.
    final date = seasonal ? '' : (entry['date'] ?? '').toString();

    DailyGitsawe? daily;
    try {
      daily = DailyGitsawe.fromJson(entry);
    } catch (e) {
      debugPrint('CalendarDetailScreen: could not parse entry: $e');
    }

    return ScreenWrapper(
      currentIndex: seasonal ? -1 : 3,
      title: title,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (daily != null)
              GitsaweView(
                entry: daily,
                dateLabel: date,
                showSinksar: false,
                showStats: false,
              )
            else
              Text(title, style: const TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}
