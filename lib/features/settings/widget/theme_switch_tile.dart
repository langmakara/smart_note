import 'package:flutter/material.dart';

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
    return ListTile(
      leading: Icon(
        isDarkMode ? Icons.dark_mode : Icons.light_mode,
        color: Colors.purple,
      ),
      title: const Text("Dark Mode"),
      trailing: Switch(
        value: isDarkMode,
        activeColor: Colors.purple,
        onChanged: onThemeChanged,
      ),
    );
  }
}