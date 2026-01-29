import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/note_model.dart';

class NoteStorage {
  static final NoteStorage instance = NoteStorage._init();
  NoteStorage._init();

  Future<File> get _localFile async {
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/notes.json';
    return File(path);
  }

  Future<List<Note>> readAllNotes() async {
    try {
      final file = await _localFile;
      if (!await file.exists()) {
        return [];
      }
      final contents = await file.readAsString();
      if (contents.isEmpty) {
        return [];
      }
      final List<dynamic> jsonList = json.decode(contents);
      return jsonList.map((json) => Note.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> saveNotes(List<Note> notes) async {
    final file = await _localFile;
    final jsonList = notes.map((note) => note.toJson()).toList();
    await file.writeAsString(json.encode(jsonList));
  }

  Future<void> create(Note note) async {
    final notes = await readAllNotes();
    notes.add(note);
    await saveNotes(notes);
  }

  Future<void> update(Note updatedNote) async {
    final notes = await readAllNotes();
    final index = notes.indexWhere((note) => note.id == updatedNote.id);
    if (index != -1) {
      notes[index] = updatedNote;
      await saveNotes(notes);
    }
  }

  Future<void> delete(String id) async {
    final notes = await readAllNotes();
    notes.removeWhere((note) => note.id == id);
    await saveNotes(notes);
  }

  Future<void> close() async {
    // No cleanup needed for JSON file storage
  }
}
