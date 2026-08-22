import 'package:flutter/material.dart';
import '../models/daily_gitsawe.dart';
import '../services/gitsawe_service.dart';
import '../services/api_client.dart';
import '../widgets/gitsawe_view.dart';
import '../core/utils/ethiopian_calendar.dart';
import '../widgets/screen_wrapper.dart';

class TodayScreen extends StatefulWidget {
  const TodayScreen({super.key});

  @override
  State<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends State<TodayScreen> {
  DailyGitsawe? _today;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadToday();
  }

  Future<void> _loadToday() async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await GitsaweService.instance.load();
      final reading = GitsaweService.instance.readingFor(DateTime.now());
      if (mounted) {
        setState(() {
          _today = reading;
          _loading = false;
        });
      }
    } catch (e, st) {
      if (mounted) {
        setState(() {
          _today = null;
          _loading = false;
          _error = e is ApiException
              ? "Couldn't reach the Gitsawe server. Check your connection and try again."
              : 'Something went wrong loading today\'s reading.';
        });
      }
      debugPrint('Error loading data: $e\n$st');
    }
  }

  @override
  Widget build(BuildContext context) {
    final eDate = EthiopianDate.fromGregorian(DateTime.now());

    Widget bodyContent;
    if (_loading) {
      bodyContent = const Center(child: CircularProgressIndicator());
    } else if (_error != null) {
      bodyContent = Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off, size: 40, color: Colors.black38),
              const SizedBox(height: 12),
              Text(_error!, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadToday,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    } else if (_today == null) {
      bodyContent = const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            "No reading found for today yet.",
            textAlign: TextAlign.center,
          ),
        ),
      );
    } else {
      bodyContent = SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: GitsaweView(
            entry: _today!, dateLabel: '${eDate.day}/${eDate.month}/${eDate.year} ዓ.ም.'),
      );
    }

    return ScreenWrapper(
      currentIndex: 0,
      title: 'የዕለቱ ግጻዌ',
      body: bodyContent,
    );
  }
}
