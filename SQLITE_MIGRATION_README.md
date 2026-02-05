# SQLite Migration Documentation

## Overview

This project has been migrated from JSON file-based storage to SQLite (using the `sqflite` package) for improved performance, data integrity, and query capabilities.

## What Changed

### Before (JSON Storage)
- **Storage Format**: JSON files (`notes.json`, `events.json`)
- **Performance**: Reads/writes entire files on every operation
- **Query Capabilities**: Limited - all filtering done in memory
- **Data Integrity**: No constraints or validation
- **Scalability**: Poor - entire dataset loaded into memory

### After (SQLite Storage)
- **Storage Format**: SQLite database (`smart_note.db`)
- **Performance**: Only modified records are read/written
- **Query Capabilities**: Full SQL support (WHERE, ORDER BY, JOIN)
- **Data Integrity**: Constraints, foreign keys, validation
- **Scalability**: Excellent - handles large datasets efficiently

## Database Schema

### Notes Table
```sql
CREATE TABLE notes (
  id TEXT PRIMARY KEY,
  title TEXT NOT NULL,
  content TEXT,
  created_at TEXT NOT NULL,
  updated_at TEXT,
  color INTEGER NOT NULL,
  is_pinned INTEGER NOT NULL DEFAULT 0
)
```

### Events Table
```sql
CREATE TABLE events (
  id TEXT PRIMARY KEY,
  title TEXT NOT NULL,
  description TEXT,
  start_time TEXT NOT NULL,
  end_time TEXT NOT NULL,
  color INTEGER NOT NULL,
  is_all_day INTEGER NOT NULL DEFAULT 0,
  location TEXT
)
```

### Settings Table
```sql
CREATE TABLE settings (
  key TEXT PRIMARY KEY,
  value TEXT
)
```

## New Files Created

### Core Database Layer
1. **`lib/services/database_helper.dart`**
   - Manages SQLite connection and database initialization
   - Provides generic query/insert/update/delete methods
   - Creates tables and indexes on first run

2. **`lib/repositories/note_repository.dart`**
   - CRUD operations for notes
   - Search functionality
   - Pinned notes filtering

3. **`lib/repositories/event_repository.dart`**
   - CRUD operations for events
   - Date-based queries
   - Event search functionality

4. **`lib/repositories/settings_repository.dart`**
   - Key-value storage for app settings
   - Settings persistence

### Migration & Services
5. **`lib/services/data_migration_service.dart`**
   - Automatic migration from JSON to SQLite
   - Export/import functionality for backups
   - Migration result tracking

6. **`lib/services/app_initialization.dart`**
   - Database initialization on app startup
   - Automatic migration detection and execution

7. **`lib/services/settings_storage.dart`**
   - Settings storage service using SQLite

### Updated Services
8. **`lib/services/note_storage.dart`**
   - Now uses SQLite instead of JSON files
   - Maintains same API for backward compatibility

9. **`lib/services/event_storage.dart`**
   - Now uses SQLite instead of JSON files
   - Maintains same API for backward compatibility

### Testing
10. **`lib/test/sqlite_migration_test.dart`**
    - Comprehensive test suite for all database operations
    - Tests migration, CRUD operations, and services

## Automatic Migration

When the app starts, it automatically:
1. Checks if JSON files exist (`notes.json`, `events.json`)
2. Checks if the SQLite database already has data
3. If JSON files exist AND database is empty, performs migration
4. Migrates all notes and events from JSON to SQLite
5. Deletes old JSON files after successful migration

## Usage Examples

### Creating a Note
```dart
final note = Note(
  id: 'note-123',
  title: 'My Note',
  content: 'Note content',
  createdAt: DateTime.now(),
  color: Colors.purple,
  isPinned: false,
);
await NoteStorage.instance.create(note);
```

### Reading All Notes
```dart
final notes = await NoteStorage.instance.readAllNotes();
```

### Updating a Note
```dart
note.title = 'Updated Title';
await NoteStorage.instance.update(note);
```

### Deleting a Note
```dart
await NoteStorage.instance.delete('note-123');
```

### Searching Notes
```dart
final results = await NoteRepository.instance.search('keyword');
```

### Saving Settings
```dart
final settings = AppSettings(
  isDarkMode: true,
  language: 'Spanish',
);
await SettingsStorage.instance.save(settings);
```

### Loading Settings
```dart
final settings = await SettingsStorage.instance.load();
```

## Performance Improvements

### Before (JSON)
- Reading all notes: O(n) - reads entire file
- Updating a note: O(n) - reads, modifies, writes entire file
- Deleting a note: O(n) - reads, filters, writes entire file
- Searching: O(n) - must load all data into memory

### After (SQLite)
- Reading all notes: O(n) - optimized with indexes
- Updating a note: O(1) - updates single record
- Deleting a note: O(1) - deletes single record
- Searching: O(log n) - uses database indexes

## Backup & Export

The migration service includes export/import functionality:

```dart
// Export all data to JSON files
final result = await DataMigrationService.instance.exportToJson();

// Import data from JSON files
final importResult = await DataMigrationService.instance.importFromJson(
  notesPath,
  eventsPath,
  settingsPath,
);
```

## Testing

Run the test suite to verify the migration:

```dart
import 'lib/test/sqlite_migration_test.dart';

void main() {
  SQLiteMigrationTest.runAllTests();
}
```

## Troubleshooting

### Migration Not Running
- Check if JSON files exist in `getApplicationDocumentsDirectory()`
- Verify database is empty (no notes/events in SQLite)
- Check console for migration logs

### Data Loss
- Migration creates backups automatically
- Old JSON files are only deleted after successful migration
- Use export functionality before manual migration

### Performance Issues
- Ensure indexes are created (they are created automatically)
- Use repository methods instead of loading all data into memory
- Consider adding pagination for large datasets

## Future Enhancements

1. **Cloud Sync**: Add Firebase/Supabase integration
2. **Advanced Queries**: Add complex filtering and sorting
3. **Data Versioning**: Track changes over time
4. **Full-Text Search**: Add SQLite FTS for better search
5. **Data Encryption**: Encrypt sensitive data at rest

## Dependencies

```yaml
dependencies:
  sqflite: ^2.3.0  # SQLite plugin
  path: ^1.9.0     # Path utilities
  path_provider: ^2.1.4  # Document directory access
```

## Notes

- The migration is automatic and transparent to the UI layer
- Existing UI code continues to work without changes
- All storage services maintain backward compatibility
- Database is initialized on app startup
- Migration only runs once (when JSON files exist and database is empty)
