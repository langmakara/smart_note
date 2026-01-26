import 'package:flutter/material.dart';
import '../../../models/app_settings_model.dart';
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
  AppSettings _settings = AppSettings();

  void _updateSettings(AppSettings newSettings) {
    setState(() => _settings = newSettings);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: const Text(
          "Settings",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.purple,
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
            children: [
              ThemeSwitchTile(
                isDarkMode: _settings.isDarkMode,
                onThemeChanged: (value) {
                  _updateSettings(_settings.copyWith(isDarkMode: value));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        value ? 'Dark mode enabled' : 'Light mode enabled',
                      ),
                      backgroundColor: Colors.purple,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  );
                },
              ),
              const Divider(height: 1),
              ListTile(
                leading: Icon(Icons.color_lens, color: _settings.accentColor),
                title: const Text("Accent Color"),
                trailing: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: _settings.accentColor,
                    shape: BoxShape.circle,
                  ),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ColorSettingsPage(
                        settings: _settings,
                        onSettingsChanged: _updateSettings,
                      ),
                    ),
                  );
                },
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.palette, color: Colors.purple),
                title: const Text("Appearance Settings"),
                trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AppearanceSettingsPage(
                        settings: _settings,
                        onSettingsChanged: _updateSettings,
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
            children: [
              ListTile(
                leading: const Icon(Icons.language, color: Colors.purple),
                title: const Text("Language"),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _settings.accentColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    _settings.language,
                    style: TextStyle(
                      color: _settings.accentColor,
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
                        settings: _settings,
                        onSettingsChanged: _updateSettings,
                      ),
                    ),
                  );
                },
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.notifications, color: Colors.purple),
                title: const Text("Notifications"),
                trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => NotificationSettingsPage(
                        settings: _settings,
                        onSettingsChanged: _updateSettings,
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
            children: [
              ListTile(
                leading: const Icon(Icons.info_outline, color: Colors.purple),
                title: const Text("About Smart Note"),
                trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                onTap: () {
                  showAboutDialog(
                    context: context,
                    applicationName: "Smart Notes",
                    applicationVersion: "1.0.0",
                    applicationIcon: const Icon(
                      Icons.note_alt,
                      size: 48,
                      color: Colors.purple,
                    ),
                    children: [
                      const Text(
                        "A beautiful and simple note-taking app built with Flutter.",
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "© 2025 Smart Notes. All rights reserved.",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  );
                },
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.storage, color: Colors.purple),
                title: const Text("Data Management"),
                trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DataManagementPage(
                        settings: _settings,
                        onSettingsChanged: _updateSettings,
                      ),
                    ),
                  );
                },
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.star_border, color: Colors.purple),
                title: const Text("Rate the App"),
                trailing: const Icon(Icons.chevron_right, color: Colors.grey),
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
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.feedback, color: Colors.purple),
                title: const Text("Send Feedback"),
                trailing: const Icon(Icons.chevron_right, color: Colors.grey),
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
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
          ),
          ...children,
        ],
      ),
    );
  }
}