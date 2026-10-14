import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// User preferences, persisted with shared_preferences.
///
/// This class only stores values. Anything that has side effects on the OS
/// (re-scheduling reminders, refreshing widgets) lives in `DailyRefresh`, which
/// the Settings screen calls after changing a value.
class AppSettings extends ChangeNotifier {
  AppSettings._();

  static final AppSettings instance = AppSettings._();

  static const _darkModeKey = 'dark_mode';
  static const _textScaleKey = 'text_scale';
  static const _notificationsKey = 'notifications_enabled';
  static const _languageKey = 'language';
  static const _reminderHourKey = 'reminder_hour';
  static const _reminderMinuteKey = 'reminder_minute';

  static const double minTextScale = 0.85;
  static const double maxTextScale = 1.4;

  bool _isDarkMode = false;
  double _textScale = 1.0;
  bool _notificationsEnabled = true;
  String _language = 'am';
  int _reminderHour = 7;
  int _reminderMinute = 0;

  bool get isDarkMode => _isDarkMode;
  double get textScale => _textScale;
  bool get notificationsEnabled => _notificationsEnabled;
  String get language => _language;
  bool get isEnglish => _language == 'en';
  int get reminderHour => _reminderHour;
  int get reminderMinute => _reminderMinute;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool(_darkModeKey) ?? false;
    _textScale = (prefs.getDouble(_textScaleKey) ?? 1.0)
        .clamp(minTextScale, maxTextScale)
        .toDouble();
    _notificationsEnabled = prefs.getBool(_notificationsKey) ?? true;
    _language = prefs.getString(_languageKey) ?? 'am';
    _reminderHour = (prefs.getInt(_reminderHourKey) ?? 7).clamp(0, 23);
    _reminderMinute = (prefs.getInt(_reminderMinuteKey) ?? 0).clamp(0, 59);
    notifyListeners();
  }

  Future<void> setDarkMode(bool value) async {
    _isDarkMode = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_darkModeKey, value);
  }

  Future<void> setTextScale(double value) async {
    _textScale = value.clamp(minTextScale, maxTextScale).toDouble();
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_textScaleKey, _textScale);
  }

  Future<void> setNotificationsEnabled(bool value) async {
    _notificationsEnabled = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notificationsKey, value);
  }

  Future<void> setReminderTime(int hour, int minute) async {
    _reminderHour = hour.clamp(0, 23);
    _reminderMinute = minute.clamp(0, 59);
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_reminderHourKey, _reminderHour);
    await prefs.setInt(_reminderMinuteKey, _reminderMinute);
  }

  Future<void> setLanguage(String value) async {
    _language = value == 'en' ? 'en' : 'am';
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, _language);
  }
}
