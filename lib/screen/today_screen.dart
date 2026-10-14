import 'package:flutter/material.dart';
import '../core/l10n/strings.dart';
import '../core/theme/app_theme.dart';
import '../core/utils/ethiopian_calendar.dart';
import '../models/daily_gitsawe.dart';
import '../services/gitsawe_service.dart';
import '../widgets/gitsawe_view.dart';
import '../widgets/screen_wrapper.dart';

class TodayScreen extends StatefulWidget {
  const TodayScreen({super.key});

  @override
  State<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends State<TodayScreen> with WidgetsBindingObserver {
  /// The calendar day being shown (local date, no time part).
  late DateTime _day;
  late DateTime _todayAtBuild;
  bool _loading = true;
  bool _hasError = false;

  static DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _todayAtBuild = _dateOnly(DateTime.now());
    _day = _todayAtBuild;
    _loadData();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // If the app was left open overnight, jump to the new "today".
    if (state == AppLifecycleState.resumed) {
      final today = _dateOnly(DateTime.now());
      if (today != _todayAtBuild && mounted) {
        setState(() {
          final wasOnToday = _day == _todayAtBuild;
          _todayAtBuild = today;
          if (wasOnToday) _day = today;
        });
      }
    }
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _hasError = false;
    });
    try {
      await GitsaweService.instance.load(allowRemote: false);
      if (mounted) setState(() => _loading = false);
    } catch (e, st) {
      debugPrint('Error loading data: $e\n$st');
      if (mounted) {
        setState(() {
          _loading = false;
          _hasError = true;
        });
      }
    }
  }

  void _shiftDay(int delta) {
    // DateTime() normalises day overflow and is immune to DST shifts.
    setState(() => _day = DateTime(_day.year, _day.month, _day.day + delta));
  }

  @override
  Widget build(BuildContext context) {
    final english = LangScope.of(context) == 'en';
    final isToday = _day == _todayAtBuild;
    final eDate = EthiopianDate.fromGregorian(_day);

    Widget bodyContent;
    if (_loading) {
      bodyContent = const Center(child: CircularProgressIndicator());
    } else if (_hasError) {
      bodyContent = Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 40, color: Colors.black38),
              const SizedBox(height: 12),
              Text(tr(context, 'today_load_error'), textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadData,
                child: Text(tr(context, 'retry')),
              ),
            ],
          ),
        ),
      );
    } else {
      final DailyGitsawe? reading = GitsaweService.instance.readingFor(_day);
      final entry = reading ?? GitsaweService.placeholderFor(eDate.dateKey, english: english);
      final dateLabel = english
          ? '${ethiopianMonthName(eDate.month, english: true)} ${eDate.day}, ${eDate.year} E.C.'
          : '${eDate.day}/${eDate.month}/${eDate.year} ዓ.ም.';

      bodyContent = Column(
        children: [
          _DayNavigator(
            label: formatDateKey(eDate.dateKey, english: english),
            isToday: isToday,
            onPrevious: () => _shiftDay(-1),
            onNext: () => _shiftDay(1),
            onToday: () => setState(() => _day = _todayAtBuild),
          ),
          Expanded(
            child: SingleChildScrollView(
              key: ValueKey(_day),
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
              child: Column(
                children: [
                  if (reading == null)
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.gold.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        tr(context, 'no_reading_today'),
                        style: const TextStyle(fontSize: 13, height: 1.5),
                      ),
                    ),
                  GitsaweView(entry: entry, dateLabel: dateLabel),
                ],
              ),
            ),
          ),
        ],
      );
    }

    return ScreenWrapper(
      currentIndex: 0,
      title: tr(context, 'title_today'),
      body: bodyContent,
    );
  }
}

class _DayNavigator extends StatelessWidget {
  final String label;
  final bool isToday;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onToday;

  const _DayNavigator({
    required this.label,
    required this.isToday,
    required this.onPrevious,
    required this.onNext,
    required this.onToday,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 12, 8, 0),
      child: Row(
        children: [
          IconButton(
            tooltip: tr(context, 'prev_day'),
            onPressed: onPrevious,
            icon: const Icon(Icons.chevron_left_rounded),
            color: colors.primary,
          ),
          Expanded(
            child: GestureDetector(
              onTap: isToday ? null : onToday,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: colors.primary,
                    ),
                  ),
                  if (!isToday)
                    Text(
                      tr(context, 'back_to_today'),
                      style: TextStyle(
                        fontSize: 11,
                        color: colors.onSurfaceVariant,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                ],
              ),
            ),
          ),
          IconButton(
            tooltip: tr(context, 'next_day'),
            onPressed: onNext,
            icon: const Icon(Icons.chevron_right_rounded),
            color: colors.primary,
          ),
        ],
      ),
    );
  }
}
