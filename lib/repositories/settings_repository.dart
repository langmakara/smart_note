import '../models/app_settings_model.dart';
import '../services/database_helper.dart';

class SettingsRepository {
  static final SettingsRepository instance = SettingsRepository._init();
  SettingsRepository._init();

  final DatabaseHelper _db = DatabaseHelper.instance;
  final String _tableName = 'settings';

  // Save settings
  Future<void> save(AppSettings settings) async {
    final settingsMap = settings.toMap();
    final db = await _db.database;
    
    await db.transaction((txn) async {
      // Delete all existing settings
      await txn.delete(_tableName);
      
      // Insert all settings as key-value pairs
      final batch = txn.batch();
      for (var entry in settingsMap.entries) {
        batch.insert(
          _tableName,
          {'key': entry.key, 'value': entry.value.toString()},
        );
      }
      await batch.commit(noResult: true);
    });
  }

  // Load settings
  Future<AppSettings> load() async {
    final maps = await _db.query(_tableName);
    
    if (maps.isEmpty) {
      // Return default settings if none exist
      return AppSettings();
    }
    
    // Convert key-value pairs to map
    final settingsMap = <String, dynamic>{};
    for (var map in maps) {
      final key = map['key'] as String;
      final value = map['value'] as String;
      
      // Try to parse as bool, int, or keep as string
      if (value == 'true') {
        settingsMap[key] = true;
      } else if (value == 'false') {
        settingsMap[key] = false;
      } else if (int.tryParse(value) != null) {
        settingsMap[key] = int.parse(value);
      } else {
        settingsMap[key] = value;
      }
    }
    
    return AppSettings.fromMap(settingsMap);
  }

  // Get a specific setting value
  Future<dynamic> get(String key) async {
    final maps = await _db.query(
      _tableName,
      where: 'key = ?',
      whereArgs: [key],
    );
    
    if (maps.isEmpty) return null;
    
    final value = maps.first['value'] as String;
    
    if (value == 'true') return true;
    if (value == 'false') return false;
    if (int.tryParse(value) != null) return int.parse(value);
    
    return value;
  }

  // Set a specific setting value
  Future<void> set(String key, dynamic value) async {
    await _db.insert(
      _tableName,
      {'key': key, 'value': value.toString()},
    );
  }

  // Delete a specific setting
  Future<void> delete(String key) async {
    await _db.delete(
      _tableName,
      'key = ?',
      [key],
    );
  }

  // Delete all settings
  Future<void> deleteAll() async {
    final db = await _db.database;
    await db.delete(_tableName);
  }
}
