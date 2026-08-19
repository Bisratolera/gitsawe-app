import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show PlatformException;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../models/daily_gitsawe.dart';

class NotificationService {
  NotificationService._internal();

  static final NotificationService instance =
      NotificationService._internal();

  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz.initializeTimeZones();

    // Set the timezone used by zonedSchedule().
    final timezone = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timezone.identifier));

    debugPrint('Notification timezone: ${timezone.identifier}');
    debugPrint('Notification local time: ${tz.TZDateTime.now(tz.local)}');

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

    await _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    if (Platform.isAndroid) {
      final AndroidFlutterLocalNotificationsPlugin? androidPlugin =
          _localNotifications
              .resolvePlatformSpecificImplementation<
                  AndroidFlutterLocalNotificationsPlugin>();

      final notificationPermission =
          await androidPlugin?.requestNotificationsPermission();

      debugPrint(
        'POST_NOTIFICATIONS permission: $notificationPermission',
      );

      final exactAlarmPermission =
          await androidPlugin?.requestExactAlarmsPermission();

      debugPrint(
        'Exact alarm permission: $exactAlarmPermission',
      );
    }

    if (Platform.isIOS) {
      final IOSFlutterLocalNotificationsPlugin? iosPlugin =
          _localNotifications
              .resolvePlatformSpecificImplementation<
                  IOSFlutterLocalNotificationsPlugin>();

      await iosPlugin?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
    }
  }

  // Future<void> triggerInstantTestNotification({
  //   required DailyGitsawe? todaysReading,
  // }) async {
  //   const AndroidNotificationDetails androidDetails =
  //       AndroidNotificationDetails(
  //     'gitsawe_test_channel',
  //     'Test Channel',
  //     channelDescription:
  //         'Used for instant Gitsawe notification testing.',
  //     importance: Importance.max,
  //     priority: Priority.high,
  //   );

  //   const NotificationDetails platformDetails = NotificationDetails(
  //     android: androidDetails,
  //     iOS: DarwinNotificationDetails(),
  //   );

  //   await _localNotifications.show(
  //     id: 99,
  //     title: 'የዕለቱ ግጻዌ',
  //     body: todaysReading?.title ?? 'No reading title found for today',
  //     notificationDetails: platformDetails,
  //   );

  //   debugPrint('Instant test notification sent.');
  // }

  Future<void> scheduleDailyGitsaweNotification({
    required int hour,
    required int minute,
    required DailyGitsawe? Function(DateTime) readingProvider,
  }) async {
    await _localNotifications.cancel(id: 0);

    final now = tz.TZDateTime.now(tz.local);

    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    // If today's time has already passed, schedule tomorrow.
    if (!scheduledDate.isAfter(now)) {
      scheduledDate = scheduledDate.add(
        const Duration(days: 1),
      );
    }

    debugPrint('Current time: $now');
    debugPrint('Scheduled time: $scheduledDate');

    final DailyGitsawe? reading = readingProvider(scheduledDate);

    if (reading == null) {
      debugPrint(
        'ERROR: No Gitsawe reading found for $scheduledDate',
      );
      return;
    }

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'gitsawe_daily_channel',
      'Daily Gitsawe Readings',
      channelDescription:
          'Daily notifications for Ethiopian Orthodox Gitsawe readings.',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
    );

    try {
      await _localNotifications.zonedSchedule(
        id: 0,
        title: 'የዕለቱ ግጻዌ',
        body: reading.title,
        scheduledDate: scheduledDate,
        notificationDetails: platformDetails,
        androidScheduleMode:
            AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );

      debugPrint(
        'SUCCESS: Daily Gitsawe notification scheduled.',
      );

      final pending =
          await _localNotifications.pendingNotificationRequests();

      debugPrint(
        'Pending notifications: ${pending.length}',
      );

      for (final notification in pending) {
        debugPrint(
          'Pending ID: ${notification.id}, '
          'title: ${notification.title}',
        );
      }
    } on PlatformException catch (e) {
      debugPrint(
        'Notification scheduling error: ${e.code} - ${e.message}',
      );

      if (e.code == 'exact_alarms_not_permitted') {
        debugPrint(
          'Exact alarms are not permitted. '
          'Scheduling inexact notification instead.',
        );

        await _localNotifications.zonedSchedule(
          id: 0,
          title: 'የዕለቱ ግጻዌ',
          body: reading.title,
          scheduledDate: scheduledDate,
          notificationDetails: platformDetails,
          androidScheduleMode:
              AndroidScheduleMode.inexactAllowWhileIdle,
          matchDateTimeComponents: DateTimeComponents.time,
        );
      } else {
        rethrow;
      }
    }
  }
}