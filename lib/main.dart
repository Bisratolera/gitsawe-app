import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'screen/today_screen.dart';
import 'services/gitsawe_service.dart';
import 'services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load Gitsawe data before the app starts.
  await GitsaweService.instance.load();

  // Initialize notifications and timezone.
  await NotificationService.instance.init();

  // Schedule the daily Gitsawe notification.
  await _setUpNotifications();

  runApp(const GitsaweApp());
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
  const GitsaweApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gitsawe',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: const TodayScreen(),
    );
  }
}