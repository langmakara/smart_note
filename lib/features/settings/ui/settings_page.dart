import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/theme_provider.dart';
import '../widget/theme_switch_tile.dart';
import 'color_settings_page.dart';
import 'language_settings_page.dart';
import 'security_settings_page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final settings = themeProvider.settings;

    return Scaffold(
      backgroundColor: themeProvider.backgroundColor,
      appBar: AppBar(
        backgroundColor: themeProvider.appBarColor,
        elevation: 1,
        title: Text(
          "Settings",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: themeProvider.accentColor,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Appearance Section
          _buildSection(
            title: "Appearance",
            themeProvider: themeProvider,
            children: [
              ThemeSwitchTile(
                isDarkMode: themeProvider.isDarkMode,
                onThemeChanged: (value) {
                  themeProvider.setDarkMode(value);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        value ? 'Dark mode enabled' : 'Light mode enabled',
                      ),
                      backgroundColor: themeProvider.accentColor,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  );
                },
              ),
              Divider(color: themeProvider.dividerColor),
              ListTile(
                leading: Icon(Icons.color_lens, color: settings.accentColor),
                title: Text(
                  "Accent Color",
                  style: TextStyle(color: themeProvider.textColor),
                ),
                trailing: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: settings.accentColor,
                    shape: BoxShape.circle,
                  ),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ColorSettingsPage(
                        settings: settings,
                        onSettingsChanged: (newSettings) {
                          themeProvider.updateSettings(newSettings);
                        },
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Preferences Section
          _buildSection(
            title: "Preferences",
            themeProvider: themeProvider,
            children: [
              ListTile(
                leading: Icon(Icons.language, color: themeProvider.accentColor),
                title: Text(
                  "Language",
                  style: TextStyle(color: themeProvider.textColor),
                ),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: settings.accentColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    settings.language,
                    style: TextStyle(
                      color: settings.accentColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LanguageSettingsPage(
                        settings: settings,
                        onSettingsChanged: (newSettings) {
                          themeProvider.updateSettings(newSettings);
                        },
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Security Section
          _buildSection(
            title: "Security",
            themeProvider: themeProvider,
            children: [
              ListTile(
                leading: Icon(Icons.lock, color: themeProvider.accentColor),
                title: Text(
                  "Numeric Password",
                  style: TextStyle(color: themeProvider.textColor),
                ),
                trailing: Icon(
                  Icons.chevron_right,
                  color: themeProvider.subtitleColor,
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SecuritySettingsPage(),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
    required ThemeProvider themeProvider,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: themeProvider.cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: themeProvider.shadowColor,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: themeProvider.textColor,
              ),
            ),
          ),
          ...children,
        ],
      ),
    );
  }
}
