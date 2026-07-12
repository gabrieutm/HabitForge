import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class ThemeProvider extends ChangeNotifier {
  static const _boxName = 'settings';
  static const _themeKey = 'isDarkMode';

  ThemeMode _mode = ThemeMode.light;
  ThemeMode get mode => _mode;

  ThemeProvider() {
    _load();
  }

  void _load() {
    final box = Hive.box(_boxName);
    final isDark = box.get(_themeKey, defaultValue: false) as bool;
    _mode = isDark ? ThemeMode.dark : ThemeMode.light;
  }

  Future<void> toggle() async {
    final box = Hive.box(_boxName);
    final newIsDark = _mode == ThemeMode.light;
    await box.put(_themeKey, newIsDark);
    _mode = newIsDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }
}
