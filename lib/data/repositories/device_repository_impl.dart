import '../../../domain/entities/device.dart';
import '../../../domain/repositories/device_repository.dart';
import '../datasources/local/device_local_datasource.dart';
import '../datasources/remote/mqtt_service.dart';
import '../models/device/device_model.dart';
import '../../../core/utils/logger.dart';

class DeviceRepositoryImpl implements DeviceRepository {
  final DeviceLocalDataSource localDataSource;
  final MQTTService mqttService;

  DeviceRepositoryImpl({
    required this.localDataSource,
    required this.mqttService,
  });

  @override
  Future<List<Device>> getDevices() async {
    try {
      final models = await localDataSource.getDevices();
      return models.map((model) => model.toEntity()).toList();
    } catch (e) {
      Logger.e('DeviceRepositoryImpl', 'Failed to get devices', e);
      return [];
    }
  }

  @override
  Future<Device?> getDevice(String id) async {
    try {
      final model = await localDataSource.getDeviceById(id);
      return model?.toEntity();
    } catch (e) {
      Logger.e('DeviceRepositoryImpl', 'Failed to get device', e);
      return null;
    }
  }

  @override
  Future<Device?> getDeviceByMacAddress(String macAddress) async {
    try {
      final model = await localDataSource.getDeviceByMacAddress(macAddress);
      return model?.toEntity();
    } catch (e) {
      Logger.e('DeviceRepositoryImpl', 'Failed to get device by mac', e);
      return null;
    }
  }

  @override
  Future<void> addDevice(Device device) async {
    try {
      final model = DeviceModel.fromEntity(device);
      await localDataSource.saveDevice(model);

      // Subscribe to device MQTT topic
      await mqttService.subscribeToDevice(device.deviceId);

      Logger.d('DeviceRepositoryImpl', 'Device added: ${device.name}');
    } catch (e) {
      Logger.e('DeviceRepositoryImpl', 'Failed to add device', e);
      throw Exception('Failed to add device: $e');
    }
  }

  @override
  Future<void> updateDevice(Device device) async {
    try {
      final model = DeviceModel.fromEntity(device);
      await localDataSource.updateDevice(model);
      Logger.d('DeviceRepositoryImpl', 'Device updated: ${device.name}');
    } catch (e) {
      Logger.e('DeviceRepositoryImpl', 'Failed to update device', e);
      throw Exception('Failed to update device: $e');
    }
  }

  @override
  Future<void> deleteDevice(String id) async {
    try {
      await localDataSource.deleteDevice(id);
      Logger.d('DeviceRepositoryImpl', 'Device deleted: $id');
    } catch (e) {
      Logger.e('DeviceRepositoryImpl', 'Failed to delete device', e);
      throw Exception('Failed to delete device: $e');
    }
  }

  @override
  Future<void> updateDeviceStatus(String id, DeviceStatus status) async {
    try {
      final device = await getDevice(id);
      if (device != null) {
        final updatedDevice =
            device.copyWith(status: status, lastSeen: DateTime.now());
        await updateDevice(updatedDevice);
      }
    } catch (e) {
      Logger.e('DeviceRepositoryImpl', 'Failed to update device status', e);
    }
  }

  @override
  Future<void> saveTelemetry(DeviceTelemetry telemetry, String deviceId) async {
    try {
      final model = DeviceTelemetryModel(
        deviceId: deviceId,
        batteryPercentage: telemetry.batteryPercentage,
        uvStatus: telemetry.uvStatus,
        pumpStatus: telemetry.pumpStatus,
        isNight: telemetry.isNight,
        timestamp: telemetry.timestamp,
      );

      await localDataSource.saveTelemetry(model);

      // Update device last seen and status
      final device = await getDevice(deviceId);
      if (device != null) {
        final updatedDevice = device.copyWith(
          telemetry: telemetry,
          lastSeen: DateTime.now(),
          status: DeviceStatus.online,
        );
        await updateDevice(updatedDevice);
      }

      Logger.d('DeviceRepositoryImpl', 'Telemetry saved for device: $deviceId');
    } catch (e) {
      Logger.e('DeviceRepositoryImpl', 'Failed to save telemetry', e);
    }
  }

  @override
  Future<List<DeviceTelemetry>> getTelemetryHistory(
    String deviceId, {
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
  }) async {
    try {
      final models = await localDataSource.getTelemetryHistory(
        deviceId,
        startDate: startDate,
        endDate: endDate,
        limit: limit ?? 100,
      );

      return models
          .map((model) => DeviceTelemetry(
                batteryPercentage: model.batteryPercentage,
                uvStatus: model.uvStatus,
                pumpStatus: model.pumpStatus,
                isNight: model.isNight,
                timestamp: model.timestamp,
              ))
          .toList();
    } catch (e) {
      Logger.e('DeviceRepositoryImpl', 'Failed to get telemetry history', e);
      return [];
    }
  }

  @override
  Future<DeviceConfig> getDeviceConfig(String deviceId) async {
    // For now, return default config
    // In future, this could be fetched from server or stored locally
    return const DeviceConfig(uvStartHour: 18, uvEndHour: 23);
  }

  @override
  Future<void> updateDeviceConfig(String deviceId, DeviceConfig config) async {
    try {
      // Send config to device via MQTT
      await mqttService.sendCommand(deviceId, 'update_config', {
        'uv_start': config.uvStartHour,
        'uv_stop': config.uvEndHour,
        'sleep_interval': config.sleepInterval,
        'auto_mode': config.autoMode,
      });

      // Update local device config
      final device = await getDevice(deviceId);
      if (device != null) {
        final updatedDevice = device.copyWith(config: config);
        await updateDevice(updatedDevice);
      }

      Logger.d('DeviceRepositoryImpl', 'Device config updated: $deviceId');
    } catch (e) {
      Logger.e('DeviceRepositoryImpl', 'Failed to update device config', e);
      throw Exception('Failed to update device config: $e');
    }
  }
}
