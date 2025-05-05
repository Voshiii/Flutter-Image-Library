import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:photo_album/themes/dark_mode.dart';
import 'package:photo_album/themes/light_mode.dart';
import 'package:shared_preferences/shared_preferences.dart';


class ThemeProvider extends ChangeNotifier with WidgetsBindingObserver {
  late ThemeData _themeData = darkMode;
  String _currentTheme = "device";

  ThemeProvider() {
    WidgetsBinding.instance.addObserver(this);
    _initTheme();
  }

  Future<void> _initTheme() async {
    final saved = await PreferencesTheme.loadTheme();

    setThemeData(saved);

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
      _currentTheme = "light";
      break;

      case "dark":
      themeData = darkMode;
      _currentTheme = "dark";
      break;

      case "device":
      themeData = SchedulerBinding.instance.platformDispatcher.platformBrightness == Brightness.dark
        ? darkMode
        : lightMode;
        _currentTheme = "device";
      break;
    }

    // currentTheme = theme;
    await PreferencesTheme.saveTheme(theme);
    notifyListeners();
  }
  

  void _setThemeFromSystem() {
    final brightness = SchedulerBinding.instance.platformDispatcher.platformBrightness;
    _themeData = (brightness == Brightness.dark) ? darkMode : lightMode;
  }

  @override
  void didChangePlatformBrightness() async {
    if (_currentTheme == "device") {
      _setThemeFromSystem();
      notifyListeners();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
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