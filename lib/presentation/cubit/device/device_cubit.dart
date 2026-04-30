import 'package:flutter_bloc/flutter_bloc.dart';
import 'device_state.dart';
import '../../../domain/usecases/device/get_devices.dart';
import '../../../domain/usecases/device/add_device.dart';
import '../../../domain/usecases/device/update_device.dart';
import '../../../domain/usecases/device/delete_device.dart';
import '../../../domain/usecases/device/control_device.dart';
import '../../../domain/entities/device.dart';
import '../../../core/utils/logger.dart';

class DeviceCubit extends Cubit<DeviceState> {
  final GetDevices getDevices;
  final AddDevice addDevice;
  final UpdateDevice updateDevice;
  final DeleteDevice deleteDevice;
  final ControlDevice controlDevice;

  DeviceCubit({
    required this.getDevices,
    required this.addDevice,
    required this.updateDevice,
    required this.deleteDevice,
    required this.controlDevice,
  }) : super(DeviceInitial());

  Future<void> loadDevices() async {
    emit(DeviceLoading());
    try {
      final devices = await getDevices.execute();
      emit(DeviceLoaded(devices));
      Logger.d('DeviceCubit', 'Loaded ${devices.length} devices');
    } catch (e) {
      emit(DeviceError('Failed to load devices: $e'));
      Logger.e('DeviceCubit', 'Failed to load devices', e);
    }
  }

  Future<bool> addNewDevice({
    required String id,
    required String name,
    required String macAddress,
    required String deviceId,
    required String mqttTopic,
    String? location,
    required DeviceConfig config,
  }) async {
    try {
      await addDevice.execute(
        id: id,
        name: name,
        macAddress: macAddress,
        deviceId: deviceId,
        mqttTopic: mqttTopic,
        location: location,
        config: config,
      );
      await loadDevices(); // Refresh list
      Logger.d('DeviceCubit', 'Device added successfully');
      return true;
    } catch (e) {
      Logger.e('DeviceCubit', 'Failed to add device', e);
      return false;
    }
  }

  Future<bool> editDevice(Device device) async {
    try {
      await updateDevice.execute(device);
      await loadDevices(); // Refresh list
      Logger.d('DeviceCubit', 'Device updated successfully');
      return true;
    } catch (e) {
      Logger.e('DeviceCubit', 'Failed to update device', e);
      return false;
    }
  }

  Future<bool> removeDevice(String deviceId) async {
    try {
      await deleteDevice.execute(deviceId);
      await loadDevices(); // Refresh list
      Logger.d('DeviceCubit', 'Device deleted successfully');
      return true;
    } catch (e) {
      Logger.e('DeviceCubit', 'Failed to delete device', e);
      return false;
    }
  }

  Future<bool> sendControlCommand({
    required String deviceId,
    required ControlType type,
    required ControlAction action,
    int? durationSeconds,
  }) async {
    try {
      final success = await controlDevice.execute(
        deviceId: deviceId,
        type: type,
        action: action,
        durationSeconds: durationSeconds,
      );

      if (success) {
        Logger.d('DeviceCubit', 'Control command sent successfully');
        // Refresh device status
        await loadDevices();
      }

      return success;
    } catch (e) {
      Logger.e('DeviceCubit', 'Failed to send control command', e);
      return false;
    }
  }

  Device? getDeviceById(String id) {
    if (state is DeviceLoaded) {
      final devices = (state as DeviceLoaded).devices;
      try {
        return devices.firstWhere((device) => device.id == id);
      } catch (e) {
        return null;
      }
    }
    return null;
  }
}
