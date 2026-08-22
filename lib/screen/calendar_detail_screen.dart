import 'package:flutter/material.dart';
import '../models/daily_gitsawe.dart';
import '../widgets/gitsawe_view.dart';
import '../core/theme/app_theme.dart';
import '../widgets/screen_wrapper.dart';

class CalendarDetailScreen extends StatelessWidget {
  final Map<String, dynamic> entry;

  const CalendarDetailScreen({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
    final title = entry['title'] ?? 'Details';
    final date = entry['date'] ?? '';

    DailyGitsawe? daily;
    try {
      daily = DailyGitsawe.fromJson(entry);
    } catch (e) {
      // If it fails, we might just show basic info
    }

    return ScreenWrapper(
      currentIndex: 1, // Calendar tab
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
              )
            else
              Text(title, style: const TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}
