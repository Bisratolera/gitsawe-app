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

/// A single hit returned by [GitsaweService.searchDaily].
class SearchHit {
  final DailyGitsawe entry;

  /// A short excerpt showing where the query matched (empty for title matches).
  final String snippet;

  const SearchHit(this.entry, this.snippet);
}

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
  Future<void>? _loading;

  /// True once [load] has completed successfully at least once.
  bool get isLoaded => _loaded;

  /// Raw access to all daily entries for search or offline features.
  List<DailyGitsawe> get allDaily => _loaded ? _daily : [];

  /// Loads from bundled assets by default. The remote Gitsawe API is kept for
  /// future use but is disabled: the app is fully offline-first and ships all
  /// reading data inside the APK.
  ///
  /// Concurrent callers share a single in-flight load.
  Future<void> load({bool forceRefresh = false, bool allowRemote = false}) {
    if (_loaded && !forceRefresh) return Future.value();
    final inFlight = _loading;
    if (inFlight != null) return inFlight;

    final future = _doLoad(allowRemote: allowRemote);
    _loading = future.whenComplete(() => _loading = null);
    return _loading!;
  }

  Future<void> _doLoad({required bool allowRemote}) async {
    try {
      if (allowRemote) {
        debugPrint('GitsaweService: Attempting to load from API...');
        await _loadFromApi();
        debugPrint('GitsaweService: Loaded from API successfully.');
        return;
      }

      await _loadFromAssets();
      debugPrint('GitsaweService: Loaded from local assets successfully.');
    } catch (e, stackTrace) {
      debugPrint('GitsaweService: load failed: $e\n$stackTrace');
      rethrow;
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

    _setDaily((results[0])
        .map((e) => DailyGitsawe.fromJson(e as Map<String, dynamic>))
        .toList());
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

    _setDaily((json.decode(results[0]) as List)
        .map((e) => DailyGitsawe.fromJson(e as Map<String, dynamic>))
        .toList());
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

  /// Stores daily entries de-duplicated by date (the source data contains
  /// at least one exact duplicate, 02-08) and in calendar order.
  void _setDaily(List<DailyGitsawe> entries) {
    final byDate = <String, DailyGitsawe>{};
    for (final e in entries) {
      byDate.putIfAbsent(e.date, () => e);
    }
    final list = byDate.values.toList()
      ..sort((a, b) {
        final ka = _sortKey(a.date);
        final kb = _sortKey(b.date);
        return ka.compareTo(kb);
      });
    _daily = list;
  }

  static int _sortKey(String dateKey) {
    final parts = dateKey.split('-');
    if (parts.length != 2) return 9999;
    final day = int.tryParse(parts[0]) ?? 99;
    final month = int.tryParse(parts[1]) ?? 99;
    return month * 100 + day;
  }

  Future<List<dynamic>> _loadFullListFromApi(String path) async {
    final summaries = await _api.getList(path);
    final full = await Future.wait(summaries.map((s) {
      final id = (s as Map)['id'];
      return _api.getMap('$path/$id', query: const {'audio': '0', 'sinksar': '0'});
    }));
    return full;
  }

  /// The core lookup: given a Gregorian DateTime, find that day's reading.
  /// Returns null when the bundled data has no entry for the date.
  DailyGitsawe? readingFor(DateTime gregorianDate) {
    if (!_loaded) return null;
    return readingForKey(EthiopianDate.fromGregorian(gregorianDate).dateKey);
  }

  DailyGitsawe? readingForKey(String dateKey) {
    if (!_loaded) return null;
    for (final d in _daily) {
      if (d.date == dateKey) return d;
    }
    return null;
  }

  /// Like [readingFor] but never null: days without a dedicated Gitsawe entry
  /// (the bundled data covers roughly 80% of the year) get a placeholder whose
  /// title is the Ethiopian date, so the Synaxarium for that day is still shown.
  DailyGitsawe readingOrPlaceholder(DateTime gregorianDate, {bool english = false}) {
    final eDate = EthiopianDate.fromGregorian(gregorianDate);
    return readingFor(gregorianDate) ?? placeholderFor(eDate.dateKey, english: english);
  }

  static DailyGitsawe placeholderFor(String dateKey, {bool english = false}) {
    return DailyGitsawe(
      date: dateKey,
      title: formatDateKey(dateKey, english: english),
      snksar: const [],
      negh: ReadingGroup(),
      kidassie: ReadingGroup(),
    );
  }

  /// Looks up a stored bookmark (date + title) across daily, monthly and
  /// seasonal data.
  DailyGitsawe? findByDateAndTitle(String date, String title) {
    if (!_loaded) return null;
    for (final d in _daily) {
      if (d.date == date && d.title == title) return d;
    }
    for (final raw in [..._monthlyGitsawe, ..._seasonalGitsawe]) {
      if (raw is Map<String, dynamic> && raw['date'] == date && raw['title'] == title) {
        try {
          return DailyGitsawe.fromJson(raw);
        } catch (_) {
          return null;
        }
      }
    }
    return readingForKey(date);
  }

  /// Case-insensitive full-text search across titles, Synaxarium text and the
  /// Amharic / English / Ge'ez verses of the morning and liturgy readings.
  List<SearchHit> searchDaily(String query, {int limit = 80}) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty || !_loaded) return const [];

    final hits = <SearchHit>[];
    for (final d in _daily) {
      if (hits.length >= limit) break;

      if (d.title.toLowerCase().contains(q) || d.date.contains(q)) {
        hits.add(SearchHit(d, ''));
        continue;
      }

      final snippet = _findSnippet(d, q);
      if (snippet != null) hits.add(SearchHit(d, snippet));
    }
    return hits;
  }

  static String? _findSnippet(DailyGitsawe d, String q) {
    for (final s in d.snksar) {
      final at = s.amharic.toLowerCase().indexOf(q);
      if (at >= 0) return _excerpt(s.amharic, at, q.length);
    }
    for (final group in [d.negh, d.kidassie]) {
      for (final list in [
        group.msbak,
        group.wengel,
        group.firstDeacon,
        group.secondDeacon,
        group.secondKahn,
      ]) {
        for (final v in list) {
          for (final text in [v.text.amharic, v.text.english, v.text.geez]) {
            final at = text.toLowerCase().indexOf(q);
            if (at >= 0) return _excerpt(text, at, q.length);
          }
        }
      }
    }
    return null;
  }

  static String _excerpt(String text, int at, int len) {
    final start = (at - 30).clamp(0, text.length);
    final end = (at + len + 60).clamp(0, text.length);
    final prefix = start > 0 ? '…' : '';
    final suffix = end < text.length ? '…' : '';
    return '$prefix${text.substring(start, end).replaceAll('\n', ' ')}$suffix';
  }

  List<Feast> feastsForMonth(String monthKey) {
    if (!_loaded) return [];
    return _feasts.where((f) => f.month == monthKey).toList();
  }

  List<Feast> get feasts => _loaded ? List.unmodifiable(_feasts) : const [];

  /// Raw monthly gitsawe entries.
  List<dynamic> get monthlyGitsawe => _loaded ? _monthlyGitsawe : [];

  /// Raw seasonal gitsawe entries.
  List<dynamic> get seasonalGitsawe => _loaded ? _seasonalGitsawe : [];

  List<Mahlet> get mahlets => _loaded ? _mahlets : [];

  List<SubFeast> subFeastsFor(String feastKey) {
    if (!_loaded) return [];
    return _subFeasts.where((s) => s.feast == feastKey).toList();
  }

  /// Drops the in-memory data and immediately reloads it from the bundled
  /// assets. (The previous implementation left the app with no data until the
  /// next restart.)
  Future<void> clearCache() async {
    _daily = [];
    _feasts = [];
    _subFeasts = [];
    _months = [];
    _monthlyGitsawe = [];
    _seasonalGitsawe = [];
    _mahlets = [];
    _loaded = false;
    await load(forceRefresh: true);
  }

  GitsaweMonth? monthByKey(String key) {
    if (!_loaded) return null;
    final matches = _months.where((m) => m.key == key);
    return matches.isEmpty ? null : matches.first;
  }
}
