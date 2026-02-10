import '../models/event_model.dart';
import 'hive_database.dart';

class EventStorage {
  static final EventStorage instance = EventStorage._init();
  EventStorage._init();

  Future<void> initialize() async {}

  Future<List<Event>> readAllEvents() async {
    try {
      return await HiveDatabase.instance.getAllEvents();
    } catch (e) {
      return [];
    }
  }

  Future<void> create(Event event) async {
    await HiveDatabase.instance.saveEvent(event);
  }

  Future<void> update(Event updatedEvent) async {
    await HiveDatabase.instance.updateEvent(updatedEvent);
  }

  Future<void> delete(String id) async {
    await HiveDatabase.instance.deleteEvent(id);
  }
}
