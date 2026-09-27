import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import '../services/gitsawe_service.dart';
import 'calendar_detail_screen.dart';

import '../widgets/screen_wrapper.dart';

class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final entries = GitsaweService.instance.monthlyGitsawe;

    return ScreenWrapper(
      currentIndex: 3,
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
                        border: Border.all(color: colors.outlineVariant.withOpacity(0.45)),
                        boxShadow: [
                          BoxShadow(
                            color: colors.shadow.withOpacity(0.15),
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
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: colors.primary,
                                ),
                              ),
                              Icon(IconsaxPlusLinear.arrow_right_3, color: colors.onSurfaceVariant),
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
