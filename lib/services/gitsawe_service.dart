import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:gitsawe/models/mahlet.dart';
import '../models/daily_gitsawe.dart';
import '../models/feast.dart';
import '../models/sub_feast.dart';
import '../models/month.dart';
import '../core/utils/ethiopian_calendar.dart';

class GitsaweService {
  // Singleton instance
  GitsaweService._internal();
  static final GitsaweService instance = GitsaweService._internal();

  List<DailyGitsawe> _daily = [];
  List<Feast> _feasts = [];
  List<SubFeast> _subFeasts = [];
  List<GitsaweMonth> _months = [];
  List<dynamic> _monthlyGitsawe = [];
  List<dynamic> _seasonalGitsawe = [];
  
  // FIXED: Declared explicitly as a List of Mahlet models
  List<Mahlet> _mahlets = [];
  bool _loaded = false;

  /// Raw access to all daily entries for search or offline features.
  List<DailyGitsawe> get allDaily => _loaded ? _daily : [];

  /// Loads and parses all JSON assets. Must be awaited before calling lookups.
  Future<void> load() async {
    if (_loaded) return;

    try {
      final results = await Future.wait([
        rootBundle.loadString('assets/data/dailyGitsawe.json'),
        rootBundle.loadString('assets/data/feasts.json'),
        rootBundle.loadString('assets/data/subFeasts.json'),
        rootBundle.loadString('assets/data/months.json'),
        rootBundle.loadString('assets/data/monthlyGitsawe.json'),
        rootBundle.loadString('assets/data/seasonalGitsawe.json'),
        rootBundle.loadString('assets/data/mahlets.json'),
      ]);

      _daily = (jsonDecode(results[0]) as List)
          .map((e) => DailyGitsawe.fromJson(e as Map<String, dynamic>))
          .toList();

      _feasts = (jsonDecode(results[1]) as List)
          .map((e) => Feast.fromJson(e as Map<String, dynamic>))
          .toList();

      _subFeasts = (jsonDecode(results[2]) as List)
          .map((e) => SubFeast.fromJson(e as Map<String, dynamic>))
          .toList();

      _months = (jsonDecode(results[3]) as List)
          .map((e) => GitsaweMonth.fromJson(e as Map<String, dynamic>))
          .toList();

      // Store raw JSON blobs for future use
      _monthlyGitsawe = jsonDecode(results[4]) as List<dynamic>;
      _seasonalGitsawe = jsonDecode(results[5]) as List<dynamic>;
      
      // FIXED: Maps and assigns perfectly to the matching List<Mahlet> type variable
      _mahlets = (jsonDecode(results[6]) as List)
          .map<Mahlet>((e) => Mahlet.fromJson(e as Map<String, dynamic>))
          .toList();

      _loaded = true;
    } catch (e, stackTrace) {
      print('Error loading Gitsawe data: $e\n$stackTrace');
      rethrow;
    }
  }

  /// The core lookup: given a Gregorian DateTime, find today's reading.
  DailyGitsawe? readingFor(DateTime gregorianDate) {
    if (!_loaded) return null;
    final eDate = EthiopianDate.fromGregorian(gregorianDate);
    final key = eDate.dateKey;
    
    return _daily.where((d) => d.date == key).firstOrNull;
  }

  List<Feast> feastsForMonth(String monthKey) {
    if (!_loaded) return [];
    return _feasts.where((f) => f.month == monthKey).toList();
  }

  /// Raw monthly gitsawe entries from `assets/data/monthlyGitsawe.json`.
  List<dynamic> get monthlyGitsawe => _loaded ? _monthlyGitsawe : [];

  /// Raw seasonal gitsawe entries from `assets/data/seasonalGitsawe.json`.
  List<dynamic> get seasonalGitsawe => _loaded ? _seasonalGitsawe : [];

  // FIXED: Changed from List<dynamic> to List<Mahlet> to expose the correct type to the UI
  List<Mahlet> get mahlets => _loaded ? _mahlets : [];

  List<SubFeast> subFeastsFor(String feastKey) {
    if (!_loaded) return [];
    return _subFeasts.where((s) => s.feast == feastKey).toList();
  }

  GitsaweMonth? monthByKey(String key) {
    if (!_loaded) return null;
    return _months.where((m) => m.key == key).firstOrNull;
  }
}
