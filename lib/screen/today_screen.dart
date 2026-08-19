import 'package:flutter/material.dart';
import '../models/daily_gitsawe.dart';
import '../services/gitsawe_service.dart';
import '../widgets/gitsawe_app_bar.dart';
import '../widgets/app_bottom_nav.dart';
import '../widgets/gitsawe_view.dart';
import 'calendar_screen.dart';
import 'search_screen.dart';
import 'more_screen.dart';
import 'mahlet_screen.dart';
import '../core/utils/ethiopian_calendar.dart';

class TodayScreen extends StatefulWidget {
  const TodayScreen({super.key});

  @override
  State<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends State<TodayScreen> {
  DailyGitsawe? _today;
  bool _loading = true;
  int _navIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadToday();
  }

  Future<void> _loadToday() async {
    try {
      await GitsaweService.instance.load();
      final reading = GitsaweService.instance.readingFor(DateTime.now());
      setState(() {
        _today = reading;
        _loading = false;
      });
    } catch (e, st) {
      // Prevent the UI from staying stuck on loading if parsing fails.
      setState(() {
        _today = null;
        _loading = false;
      });
      // Log the error; optionally show a snackbar when mounted.
      debugPrint('Error loading data: $e\n$st');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading data: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final eDate = EthiopianDate.fromGregorian(DateTime.now());
    Widget bodyContent;
    if (_loading) {
      bodyContent = const Center(child: CircularProgressIndicator());
    } else if (_navIndex == 0) {
      bodyContent = _today == null
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                    child: Text(
                    'No reading found for today yet.\n(This date isn\'t in dailyGitsawe.json)',
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : SingleChildScrollView(
              child: GitsaweView(entry: _today!, dateLabel: '${eDate.day}/${eDate.month}/${eDate.year}'),
            );
    } else if (_navIndex == 1) {
      bodyContent = const CalendarScreen();
    } else if (_navIndex == 2) {
      bodyContent = const MahletScreen();
    } else if (_navIndex == 3) {
      bodyContent = const SearchScreen();
    } else {
      bodyContent = const MoreScreen();
    }

    return Scaffold(
      appBar: const GitsaweAppBar(),
      bottomNavigationBar: AppBottomNav(
        currentIndex: _navIndex,
        onTap: (i) => setState(() => _navIndex = i),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: bodyContent is Column || bodyContent is ListView
            ? bodyContent
            : bodyContent,
      ),
    );
  }
}