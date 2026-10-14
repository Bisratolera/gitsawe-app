import 'package:flutter/foundation.dart';

import '../core/utils/ethiopian_calendar.dart';
import 'app_settings.dart';
import 'gitsawe_service.dart';
import 'gitsawe_widgets_service.dart';
import 'notification_service.dart';

/// Keeps everything that depends on "today" in step with the clock:
/// home-screen widgets and the rolling window of reminder notifications.
///
/// Called at launch, whenever the app returns to the foreground (so the next
/// morning's widget and reminders are correct), and after the user changes a
/// related setting.
class DailyRefresh {
  DailyRefresh._();
  static final DailyRefresh instance = DailyRefresh._();

  /// Refreshes widgets and reminders. Never throws.
  Future<void> run() async {
    await refreshWidgets();
    await syncReminders();
  }

  Future<void> refreshWidgets() async {
    try {
      final now = DateTime.now();
      final english = AppSettings.instance.isEnglish;
      await GitsaweWidgetsService.instance.updateAllWidgets(
        ethiopianDateLabel: EthiopianDate.fromGregorian(now).shortLabel,
        reading: GitsaweService.instance.readingOrPlaceholder(now, english: english),
      );
    } catch (e, st) {
      debugPrint('DailyRefresh.refreshWidgets failed: $e\n$st');
    }
  }

  /// Re-creates the reminder window from the current settings (or cancels it).
  Future<void> syncReminders() async {
    try {
      final settings = AppSettings.instance;
      if (!settings.notificationsEnabled) {
        await NotificationService.instance.cancelAll();
        return;
      }
      await NotificationService.instance.scheduleUpcoming(
        hour: settings.reminderHour,
        minute: settings.reminderMinute,
        lang: settings.language,
        readingProvider: (day) => GitsaweService.instance.readingFor(day),
      );
    } catch (e, st) {
      debugPrint('DailyRefresh.syncReminders failed: $e\n$st');
    }
  }
}
