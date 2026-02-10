import 'package:flutter/material.dart';
import 'hive_database.dart';
import 'note_storage.dart';
import 'event_storage.dart';
import 'security_service.dart';

class AppInitialization {
  static bool _isInitialized = false;

  static bool get isInitialized => _isInitialized;

  static Future<void> initialize(BuildContext context) async {
    if (_isInitialized) return;

    try {
      await HiveDatabase.instance.init();

      await NoteStorage.instance.initialize();
      await EventStorage.instance.initialize();
      await SecurityService.instance.init();

      _isInitialized = true;
      debugPrint('App initialization completed successfully');
    } catch (e) {
      debugPrint('App initialization failed: $e');
    }
  }

  static void reset() {
    _isInitialized = false;
  }
}
