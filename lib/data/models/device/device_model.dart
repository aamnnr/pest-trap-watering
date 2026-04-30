import 'package:equatable/equatable.dart';
import '../../../domain/entities/device.dart';

class DeviceModel extends Equatable {
  final String id;
  final String name;
  final String macAddress;
  final String deviceId;
  final String mqttTopic;
  final String? location;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const DeviceModel({
    required this.id,
    required this.name,
    required this.macAddress,
    required this.deviceId,
    required this.mqttTopic,
    this.location,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  factory DeviceModel.fromJson(Map<String, dynamic> json) {
    return DeviceModel(
      id: json['id'] as String,
      name: json['name'] as String,
      macAddress: json['mac_address'] as String,
      deviceId: json['device_id'] as String,
      mqttTopic: json['mqtt_topic'] as String,
      location: json['location'] as String?,
      isActive: (json['is_active'] as int?) == 1,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'mac_address': macAddress,
      'device_id': deviceId,
      'mqtt_topic': mqttTopic,
      'location': location,
      'is_active': isActive ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory DeviceModel.fromEntity(Device device) {
    return DeviceModel(
      id: device.id,
      name: device.name,
      macAddress: device.macAddress,
      deviceId: device.deviceId,
      mqttTopic: device.mqttTopic,
      location: device.location,
      isActive: device.isActive,
      createdAt: device.createdAt,
      updatedAt: device.updatedAt,
    );
  }

  Device toEntity() {
    return Device(
      id: id,
      name: name,
      macAddress: macAddress,
      deviceId: deviceId,
      mqttTopic: mqttTopic,
      location: location,
      isActive: isActive,
      status: DeviceStatus.offline, // Default, will be updated by telemetry
      telemetry: null,
      lastSeen: updatedAt,
      createdAt: createdAt,
      updatedAt: updatedAt,
      config: const DeviceConfig(uvStartHour: 18, uvEndHour: 23),
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        macAddress,
        deviceId,
        mqttTopic,
        location,
        isActive,
        createdAt,
        updatedAt,
      ];
}

class DeviceTelemetryModel extends Equatable {
  final String deviceId;
  final int batteryPercentage;
  final bool uvStatus;
  final bool pumpStatus;
  final bool isNight;
  final DateTime timestamp;

  const DeviceTelemetryModel({
    required this.deviceId,
    required this.batteryPercentage,
    required this.uvStatus,
    required this.pumpStatus,
    required this.isNight,
    required this.timestamp,
  });

  factory DeviceTelemetryModel.fromJson(Map<String, dynamic> json) {
    return DeviceTelemetryModel(
      deviceId: json['device_id'] as String,
      batteryPercentage: json['battery_percentage'] as int,
      uvStatus: (json['uv_status'] as int) == 1,
      pumpStatus: (json['pump_status'] as int) == 1,
      isNight: (json['is_night'] as int) == 1,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'device_id': deviceId,
      'battery_percentage': batteryPercentage,
      'uv_status': uvStatus ? 1 : 0,
      'pump_status': pumpStatus ? 1 : 0,
      'is_night': isNight ? 1 : 0,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory DeviceTelemetryModel.fromMqtt(
      String deviceId, Map<String, dynamic> data) {
    return DeviceTelemetryModel(
      deviceId: deviceId,
      batteryPercentage: data['bat'] ?? 0,
      uvStatus: data['uv'] == 1,
      pumpStatus: data['pump'] == 1,
      isNight: data['is_night'] == true,
      timestamp:
          data['time'] != null ? DateTime.parse(data['time']) : DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [
        deviceId,
        batteryPercentage,
        uvStatus,
        pumpStatus,
        isNight,
        timestamp,
      ];
}

class DeviceConfigModel extends Equatable {
  final String deviceId;
  final int uvStartHour;
  final int uvEndHour;
  final int sleepInterval;
  final bool autoMode;
  final DateTime updatedAt;

  const DeviceConfigModel({
    required this.deviceId,
    required this.uvStartHour,
    required this.uvEndHour,
    required this.sleepInterval,
    required this.autoMode,
    required this.updatedAt,
  });

  factory DeviceConfigModel.fromJson(Map<String, dynamic> json) {
    return DeviceConfigModel(
      deviceId: json['device_id'] as String,
      uvStartHour: json['uv_start_hour'] as int,
      uvEndHour: json['uv_end_hour'] as int,
      sleepInterval: json['sleep_interval'] as int,
      autoMode: (json['auto_mode'] as int) == 1,
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'device_id': deviceId,
      'uv_start_hour': uvStartHour,
      'uv_end_hour': uvEndHour,
      'sleep_interval': sleepInterval,
      'auto_mode': autoMode ? 1 : 0,
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
        deviceId,
        uvStartHour,
        uvEndHour,
        sleepInterval,
        autoMode,
        updatedAt,
      ];
}
