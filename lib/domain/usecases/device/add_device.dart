import '../../entities/device.dart';
import '../../repositories/device_repository.dart';
import '../../../core/utils/logger.dart';

class AddDevice {
  final DeviceRepository repository;

  AddDevice(this.repository);

  Future<void> execute({
    required String id,
    required String name,
    required String macAddress,
    required String deviceId,
    required String mqttTopic,
    String? location,
    required DeviceConfig config,
  }) async {
    try {
      final device = Device(
        id: id,
        name: name,
        macAddress: macAddress,
        deviceId: deviceId,
        mqttTopic: mqttTopic,
        location: location,
        isActive: true,
        status: DeviceStatus.configuring,
        telemetry: null,
        lastSeen: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        config: config,
      );

      await repository.addDevice(device);
      Logger.d('AddDevice', 'Device added: $name');
    } catch (e) {
      Logger.e('AddDevice', 'Failed to add device', e);
      throw Exception('Failed to add device: $e');
    }
  }
}
