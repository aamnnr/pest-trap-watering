class AppStrings {
  // App Info
  static const String appName = 'PestTrap-Watering System';
  static const String version = '1.0.0';

  // MQTT Topics
  static const String mqttTopicPrefix = 'tanisolution';
  static String getMqttTelemetryTopic(String deviceId) =>
      '$mqttTopicPrefix/$deviceId/telemetry';
  static String getMqttCommandTopic(String deviceId) =>
      '$mqttTopicPrefix/$deviceId/command';

  // WiFi Config
  static const String esp32ApIp = '192.168.4.1';
  static const String esp32ConfigEndpoint = '/save';

  // Storage Keys
  static const String keyDevices = 'devices';
  static const String keyUserPreferences = 'user_preferences';
  static const String keyThemeMode = 'theme_mode';

  // Error Messages
  static const String errorNoInternet = 'Tidak ada koneksi internet';
  static const String errorMqttDisconnected = 'Koneksi MQTT terputus';
  static const String errorDeviceOffline = 'Device sedang offline';
  static const String errorTimeout = 'Timeout, silakan coba lagi';
  static const String errorUnknown = 'Terjadi kesalahan, silakan coba lagi';

  // Success Messages
  static const String successDeviceAdded = 'Device berhasil ditambahkan';
  static const String successDeviceDeleted = 'Device berhasil dihapus';
  static const String successScheduleCreated = 'Jadwal berhasil dibuat';
  static const String successControlCommand = 'Perintah berhasil dikirim';
}
