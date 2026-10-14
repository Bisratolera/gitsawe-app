import 'package:flutter_test/flutter_test.dart';

import 'package:gitsawe/services/gitsawe_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await GitsaweService.instance.load(allowRemote: false);
  });

  test('loads bundled data', () {
    final s = GitsaweService.instance;
    expect(s.isLoaded, isTrue);
    expect(s.allDaily, isNotEmpty);
    expect(s.monthlyGitsawe, isNotEmpty);
    expect(s.seasonalGitsawe, isNotEmpty);
    expect(s.mahlets, isNotEmpty);
    expect(s.feasts, isNotEmpty);
  });

  test('daily entries are unique by date', () {
    final dates = GitsaweService.instance.allDaily.map((d) => d.date).toList();
    expect(dates.toSet().length, dates.length);
  });

  test('placeholder is returned for days without a reading', () {
    final p = GitsaweService.placeholderFor('06-13');
    expect(p.date, '06-13');
    expect(p.title, isNotEmpty);
  });

  test('every day of the year gets a non-null reading or placeholder', () {
    final s = GitsaweService.instance;
    var day = DateTime(2026, 1, 1);
    for (var i = 0; i < 366; i++) {
      expect(s.readingOrPlaceholder(day).title, isNotEmpty);
      day = DateTime(day.year, day.month, day.day + 1);
    }
  });

  test('search finds titles and ignores empty queries', () {
    final s = GitsaweService.instance;
    expect(s.searchDaily('   '), isEmpty);
    final first = s.allDaily.first;
    final hits = s.searchDaily(first.title.substring(0, 3));
    expect(hits, isNotEmpty);
  });

  test('clearCache reloads data instead of leaving the app empty', () async {
    await GitsaweService.instance.clearCache();
    expect(GitsaweService.instance.isLoaded, isTrue);
    expect(GitsaweService.instance.allDaily, isNotEmpty);
  });
}
