import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';

import '../models/daily_gitsawe.dart';

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

  /// Must match the class name of GitsaweWidgetProvider.kt.
  static const String _androidWidgetName = 'GitsaweWidgetProvider';

  /// Must match the `kind:` string used in the iOS WidgetKit extension.
  static const String _iOSWidgetKind = 'GitsaweWidget';

  // Keys shared with the native widget code — keep these in sync with
  // GitsaweWidgetProvider.kt and the iOS widget's timeline provider.
  static const String keyDate = 'gitsawe_date';
  static const String keyTitle = 'gitsawe_title';
  static const String keySnksar = 'gitsawe_snksar';
  static const String keyUpdatedAt = 'gitsawe_updated_at';

  /// Writes today's reading into widget storage and asks the OS to redraw
  /// any placed widgets. Safe to call often — it's cheap and never throws
  /// (a widget failing to refresh shouldn't take down the app).
  Future<void> updateWidget({
    required String ethiopianDateLabel,
    DailyGitsawe? reading,
  }) async {
    try {
      debugPrint('HomeWidgetService: Updating widget with $ethiopianDateLabel');
      final title = reading?.title ?? 'ዛሬ ንባብ አልተገኘም';
      final snksar = (reading != null && reading.snksar.isNotEmpty)
          ? reading.snksar.first.amharic
          : 'ለዛሬ ስንክሳር የለም';

      await Future.wait([
        HomeWidget.saveWidgetData<String>(keyDate, ethiopianDateLabel),
        HomeWidget.saveWidgetData<String>(keyTitle, title),
        HomeWidget.saveWidgetData<String>(keySnksar, snksar),
        HomeWidget.saveWidgetData<String>(
          keyUpdatedAt,
          DateTime.now().toIso8601String(),
        ),
      ]);

      await HomeWidget.updateWidget(
        androidName: _androidWidgetName,
        iOSName: _iOSWidgetKind,
      );
      debugPrint('HomeWidgetService: Widget update signals sent');
    } catch (e, st) {
      // Widget refresh is best-effort; never let it crash the app.
      debugPrint('HomeWidgetService.updateWidget failed: $e\n$st');
    }
  }
}
