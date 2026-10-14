import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/l10n/strings.dart';
import '../core/utils/ethiopian_calendar.dart';
import '../screen/daily_gitsawe_screen.dart';
import 'app_settings.dart';
import 'gitsawe_service.dart';
import '../models/daily_gitsawe.dart';

/// Tracks which days' readings the user has not opened the app for.
///
/// The app remembers the last (Gregorian) day it was opened; every day since
/// then that has a reading in the bundled data counts as "missed" (most recent
/// first, at most [maxMissed]). Opening the app on a day marks that day seen.
class MissedUpdatesService extends ChangeNotifier {
  MissedUpdatesService._();

  static final MissedUpdatesService instance = MissedUpdatesService._();

  static const _lastSeenKey = 'last_seen_day';
  static const int maxMissed = 14;

  /// Date keys ("DD-MM") of missed days, most recent first.
  List<String> missedDates = const [];

  static String _isoDay(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  /// Call once per app start / return to foreground. Works out which days were
  /// skipped since the previous visit and records today as visited. A second
  /// call on the same day keeps the list already computed this morning.
  Future<void> onAppOpened() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final todayDay = DateTime(now.year, now.month, now.day);
    final lastSeenRaw = prefs.getString(_lastSeenKey);
    final lastSeen = lastSeenRaw == null ? null : DateTime.tryParse(lastSeenRaw);

    if (lastSeen == null) {
      await prefs.setString(_lastSeenKey, _isoDay(todayDay));
      return;
    }

    final lastSeenDay = DateTime(lastSeen.year, lastSeen.month, lastSeen.day);
    if (!lastSeenDay.isBefore(todayDay)) return; // already visited today

    final missed = <String>[];
    var cursor = todayDay.subtract(const Duration(days: 1));
    while (cursor.isAfter(lastSeenDay) && missed.length < maxMissed) {
      final key = EthiopianDate.fromGregorian(cursor).dateKey;
      if (GitsaweService.instance.readingForKey(key) != null && !missed.contains(key)) {
        missed.add(key);
      }
      cursor = cursor.subtract(const Duration(days: 1));
    }

    await prefs.setString(_lastSeenKey, _isoDay(todayDay));
    missedDates = missed;
    notifyListeners();
  }

  void _markRead(String date) {
    missedDates = missedDates.where((d) => d != date).toList();
    notifyListeners();
  }

  void showMissedSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        final english = AppSettings.instance.isEnglish;
        final items = missedDates;
        return SafeArea(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(sheetContext).size.height * 0.7,
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tr(sheetContext, 'title_missed'),
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  if (items.isEmpty)
                    Text(tr(sheetContext, 'all_caught_up'))
                  else
                    Flexible(
                      child: ListView(
                        shrinkWrap: true,
                        children: [
                          for (final date in items)
                            _tile(context, sheetContext, date, english),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _tile(BuildContext context, BuildContext sheetContext, String date, bool english) {
    final DailyGitsawe? entry = GitsaweService.instance.readingForKey(date);
    return ListTile(
      title: Text(formatDateKey(date, english: english)),
      subtitle: Text(
        (entry == null || entry.title.isEmpty)
            ? tr(sheetContext, 'reading_fallback_title')
            : entry.title,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      onTap: entry == null
          ? null
          : () {
              _markRead(date);
              Navigator.pop(sheetContext);
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => DailyGitsaweDetailScreen(entry: entry)),
              );
            },
    );
  }
}
