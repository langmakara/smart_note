import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/theme_provider.dart';

class ThemeSwitchTile extends StatelessWidget {
  final bool isDarkMode;
  final ValueChanged<bool> onThemeChanged;

  const ThemeSwitchTile({
    super.key,
    required this.isDarkMode,
    required this.onThemeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return ListTile(
      leading: Icon(
        isDarkMode ? Icons.dark_mode : Icons.light_mode,
        color: themeProvider.accentColor,
      ),
      title: const Text("Dark Mode"),
      trailing: Switch(
        value: isDarkMode,
        activeColor: themeProvider.accentColor,
        onChanged: onThemeChanged,
      ),
    );
  }
}