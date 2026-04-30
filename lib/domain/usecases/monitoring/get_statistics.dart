import '../../repositories/device_repository.dart';
import '../../repositories/log_repository.dart';
import '../../../core/utils/logger.dart';

class GetStatistics {
  final DeviceRepository deviceRepository;
  final LogRepository logRepository;

  GetStatistics({
    required this.deviceRepository,
    required this.logRepository,
  });

  Future<Map<String, dynamic>> execute(
      String deviceId, DateTime startDate, DateTime endDate) async {
    try {
      final telemetry = await deviceRepository.getTelemetryHistory(
        deviceId,
        startDate: startDate,
        endDate: endDate,
      );

      final logs = await logRepository.getLogs(
        deviceId: deviceId,
        startDate: startDate,
        endDate: endDate,
      );

      // Calculate statistics
      final avgBattery = telemetry.isNotEmpty
          ? telemetry.map((t) => t.batteryPercentage).reduce((a, b) => a + b) /
              telemetry.length
          : 0.0;

      final maxBattery = telemetry.isNotEmpty
          ? telemetry
              .map((t) => t.batteryPercentage)
              .reduce((a, b) => a > b ? a : b)
          : 0;

      final minBattery = telemetry.isNotEmpty
          ? telemetry
              .map((t) => t.batteryPercentage)
              .reduce((a, b) => a < b ? a : b)
          : 0;

      final uvOnCount = telemetry.where((t) => t.uvStatus).length;
      final pumpOnCount = telemetry.where((t) => t.pumpStatus).length;

      return {
        'averageBattery': avgBattery.round(),
        'maxBattery': maxBattery,
        'minBattery': minBattery,
        'uvOnPercentage': telemetry.isNotEmpty
            ? (uvOnCount / telemetry.length * 100).round()
            : 0,
        'pumpOnPercentage': telemetry.isNotEmpty
            ? (pumpOnCount / telemetry.length * 100).round()
            : 0,
        'totalCommands': logs.length,
        'dataPoints': telemetry.length,
      };
    } catch (e) {
      Logger.e('GetStatistics', 'Failed to get statistics', e);
      return {
        'averageBattery': 0,
        'maxBattery': 0,
        'minBattery': 0,
        'uvOnPercentage': 0,
        'pumpOnPercentage': 0,
        'totalCommands': 0,
        'dataPoints': 0,
      };
    }
  }
}
