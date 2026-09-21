// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:gitsawe/main.dart';
import 'package:gitsawe/screen/daily_gitsawe_screen.dart';
import 'package:gitsawe/services/gitsawe_service.dart';

void main() {
  testWidgets('Daily Gitsawe screen lists entries and opens the details view', (WidgetTester tester) async {
    await GitsaweService.instance.load();
    final firstEntry = GitsaweService.instance.allDaily.first;

    await tester.pumpWidget(
      const MaterialApp(
        home: DailyGitsaweScreen(),
      ),
    );

    expect(find.text('Daily Gitsawe'), findsOneWidget);
    expect(find.text(firstEntry.title), findsOneWidget);

    await tester.tap(find.text(firstEntry.title));
    await tester.pumpAndSettle();

    expect(find.text(firstEntry.title), findsWidgets);
  });

  testWidgets('App loads without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(const GitsaweApp(onboardingCompleted: true));
    expect(find.text('ዛሬ'), findsWidgets);
  });
}
