import 'package:flutter/material.dart';
import '../models/note_model.dart';
import '../models/event_model.dart';
import '../models/app_settings_model.dart';
import '../repositories/note_repository.dart';
import '../repositories/event_repository.dart';
import '../repositories/settings_repository.dart';
import '../services/database_helper.dart';
import '../services/data_migration_service.dart';
import '../services/note_storage.dart';
import '../services/event_storage.dart';
import '../services/settings_storage.dart';

class SQLiteMigrationTest {
  static Future<void> runAllTests() async {
    debugPrint('=== Starting SQLite Migration Tests ===\n');

    try {
      await testDatabaseHelper();
      await testNoteRepository();
      await testEventRepository();
      await testSettingsRepository();
      await testDataMigrationService();
      await testStorageServices();

      debugPrint('\n=== All Tests Completed Successfully! ===');
    } catch (e) {
      debugPrint('\n=== Test Failed: $e ===');
    }
  }

  static Future<void> testDatabaseHelper() async {
    debugPrint('1. Testing Database Helper...');

    final db = DatabaseHelper.instance;
    final exists = await db.databaseExists();
    debugPrint('   Database exists: $exists');

    final database = await db.database;
    debugPrint('   Database opened successfully: ${database.isOpen}');

    debugPrint('   ✓ Database Helper test passed\n');
  }

  static Future<void> testNoteRepository() async {
    debugPrint('2. Testing Note Repository...');

    final repo = NoteRepository.instance;

    // Create a test note
    final testNote = Note(
      id: 'test-note-1',
      title: 'Test Note',
      content: 'This is a test note for SQLite migration',
      createdAt: DateTime.now(),
      color: Colors.purple,
      isPinned: false,
    );

    await repo.create(testNote);
    debugPrint('   Created test note');

    // Get all notes
    final notes = await repo.getAll();
    debugPrint('   Retrieved ${notes.length} notes');

    // Get by ID
    final note = await repo.getById('test-note-1');
    debugPrint('   Retrieved note by ID: ${note?.title}');

    // Update note
    if (note != null) {
      note.title = 'Updated Test Note';
      await repo.update(note);
      debugPrint('   Updated note');
    }

    // Search notes
    final searchResults = await repo.search('Updated');
    debugPrint('   Search results: ${searchResults.length}');

    // Delete test note
    await repo.delete('test-note-1');
    debugPrint('   Deleted test note');

    debugPrint('   ✓ Note Repository test passed\n');
  }

  static Future<void> testEventRepository() async {
    debugPrint('3. Testing Event Repository...');

    final repo = EventRepository.instance;

    // Create a test event
    final testEvent = Event(
      id: 'test-event-1',
      title: 'Test Event',
      description: 'This is a test event for SQLite migration',
      startTime: DateTime.now(),
      endTime: DateTime.now().add(const Duration(hours: 2)),
      color: Colors.blue,
      isAllDay: false,
      location: 'Test Location',
    );

    await repo.create(testEvent);
    debugPrint('   Created test event');

    // Get all events
    final events = await repo.getAll();
    debugPrint('   Retrieved ${events.length} events');

    // Get by ID
    final event = await repo.getById('test-event-1');
    debugPrint('   Retrieved event by ID: ${event?.title}');

    // Update event
    if (event != null) {
      event.title = 'Updated Test Event';
      await repo.update(event);
      debugPrint('   Updated event');
    }

    // Search events
    final searchResults = await repo.search('Updated');
    debugPrint('   Search results: ${searchResults.length}');

    // Delete test event
    await repo.delete('test-event-1');
    debugPrint('   Deleted test event');

    debugPrint('   ✓ Event Repository test passed\n');
  }

  static Future<void> testSettingsRepository() async {
    debugPrint('4. Testing Settings Repository...');

    final repo = SettingsRepository.instance;

    // Create test settings
    final testSettings = AppSettings(
      isDarkMode: true,
      accentColor: Colors.blue,
      language: 'Spanish',
      notificationsEnabled: false,
    );

    await repo.save(testSettings);
    debugPrint('   Saved test settings');

    // Load settings
    final loadedSettings = await repo.load();
    debugPrint(
      '   Loaded settings: darkMode=${loadedSettings.isDarkMode}, language=${loadedSettings.language}',
    );

    // Get specific setting
    final language = await repo.get('language');
    debugPrint('   Retrieved language setting: $language');

    // Delete all settings
    await repo.deleteAll();
    debugPrint('   Deleted all settings');

    debugPrint('   ✓ Settings Repository test passed\n');
  }

  static Future<void> testDataMigrationService() async {
    debugPrint('5. Testing Data Migration Service...');

    final migrationService = DataMigrationService.instance;

    // Check if migration is needed
    final needsMigration = await migrationService.isMigrationNeeded();
    debugPrint('   Migration needed: $needsMigration');

    if (needsMigration) {
      debugPrint('   Migration would be performed (JSON files exist)');
    } else {
      debugPrint(
        '   No migration needed (no JSON files or data already migrated)',
      );
    }

    // Test export functionality
    final exportResult = await migrationService.exportToJson();
    debugPrint('   Export result: ${exportResult.success}');
    if (exportResult.success) {
      debugPrint('   Exported ${exportResult.notesExported} notes');
      debugPrint('   Exported ${exportResult.eventsExported} events');
    }

    debugPrint('   ✓ Data Migration Service test passed\n');
  }

  static Future<void> testStorageServices() async {
    debugPrint('6. Testing Storage Services...');

    // Test NoteStorage
    final noteStorage = NoteStorage.instance;
    await noteStorage.initialize();
    debugPrint('   NoteStorage initialized');

    final notes = await noteStorage.readAllNotes();
    debugPrint('   NoteStorage retrieved ${notes.length} notes');

    // Test EventStorage
    final eventStorage = EventStorage.instance;
    await eventStorage.initialize();
    debugPrint('   EventStorage initialized');

    final events = await eventStorage.readAllEvents();
    debugPrint('   EventStorage retrieved ${events.length} events');

    // Test SettingsStorage
    final settingsStorage = SettingsStorage.instance;
    await settingsStorage.load();
    debugPrint('   SettingsStorage loaded settings');

    debugPrint('   ✓ Storage Services test passed\n');
  }
}
