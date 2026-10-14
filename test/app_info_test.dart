import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:gitsawe/core/app_info.dart';

void main() {
  test('AppInfo matches the version in pubspec.yaml', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    final match = RegExp(r'^version:\s*(\d+\.\d+\.\d+)\+(\d+)\s*$', multiLine: true)
        .firstMatch(pubspec);
    expect(match, isNotNull, reason: 'pubspec.yaml has no "version: x.y.z+n" line');
    expect(AppInfo.version, match!.group(1));
    expect(AppInfo.buildNumber, int.parse(match.group(2)!));
  });
}
