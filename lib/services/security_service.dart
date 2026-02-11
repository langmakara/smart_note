import 'package:hive_flutter/hive_flutter.dart';

class SecurityService {
  static const String _boxName = 'security';
  static const String _passwordKey = 'numeric_password';
  static const String _enabledKey = 'password_enabled';

  static final SecurityService instance = SecurityService._init();
  SecurityService._init();

  Future<void> init() async {
    await Hive.openBox(_boxName);
  }

  Box<dynamic> get _securityBox => Hive.box<dynamic>(_boxName);

  Future<void> setPassword(String password) async {
    await _securityBox.put(_passwordKey, password);
    await _securityBox.put(_enabledKey, true);
  }

  bool verifyPassword(String password) {
    final storedPassword = _securityBox.get(_passwordKey) as String?;
    return storedPassword == password;
  }

  Future<void> disablePassword() async {
    await _securityBox.delete(_passwordKey);
    await _securityBox.put(_enabledKey, false);
  }

  bool isPasswordEnabled() {
    return _securityBox.get(_enabledKey, defaultValue: false) as bool;
  }

  Future<void> clearAll() async {
    await _securityBox.clear();
  }
}
