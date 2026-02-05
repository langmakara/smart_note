import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'data_migration_service.dart';
import 'note_storage.dart';
import 'event_storage.dart';

class AppInitialization {
  static bool _isInitialized = false;
  static bool _migrationCompleted = false;

  static bool get isInitialized => _isInitialized;
  static bool get migrationCompleted => _migrationCompleted;

  /// Initialize the app database and perform migration if needed
  static Future<void> initialize(BuildContext context) async {
    if (_isInitialized) return;

    try {
      // Initialize database
      await DatabaseHelper.instance.database;
      
      // Check for migration
      final migrationService = DataMigrationService.instance;
      final needsMigration = await migrationService.isMigrationNeeded();

      if (needsMigration) {
        // Perform migration
        final result = await migrationService.migrate();
        _migrationCompleted = result.success;
        
        if (result.success) {
          print('Migration successful: ${result.notesMigrated} notes, ${result.eventsMigrated} events migrated');
        } else {
          print('Migration failed: ${result.message}');
        }
      } else {
        _migrationCompleted = true;
      }

      // Initialize storage services
      await NoteStorage.instance.initialize();
      await EventStorage.instance.initialize();

      _isInitialized = true;
      print('App initialization completed successfully');
    } catch (e) {
      print('App initialization failed: $e');
      // Don't throw - app should still work even if initialization fails
    }
  }

  /// Reset initialization state (useful for testing)
  static void reset() {
    _isInitialized = false;
    _migrationCompleted = false;
  }
}
