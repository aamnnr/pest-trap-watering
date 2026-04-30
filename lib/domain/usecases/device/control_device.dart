import '../../repositories/device_repository.dart';
import '../../../data/datasources/remote/mqtt_service.dart';
import '../../../core/utils/logger.dart';

enum ControlType {
  pump,
  uv,
}

enum ControlAction {
  turnOn,
  turnOff,
  toggle,
}

class ControlDevice {
  final MQTTService mqttService;
  final DeviceRepository deviceRepository;

  ControlDevice({
    required this.mqttService,
    required this.deviceRepository,
  });

  Future<bool> execute({
    required String deviceId,
    required ControlType type,
    required ControlAction action,
    int? durationSeconds,
  }) async {
    try {
      String command;
      Map<String, dynamic> params = {};

      // Build command based on type and action
      if (type == ControlType.pump) {
        switch (action) {
          case ControlAction.turnOn:
            command = 'pump_on';
            if (durationSeconds != null) {
              params['duration_sec'] = durationSeconds;
            }
            break;
          case ControlAction.turnOff:
            command = 'pump_off';
            break;
          case ControlAction.toggle:
            command = 'pump_toggle';
            break;
        }
      } else {
        switch (action) {
          case ControlAction.turnOn:
            command = 'uv_on';
            break;
          case ControlAction.turnOff:
            command = 'uv_off';
            break;
          case ControlAction.toggle:
            command = 'uv_toggle';
            break;
        }
      }

      final success = await mqttService.sendCommand(deviceId, command, params);

      if (success) {
        Logger.d('ControlDevice', 'Command sent: $command to $deviceId');

        // Log activity
        await _logActivity(deviceId, command, params);
      }

      return success;
    } catch (e) {
      Logger.e('ControlDevice', 'Failed to control device', e);
      return false;
    }
  }

  Future<void> _logActivity(
      String deviceId, String command, Map<String, dynamic> params) async {
    // This will be implemented when we have ActivityLogRepository
    // For now, just log to console
    Logger.d('ControlDevice', 'Activity logged: $command on $deviceId');
  }
}
