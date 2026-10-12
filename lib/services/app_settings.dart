import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'notification_service.dart';

class AppSettings extends ChangeNotifier {
  AppSettings._();

  static final AppSettings instance = AppSettings._();

  static const _darkModeKey = 'dark_mode';
  static const _textScaleKey = 'text_scale';
  static const _notificationsKey = 'notifications_enabled';
  static const _languageKey = 'language';

  bool _isDarkMode = false;
  double _textScale = 1.0;
  bool _notificationsEnabled = true;
  String _language = 'am';

  bool get isDarkMode => _isDarkMode;
  double get textScale => _textScale;
  bool get notificationsEnabled => _notificationsEnabled;
  String get language => _language;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool(_darkModeKey) ?? false;
    _textScale = prefs.getDouble(_textScaleKey) ?? 1.0;
    _notificationsEnabled = prefs.getBool(_notificationsKey) ?? true;
    _language = prefs.getString(_languageKey) ?? 'am';
  }

  Future<void> setDarkMode(bool value) async {
    _isDarkMode = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_darkModeKey, value);
  }

  Future<void> setTextScale(double value) async {
    _textScale = value.clamp(0.85, 1.4);
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_textScaleKey, _textScale);
  }

  Future<void> setNotificationsEnabled(bool value) async {
    _notificationsEnabled = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notificationsKey, value);

    if (value) {
      await NotificationService.instance.scheduleDailyGitsaweNotification(
        hour: 7,
        minute: 0,
        readingProvider: (targetDate) => null,
      );
    } else {
      await NotificationService.instance.cancelAll();
    }
  }

  Future<void> setLanguage(String value) async {
    _language = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, value);
  }
}