import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../screen/calendar_detail_screen.dart';
import '../core/utils/ethiopian_calendar.dart';
import 'gitsawe_service.dart';

class MissedUpdatesService extends ChangeNotifier {
  MissedUpdatesService._();

  static final MissedUpdatesService instance = MissedUpdatesService._();

  static const _lastSeenKey = 'last_seen_reading_date';

  List<String> missedDates = const [];

  Future<void> checkForMissed() async {
    final prefs = await SharedPreferences.getInstance();
    final lastSeen = prefs.getString(_lastSeenKey);
    final today = EthiopianDate.fromGregorian(DateTime.now()).dateKey;

    if (lastSeen == null) {
      await prefs.setString(_lastSeenKey, today);
      missedDates = const [];
      notifyListeners();
      return;
    }

    if (lastSeen == today) {
      missedDates = const [];
      notifyListeners();
      return;
    }

    final available = GitsaweService.instance.allDaily
        .map((entry) => entry.date)
        .where((date) => date.isNotEmpty && date != today && date != lastSeen)
        .toList();

    missedDates = available.take(14).toList();
    notifyListeners();
  }

  Future<void> markSeenToday() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastSeenKey, EthiopianDate.fromGregorian(DateTime.now()).dateKey);
    missedDates = const [];
    notifyListeners();
  }

  void showMissedSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (sheetContext) {
        final items = missedDates;
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Missed readings',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                if (items.isEmpty)
                  const Text("You're all caught up.")
                else
                  ...items.map((date) {
                    final entry = GitsaweService.instance.allDaily.firstWhere(
                      (item) => item.date == date,
                      orElse: () => GitsaweService.instance.allDaily.first,
                    );
                    return ListTile(
                      title: Text(date),
                      subtitle: Text(entry.title.isEmpty ? 'Reading' : entry.title),
                      onTap: () {
                        Navigator.pop(sheetContext);
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => CalendarDetailScreen(entry: {
                              'date': entry.date,
                              'title': entry.title,
                              'snksar': entry.snksar
                                  .map((s) => {'amharic': s.amharic})
                                  .toList(),
                            }),
                          ),
                        );
                      },
                    );
                  }),
              ],
            ),
          ),
        );
      },
    );
  }
}
