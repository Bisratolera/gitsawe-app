import 'package:flutter/material.dart';
import '../models/daily_gitsawe.dart';
import '../widgets/gitsawe_app_bar.dart';
import '../widgets/gitsawe_view.dart';
import '../core/theme/app_theme.dart';

class CalendarDetailScreen extends StatelessWidget {
  final Map<String, dynamic> entry;

  const CalendarDetailScreen({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
    final title = entry['title'] ?? 'Details';
    final date = entry['date'] ?? '';

    // Convert raw map to DailyGitsawe model if it has the readings
    // In your service, these are loaded as full entries.
    DailyGitsawe? daily;
    try {
      daily = DailyGitsawe.fromJson(entry);
    } catch (e) {
      // If it fails, we might just show basic info
    }

    return Scaffold(
      appBar: GitsaweAppBar(title: title),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (date.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(
                  date,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.maroon,
                  ),
                ),
              ),
            if (daily != null)
              GitsaweView(entry: daily)
            else
              Text(title, style: const TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}
