import 'package:equatable/equatable.dart';

class ActivityLogModel extends Equatable {
  final int? id;
  final String deviceId;
  final String action;
  final String source;
  final String? details;
  final String status;
  final DateTime timestamp;

  const ActivityLogModel({
    this.id,
    required this.deviceId,
    required this.action,
    required this.source,
    this.details,
    required this.status,
    required this.timestamp,
  });

  factory ActivityLogModel.fromJson(Map<String, dynamic> json) {
    return ActivityLogModel(
      id: json['id'] as int?,
      deviceId: json['device_id'] as String,
      action: json['action'] as String,
      source: json['source'] as String,
      details: json['details'] as String?,
      status: json['status'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'device_id': deviceId,
      'action': action,
      'source': source,
      'details': details,
      'status': status,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
        id,
        deviceId,
        action,
        source,
        details,
        status,
        timestamp,
      ];
}

class HistoricalDataModel extends Equatable {
  final String deviceId;
  final DateTime date;
  final double avgBattery;
  final int maxBattery;
  final int minBattery;
  final int totalUvOnMinutes;
  final int totalPumpOnMinutes;
  final int totalCommands;

  const HistoricalDataModel({
    required this.deviceId,
    required this.date,
    required this.avgBattery,
    required this.maxBattery,
    required this.minBattery,
    required this.totalUvOnMinutes,
    required this.totalPumpOnMinutes,
    required this.totalCommands,
  });

  @override
  List<Object?> get props => [
        deviceId,
        date,
        avgBattery,
        maxBattery,
        minBattery,
        totalUvOnMinutes,
        totalPumpOnMinutes,
        totalCommands,
      ];
}
