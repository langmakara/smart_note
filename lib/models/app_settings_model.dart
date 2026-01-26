import 'package:flutter/material.dart';

class AppSettings {
  bool isDarkMode;
  Color accentColor;
  String language;
  bool notificationsEnabled;
  bool eventReminders;
  bool noteReminders;
  String reminderTime;
  bool autoBackup;
  bool showGridLines;
  bool compactMode;
  String themeMode; // 'light', 'dark', 'system'

  AppSettings({
    this.isDarkMode = false,
    this.accentColor = Colors.purple,
    this.language = 'English',
    this.notificationsEnabled = true,
    this.eventReminders = true,
    this.noteReminders = false,
    this.reminderTime = '09:00',
    this.autoBackup = false,
    this.showGridLines = true,
    this.compactMode = false,
    this.themeMode = 'system',
  });

  Map<String, dynamic> toMap() {
    return {
      'isDarkMode': isDarkMode,
      'accentColor': accentColor.value,
      'language': language,
      'notificationsEnabled': notificationsEnabled,
      'eventReminders': eventReminders,
      'noteReminders': noteReminders,
      'reminderTime': reminderTime,
      'autoBackup': autoBackup,
      'showGridLines': showGridLines,
      'compactMode': compactMode,
      'themeMode': themeMode,
    };
  }

  factory AppSettings.fromMap(Map<String, dynamic> map) {
    return AppSettings(
      isDarkMode: map['isDarkMode'] ?? false,
      accentColor: Color(map['accentColor'] ?? Colors.purple.value),
      language: map['language'] ?? 'English',
      notificationsEnabled: map['notificationsEnabled'] ?? true,
      eventReminders: map['eventReminders'] ?? true,
      noteReminders: map['noteReminders'] ?? false,
      reminderTime: map['reminderTime'] ?? '09:00',
      autoBackup: map['autoBackup'] ?? false,
      showGridLines: map['showGridLines'] ?? true,
      compactMode: map['compactMode'] ?? false,
      themeMode: map['themeMode'] ?? 'system',
    );
  }

  AppSettings copyWith({
    bool? isDarkMode,
    Color? accentColor,
    String? language,
    bool? notificationsEnabled,
    bool? eventReminders,
    bool? noteReminders,
    String? reminderTime,
    bool? autoBackup,
    bool? showGridLines,
    bool? compactMode,
    String? themeMode,
  }) {
    return AppSettings(
      isDarkMode: isDarkMode ?? this.isDarkMode,
      accentColor: accentColor ?? this.accentColor,
      language: language ?? this.language,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      eventReminders: eventReminders ?? this.eventReminders,
      noteReminders: noteReminders ?? this.noteReminders,
      reminderTime: reminderTime ?? this.reminderTime,
      autoBackup: autoBackup ?? this.autoBackup,
      showGridLines: showGridLines ?? this.showGridLines,
      compactMode: compactMode ?? this.compactMode,
      themeMode: themeMode ?? this.themeMode,
    );
  }
}
