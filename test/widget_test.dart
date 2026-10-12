import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:gitsawe/main.dart';
import 'package:gitsawe/services/app_settings.dart';
import 'package:gitsawe/services/gitsawe_service.dart';

void main() {
  setUp(() async {
    // 1. Mock shared preferences and load app configurations
    SharedPreferences.setMockInitialValues({});
    await AppSettings.instance.load();

    // 2. Pre-load local asset data so the UI doesn't hang on a loading state
    await GitsaweService.instance.load(allowRemote: false);
  });

  testWidgets('GitsaweApp renders home view successfully smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const GitsaweApp(onboardingCompleted: true));

    // Wait for any animations, loading states, or future builders to fully settle
    await tester.pumpAndSettle();

    // Verify your actual application successfully loaded instead of checking for "0".
    // TODO: Replace 'Home' with a word, title, or icon that actually exists on your main screen.
    // Example for localization check: find.text('ግጻዌ') or find.text('Gitsawe')
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
