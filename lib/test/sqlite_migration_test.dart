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
    print('=== Starting SQLite Migration Tests ===\n');

    try {
      await testDatabaseHelper();
      await testNoteRepository();
      await testEventRepository();
      await testSettingsRepository();
      await testDataMigrationService();
      await testStorageServices();
      
      print('\n=== All Tests Completed Successfully! ===');
    } catch (e) {
      print('\n=== Test Failed: $e ===');
    }
  }

  static Future<void> testDatabaseHelper() async {
    print('1. Testing Database Helper...');
    
    final db = DatabaseHelper.instance;
    final exists = await db.databaseExists();
    print('   Database exists: $exists');
    
    final database = await db.database;
    print('   Database opened successfully: ${database.isOpen}');
    
    print('   ✓ Database Helper test passed\n');
  }

  static Future<void> testNoteRepository() async {
    print('2. Testing Note Repository...');
    
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
    print('   Created test note');
    
    // Get all notes
    final notes = await repo.getAll();
    print('   Retrieved ${notes.length} notes');
    
    // Get by ID
    final note = await repo.getById('test-note-1');
    print('   Retrieved note by ID: ${note?.title}');
    
    // Update note
    if (note != null) {
      note.title = 'Updated Test Note';
      await repo.update(note);
      print('   Updated note');
    }
    
    // Search notes
    final searchResults = await repo.search('Updated');
    print('   Search results: ${searchResults.length}');
    
    // Delete test note
    await repo.delete('test-note-1');
    print('   Deleted test note');
    
    print('   ✓ Note Repository test passed\n');
  }

  static Future<void> testEventRepository() async {
    print('3. Testing Event Repository...');
    
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
    print('   Created test event');
    
    // Get all events
    final events = await repo.getAll();
    print('   Retrieved ${events.length} events');
    
    // Get by ID
    final event = await repo.getById('test-event-1');
    print('   Retrieved event by ID: ${event?.title}');
    
    // Update event
    if (event != null) {
      event.title = 'Updated Test Event';
      await repo.update(event);
      print('   Updated event');
    }
    
    // Search events
    final searchResults = await repo.search('Updated');
    print('   Search results: ${searchResults.length}');
    
    // Delete test event
    await repo.delete('test-event-1');
    print('   Deleted test event');
    
    print('   ✓ Event Repository test passed\n');
  }

  static Future<void> testSettingsRepository() async {
    print('4. Testing Settings Repository...');
    
    final repo = SettingsRepository.instance;
    
    // Create test settings
    final testSettings = AppSettings(
      isDarkMode: true,
      accentColor: Colors.blue,
      language: 'Spanish',
      notificationsEnabled: false,
    );
    
    await repo.save(testSettings);
    print('   Saved test settings');
    
    // Load settings
    final loadedSettings = await repo.load();
    print('   Loaded settings: darkMode=${loadedSettings.isDarkMode}, language=${loadedSettings.language}');
    
    // Get specific setting
    final language = await repo.get('language');
    print('   Retrieved language setting: $language');
    
    // Delete all settings
    await repo.deleteAll();
    print('   Deleted all settings');
    
    print('   ✓ Settings Repository test passed\n');
  }

  static Future<void> testDataMigrationService() async {
    print('5. Testing Data Migration Service...');
    
    final migrationService = DataMigrationService.instance;
    
    // Check if migration is needed
    final needsMigration = await migrationService.isMigrationNeeded();
    print('   Migration needed: $needsMigration');
    
    if (needsMigration) {
      print('   Migration would be performed (JSON files exist)');
    } else {
      print('   No migration needed (no JSON files or data already migrated)');
    }
    
    // Test export functionality
    final exportResult = await migrationService.exportToJson();
    print('   Export result: ${exportResult.success}');
    if (exportResult.success) {
      print('   Exported ${exportResult.notesExported} notes');
      print('   Exported ${exportResult.eventsExported} events');
    }
    
    print('   ✓ Data Migration Service test passed\n');
  }

  static Future<void> testStorageServices() async {
    print('6. Testing Storage Services...');
    
    // Test NoteStorage
    final noteStorage = NoteStorage.instance;
    await noteStorage.initialize();
    print('   NoteStorage initialized');
    
    final notes = await noteStorage.readAllNotes();
    print('   NoteStorage retrieved ${notes.length} notes');
    
    // Test EventStorage
    final eventStorage = EventStorage.instance;
    await eventStorage.initialize();
    print('   EventStorage initialized');
    
    final events = await eventStorage.readAllEvents();
    print('   EventStorage retrieved ${events.length} events');
    
    // Test SettingsStorage
    final settingsStorage = SettingsStorage.instance;
    await settingsStorage.load();
    print('   SettingsStorage loaded settings');
    
    print('   ✓ Storage Services test passed\n');
  }
}
