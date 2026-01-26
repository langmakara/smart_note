import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/app_settings_model.dart';
import '../../../providers/theme_provider.dart';

class AppearanceSettingsPage extends StatefulWidget {
  final AppSettings settings;
  final Function(AppSettings) onSettingsChanged;

  const AppearanceSettingsPage({
    super.key,
    required this.settings,
    required this.onSettingsChanged,
  });

  @override
  State<AppearanceSettingsPage> createState() => _AppearanceSettingsPageState();
}

class _AppearanceSettingsPageState extends State<AppearanceSettingsPage> {
  late AppSettings _settings;

  @override
  void initState() {
    super.initState();
    _settings = widget.settings;
  }

  void _updateSettings(AppSettings newSettings) {
    setState(() => _settings = newSettings);
    widget.onSettingsChanged(newSettings);
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return Scaffold(
      backgroundColor: themeProvider.backgroundColor,
      appBar: AppBar(
        backgroundColor: themeProvider.appBarColor,
        elevation: 1,
        title: const Text(
          'Appearance',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.purple,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Theme Mode
          Container(
            padding: const EdgeInsets.all(16),
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
                Text(
                  'Theme Mode',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: themeProvider.textColor,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildThemeOption(
                        icon: Icons.light_mode,
                        label: 'Light',
                        isSelected: _settings.themeMode == 'light',
                        onTap: () {
                          _updateSettings(_settings.copyWith(
                            themeMode: 'light',
                            isDarkMode: false,
                          ));
                          themeProvider.setDarkMode(false);
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildThemeOption(
                        icon: Icons.dark_mode,
                        label: 'Dark',
                        isSelected: _settings.themeMode == 'dark',
                        onTap: () {
                          _updateSettings(_settings.copyWith(
                            themeMode: 'dark',
                            isDarkMode: true,
                          ));
                          themeProvider.setDarkMode(true);
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildThemeOption(
                        icon: Icons.computer,
                        label: 'System',
                        isSelected: _settings.themeMode == 'system',
                        onTap: () {
                          _updateSettings(_settings.copyWith(
                            themeMode: 'system',
                          ));
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Display Options
          Container(
            padding: const EdgeInsets.all(16),
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
                Text(
                  'Display Options',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: themeProvider.textColor,
                  ),
                ),
                const SizedBox(height: 12),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.grid_on, color: Colors.purple),
                  title: Text(
                    'Show Grid Lines',
                    style: TextStyle(color: themeProvider.textColor),
                  ),
                  subtitle: Text(
                    'Display grid lines in calendar',
                    style: TextStyle(color: themeProvider.subtitleColor),
                  ),
                  trailing: Switch(
                    value: _settings.showGridLines,
                    onChanged: (value) {
                      _updateSettings(_settings.copyWith(showGridLines: value));
                    },
                    activeColor: Colors.purple,
                  ),
                ),
                Divider(color: themeProvider.dividerColor),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.zoom_out, color: Colors.blue),
                  title: Text(
                    'Compact Mode',
                    style: TextStyle(color: themeProvider.textColor),
                  ),
                  subtitle: Text(
                    'Smaller cards and tighter spacing',
                    style: TextStyle(color: themeProvider.subtitleColor),
                  ),
                  trailing: Switch(
                    value: _settings.compactMode,
                    onChanged: (value) {
                      _updateSettings(_settings.copyWith(compactMode: value));
                    },
                    activeColor: Colors.blue,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Animation Settings
          Container(
            padding: const EdgeInsets.all(16),
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
                Text(
                  'Animations',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: themeProvider.textColor,
                  ),
                ),
                const SizedBox(height: 12),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.animation, color: Colors.green),
                  title: Text(
                    'Reduce Animations',
                    style: TextStyle(color: themeProvider.textColor),
                  ),
                  subtitle: Text(
                    'Minimize motion effects',
                    style: TextStyle(color: themeProvider.subtitleColor),
                  ),
                  trailing: Switch(
                    value: false,
                    onChanged: (value) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(value ? 'Animations reduced' : 'Animations enabled'),
                          backgroundColor: Colors.green,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      );
                    },
                    activeColor: Colors.green,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeOption({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.purple : Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
          border: isSelected
              ? Border.all(color: Colors.purple, width: 2)
              : Border.all(color: Colors.grey[200]!),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 24,
              color: isSelected ? Colors.white : Colors.grey,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
