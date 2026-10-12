// lib/core/navigation/main_tabs.dart
import 'package:flutter/material.dart';
import '../../screen/today_screen.dart';
import '../../screen/daily_gitsawe_screen.dart';
import '../../screen/teachings_screen.dart';
import '../../screen/calendar_screen.dart';
import '../../screen/mahlet_screen.dart';
import '../../screen/search_screen.dart';
import '../../screen/more_screen.dart';

/// One builder per tab, in AppBottomNav's index order.
/// No route names, no table to keep in sync — if this list and
/// AppBottomNav's items list have the same length and order,
/// it's correct by construction.
final List<WidgetBuilder> mainTabBuilders = [
  (_) => const TodayScreen(),        // 0 — Today
  (_) => const DailyGitsaweScreen(), // 1 — Daily
  (_) => const TeachingsScreen(),    // 2 — Teachings
  (_) => const CalendarScreen(),     // 3 — Calendar
  (_) => const MahletScreen(),       // 4 — Mahlet
  (_) => const SearchScreen(),       // 5 — Search
  (_) => const MoreScreen(),         // 6 — More
];

void goToMainTab(BuildContext context, int index) {
  Navigator.of(context).pushReplacement(
    MaterialPageRoute(builder: mainTabBuilders[index]),
  );
}