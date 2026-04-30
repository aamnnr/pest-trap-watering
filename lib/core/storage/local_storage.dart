import 'package:shared_preferences/shared_preferences.dart';
import '../utils/logger.dart';

class LocalStorage {
  static const String _keyThemeMode = 'theme_mode';
  static const String _keyNotificationsEnabled = 'notifications_enabled';
  static const String _keyLastSyncTime = 'last_sync_time';
  static const String _keyOnboardingCompleted = 'onboarding_completed';

  Future<SharedPreferences> get _prefs async =>
      await SharedPreferences.getInstance();

  // Theme mode
  Future<void> setThemeMode(String mode) async {
    final prefs = await _prefs;
    await prefs.setString(_keyThemeMode, mode);
  }

  Future<String> getThemeMode() async {
    final prefs = await _prefs;
    return prefs.getString(_keyThemeMode) ?? 'system';
  }

  // Notifications
  Future<void> setNotificationsEnabled(bool enabled) async {
    final prefs = await _prefs;
    await prefs.setBool(_keyNotificationsEnabled, enabled);
  }

  Future<bool> isNotificationsEnabled() async {
    final prefs = await _prefs;
    return prefs.getBool(_keyNotificationsEnabled) ?? true;
  }

  // Last sync time
  Future<void> setLastSyncTime(DateTime time) async {
    final prefs = await _prefs;
    await prefs.setString(_keyLastSyncTime, time.toIso8601String());
  }

  Future<DateTime?> getLastSyncTime() async {
    final prefs = await _prefs;
    final timeStr = prefs.getString(_keyLastSyncTime);
    return timeStr != null ? DateTime.parse(timeStr) : null;
  }

  // Onboarding
  Future<void> setOnboardingCompleted(bool completed) async {
    final prefs = await _prefs;
    await prefs.setBool(_keyOnboardingCompleted, completed);
  }

  Future<bool> isOnboardingCompleted() async {
    final prefs = await _prefs;
    return prefs.getBool(_keyOnboardingCompleted) ?? false;
  }

  // Generic methods
  Future<void> saveString(String key, String value) async {
    final prefs = await _prefs;
    await prefs.setString(key, value);
  }

  Future<String?> getString(String key) async {
    final prefs = await _prefs;
    return prefs.getString(key);
  }

  Future<void> saveBool(String key, bool value) async {
    final prefs = await _prefs;
    await prefs.setBool(key, value);
  }

  Future<bool> getBool(String key, {bool defaultValue = false}) async {
    final prefs = await _prefs;
    return prefs.getBool(key) ?? defaultValue;
  }

  Future<void> clearAll() async {
    final prefs = await _prefs;
    await prefs.clear();
    Logger.d('LocalStorage', 'All local data cleared');
  }
}
