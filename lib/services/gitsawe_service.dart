import 'package:flutter/foundation.dart';
import '../models/mahlet.dart';
import '../models/daily_gitsawe.dart';
import '../models/feast.dart';
import '../models/sub_feast.dart';
import '../models/month.dart';
import '../core/utils/ethiopian_calendar.dart';
import 'api_client.dart';

class GitsaweService {
  // Singleton instance
  GitsaweService._internal();
  static final GitsaweService instance = GitsaweService._internal();

  final ApiClient _api = ApiClient.instance;

  List<DailyGitsawe> _daily = [];
  List<Feast> _feasts = [];
  List<SubFeast> _subFeasts = [];
  List<GitsaweMonth> _months = [];
  List<dynamic> _monthlyGitsawe = [];
  List<dynamic> _seasonalGitsawe = [];
  List<Mahlet> _mahlets = [];
  bool _loaded = false;

  /// True once [load] has completed successfully at least once.
  bool get isLoaded => _loaded;

  /// Raw access to all daily entries for search or offline features.
  List<DailyGitsawe> get allDaily => _loaded ? _daily : [];

  /// Loads and parses everything from the Gitsawe API. Must be awaited
  /// before calling lookups. Safe to call repeatedly: once loaded it's a
  /// no-op unless [forceRefresh] is set (e.g. for pull-to-refresh).
  Future<void> load({bool forceRefresh = false}) async {
    if (_loaded && !forceRefresh) return;

    try {
      final results = await Future.wait([
        // Same shape as the old bundled dailyGitsawe.json.
        _api.getList('/daily', query: const {'full': '1'}),
        _api.getList('/feasts'),
        _api.getList('/subfeasts'),
        _api.getList('/months'),
        _api.getList('/mahlets'),
        _loadFullList('/monthly'),
        _loadFullList('/seasonal'),
      ]);

      final daily = (results[0])
          .map((e) => DailyGitsawe.fromJson(e as Map<String, dynamic>))
          .toList();
      final feasts = (results[1])
          .map((e) => Feast.fromJson(e as Map<String, dynamic>))
          .toList();
      final subFeasts = (results[2])
          .map((e) => SubFeast.fromJson(e as Map<String, dynamic>))
          .toList();
      final months = (results[3])
          .map((e) => GitsaweMonth.fromJson(e as Map<String, dynamic>))
          .toList();
      final mahlets = (results[4])
          .map<Mahlet>((e) => Mahlet.fromJson(e as Map<String, dynamic>))
          .toList();
      final monthly = results[5];
      final seasonal = results[6];

      // Only commit once everything decoded cleanly, so a mid-load failure
      // never leaves the service in a half-updated state.
      _daily = daily;
      _feasts = feasts;
      _subFeasts = subFeasts;
      _months = months;
      _mahlets = mahlets;
      _monthlyGitsawe = monthly;
      _seasonalGitsawe = seasonal;
      _loaded = true;
    } catch (e, stackTrace) {
      debugPrint('Error loading Gitsawe data from API: $e\n$stackTrace');
      rethrow;
    }
  }

  /// `/monthly` and `/seasonal` only return `{id, date, title}` summaries.
  /// Fetch each entry individually (skipping the sinksar/audio enrichment,
  /// which the calendar list doesn't need) to get the full reading content
  /// — matching the shape the old bundled monthlyGitsawe.json/seasonalGitsawe.json had.
  Future<List<dynamic>> _loadFullList(String path) async {
    final summaries = await _api.getList(path);
    final full = await Future.wait(summaries.map((s) {
      final id = (s as Map)['id'];
      return _api.getMap('$path/$id', query: const {'audio': '0', 'sinksar': '0'});
    }));
    return full;
  }

  /// The core lookup: given a Gregorian DateTime, find today's reading.
  DailyGitsawe? readingFor(DateTime gregorianDate) {
    if (!_loaded) return null;
    final eDate = EthiopianDate.fromGregorian(gregorianDate);
    final key = eDate.dateKey;

    final matches = _daily.where((d) => d.date == key);
    return matches.isEmpty ? null : matches.first;
  }

  List<Feast> feastsForMonth(String monthKey) {
    if (!_loaded) return [];
    return _feasts.where((f) => f.month == monthKey).toList();
  }

  /// Raw monthly gitsawe entries from the `/monthly` API endpoint.
  List<dynamic> get monthlyGitsawe => _loaded ? _monthlyGitsawe : [];

  /// Raw seasonal gitsawe entries from the `/seasonal` API endpoint.
  List<dynamic> get seasonalGitsawe => _loaded ? _seasonalGitsawe : [];

  List<Mahlet> get mahlets => _loaded ? _mahlets : [];

  List<SubFeast> subFeastsFor(String feastKey) {
    if (!_loaded) return [];
    return _subFeasts.where((s) => s.feast == feastKey).toList();
  }

  GitsaweMonth? monthByKey(String key) {
    if (!_loaded) return null;
    final matches = _months.where((m) => m.key == key);
    return matches.isEmpty ? null : matches.first;
  }
}
