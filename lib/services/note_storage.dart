import '../models/note_model.dart';
import 'hive_database.dart';

class NoteStorage {
  static final NoteStorage instance = NoteStorage._init();
  NoteStorage._init();

  Future<void> initialize() async {}

  Future<List<Note>> readAllNotes() async {
    try {
      return await HiveDatabase.instance.getAllNotes();
    } catch (e) {
      return [];
    }
  }

  Future<void> create(Note note) async {
    await HiveDatabase.instance.saveNote(note);
  }

  Future<void> update(Note updatedNote) async {
    await HiveDatabase.instance.updateNote(updatedNote);
  }

  Future<void> delete(String id) async {
    await HiveDatabase.instance.deleteNote(id);
  }
}
