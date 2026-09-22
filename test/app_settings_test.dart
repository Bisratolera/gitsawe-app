import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:gitsawe/services/app_settings.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await AppSettings.instance.load();
  });

  test('loads default notification and language settings', () async {
    expect(AppSettings.instance.notificationsEnabled, isTrue);
    expect(AppSettings.instance.language, 'am');
  });

  test('updates notification and language preferences', () async {
    await AppSettings.instance.setNotificationsEnabled(false);
    await AppSettings.instance.setLanguage('en');

    expect(AppSettings.instance.notificationsEnabled, isFalse);
    expect(AppSettings.instance.language, 'en');
  });
}
