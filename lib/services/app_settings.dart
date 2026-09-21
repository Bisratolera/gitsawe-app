import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSettings extends ChangeNotifier {
  AppSettings._();

  static final AppSettings instance = AppSettings._();

  static const _darkModeKey = 'dark_mode';
  static const _textScaleKey = 'text_scale';

  bool _isDarkMode = false;
  double _textScale = 1.0;

  bool get isDarkMode => _isDarkMode;
  double get textScale => _textScale;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool(_darkModeKey) ?? false;
    _textScale = prefs.getDouble(_textScaleKey) ?? 1.0;
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
}