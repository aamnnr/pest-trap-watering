import '../../entities/device.dart';
import '../../repositories/device_repository.dart';
import '../../../core/utils/logger.dart';

class UpdateDevice {
  final DeviceRepository repository;

  UpdateDevice(this.repository);

  Future<void> execute(Device device) async {
    try {
      await repository.updateDevice(device);
      Logger.d('UpdateDevice', 'Device updated: ${device.name}');
    } catch (e) {
      Logger.e('UpdateDevice', 'Failed to update device', e);
      throw Exception('Failed to update device: $e');
    }
  }
}
