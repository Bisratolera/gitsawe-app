import 'package:flutter/material.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/theme/app_theme.dart';
import 'core/utils/ethiopian_calendar.dart';
import 'screen/today_screen.dart';
import 'screen/onboarding_screen.dart';
import 'screen/daily_gitsawe_screen.dart';
import 'screen/calendar_screen.dart';
import 'screen/mahlet_screen.dart';
import 'services/gitsawe_service.dart';
import 'services/gitsawe_widgets_service.dart';
import 'services/notification_service.dart';
import 'services/audio_library_service.dart';
import 'services/sinksar_service.dart';
import 'services/app_settings.dart';
import 'services/bookmark_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.example.gitsawe.audio',
    androidNotificationChannelName: 'Gitsawe audio playback',
    androidNotificationOngoing: true,
  );

  final prefs = await SharedPreferences.getInstance();
  final bool onboardingCompleted = prefs.getBool('onboarding_completed') ?? false;

  await AppSettings.instance.load();
  await BookmarkService.instance.load();

  // Load Gitsawe data from the API before the app starts. If this fails
  // (e.g. offline at launch), TodayScreen retries once it's mounted.
  try {
    await Future.wait([
      GitsaweService.instance.load(allowRemote: false),
      AudioLibraryService.instance.load(),
      SinksarService.instance.loadManifest(),
    ]);
    await GitsaweWidgetsService.instance.init();
    final eDate = EthiopianDate.fromGregorian(DateTime.now());
    await GitsaweWidgetsService.instance.updateAllWidgets(
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
    return ListenableBuilder(
      listenable: AppSettings.instance,
      builder: (context, child) {
        return MaterialApp(
          title: 'Gitsawe',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.theme,
          darkTheme: AppTheme.darkTheme,
          themeMode: AppSettings.instance.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          builder: (context, child) {
            final mediaQuery = MediaQuery.of(context);
            return MediaQuery(
              data: mediaQuery.copyWith(
                textScaler: TextScaler.linear(AppSettings.instance.textScale),
              ),
              child: child!,
            );
          },
          home: onboardingCompleted ? const TodayScreen() : const OnboardingScreen(),
          routes: {
            '/daily_gitsawe': (context) => const DailyGitsaweScreen(),
            '/monthly_gitsawe': (context) => const CalendarScreen(),
            '/seasonal_gitsawe': (context) => const CalendarScreen(),
            '/feasts': (context) => const CalendarScreen(),
            '/mahlet': (context) => const MahletScreen(),
          },
        );
      },
    );
  }
}
