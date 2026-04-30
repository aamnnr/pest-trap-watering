import 'package:equatable/equatable.dart';
import '../../../domain/entities/schedule.dart';

class ScheduleModel extends Equatable {
  final String id;
  final String deviceId;
  final ScheduleType type;
  final ScheduleAction action;
  final String startTime;
  final String? endTime;
  final List<int> repeatDays;
  final bool isEnabled;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const ScheduleModel({
    required this.id,
    required this.deviceId,
    required this.type,
    required this.action,
    required this.startTime,
    this.endTime,
    required this.repeatDays,
    this.isEnabled = true,
    required this.createdAt,
    this.updatedAt,
  });

  factory ScheduleModel.fromJson(Map<String, dynamic> json) {
    return ScheduleModel(
      id: json['id'] as String,
      deviceId: json['device_id'] as String,
      type: ScheduleType.values[json['type'] as int],
      action: ScheduleAction.values[json['action'] as int],
      startTime: json['start_time'] as String,
      endTime: json['end_time'] as String?,
      repeatDays:
          (json['repeat_days'] as String).split(',').map(int.parse).toList(),
      isEnabled: (json['is_enabled'] as int) == 1,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'device_id': deviceId,
      'type': type.index,
      'action': action.index,
      'start_time': startTime,
      'end_time': endTime,
      'repeat_days': repeatDays.join(','),
      'is_enabled': isEnabled ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  factory ScheduleModel.fromEntity(Schedule schedule) {
    return ScheduleModel(
      id: schedule.id,
      deviceId: schedule.deviceId,
      type: schedule.type,
      action: schedule.action,
      startTime: schedule.startTime,
      endTime: schedule.endTime,
      repeatDays: schedule.repeatDays,
      isEnabled: schedule.isEnabled,
      createdAt: schedule.createdAt,
      updatedAt: schedule.updatedAt,
    );
  }

  Schedule toEntity() {
    return Schedule(
      id: id,
      deviceId: deviceId,
      type: type,
      action: action,
      startTime: startTime,
      endTime: endTime,
      repeatDays: repeatDays,
      isEnabled: isEnabled,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        deviceId,
        type,
        action,
        startTime,
        endTime,
        repeatDays,
        isEnabled,
        createdAt,
        updatedAt,
      ];
}
