import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/theme/app_theme.dart';
import 'core/utils/ethiopian_calendar.dart';
import 'screen/today_screen.dart';
import 'screen/onboarding_screen.dart';
import 'services/gitsawe_service.dart';
import 'services/home_widget_service.dart';
import 'services/notification_service.dart';
import 'services/audio_library_service.dart';
import 'services/sinksar_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final bool onboardingCompleted = prefs.getBool('onboarding_completed') ?? false;

  // Load Gitsawe data from the API before the app starts. If this fails
  // (e.g. offline at launch), TodayScreen retries once it's mounted.
  try {
    await Future.wait([
      GitsaweService.instance.load(),
      AudioLibraryService.instance.load(),
      SinksarService.instance.loadManifest(),
    ]);
    final eDate = EthiopianDate.fromGregorian(DateTime.now());
    await HomeWidgetService.instance.updateWidget(
      ethiopianDateLabel: '${eDate.day}/${eDate.month}/${eDate.year}',
      reading: GitsaweService.instance.readingFor(DateTime.now()),
    );
  } catch (e, st) {
    debugPrint('Initial Gitsawe data load failed: $e\n$st');
  }

  // Initialize notifications and timezone.
  await NotificationService.instance.init();

  // Schedule the daily Gitsawe notification.
  await _setUpNotifications();

  runApp(GitsaweApp(onboardingCompleted: onboardingCompleted));
}

Future<void> _setUpNotifications() async {
  await NotificationService.instance.scheduleDailyGitsaweNotification(
    hour: 7,
    minute: 0,
    readingProvider: (targetDate) {
      return GitsaweService.instance.readingFor(targetDate);
    },
  );
}

class GitsaweApp extends StatelessWidget {
  final bool onboardingCompleted;

  const GitsaweApp({super.key, required this.onboardingCompleted});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gitsawe',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: onboardingCompleted ? const TodayScreen() : const OnboardingScreen(),
    );
  }
}
