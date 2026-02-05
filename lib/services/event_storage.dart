import '../models/event_model.dart';
import '../repositories/event_repository.dart';
import '../services/data_migration_service.dart';
import '../services/database_helper.dart';

class EventStorage {
  static final EventStorage instance = EventStorage._init();
  EventStorage._init();

  // Initialize storage and migrate data if needed
  Future<void> initialize() async {
    final migrationService = DataMigrationService.instance;
    
    if (await migrationService.isMigrationNeeded()) {
      await migrationService.migrate();
    }
  }

  Future<List<Event>> readAllEvents() async {
    try {
      return await EventRepository.instance.getAll();
    } catch (e) {
      return [];
    }
  }

  Future<void> saveEvents(List<Event> events) async {
    // Note: This method is kept for compatibility but should not be used
    // Individual operations (create, update, delete) are preferred
    for (var event in events) {
      await EventRepository.instance.update(event);
    }
  }

  Future<void> create(Event event) async {
    await EventRepository.instance.create(event);
  }

  Future<void> update(Event updatedEvent) async {
    await EventRepository.instance.update(updatedEvent);
  }

  Future<void> delete(String id) async {
    await EventRepository.instance.delete(id);
  }

  Future<void> close() async {
    await DatabaseHelper.instance.close();
  }
}
