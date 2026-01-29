import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;
  Color _accentColor = Colors.purple;

  bool get isDarkMode => _isDarkMode;
  Color get accentColor => _accentColor;

  void toggleDarkMode() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  void setDarkMode(bool value) {
    _isDarkMode = value;
    notifyListeners();
  }

  void setAccentColor(Color color) {
    _accentColor = color;
    notifyListeners();
  }

  ThemeData get themeData {
    return _isDarkMode ? _darkTheme : _lightTheme;
  }

  Color get backgroundColor {
    return _isDarkMode ? Colors.grey[900]! : Colors.grey[50]!;
  }

  Color get appBarColor {
    return _isDarkMode ? Colors.grey[850]! : Colors.white;
  }

  Color get cardColor {
    return _isDarkMode ? Colors.grey[800]! : Colors.white;
  }

  Color get textColor {
    return _isDarkMode ? Colors.white : Colors.black87;
  }

  Color get subtitleColor {
    return _isDarkMode ? Colors.grey[400]! : Colors.grey[600]!;
  }

  Color get dividerColor {
    return _isDarkMode ? Colors.grey[700]! : Colors.grey[200]!;
  }

  Color get searchFillColor {
    return _isDarkMode ? Colors.grey[800]! : Colors.grey[100]!;
  }

  Color get bottomNavBgColor {
    return _isDarkMode ? Colors.grey[900]! : Colors.white;
  }

  Color get shadowColor {
    return _isDarkMode ? Colors.black.withOpacity(0.3) : Colors.black.withOpacity(0.1);
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
      primarySwatch: _getMaterialColor(_accentColor),
      scaffoldBackgroundColor: Colors.grey[50],
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: IconThemeData(color: _accentColor),
        titleTextStyle: TextStyle(
          color: _accentColor,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: _accentColor,
        unselectedItemColor: Colors.grey,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: _accentColor,
      ),
      cardColor: Colors.white,
      dividerColor: Colors.grey[200],
      textTheme: TextTheme(
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
      primarySwatch: _getMaterialColor(_accentColor),
      scaffoldBackgroundColor: Colors.grey[900],
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.grey[850],
        elevation: 1,
        iconTheme: IconThemeData(color: _accentColor),
        titleTextStyle: TextStyle(
          color: _accentColor,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.grey[900],
        selectedItemColor: _accentColor,
        unselectedItemColor: Colors.grey[400],
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: _accentColor,
      ),
      cardColor: Colors.grey[800],
      dividerColor: Colors.grey[700],
      textTheme: TextTheme(
        bodyLarge: TextStyle(color: Colors.white),
        bodyMedium: TextStyle(color: Colors.white),
        titleLarge: TextStyle(color: Colors.white),
        titleMedium: TextStyle(color: Colors.white),
      ),
    );
  }

  MaterialColor _getMaterialColor(Color color) {
    final Map<int, Color> colorCodes = {
      50: color.withOpacity(0.1),
      100: color.withOpacity(0.2),
      200: color.withOpacity(0.3),
      300: color.withOpacity(0.4),
      400: color.withOpacity(0.5),
      500: color,
      600: color.withOpacity(0.7),
      700: color.withOpacity(0.8),
      800: color.withOpacity(0.9),
      900: color.withOpacity(1.0),
    };
    return MaterialColor(color.value, colorCodes);
  }
}
