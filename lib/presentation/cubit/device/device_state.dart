import '../../../domain/entities/device.dart';

abstract class DeviceState {
  const DeviceState();
}

class DeviceInitial extends DeviceState {}

class DeviceLoading extends DeviceState {}

class DeviceLoaded extends DeviceState {
  final List<Device> devices;

  const DeviceLoaded(this.devices);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DeviceLoaded && other.devices == devices;
  }

  @override
  int get hashCode => devices.hashCode;
}

class DeviceError extends DeviceState {
  final String message;

  const DeviceError(this.message);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DeviceError && other.message == message;
  }

  @override
  int get hashCode => message.hashCode;
}
