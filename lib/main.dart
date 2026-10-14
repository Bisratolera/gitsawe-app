import 'dart:async';

import 'package:flutter/material.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/l10n/strings.dart';
import 'core/theme/app_theme.dart';
import 'screen/today_screen.dart';
import 'screen/onboarding_screen.dart';
import 'screen/daily_gitsawe_screen.dart';
import 'screen/calendar_screen.dart';
import 'screen/feasts_screen.dart';
import 'screen/mahlet_screen.dart';
import 'services/daily_refresh.dart';
import 'services/gitsawe_service.dart';
import 'services/gitsawe_widgets_service.dart';
import 'services/missed_updates_service.dart';
import 'services/notification_service.dart';
import 'services/audio_library_service.dart';
import 'services/sinksar_service.dart';
import 'services/app_settings.dart';
import 'services/bookmark_service.dart';

/// Runs [task], logging (not rethrowing) any error so one failing data source
/// can never stop the app from starting.
Future<void> _guard(String name, Future<void> Function() task) async {
  try {
    await task();
  } catch (e, st) {
    debugPrint('Startup task "$name" failed: $e\n$st');
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await _guard('audio background', () async {
    await JustAudioBackground.init(
      androidNotificationChannelId: 'com.gitsawe.app.audio',
      androidNotificationChannelName: 'Gitsawe audio playback',
      androidNotificationOngoing: true,
    );
  });

  final prefs = await SharedPreferences.getInstance();
  final bool onboardingCompleted = prefs.getBool('onboarding_completed') ?? false;

  await _guard('settings', AppSettings.instance.load);
  await _guard('bookmarks', BookmarkService.instance.load);

  // All reading data is bundled in the app, so this works fully offline.
  await Future.wait([
    _guard('gitsawe data', () => GitsaweService.instance.load(allowRemote: false)),
    _guard('audio library', AudioLibraryService.instance.load),
    _guard('sinksar manifest', SinksarService.instance.loadManifest),
  ]);

  await _guard('widgets', GitsaweWidgetsService.instance.init);
  await _guard('notifications', NotificationService.instance.init);
  await _guard('missed readings', MissedUpdatesService.instance.onAppOpened);

  runApp(GitsaweApp(onboardingCompleted: onboardingCompleted));

  // Widgets + reminder window. Not awaited: the first frame must not wait for it.
  unawaited(DailyRefresh.instance.run());
}

class GitsaweApp extends StatefulWidget {
  final bool onboardingCompleted;

  const GitsaweApp({super.key, required this.onboardingCompleted});

  @override
  State<GitsaweApp> createState() => _GitsaweAppState();
}

class _GitsaweAppState extends State<GitsaweApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // A new day may have started while the app was in the background.
      unawaited(MissedUpdatesService.instance.onAppOpened());
      unawaited(DailyRefresh.instance.run());
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppSettings.instance,
      builder: (context, child) {
        final settings = AppSettings.instance;
        return MaterialApp(
          title: 'Gitsawe',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.theme,
          darkTheme: AppTheme.darkTheme,
          themeMode: settings.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          builder: (context, child) {
            final mediaQuery = MediaQuery.of(context);
            return LangScope(
              lang: settings.language,
              child: MediaQuery(
                data: mediaQuery.copyWith(
                  textScaler: TextScaler.linear(settings.textScale),
                ),
                child: child!,
              ),
            );
          },
          home: widget.onboardingCompleted ? const TodayScreen() : const OnboardingScreen(),
          routes: {
            '/daily_gitsawe': (context) => const DailyGitsaweScreen(),
            '/monthly_gitsawe': (context) => const CalendarScreen(),
            '/seasonal_gitsawe': (context) => const CalendarScreen(seasonal: true),
            '/feasts': (context) => const FeastsScreen(),
            '/mahlet': (context) => const MahletScreen(),
          },
        );
      },
    );
  }
}
