import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../utils/logger.dart';

class SecureStorage {
  static const String _keyMqttUsername = 'mqtt_username';
  static const String _keyMqttPassword = 'mqtt_password';
  static const String _keyUserToken = 'user_token';
  static const String _keyDeviceCredentials = 'device_credentials';

  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  // Save MQTT credentials
  Future<void> saveMqttCredentials(String username, String password) async {
    try {
      await _storage.write(key: _keyMqttUsername, value: username);
      await _storage.write(key: _keyMqttPassword, value: password);
      Logger.d('SecureStorage', 'MQTT credentials saved');
    } catch (e) {
      Logger.e('SecureStorage', 'Failed to save MQTT credentials', e);
      rethrow;
    }
  }

  // Get MQTT credentials
  Future<Map<String, String?>> getMqttCredentials() async {
    try {
      final username = await _storage.read(key: _keyMqttUsername);
      final password = await _storage.read(key: _keyMqttPassword);
      return {'username': username, 'password': password};
    } catch (e) {
      Logger.e('SecureStorage', 'Failed to get MQTT credentials', e);
      return {'username': null, 'password': null};
    }
  }

  // Save user token
  Future<void> saveUserToken(String token) async {
    await _storage.write(key: _keyUserToken, value: token);
  }

  // Get user token
  Future<String?> getUserToken() async {
    return await _storage.read(key: _keyUserToken);
  }

  // Save device credentials (for offline auth)
  Future<void> saveDeviceCredentials(String deviceId, String credential) async {
    final key = '${_keyDeviceCredentials}_$deviceId';
    await _storage.write(key: key, value: credential);
  }

  // Clear all data
  Future<void> clearAll() async {
    await _storage.deleteAll();
    Logger.d('SecureStorage', 'All secure data cleared');
  }
}
