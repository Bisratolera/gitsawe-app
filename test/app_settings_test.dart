import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:gitsawe/services/app_settings.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await AppSettings.instance.load();
  });

  test('loads defaults', () {
    final s = AppSettings.instance;
    expect(s.notificationsEnabled, isTrue);
    expect(s.language, 'am');
    expect(s.reminderHour, 7);
    expect(s.reminderMinute, 0);
    expect(s.textScale, 1.0);
  });

  test('persists notification, language and reminder time', () async {
    final s = AppSettings.instance;
    await s.setNotificationsEnabled(false);
    await s.setLanguage('en');
    await s.setReminderTime(18, 30);

    SharedPreferences.setMockInitialValues({
      'notifications_enabled': false,
      'language': 'en',
      'reminder_hour': 18,
      'reminder_minute': 30,
    });
    await s.load();
    expect(s.notificationsEnabled, isFalse);
    expect(s.language, 'en');
    expect(s.reminderHour, 18);
    expect(s.reminderMinute, 30);
  });

  test('text scale is clamped', () async {
    await AppSettings.instance.setTextScale(5);
    expect(AppSettings.instance.textScale, AppSettings.maxTextScale);
    await AppSettings.instance.setTextScale(0.1);
    expect(AppSettings.instance.textScale, AppSettings.minTextScale);
  });
}
