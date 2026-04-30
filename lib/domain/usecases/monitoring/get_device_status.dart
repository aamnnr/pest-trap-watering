import '../../entities/device.dart';
import '../../repositories/device_repository.dart';
import '../../../core/utils/logger.dart';

class GetDeviceStatus {
  final DeviceRepository repository;

  GetDeviceStatus(this.repository);

  Future<Map<String, dynamic>> execute(String deviceId) async {
    try {
      final device = await repository.getDevice(deviceId);

      if (device == null) {
        return {
          'isOnline': false,
          'status': DeviceStatus.offline,
          'lastSeen': null,
        };
      }

      // Check if device is online (last seen within 5 minutes)
      final isOnline = device.lastSeen
          .isAfter(DateTime.now().subtract(const Duration(minutes: 5)));
      final status = isOnline ? DeviceStatus.online : device.status;

      return {
        'isOnline': isOnline,
        'status': status,
        'lastSeen': device.lastSeen,
        'batteryPercentage': device.telemetry?.batteryPercentage,
        'uvStatus': device.telemetry?.uvStatus,
        'pumpStatus': device.telemetry?.pumpStatus,
      };
    } catch (e) {
      Logger.e('GetDeviceStatus', 'Failed to get device status', e);
      return {
        'isOnline': false,
        'status': DeviceStatus.offline,
        'lastSeen': null,
      };
    }
  }
}
