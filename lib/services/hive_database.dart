import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/note_model.dart';
import '../models/event_model.dart';
import '../models/todo_model.dart';
import '../models/app_settings_model.dart';

class HiveDatabase {
  static final HiveDatabase instance = HiveDatabase._init();
  HiveDatabase._init();

  Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox('settings');
    await Hive.openBox<dynamic>('notes');
    await Hive.openBox<dynamic>('events');
    await Hive.openBox<dynamic>('todos');
  }

  Box<dynamic> get notesBox => Hive.box<dynamic>('notes');
  Box<dynamic> get eventsBox => Hive.box<dynamic>('events');
  Box<dynamic> get todosBox => Hive.box<dynamic>('todos');
  Box<dynamic> get settingsBox => Hive.box<dynamic>('settings');

  Future<void> saveNote(Note note) async {
    await notesBox.put(note.id, note.toJson());
  }

  Future<List<Note>> getAllNotes() async {
    final notes = <Note>[];
    for (var key in notesBox.keys) {
      final note = notesBox.get(key);
      if (note is Map) {
        notes.add(Note.fromJson(Map<String, dynamic>.from(note)));
      }
    }
    notes.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return notes;
  }

  Future<void> updateNote(Note note) async {
    await notesBox.put(note.id, note.toJson());
  }

  Future<void> deleteNote(String id) async {
    await notesBox.delete(id);
  }

  Future<void> saveEvent(Event event) async {
    await eventsBox.put(event.id, event.toJson());
  }

  Future<List<Event>> getAllEvents() async {
    final events = <Event>[];
    for (var key in eventsBox.keys) {
      final event = eventsBox.get(key);
      if (event is Map) {
        events.add(Event.fromJson(Map<String, dynamic>.from(event)));
      }
    }
    events.sort((a, b) => a.startTime.compareTo(b.startTime));
    return events;
  }

  Future<void> updateEvent(Event event) async {
    await eventsBox.put(event.id, event.toJson());
  }

  Future<void> deleteEvent(String id) async {
    await eventsBox.delete(id);
  }

  Future<void> saveTodo(Todo todo) async {
    await todosBox.put(todo.id, todo.toJson());
  }

  Future<List<Todo>> getAllTodos() async {
    final todos = <Todo>[];
    for (var key in todosBox.keys) {
      final todo = todosBox.get(key);
      if (todo is Map) {
        todos.add(Todo.fromJson(Map<String, dynamic>.from(todo)));
      }
    }
    todos.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return todos;
  }

  Future<void> updateTodo(Todo todo) async {
    await todosBox.put(todo.id, todo.toJson());
  }

  Future<void> deleteTodo(String id) async {
    await todosBox.delete(id);
  }

  Future<void> saveSettings(AppSettings settings) async {
    await settingsBox.put('isDarkMode', settings.isDarkMode);
    await settingsBox.put('accentColor', settings.accentColor.toARGB32());
    await settingsBox.put('language', settings.language);
    await settingsBox.put(
      'notificationsEnabled',
      settings.notificationsEnabled,
    );
    await settingsBox.put('eventReminders', settings.eventReminders);
    await settingsBox.put('noteReminders', settings.noteReminders);
    await settingsBox.put('reminderTime', settings.reminderTime);
    await settingsBox.put('autoBackup', settings.autoBackup);
    await settingsBox.put('showGridLines', settings.showGridLines);
    await settingsBox.put('compactMode', settings.compactMode);
    await settingsBox.put('themeMode', settings.themeMode);
  }

  AppSettings loadSettings() {
    return AppSettings(
      isDarkMode: settingsBox.get('isDarkMode', defaultValue: false) as bool,
      accentColor: Color(
        settingsBox.get('accentColor', defaultValue: Colors.purple.toARGB32())
            as int,
      ),
      language: settingsBox.get('language', defaultValue: 'English') as String,
      notificationsEnabled:
          settingsBox.get('notificationsEnabled', defaultValue: true) as bool,
      eventReminders:
          settingsBox.get('eventReminders', defaultValue: true) as bool,
      noteReminders:
          settingsBox.get('noteReminders', defaultValue: false) as bool,
      reminderTime:
          settingsBox.get('reminderTime', defaultValue: '09:00') as String,
      autoBackup: settingsBox.get('autoBackup', defaultValue: false) as bool,
      showGridLines:
          settingsBox.get('showGridLines', defaultValue: true) as bool,
      compactMode: settingsBox.get('compactMode', defaultValue: false) as bool,
      themeMode: settingsBox.get('themeMode', defaultValue: 'system') as String,
    );
  }
}
