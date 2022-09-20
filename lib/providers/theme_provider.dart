import 'package:flutter/material.dart';
import 'package:irish_bus_refresh/widgets/theme_switcher.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  ThemeMode selectedThemeMode;

  

  ThemeProvider(_initialTheme) {
    print("theme provider initial theme: ${_initialTheme.toString()}");
   selectedThemeMode = _initialTheme;
  }

  setSelectedThemeMode(ThemeMode _themeMode) {
    selectedThemeMode = _themeMode;
    _saveThemePreferences(_themeMode);
    notifyListeners();
  }

  _saveThemePreferences(themeMode) async {

    print("saving theme mode: ${themeMode.toString()}");
    
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (themeMode == appThemes[0].mode) {
      prefs.setString("savedTheme", "Light");
    }
    if (themeMode == appThemes[1].mode) {
      prefs.setString("savedTheme", "Dark");
    }
    if (themeMode == appThemes[2].mode) {
      prefs.setString("savedTheme", "Auto");
    }
  }
}
