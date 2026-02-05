import '../models/app_settings_model.dart';
import '../repositories/settings_repository.dart';
import '../services/database_helper.dart';

class SettingsStorage {
  static final SettingsStorage instance = SettingsStorage._init();
  SettingsStorage._init();

  Future<AppSettings> load() async {
    try {
      return await SettingsRepository.instance.load();
    } catch (e) {
      return AppSettings();
    }
  }

  Future<void> save(AppSettings settings) async {
    await SettingsRepository.instance.save(settings);
  }

  Future<void> close() async {
    await DatabaseHelper.instance.close();
  }
}
