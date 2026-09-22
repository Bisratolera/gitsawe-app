import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
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

  /// Loads and parses everything from the Gitsawe API. Falls back to local
  /// assets if the API is unreachable.
  Future<void> load({bool forceRefresh = false}) async {
    if (_loaded && !forceRefresh) return;

    try {
      debugPrint('GitsaweService: Attempting to load from API...');
      await _loadFromApi();
      debugPrint('GitsaweService: Loaded from API successfully.');
    } catch (e) {
      debugPrint('GitsaweService: API load failed ($e). Falling back to local assets...');
      try {
        await _loadFromAssets();
        debugPrint('GitsaweService: Loaded from local assets successfully.');
      } catch (assetError, stackTrace) {
        debugPrint('GitsaweService: Asset fallback also failed: $assetError\n$stackTrace');
        rethrow;
      }
    }
  }

  Future<void> _loadFromApi() async {
    final results = await Future.wait([
      _api.getList('/daily', query: const {'full': '1'}),
      _api.getList('/feasts'),
      _api.getList('/subfeasts'),
      _api.getList('/months'),
      _api.getList('/mahlets'),
      _loadFullListFromApi('/monthly'),
      _loadFullListFromApi('/seasonal'),
    ]);

    _daily = (results[0])
        .map((e) => DailyGitsawe.fromJson(e as Map<String, dynamic>))
        .toList();
    _feasts = (results[1])
        .map((e) => Feast.fromJson(e as Map<String, dynamic>))
        .toList();
    _subFeasts = (results[2])
        .map((e) => SubFeast.fromJson(e as Map<String, dynamic>))
        .toList();
    _months = (results[3])
        .map((e) => GitsaweMonth.fromJson(e as Map<String, dynamic>))
        .toList();
    _mahlets = (results[4])
        .map<Mahlet>((e) => Mahlet.fromJson(e as Map<String, dynamic>))
        .toList();
    _monthlyGitsawe = results[5];
    _seasonalGitsawe = results[6];
    _loaded = true;
  }

  Future<void> _loadFromAssets() async {
    final results = await Future.wait([
      rootBundle.loadString('assets/data/dailyGitsawe.json'),
      rootBundle.loadString('assets/data/feasts.json'),
      rootBundle.loadString('assets/data/months.json'),
      rootBundle.loadString('assets/data/mahlets.json'),
      rootBundle.loadString('assets/data/subFeasts.json'),
      rootBundle.loadString('assets/data/monthlyGitsawe.json'),
      rootBundle.loadString('assets/data/seasonalGitsawe.json'),
    ]);

    _daily = (json.decode(results[0]) as List)
        .map((e) => DailyGitsawe.fromJson(e as Map<String, dynamic>))
        .toList();
    _feasts = (json.decode(results[1]) as List)
        .map((e) => Feast.fromJson(e as Map<String, dynamic>))
        .toList();
    _months = (json.decode(results[2]) as List)
        .map((e) => GitsaweMonth.fromJson(e as Map<String, dynamic>))
        .toList();
    _mahlets = (json.decode(results[3]) as List)
        .map((e) => Mahlet.fromJson(e as Map<String, dynamic>))
        .toList();
    _subFeasts = (json.decode(results[4]) as List)
        .map((e) => SubFeast.fromJson(e as Map<String, dynamic>))
        .toList();
    _monthlyGitsawe = json.decode(results[5]) as List;
    _seasonalGitsawe = json.decode(results[6]) as List;
    _loaded = true;
  }

  Future<List<dynamic>> _loadFullListFromApi(String path) async {
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

  Future<void> clearCache() async {
    _daily = [];
    _feasts = [];
    _subFeasts = [];
    _months = [];
    _monthlyGitsawe = [];
    _seasonalGitsawe = [];
    _mahlets = [];
    _loaded = false;
  }

  GitsaweMonth? monthByKey(String key) {
    if (!_loaded) return null;
    final matches = _months.where((m) => m.key == key);
    return matches.isEmpty ? null : matches.first;
  }
}
