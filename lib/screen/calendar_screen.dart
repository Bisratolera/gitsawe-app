import 'package:flutter/material.dart';
import '../services/gitsawe_service.dart';
import '../core/theme/app_theme.dart';

class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final entries = GitsaweService.instance.monthlyGitsawe;

    return Scaffold(
      appBar: AppBar(title: const Text('የወር ግጻዌ')),
      body: entries.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text('ምንም የወር ግጻዌ አልተገኘም።'),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: entries.length,
              itemBuilder: (context, i) {
                final e = entries[i];
                final date = e is Map ? (e['date'] ?? 'Unknown') : 'Unknown';
                final title = e is Map ? (e['title'] ?? '') : '';
                final mezmur = e is Map ? (e['mezmur'] ?? '') : '';

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.cream,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          date,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.maroon,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          title,
                          style: const TextStyle(fontSize: 14),
                        ),
                        if (mezmur.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            'መዝሙር፦ $mezmur',
                            style: const TextStyle(fontSize: 12, color: Colors.black54),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

