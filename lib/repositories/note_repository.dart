import '../models/note_model.dart';
import '../services/database_helper.dart';

class NoteRepository {
  static final NoteRepository instance = NoteRepository._init();
  NoteRepository._init();

  final DatabaseHelper _db = DatabaseHelper.instance;
  final String _tableName = 'notes';

  // Create a new note
  Future<void> create(Note note) async {
    await _db.insert(_tableName, note.toMap());
  }

  // Get all notes
  Future<List<Note>> getAll() async {
    final maps = await _db.query(
      _tableName,
      orderBy: 'is_pinned DESC, created_at DESC',
    );
    return maps.map((map) => Note.fromMap(map)).toList();
  }

  // Get a specific note by ID
  Future<Note?> getById(String id) async {
    final maps = await _db.query(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return Note.fromMap(maps.first);
  }

  // Update a note
  Future<void> update(Note note) async {
    await _db.update(
      _tableName,
      note.toMap(),
      'id = ?',
      [note.id],
    );
  }

  // Delete a note
  Future<void> delete(String id) async {
    await _db.delete(
      _tableName,
      'id = ?',
      [id],
    );
  }

  // Get pinned notes
  Future<List<Note>> getPinned() async {
    final maps = await _db.query(
      _tableName,
      where: 'is_pinned = 1',
      orderBy: 'created_at DESC',
    );
    return maps.map((map) => Note.fromMap(map)).toList();
  }

  // Search notes by title or content
  Future<List<Note>> search(String query) async {
    final maps = await _db.query(
      _tableName,
      where: 'title LIKE ? OR content LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
      orderBy: 'created_at DESC',
    );
    return maps.map((map) => Note.fromMap(map)).toList();
  }

  // Get notes count
  Future<int> getCount() async {
    final maps = await _db.query(_tableName);
    return maps.length;
  }

  // Delete all notes (for migration/testing)
  Future<void> deleteAll() async {
    final db = await _db.database;
    await db.delete(_tableName);
  }
}
