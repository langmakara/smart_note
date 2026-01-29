import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/event_model.dart';

class EventStorage {
  static final EventStorage instance = EventStorage._init();
  EventStorage._init();

  Future<File> get _localFile async {
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/events.json';
    return File(path);
  }

  Future<List<Event>> readAllEvents() async {
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
      return jsonList.map((json) => Event.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> saveEvents(List<Event> events) async {
    final file = await _localFile;
    final jsonList = events.map((event) => event.toJson()).toList();
    await file.writeAsString(json.encode(jsonList));
  }

  Future<void> create(Event event) async {
    final events = await readAllEvents();
    events.add(event);
    await saveEvents(events);
  }

  Future<void> update(Event updatedEvent) async {
    final events = await readAllEvents();
    final index = events.indexWhere((event) => event.id == updatedEvent.id);
    if (index != -1) {
      events[index] = updatedEvent;
      await saveEvents(events);
    }
  }

  Future<void> delete(String id) async {
    final events = await readAllEvents();
    events.removeWhere((event) => event.id == id);
    await saveEvents(events);
  }

  Future<void> close() async {
    // No cleanup needed for JSON file storage
  }
}
