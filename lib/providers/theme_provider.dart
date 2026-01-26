import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  void toggleDarkMode() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  void setDarkMode(bool value) {
    _isDarkMode = value;
    notifyListeners();
  }

  ThemeData get themeData {
    return _isDarkMode ? darkTheme : lightTheme;
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

  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primarySwatch: Colors.purple,
    scaffoldBackgroundColor: Colors.grey[50],
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.white,
      elevation: 1,
      iconTheme: IconThemeData(color: Colors.purple),
      titleTextStyle: TextStyle(
        color: Colors.purple,
        fontWeight: FontWeight.bold,
        fontSize: 20,
      ),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: Colors.purple,
      unselectedItemColor: Colors.grey,
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

  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primarySwatch: Colors.purple,
    scaffoldBackgroundColor: Colors.grey[900],
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.grey[850],
      elevation: 1,
      iconTheme: IconThemeData(color: Colors.purple),
      titleTextStyle: TextStyle(
        color: Colors.purple,
        fontWeight: FontWeight.bold,
        fontSize: 20,
      ),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: Colors.grey[900],
      selectedItemColor: Colors.purple,
      unselectedItemColor: Colors.grey[400],
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
