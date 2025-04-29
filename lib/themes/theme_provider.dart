import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:photo_album/themes/dark_mode.dart';
import 'package:photo_album/themes/light_mode.dart';


class ThemeProvider extends ChangeNotifier {
  ThemeData _themeData;
  var currentTheme = "device";

  ThemeProvider()
  : _themeData = SchedulerBinding.instance.platformDispatcher.platformBrightness == Brightness.dark
    ? darkMode
    : lightMode;

  ThemeData get themeData => _themeData;

  bool get isDarkMode => _themeData == darkMode;

  set themeData(ThemeData themeData){
    _themeData = themeData;
    notifyListeners();
  }

  void toggleTheme() {
    themeData = isDarkMode ? lightMode : darkMode;
  }

  String getCurrentTheme(){
    return currentTheme;
  }

  void setThemeData(String theme){
    switch (theme){
      case "light":
      themeData = lightMode;
      currentTheme = theme;

      case "dark":
      themeData = darkMode;
      currentTheme = theme;

      case "device":
      themeData = SchedulerBinding.instance.platformDispatcher.platformBrightness == Brightness.dark
        ? darkMode
        : lightMode;
      currentTheme = theme;

    }
  }

}