import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';
import '../models/daily_gitsawe.dart';
import 'home_widget_service.dart';

/// Background callback for widget interaction (reserved for interactive widgets).
@pragma('vm:entry-point')
Future<void> backgroundWidgetCallback(Uri? uri) async {
  debugPrint('Background widget callback: $uri');
}

/// Thin facade used by `main.dart`; all widget data is written by
/// [HomeWidgetService] so the two never disagree.
class GitsaweWidgetsService {
  GitsaweWidgetsService._internal();
  static final GitsaweWidgetsService instance = GitsaweWidgetsService._internal();

  /// Initializes widget background interaction callbacks if supported.
  Future<void> init() async {
    if (!Platform.isAndroid && !Platform.isIOS) return;
    try {
      await HomeWidget.registerInteractivityCallback(backgroundWidgetCallback);
    } catch (e, st) {
      debugPrint('GitsaweWidgetsService.init failed: $e\n$st');
    }
  }

  /// Refreshes every widget with the given day's reading.
  Future<void> updateAllWidgets({
    required String ethiopianDateLabel,
    DailyGitsawe? reading,
  }) {
    return HomeWidgetService.instance.updateWidget(
      ethiopianDateLabel: ethiopianDateLabel,
      reading: reading,
    );
  }
}
