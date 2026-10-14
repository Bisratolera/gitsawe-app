import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show PlatformException;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../core/l10n/strings.dart';
import '../models/daily_gitsawe.dart';

/// Schedules the daily "today's Gitsawe" reminder.
///
/// Every day gets its **own** notification carrying that day's reading title
/// (a single repeating notification would show the same title forever). A
/// rolling window of [daysAhead] notifications is scheduled and topped up every
/// time the app is opened, so the reminders keep arriving with correct content
/// even if the app is not opened for a couple of weeks.
///
/// Reminders use inexact alarms on purpose: they may arrive a few minutes
/// late, but the app needs no special alarm permission (which Google Play
/// restricts to alarm/calendar apps).
class NotificationService {
  NotificationService._internal();

  static final NotificationService instance = NotificationService._internal();

  static const int daysAhead = 14;
  static const int _firstId = 100;
  static const String _channelId = 'gitsawe_daily_channel';

  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  bool get _supported => Platform.isAndroid || Platform.isIOS;

  /// False on platforms where no permission prompt exists (e.g. desktop), so
  /// the Settings switch is not turned off just because [requestPermission]
  /// returned false there.
  bool get supportsRuntimePermission => _supported;

  Future<void> init() async {
    if (_initialized) return;
    if (!_supported) {
      debugPrint(
        'NotificationService: notifications are unavailable on ${Platform.operatingSystem}.',
      );
      return;
    }

    tz.initializeTimeZones();

    // Set the timezone used by zonedSchedule(). If this fails we stay on UTC,
    // which only shifts the reminder time — never crashes the app.
    try {
      final timezone = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timezone.identifier));
    } catch (e) {
      debugPrint('NotificationService: could not resolve local timezone: $e');
    }

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/launcher_icon');

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      settings: initSettings,
    );

    _initialized = true;
  }

  /// Asks the OS for permission to show notifications (Android 13+ / iOS).
  /// Returns true when notifications may be shown.
  Future<bool> requestPermission() async {
    if (!_initialized) return false;

    if (Platform.isAndroid) {
      final androidPlugin = _localNotifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      final granted = await androidPlugin?.requestNotificationsPermission();
      // `null` means the platform does not need a runtime permission (Android < 13).
      return granted ?? true;
    }

    if (Platform.isIOS) {
      final iosPlugin = _localNotifications
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>();
      final granted = await iosPlugin?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return granted ?? false;
    }

    return false;
  }

  Future<bool> areNotificationsAllowed() async {
    if (!_initialized) return false;
    if (Platform.isAndroid) {
      final androidPlugin = _localNotifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      return await androidPlugin?.areNotificationsEnabled() ?? true;
    }
    return true;
  }

  Future<void> cancelAll() async {
    if (!_initialized) return;
    await _localNotifications.cancelAll();
  }

  /// Replaces every pending reminder with a fresh [daysAhead]-day window
  /// starting today (or tomorrow if today's time has already passed).
  ///
  /// [readingProvider] returns the reading for a given local calendar day;
  /// when it returns null a generic body is used.
  Future<void> scheduleUpcoming({
    required int hour,
    required int minute,
    required String lang,
    required DailyGitsawe? Function(DateTime day) readingProvider,
  }) async {
    if (!_initialized || !_supported) return;

    await _localNotifications.cancelAll();

    final now = tz.TZDateTime.now(tz.local);

    final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      _channelId,
      trLang(lang, 'notif_channel'),
      channelDescription: trLang(lang, 'notif_channel_desc'),
      importance: Importance.high,
      priority: Priority.high,
    );
    final NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: const DarwinNotificationDetails(),
    );

    var scheduled = 0;
    for (var i = 0; i < daysAhead; i++) {
      // DateTime() normalises day overflow (e.g. 31 + 1 → next month).
      final day = DateTime(now.year, now.month, now.day + i);
      final when = tz.TZDateTime(tz.local, day.year, day.month, day.day, hour, minute);
      if (!when.isAfter(now)) continue;

      final reading = readingProvider(day);
      final body = (reading != null && reading.title.trim().isNotEmpty)
          ? reading.title
          : trLang(lang, 'notif_fallback_body');

      try {
        await _localNotifications.zonedSchedule(
          id: _firstId + i,
          title: trLang(lang, 'notif_title'),
          body: body,
          scheduledDate: when,
          notificationDetails: platformDetails,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        );
        scheduled++;
      } on PlatformException catch (e) {
        debugPrint('NotificationService: scheduling failed: ${e.code} ${e.message}');
        break;
      }
    }
    debugPrint('NotificationService: scheduled $scheduled reminders at $hour:$minute');
  }
}
