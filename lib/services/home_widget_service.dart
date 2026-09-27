import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';

import '../models/daily_gitsawe.dart';
import 'gitsawe_service.dart';

/// Pushes today's Gitsawe reading to the native home screen widget
/// (Android AppWidget / iOS WidgetKit) via the `home_widget` plugin.
///
/// The plugin just hands data back and forth through a small native
/// key-value store; the actual widget UI lives in:
///  - android/app/src/main/kotlin/.../GitsaweWidgetProvider.kt
///  - android/app/src/main/res/layout/gitsawe_widget.xml
///  - android/app/src/main/res/xml/gitsawe_widget_info.xml
///  - ios/GitsaweWidget/ (WidgetKit extension, added via Xcode)
class HomeWidgetService {
  HomeWidgetService._internal();
  static final HomeWidgetService instance = HomeWidgetService._internal();

  /// Keep only the summary widget available so the home screen doesn't show
  /// multiple competing widget variants.
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

  /// Must match the `kind:` string used in the iOS WidgetKit extension.
  static const String _iOSWidgetKind = 'GitsaweWidget';

  // Keys shared with the native widget code — keep these in sync with
  // GitsaweWidgetProvider.kt and the iOS widget's timeline provider.
  static const String keyDate = 'gitsawe_date';
  static const String keyTitle = 'gitsawe_title';
  static const String keySnksar = 'gitsawe_snksar';
  static const String keyDailyCache = 'gitsawe_daily_cache';
  static const String keyUpdatedAt = 'gitsawe_updated_at';

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

  static String buildDailyCacheJson(List<DailyGitsawe> entries) {
    final payload = entries.map((entry) {
      return {
        'date': entry.date,
        'title': entry.title,
        'snksar': entry.snksar
            .map((s) => {'amharic': s.amharic})
            .toList(growable: false),
      };
    }).toList(growable: false);

    return jsonEncode(payload);
  }

  /// Writes today's reading into widget storage and asks the OS to redraw
  /// any placed widgets. Safe to call often — it's cheap and never throws
  /// (a widget failing to refresh shouldn't take down the app).
  Future<void> updateWidget({
    required String ethiopianDateLabel,
    DailyGitsawe? reading,
  }) async {
    if (!Platform.isAndroid && !Platform.isIOS) {
      debugPrint('HomeWidgetService.updateWidget skipped: unsupported platform ${Platform.operatingSystem}.');
      return;
    }

    try {
      debugPrint('HomeWidgetService: Updating widget with $ethiopianDateLabel');
      final title = reading?.title ?? 'ዛሬ ንባብ አልተገኘም';
      final snksar = (reading != null && reading.snksar.isNotEmpty)
          ? reading.snksar.first.amharic
          : 'ለዛሬ ስንክሳር የለም';

      String verseText = '”የቅዱሳን መታሰቢያ ለበረከት ነው።”';
      String verseRef = 'ምሳሌ 10:7';
      if (reading != null && reading.negh.msbak.isNotEmpty) {
        final v = reading.negh.msbak.first;
        if (v.text.amharic.isNotEmpty) {
          verseText = v.text.amharic;
          verseRef = v.verse.display.isNotEmpty ? '${v.verse.bookTitle} ${v.verse.display}' : v.verse.bookTitle;
        }
      }

      final cacheJson = buildDailyCacheJson(GitsaweService.instance.allDaily);

      await Future.wait([
        HomeWidget.saveWidgetData<String>(keyDate, ethiopianDateLabel),
        HomeWidget.saveWidgetData<String>(keyTitle, title),
        HomeWidget.saveWidgetData<String>(keySnksar, snksar),
        HomeWidget.saveWidgetData<String>('gitsawe_verse_text', verseText),
        HomeWidget.saveWidgetData<String>('gitsawe_verse_ref', verseRef),
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
      debugPrint('HomeWidgetService: Widget update signals sent');
    } catch (e, st) {
      // Widget refresh is best-effort; never let it crash the app.
      debugPrint('HomeWidgetService.updateWidget failed: $e\n$st');
    }
  }
}
