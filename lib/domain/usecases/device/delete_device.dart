import '../../repositories/device_repository.dart';
import '../../../core/utils/logger.dart';

class DeleteDevice {
  final DeviceRepository repository;

  DeleteDevice(this.repository);

  Future<void> execute(String deviceId) async {
    try {
      await repository.deleteDevice(deviceId);
      Logger.d('DeleteDevice', 'Device deleted: $deviceId');
    } catch (e) {
      Logger.e('DeleteDevice', 'Failed to delete device', e);
      throw Exception('Failed to delete device: $e');
    }
  }
}
