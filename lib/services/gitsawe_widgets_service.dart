import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';
import '../models/daily_gitsawe.dart';
import 'gitsawe_service.dart';

/// Background callback for widget interaction (e.g. refresh button on Verse widget)
@pragma('vm:entry-point')
Future<void> backgroundWidgetCallback(Uri? uri) async {
  if (uri?.host == 'refresh_verse' || uri?.path == '/refresh') {
    debugPrint('Background widget callback triggered for verse refresh');
  }
}

/// Service managing GitsaweReadingWidgetProvider and GitsaweVerseWidgetProvider from Flutter.
class GitsaweWidgetsService {
  GitsaweWidgetsService._internal();
  static final GitsaweWidgetsService instance = GitsaweWidgetsService._internal();

  static const String readingWidgetName = 'GitsaweReadingWidgetProvider';
  static const String verseWidgetName = 'GitsaweVerseWidgetProvider';
  static const String iOSWidgetKind = 'GitsaweWidget';

  /// Initializes widget background interaction callbacks if supported
  Future<void> init() async {
    if (!Platform.isAndroid && !Platform.isIOS) return;
    try {
      await HomeWidget.registerInteractivityCallback(backgroundWidgetCallback);
    } catch (e, st) {
      debugPrint('GitsaweWidgetsService.init failed: $e\n$st');
    }
  }

  /// Updates the Reading (Feast/Saint) Widget specifically
  Future<void> updateReadingWidget({
    required String dateLabel,
    required String title,
    required String snksar,
  }) async {
    if (!Platform.isAndroid && !Platform.isIOS) return;
    try {
      await Future.wait([
        HomeWidget.saveWidgetData<String>('gitsawe_date', dateLabel),
        HomeWidget.saveWidgetData<String>('gitsawe_title', title),
        HomeWidget.saveWidgetData<String>('gitsawe_snksar', snksar),
      ]);
      await HomeWidget.updateWidget(
        androidName: readingWidgetName,
        iOSName: iOSWidgetKind,
      );
      debugPrint('GitsaweWidgetsService: Reading widget updated successfully.');
    } catch (e, st) {
      debugPrint('GitsaweWidgetsService.updateReadingWidget failed: $e\n$st');
    }
  }

  /// Updates the Verse (Msbak) Widget specifically
  Future<void> updateVerseWidget({
    required String verseText,
    required String verseRef,
  }) async {
    if (!Platform.isAndroid && !Platform.isIOS) return;
    try {
      await Future.wait([
        HomeWidget.saveWidgetData<String>('gitsawe_verse_text', verseText),
        HomeWidget.saveWidgetData<String>('gitsawe_verse_ref', verseRef),
      ]);
      await HomeWidget.updateWidget(
        androidName: verseWidgetName,
        iOSName: iOSWidgetKind,
      );
      debugPrint('GitsaweWidgetsService: Verse widget updated successfully.');
    } catch (e, st) {
      debugPrint('GitsaweWidgetsService.updateVerseWidget failed: $e\n$st');
    }
  }

  /// Updates both widgets along with the overall home widget data
  Future<void> updateAllWidgets({
    required String ethiopianDateLabel,
    DailyGitsawe? reading,
  }) async {
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
        verseRef = v.verse.display.isNotEmpty
            ? '${v.verse.bookTitle} ${v.verse.display}'
            : v.verse.bookTitle;
      }
    }

    await updateReadingWidget(
      dateLabel: ethiopianDateLabel,
      title: title,
      snksar: snksar,
    );

    await updateVerseWidget(
      verseText: verseText,
      verseRef: verseRef,
    );
  }
}
