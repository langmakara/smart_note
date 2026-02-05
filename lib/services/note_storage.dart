import '../models/note_model.dart';
import '../repositories/note_repository.dart';
import '../services/data_migration_service.dart';
import '../services/database_helper.dart';

class NoteStorage {
  static final NoteStorage instance = NoteStorage._init();
  NoteStorage._init();

  // Initialize storage and migrate data if needed
  Future<void> initialize() async {
    final migrationService = DataMigrationService.instance;
    
    if (await migrationService.isMigrationNeeded()) {
      await migrationService.migrate();
    }
  }

  Future<List<Note>> readAllNotes() async {
    try {
      return await NoteRepository.instance.getAll();
    } catch (e) {
      return [];
    }
  }

  Future<void> saveNotes(List<Note> notes) async {
    // Note: This method is kept for compatibility but should not be used
    // Individual operations (create, update, delete) are preferred
    for (var note in notes) {
      await NoteRepository.instance.update(note);
    }
  }

  Future<void> create(Note note) async {
    await NoteRepository.instance.create(note);
  }

  Future<void> update(Note updatedNote) async {
    await NoteRepository.instance.update(updatedNote);
  }

  Future<void> delete(String id) async {
    await NoteRepository.instance.delete(id);
  }

  Future<void> close() async {
    await DatabaseHelper.instance.close();
  }
}
