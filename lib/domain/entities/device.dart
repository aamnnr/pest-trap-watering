import 'package:equatable/equatable.dart';

enum DeviceStatus {
  online,
  offline,
  sleeping,
  configuring,
}

class Device extends Equatable {
  final String id;
  final String name;
  final String macAddress;
  final String deviceId;
  final String mqttTopic;
  final String? location;
  final bool isActive;
  final DeviceStatus status;
  final DeviceTelemetry? telemetry;
  final DateTime lastSeen;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DeviceConfig config;

  const Device({
    required this.id,
    required this.name,
    required this.macAddress,
    required this.deviceId,
    required this.mqttTopic,
    this.location,
    this.isActive = true,
    this.status = DeviceStatus.offline,
    this.telemetry,
    required this.lastSeen,
    required this.createdAt,
    required this.updatedAt,
    required this.config,
  });

  Device copyWith({
    String? name,
    String? location,
    bool? isActive,
    DeviceStatus? status,
    DeviceTelemetry? telemetry,
    DateTime? lastSeen,
    DateTime? updatedAt,
    DeviceConfig? config,
  }) {
    return Device(
      id: id,
      name: name ?? this.name,
      macAddress: macAddress,
      deviceId: deviceId,
      mqttTopic: mqttTopic,
      location: location ?? this.location,
      isActive: isActive ?? this.isActive,
      status: status ?? this.status,
      telemetry: telemetry ?? this.telemetry,
      lastSeen: lastSeen ?? this.lastSeen,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      config: config ?? this.config,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        macAddress,
        deviceId,
        location,
        isActive,
        status,
        telemetry,
        lastSeen,
        createdAt,
        updatedAt,
        config,
      ];
}

class DeviceTelemetry extends Equatable {
  final int batteryPercentage;
  final bool uvStatus;
  final bool pumpStatus;
  final bool isNight;
  final DateTime timestamp;

  const DeviceTelemetry({
    required this.batteryPercentage,
    required this.uvStatus,
    required this.pumpStatus,
    required this.isNight,
    required this.timestamp,
  });

  @override
  List<Object?> get props => [
        batteryPercentage,
        uvStatus,
        pumpStatus,
        isNight,
        timestamp,
      ];
}

class DeviceConfig extends Equatable {
  final int uvStartHour;
  final int uvEndHour;
  final int sleepInterval;
  final bool autoMode;

  const DeviceConfig({
    required this.uvStartHour,
    required this.uvEndHour,
    this.sleepInterval = 600,
    this.autoMode = true,
  });

  DeviceConfig copyWith({
    int? uvStartHour,
    int? uvEndHour,
    int? sleepInterval,
    bool? autoMode,
  }) {
    return DeviceConfig(
      uvStartHour: uvStartHour ?? this.uvStartHour,
      uvEndHour: uvEndHour ?? this.uvEndHour,
      sleepInterval: sleepInterval ?? this.sleepInterval,
      autoMode: autoMode ?? this.autoMode,
    );
  }

  @override
  List<Object?> get props => [uvStartHour, uvEndHour, sleepInterval, autoMode];
}
