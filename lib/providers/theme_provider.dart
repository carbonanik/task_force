import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:task_ring/theme/app_theme.dart';

enum AppThemeMode { light, dark, nature, ocean }

final themeProvider = NotifierProvider<ThemeNotifier, AppThemeMode>(() {
  return ThemeNotifier();
});

class ThemeNotifier extends Notifier<AppThemeMode> {
  static const _themeKey = 'theme_mode';
  late SharedPreferences _prefs;

  @override
  AppThemeMode build() {
    _loadTheme();
    return AppThemeMode.light;
  }

  Future<void> _loadTheme() async {
    _prefs = await SharedPreferences.getInstance();
    final themeIndex = _prefs.getInt(_themeKey) ?? 0;
    state = AppThemeMode.values[themeIndex];
  }

  Future<void> setTheme(AppThemeMode mode) async {
    state = mode;
    await _prefs.setInt(_themeKey, mode.index);
  }

  ThemeData getThemeData(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.light:
        return AppTheme.lightTheme;
      case AppThemeMode.dark:
        return AppTheme.darkTheme;
      case AppThemeMode.nature:
        return AppTheme.natureTheme;
      case AppThemeMode.ocean:
        return AppTheme.oceanTheme;
    }
  }
}
