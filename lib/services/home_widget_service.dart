import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';

import '../models/daily_gitsawe.dart';
import 'gitsawe_service.dart';

/// Pushes today's Gitsawe reading to the native home screen widgets
/// (Android AppWidgets) via the `home_widget` plugin.
///
/// The plugin hands data to the native side through a small key-value store.
/// The widgets themselves are implemented in
/// `android/app/src/main/kotlin/com/gitsawe/app/MainActivity.kt` and the
/// layouts in `android/app/src/main/res/layout/`.
///
/// Besides today's values, a compact "DD-MM → reading" cache is stored so the
/// native widget code can pick the right reading by itself when the day
/// changes and the app has not been opened.
class HomeWidgetService {
  HomeWidgetService._internal();
  static final HomeWidgetService instance = HomeWidgetService._internal();

  static const String _androidPinWidgetName = 'GitsaweWidgetMediumProvider';
  static const List<String> _androidWidgetNames = [
    'GitsaweWidgetSmallProvider',
    'GitsaweWidgetCompactProvider',
    'GitsaweWidgetMediumProvider',
    'GitsaweWidgetLargeProvider',
    'GitsaweWidgetCustomProvider',
    'GitsaweReadingWidgetProvider',
    'GitsaweVerseWidgetProvider',
  ];

  /// Must match the `kind:` string used in an iOS WidgetKit extension (none yet).
  static const String _iOSWidgetKind = 'GitsaweWidget';

  // Keys shared with the native widget code (see MainActivity.kt).
  static const String keyDate = 'gitsawe_date';
  static const String keyTitle = 'gitsawe_title';
  static const String keySnksar = 'gitsawe_snksar';
  static const String keyVerseText = 'gitsawe_verse_text';
  static const String keyVerseRef = 'gitsawe_verse_ref';
  static const String keyDailyCache = 'gitsawe_daily_cache';
  static const String keyUpdatedAt = 'gitsawe_updated_at';

  static const String defaultVerseText = '”የቅዱሳን መታሰቢያ ለበረከት ነው።”';
  static const String defaultVerseRef = 'ምሳሌ 10:7';

  Future<bool> requestPinWidget({String? androidName}) async {
    if (!Platform.isAndroid && !Platform.isIOS) {
      debugPrint('HomeWidgetService.requestPinWidget skipped: unsupported platform ${Platform.operatingSystem}.');
      return false;
    }

    try {
      final supported = await HomeWidget.isRequestPinWidgetSupported() ?? false;
      if (!supported) return false;

      await HomeWidget.requestPinWidget(
        androidName: androidName ?? _androidPinWidgetName,
      );
      return true;
    } catch (e, st) {
      debugPrint('HomeWidgetService.requestPinWidget failed: $e\n$st');
      return false;
    }
  }

  /// First Misbak verse of the reading as (text, reference), or null.
  static ({String text, String ref})? verseOf(DailyGitsawe? reading) {
    if (reading == null || reading.negh.msbak.isEmpty) return null;
    final v = reading.negh.msbak.first;
    if (v.text.amharic.isEmpty) return null;
    final ref = v.verse.display.isNotEmpty && v.verse.bookTitle.isNotEmpty
        ? '${v.verse.bookTitle} ${v.verse.display}'
        : v.verse.bookTitle;
    return (text: v.text.amharic, ref: ref);
  }

  static String _clip(String s, int max) =>
      s.length <= max ? s : '${s.substring(0, max).trimRight()}…';

  /// Compact cache read by the native widget code. Kept small on purpose
  /// (it lives in SharedPreferences): only what the widgets display.
  static String buildDailyCacheJson(List<DailyGitsawe> entries) {
    final payload = entries.map((entry) {
      final verse = verseOf(entry);
      return {
        'date': entry.date,
        'title': entry.title,
        'snksar': entry.snksar.isEmpty ? '' : _clip(entry.snksar.first.amharic, 240),
        if (verse != null) 'verse': _clip(verse.text, 240),
        if (verse != null) 'ref': verse.ref,
      };
    }).toList(growable: false);

    return jsonEncode(payload);
  }

  /// Writes today's reading into widget storage and asks the OS to redraw
  /// any placed widgets. Safe to call often and never throws.
  Future<void> updateWidget({
    required String ethiopianDateLabel,
    DailyGitsawe? reading,
  }) async {
    if (!Platform.isAndroid && !Platform.isIOS) return;

    try {
      final title = reading?.title ?? 'ዛሬ ንባብ አልተገኘም';
      final snksar = (reading != null && reading.snksar.isNotEmpty)
          ? reading.snksar.first.amharic
          : '';
      final verse = verseOf(reading);

      final cacheJson = buildDailyCacheJson(GitsaweService.instance.allDaily);

      await Future.wait([
        HomeWidget.saveWidgetData<String>(keyDate, ethiopianDateLabel),
        HomeWidget.saveWidgetData<String>(keyTitle, title),
        HomeWidget.saveWidgetData<String>(keySnksar, snksar),
        HomeWidget.saveWidgetData<String>(keyVerseText, verse?.text ?? defaultVerseText),
        HomeWidget.saveWidgetData<String>(keyVerseRef, verse?.ref ?? defaultVerseRef),
        HomeWidget.saveWidgetData<String>(keyDailyCache, cacheJson),
        HomeWidget.saveWidgetData<String>(
          keyUpdatedAt,
          DateTime.now().toIso8601String(),
        ),
      ]);

      await Future.wait([
        for (final androidName in _androidWidgetNames)
          HomeWidget.updateWidget(
            androidName: androidName,
            iOSName: _iOSWidgetKind,
          ),
      ]);
    } catch (e, st) {
      // Widget refresh is best-effort; never let it crash the app.
      debugPrint('HomeWidgetService.updateWidget failed: $e\n$st');
    }
  }
}
