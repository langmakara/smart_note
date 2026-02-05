import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

import '../models/note_model.dart';
import '../models/event_model.dart';
import '../models/app_settings_model.dart';
import '../repositories/note_repository.dart';
import '../repositories/event_repository.dart';
import '../repositories/settings_repository.dart';
import '../services/database_helper.dart';

class DataMigrationService {
  static final DataMigrationService instance = DataMigrationService._init();
  DataMigrationService._init();

  // Check if migration is needed
  Future<bool> isMigrationNeeded() async {
    try {
      // Check if JSON files exist
      final directory = await getApplicationDocumentsDirectory();
      final notesFile = File('${directory.path}/notes.json');
      final eventsFile = File('${directory.path}/events.json');
      
      final notesExist = await notesFile.exists();
      final eventsExist = await eventsFile.exists();
      
      // Check if database already has data
      final noteCount = await NoteRepository.instance.getCount();
      final eventCount = await EventRepository.instance.getCount();
      
      // Migration needed if JSON files exist AND database is empty
      return (notesExist || eventsExist) && (noteCount == 0 && eventCount == 0);
    } catch (e) {
      return false;
    }
  }

  // Perform migration
  Future<MigrationResult> migrate() async {
    final result = MigrationResult();
    
    try {
      // Check if database exists, create if not
      final dbExists = await DatabaseHelper.instance.databaseExists();
      if (!dbExists) {
        await DatabaseHelper.instance.database;
      }

      // Migrate notes
      final notesMigrated = await _migrateNotes();
      result.notesMigrated = notesMigrated;

      // Migrate events
      final eventsMigrated = await _migrateEvents();
      result.eventsMigrated = eventsMigrated;

      // Mark migration as complete
      result.success = true;
      result.message = 'Migration completed successfully';

      // Optionally delete old JSON files after successful migration
      await _cleanupOldFiles();

      return result;
    } catch (e) {
      result.success = false;
      result.message = 'Migration failed: $e';
      return result;
    }
  }

  // Migrate notes from JSON to SQLite
  Future<int> _migrateNotes() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/notes.json');
      
      if (!await file.exists()) {
        return 0;
      }

      final contents = await file.readAsString();
      if (contents.isEmpty) {
        return 0;
      }

      final List<dynamic> jsonList = json.decode(contents);
      int count = 0;

      for (var json in jsonList) {
        try {
          final note = Note.fromJson(json);
          await NoteRepository.instance.create(note);
          count++;
        } catch (e) {
          print('Error migrating note: $e');
        }
      }

      return count;
    } catch (e) {
      print('Error migrating notes: $e');
      return 0;
    }
  }

  // Migrate events from JSON to SQLite
  Future<int> _migrateEvents() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/events.json');
      
      if (!await file.exists()) {
        return 0;
      }

      final contents = await file.readAsString();
      if (contents.isEmpty) {
        return 0;
      }

      final List<dynamic> jsonList = json.decode(contents);
      int count = 0;

      for (var json in jsonList) {
        try {
          final event = Event.fromJson(json);
          await EventRepository.instance.create(event);
          count++;
        } catch (e) {
          print('Error migrating event: $e');
        }
      }

      return count;
    } catch (e) {
      print('Error migrating events: $e');
      return 0;
    }
  }

  // Clean up old JSON files after successful migration
  Future<void> _cleanupOldFiles() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      
      // Delete notes.json
      final notesFile = File('${directory.path}/notes.json');
      if (await notesFile.exists()) {
        await notesFile.delete();
      }

      // Delete events.json
      final eventsFile = File('${directory.path}/events.json');
      if (await eventsFile.exists()) {
        await eventsFile.delete();
      }
    } catch (e) {
      print('Error cleaning up old files: $e');
    }
  }

  // Export data to JSON (for backup)
  Future<ExportResult> exportToJson() async {
    final result = ExportResult();
    
    try {
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-').substring(0, 19);
      
      // Export notes
      final notes = await NoteRepository.instance.getAll();
      final notesJson = notes.map((note) => note.toJson()).toList();
      final notesFile = File('${directory.path}/notes_backup_$timestamp.json');
      await notesFile.writeAsString(json.encode(notesJson));
      result.notesExported = notes.length;
      result.notesFilePath = notesFile.path;

      // Export events
      final events = await EventRepository.instance.getAll();
      final eventsJson = events.map((event) => event.toJson()).toList();
      final eventsFile = File('${directory.path}/events_backup_$timestamp.json');
      await eventsFile.writeAsString(json.encode(eventsJson));
      result.eventsExported = events.length;
      result.eventsFilePath = eventsFile.path;

      // Export settings
      final settings = await SettingsRepository.instance.load();
      final settingsMap = settings.toMap();
      final settingsFile = File('${directory.path}/settings_backup_$timestamp.json');
      await settingsFile.writeAsString(json.encode(settingsMap));
      result.settingsFilePath = settingsFile.path;

      result.success = true;
      result.message = 'Export completed successfully';
      
      return result;
    } catch (e) {
      result.success = false;
      result.message = 'Export failed: $e';
      return result;
    }
  }

  // Import data from JSON (for restore)
  Future<ImportResult> importFromJson(String notesPath, String eventsPath, String settingsPath) async {
    final result = ImportResult();
    
    try {
      // Import notes
      final notesFile = File(notesPath);
      if (await notesFile.exists()) {
        final contents = await notesFile.readAsString();
        final List<dynamic> jsonList = json.decode(contents);
        
        for (var json in jsonList) {
          final note = Note.fromJson(json);
          await NoteRepository.instance.create(note);
          result.notesImported++;
        }
      }

      // Import events
      final eventsFile = File(eventsPath);
      if (await eventsFile.exists()) {
        final contents = await eventsFile.readAsString();
        final List<dynamic> jsonList = json.decode(contents);
        
        for (var json in jsonList) {
          final event = Event.fromJson(json);
          await EventRepository.instance.create(event);
          result.eventsImported++;
        }
      }

      // Import settings
      final settingsFile = File(settingsPath);
      if (await settingsFile.exists()) {
        final contents = await settingsFile.readAsString();
        final Map<String, dynamic> settingsMap = json.decode(contents);
        
        final settings = AppSettings.fromMap(settingsMap);
        await SettingsRepository.instance.save(settings);
        result.settingsImported = true;
      }

      result.success = true;
      result.message = 'Import completed successfully';
      
      return result;
    } catch (e) {
      result.success = false;
      result.message = 'Import failed: $e';
      return result;
    }
  }
}

// Result classes
class MigrationResult {
  bool success = false;
  String message = '';
  int notesMigrated = 0;
  int eventsMigrated = 0;
}

class ExportResult {
  bool success = false;
  String message = '';
  int notesExported = 0;
  int eventsExported = 0;
  String? notesFilePath;
  String? eventsFilePath;
  String? settingsFilePath;
}

class ImportResult {
  bool success = false;
  String message = '';
  int notesImported = 0;
  int eventsImported = 0;
  bool settingsImported = false;
}
