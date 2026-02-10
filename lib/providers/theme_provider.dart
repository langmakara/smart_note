import 'package:flutter/material.dart';
import '../models/app_settings_model.dart';
import '../services/settings_storage.dart';

class ThemeProvider extends ChangeNotifier {
  AppSettings _settings = AppSettings();

  AppSettings get settings => _settings;

  bool get isDarkMode => _settings.isDarkMode;
  Color get accentColor => _settings.accentColor;

  Future<void> init() async {
    _settings = await SettingsStorage.instance.load();
    notifyListeners();
  }

  void toggleDarkMode() {
    _settings.isDarkMode = !_settings.isDarkMode;
    _saveSettings();
    notifyListeners();
  }

  void setDarkMode(bool value) {
    _settings.isDarkMode = value;
    _settings.themeMode = value ? 'dark' : 'light';
    _saveSettings();
    notifyListeners();
  }

  void setAccentColor(Color color) {
    _settings.accentColor = color;
    _saveSettings();
    notifyListeners();
  }

  void updateSettings(AppSettings newSettings) {
    _settings = newSettings;
    _saveSettings();
    notifyListeners();
  }

  Future<void> _saveSettings() async {
    await SettingsStorage.instance.save(_settings);
  }

  ThemeData get themeData {
    return isDarkMode ? _darkTheme : _lightTheme;
  }

  Color get backgroundColor {
    return isDarkMode ? Colors.grey[900]! : Colors.grey[50]!;
  }

  Color get appBarColor {
    return isDarkMode ? Colors.grey[850]! : Colors.white;
  }

  Color get cardColor {
    return isDarkMode ? Colors.grey[800]! : Colors.white;
  }

  Color get textColor {
    return isDarkMode ? Colors.white : Colors.black87;
  }

  Color get subtitleColor {
    return isDarkMode ? Colors.grey[400]! : Colors.grey[600]!;
  }

  Color get dividerColor {
    return isDarkMode ? Colors.grey[700]! : Colors.grey[200]!;
  }

  Color get searchFillColor {
    return isDarkMode ? Colors.grey[800]! : Colors.grey[100]!;
  }

  Color get bottomNavBgColor {
    return isDarkMode ? Colors.grey[900]! : Colors.white;
  }

  Color get shadowColor {
    return isDarkMode
        ? Colors.black.withValues(alpha: 0.3)
        : Colors.black.withValues(alpha: 0.1);
  }

  ThemeData get lightTheme {
    return _lightTheme;
  }

  ThemeData get darkTheme {
    return _darkTheme;
  }

  ThemeData get _lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      primarySwatch: _getMaterialColor(accentColor),
      scaffoldBackgroundColor: Colors.grey[50],
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: IconThemeData(color: accentColor),
        titleTextStyle: TextStyle(
          color: accentColor,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: accentColor,
        unselectedItemColor: Colors.grey,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: accentColor,
      ),
      cardColor: Colors.white,
      dividerColor: Colors.grey[200],
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: Colors.black87),
        bodyMedium: TextStyle(color: Colors.black87),
        titleLarge: TextStyle(color: Colors.black87),
        titleMedium: TextStyle(color: Colors.black87),
      ),
    );
  }

  ThemeData get _darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primarySwatch: _getMaterialColor(accentColor),
      scaffoldBackgroundColor: Colors.grey[900],
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.grey[850],
        elevation: 1,
        iconTheme: IconThemeData(color: accentColor),
        titleTextStyle: TextStyle(
          color: accentColor,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.grey[900],
        selectedItemColor: accentColor,
        unselectedItemColor: Colors.grey[400],
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: accentColor,
      ),
      cardColor: Colors.grey[800],
      dividerColor: Colors.grey[700],
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: Colors.white),
        bodyMedium: TextStyle(color: Colors.white),
        titleLarge: TextStyle(color: Colors.white),
        titleMedium: TextStyle(color: Colors.white),
      ),
    );
  }

  MaterialColor _getMaterialColor(Color color) {
    final Map<int, Color> colorCodes = {
      50: color.withValues(alpha: 0.1),
      100: color.withValues(alpha: 0.2),
      200: color.withValues(alpha: 0.3),
      300: color.withValues(alpha: 0.4),
      400: color.withValues(alpha: 0.5),
      500: color,
      600: color.withValues(alpha: 0.7),
      700: color.withValues(alpha: 0.8),
      800: color.withValues(alpha: 0.9),
      900: color.withValues(alpha: 1.0),
    };
    return MaterialColor(color.toARGB32(), colorCodes);
  }
}
