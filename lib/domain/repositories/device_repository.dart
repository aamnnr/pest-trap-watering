import '../entities/device.dart';

abstract class DeviceRepository {
  Future<List<Device>> getDevices();
  Future<Device?> getDevice(String id);
  Future<Device?> getDeviceByMacAddress(String macAddress);
  Future<void> addDevice(Device device);
  Future<void> updateDevice(Device device);
  Future<void> deleteDevice(String id);
  Future<void> updateDeviceStatus(String id, DeviceStatus status);
  Future<void> saveTelemetry(DeviceTelemetry telemetry, String deviceId);
  Future<List<DeviceTelemetry>> getTelemetryHistory(
    String deviceId, {
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
  });
  Future<DeviceConfig> getDeviceConfig(String deviceId);
  Future<void> updateDeviceConfig(String deviceId, DeviceConfig config);
}
