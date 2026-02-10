import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/app_settings_model.dart';
import '../../../providers/theme_provider.dart';

class NotificationSettingsPage extends StatefulWidget {
  final AppSettings settings;
  final Function(AppSettings) onSettingsChanged;

  const NotificationSettingsPage({
    super.key,
    required this.settings,
    required this.onSettingsChanged,
  });

  @override
  State<NotificationSettingsPage> createState() =>
      _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage> {
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

  Future<void> _selectReminderTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: int.parse(_settings.reminderTime.split(':')[0]),
        minute: int.parse(_settings.reminderTime.split(':')[1]),
      ),
    );
    if (time != null) {
      final timeString =
          '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
      _updateSettings(_settings.copyWith(reminderTime: timeString));
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      backgroundColor: themeProvider.backgroundColor,
      appBar: AppBar(
        backgroundColor: themeProvider.appBarColor,
        elevation: 1,
        title: Text(
          'Notification Settings',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: themeProvider.accentColor,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Main Notifications Toggle
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
            child: Row(
              children: [
                Icon(
                  _settings.notificationsEnabled
                      ? Icons.notifications_active
                      : Icons.notifications_off,
                  color: _settings.notificationsEnabled
                      ? themeProvider.accentColor
                      : themeProvider.subtitleColor,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Notifications',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: themeProvider.textColor,
                        ),
                      ),
                      Text(
                        _settings.notificationsEnabled ? 'Enabled' : 'Disabled',
                        style: TextStyle(
                          fontSize: 13,
                          color: themeProvider.subtitleColor,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: _settings.notificationsEnabled,
                  onChanged: (value) {
                    _updateSettings(
                      _settings.copyWith(notificationsEnabled: value),
                    );
                  },
                  activeThumbColor: themeProvider.accentColor,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Notification Types
          if (_settings.notificationsEnabled) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Notification Types',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(Icons.event, color: Colors.green[700]),
                    title: const Text('Event Reminders'),
                    subtitle: const Text('Get notified before events'),
                    trailing: Switch(
                      value: _settings.eventReminders,
                      onChanged: (value) {
                        _updateSettings(
                          _settings.copyWith(eventReminders: value),
                        );
                      },
                      activeThumbColor: themeProvider.accentColor,
                    ),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(Icons.note, color: Colors.blue[700]),
                    title: const Text('Note Reminders'),
                    subtitle: const Text('Reminders for pinned notes'),
                    trailing: Switch(
                      value: _settings.noteReminders,
                      onChanged: (value) {
                        _updateSettings(
                          _settings.copyWith(noteReminders: value),
                        );
                      },
                      activeThumbColor: themeProvider.accentColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Reminder Time
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Default Reminder Time',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      Icons.access_time,
                      color: themeProvider.accentColor,
                    ),
                    title: const Text('Reminder Time'),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: themeProvider.accentColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _settings.reminderTime,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: themeProvider.accentColor,
                        ),
                      ),
                    ),
                    onTap: _selectReminderTime,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Sound & Vibration
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Sound & Vibration',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.volume_up, color: Colors.orange),
                    title: const Text('Notification Sound'),
                    trailing: const Icon(
                      Icons.chevron_right,
                      color: Colors.grey,
                    ),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Sound selection coming soon!'),
                          backgroundColor: Colors.orange,
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
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.vibration, color: Colors.red),
                    title: const Text('Vibration'),
                    trailing: Switch(
                      value: true,
                      onChanged: (value) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              value
                                  ? 'Vibration enabled'
                                  : 'Vibration disabled',
                            ),
                            backgroundColor: Colors.red,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        );
                      },
                      activeThumbColor: Colors.red,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
