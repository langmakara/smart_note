import '../models/app_settings_model.dart';
import 'hive_database.dart';

class SettingsStorage {
  static final SettingsStorage instance = SettingsStorage._init();
  SettingsStorage._init();

  Future<AppSettings> load() async {
    try {
      return HiveDatabase.instance.loadSettings();
    } catch (e) {
      return AppSettings();
    }
  }

  Future<void> save(AppSettings settings) async {
    await HiveDatabase.instance.saveSettings(settings);
  }
}
