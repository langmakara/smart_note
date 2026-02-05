import '../models/event_model.dart';
import '../services/database_helper.dart';

class EventRepository {
  static final EventRepository instance = EventRepository._init();
  EventRepository._init();

  final DatabaseHelper _db = DatabaseHelper.instance;
  final String _tableName = 'events';

  // Create a new event
  Future<void> create(Event event) async {
    await _db.insert(_tableName, event.toMap());
  }

  // Get all events
  Future<List<Event>> getAll() async {
    final maps = await _db.query(
      _tableName,
      orderBy: 'start_time ASC',
    );
    return maps.map((map) => Event.fromMap(map)).toList();
  }

  // Get a specific event by ID
  Future<Event?> getById(String id) async {
    final maps = await _db.query(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return Event.fromMap(maps.first);
  }

  // Update an event
  Future<void> update(Event event) async {
    await _db.update(
      _tableName,
      event.toMap(),
      'id = ?',
      [event.id],
    );
  }

  // Delete an event
  Future<void> delete(String id) async {
    await _db.delete(
      _tableName,
      'id = ?',
      [id],
    );
  }

  // Get events for a specific date
  Future<List<Event>> getEventsForDate(DateTime date) async {
    final dateStr = date.toIso8601String().substring(0, 10); // YYYY-MM-DD
    final maps = await _db.query(
      _tableName,
      where: 'DATE(start_time) = ? OR DATE(end_time) = ?',
      whereArgs: [dateStr, dateStr],
      orderBy: 'start_time ASC',
    );
    return maps.map((map) => Event.fromMap(map)).toList();
  }

  // Get events within a date range
  Future<List<Event>> getEventsInRange(DateTime start, DateTime end) async {
    final maps = await _db.query(
      _tableName,
      where: 'start_time BETWEEN ? AND ?',
      whereArgs: [start.toIso8601String(), end.toIso8601String()],
      orderBy: 'start_time ASC',
    );
    return maps.map((map) => Event.fromMap(map)).toList();
  }

  // Search events by title or description
  Future<List<Event>> search(String query) async {
    final maps = await _db.query(
      _tableName,
      where: 'title LIKE ? OR description LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
      orderBy: 'start_time ASC',
    );
    return maps.map((map) => Event.fromMap(map)).toList();
  }

  // Get events count
  Future<int> getCount() async {
    final maps = await _db.query(_tableName);
    return maps.length;
  }

  // Delete all events (for migration/testing)
  Future<void> deleteAll() async {
    final db = await _db.database;
    await db.delete(_tableName);
  }
}
