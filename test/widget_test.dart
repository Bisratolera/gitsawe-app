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
    // Build the app and give the home screen a couple of frames to render.
    await tester.pumpWidget(const GitsaweApp(onboardingCompleted: true));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Verify the app's actual home screen loads and shows the expected title.
    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.text('የዕለቱ ግጻዌ'), findsOneWidget);
  });
}
