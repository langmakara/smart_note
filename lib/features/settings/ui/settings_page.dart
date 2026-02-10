import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/theme_provider.dart';
import '../widget/theme_switch_tile.dart';
import 'appearance_settings_page.dart';
import 'color_settings_page.dart';
import 'language_settings_page.dart';
import 'notification_settings_page.dart';
import 'data_management_page.dart';

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
              Divider(color: themeProvider.dividerColor),
              ListTile(
                leading: Icon(Icons.palette, color: themeProvider.accentColor),
                title: Text(
                  "Appearance Settings",
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
                      builder: (context) => AppearanceSettingsPage(
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
              Divider(color: themeProvider.dividerColor),
              ListTile(
                leading: Icon(
                  Icons.notifications,
                  color: themeProvider.accentColor,
                ),
                title: Text(
                  "Notifications",
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
                      builder: (context) => NotificationSettingsPage(
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
          // About Section
          _buildSection(
            title: "About",
            themeProvider: themeProvider,
            children: [
              ListTile(
                leading: Icon(
                  Icons.info_outline,
                  color: themeProvider.accentColor,
                ),
                title: Text(
                  "About Smart Note",
                  style: TextStyle(color: themeProvider.textColor),
                ),
                trailing: Icon(
                  Icons.chevron_right,
                  color: themeProvider.subtitleColor,
                ),
                onTap: () {
                  showAboutDialog(
                    context: context,
                    applicationName: "Smart Notes",
                    applicationVersion: "1.0.0",
                    applicationIcon: Icon(
                      Icons.note_alt,
                      size: 48,
                      color: themeProvider.accentColor,
                    ),
                    children: [
                      Text(
                        "A beautiful and simple note-taking app built with Flutter.",
                        style: TextStyle(color: themeProvider.textColor),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "© 2025 Smart Notes. All rights reserved.",
                        style: TextStyle(color: themeProvider.subtitleColor),
                      ),
                    ],
                  );
                },
              ),
              Divider(color: themeProvider.dividerColor),
              ListTile(
                leading: Icon(Icons.storage, color: themeProvider.accentColor),
                title: Text(
                  "Data Management",
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
                      builder: (context) => DataManagementPage(
                        settings: settings,
                        onSettingsChanged: (newSettings) {
                          themeProvider.updateSettings(newSettings);
                        },
                      ),
                    ),
                  );
                },
              ),
              Divider(color: themeProvider.dividerColor),
              ListTile(
                leading: Icon(
                  Icons.star_border,
                  color: themeProvider.accentColor,
                ),
                title: Text(
                  "Rate the App",
                  style: TextStyle(color: themeProvider.textColor),
                ),
                trailing: Icon(
                  Icons.chevron_right,
                  color: themeProvider.subtitleColor,
                ),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Thanks for your support! ⭐'),
                      backgroundColor: Colors.amber,
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
                leading: Icon(Icons.feedback, color: themeProvider.accentColor),
                title: Text(
                  "Send Feedback",
                  style: TextStyle(color: themeProvider.textColor),
                ),
                trailing: Icon(
                  Icons.chevron_right,
                  color: themeProvider.subtitleColor,
                ),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Feedback form coming soon!'),
                      backgroundColor: Colors.green,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
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
