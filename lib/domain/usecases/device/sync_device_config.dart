import '../../repositories/device_repository.dart';
import '../../../data/datasources/remote/mqtt_service.dart';
import '../../../core/utils/logger.dart';

class SyncDeviceConfig {
  final DeviceRepository deviceRepository;
  final MQTTService mqttService;

  SyncDeviceConfig({
    required this.deviceRepository,
    required this.mqttService,
  });

  Future<void> execute(String deviceId) async {
    try {
      final device = await deviceRepository.getDevice(deviceId);
      if (device == null) {
        throw Exception('Device not found');
      }

      // Send config to device
      await mqttService.sendCommand(deviceId, 'update_config', {
        'uv_start': device.config.uvStartHour,
        'uv_stop': device.config.uvEndHour,
        'sleep_interval': device.config.sleepInterval,
        'auto_mode': device.config.autoMode,
      });

      Logger.d('SyncDeviceConfig', 'Config synced for device: $deviceId');
    } catch (e) {
      Logger.e('SyncDeviceConfig', 'Failed to sync config', e);
      throw Exception('Failed to sync config: $e');
    }
  }
}
