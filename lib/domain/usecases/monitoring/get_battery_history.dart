import '../../repositories/device_repository.dart';
import '../../../core/utils/logger.dart';

class GetBatteryHistory {
  final DeviceRepository repository;

  GetBatteryHistory(this.repository);

  Future<List<Map<String, dynamic>>> execute({
    required String deviceId,
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
  }) async {
    try {
      final telemetry = await repository.getTelemetryHistory(
        deviceId,
        startDate: startDate,
        endDate: endDate,
        limit: limit,
      );

      return telemetry.map((data) {
        return {
          'timestamp': data.timestamp,
          'batteryPercentage': data.batteryPercentage,
          'uvStatus': data.uvStatus,
          'pumpStatus': data.pumpStatus,
        };
      }).toList();
    } catch (e) {
      Logger.e('GetBatteryHistory', 'Failed to get battery history', e);
      return [];
    }
  }
}
