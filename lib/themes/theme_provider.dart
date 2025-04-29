import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:photo_album/themes/dark_mode.dart';
import 'package:photo_album/themes/light_mode.dart';
import 'package:shared_preferences/shared_preferences.dart';


class ThemeProvider extends ChangeNotifier {
  late ThemeData _themeData = darkMode;

  ThemeProvider() {
    _initTheme();
  }

  Future<void> _initTheme() async {
    final saved = await PreferencesTheme.loadTheme();

    switch (saved) {
      case "light":
        _themeData = lightMode;
        break;
      case "dark":
        _themeData = darkMode;
        break;
      default:
        final brightness = SchedulerBinding.instance.platformDispatcher.platformBrightness;
        _themeData = (brightness == Brightness.dark) ? darkMode : lightMode;
        break;
    }

    notifyListeners();
  }

  ThemeData get themeData => _themeData;

  bool get isDarkMode => _themeData == darkMode;

  set themeData(ThemeData themeData){
    _themeData = themeData;
    notifyListeners();
  }

  void toggleTheme() {
    themeData = isDarkMode ? lightMode : darkMode;
  }

  ThemeData getThemeData() {
    return themeData;
  }

  Future<String> getCurrentTheme() async {
    return await PreferencesTheme.loadTheme();
  }

  void setThemeData(String theme) async {
    switch (theme){
      case "light":
      themeData = lightMode;
      break;

      case "dark":
      themeData = darkMode;
      break;

      case "device":
      themeData = SchedulerBinding.instance.platformDispatcher.platformBrightness == Brightness.dark
        ? darkMode
        : lightMode;
      break;
    }

    // currentTheme = theme;
    await PreferencesTheme.saveTheme(theme);
    notifyListeners();
  }

}

class PreferencesTheme {
  static const _themePreference = 'theme_preference';

  static Future<void> saveTheme(String themeData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themePreference, themeData);
  }

  static Future<String> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_themePreference) ?? "device";
  }
}