import '../../entities/device.dart';
import '../../repositories/device_repository.dart';
import '../../../core/utils/logger.dart';

class GetDevices {
  final DeviceRepository repository;

  GetDevices(this.repository);

  Future<List<Device>> execute() async {
    try {
      final devices = await repository.getDevices();
      Logger.d('GetDevices', 'Retrieved ${devices.length} devices');
      return devices;
    } catch (e) {
      Logger.e('GetDevices', 'Failed to get devices', e);
      return [];
    }
  }
}
