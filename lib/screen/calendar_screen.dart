import 'package:flutter/material.dart';
import '../services/gitsawe_service.dart';
import '../core/theme/app_theme.dart';
import '../widgets/gitsawe_app_bar.dart';
import '../widgets/app_sidebar.dart';
import 'calendar_detail_screen.dart';

import '../widgets/screen_wrapper.dart';

class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final entries = GitsaweService.instance.monthlyGitsawe;

    return ScreenWrapper(
      currentIndex: 1,
      title: 'የወር ግጻዌ',
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
                  child: InkWell(
                    onTap: () {
                      if (e is Map<String, dynamic>) {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => CalendarDetailScreen(entry: e),
                          ),
                        );
                      }
                    },
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.black12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.02),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                date,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.maroon,
                                ),
                              ),
                              const Icon(Icons.chevron_right, color: Colors.black26),
                            ],
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
                  ),
                );
              },
            ),
    );
  }
}
