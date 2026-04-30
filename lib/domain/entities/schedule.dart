import 'package:equatable/equatable.dart';

enum ScheduleType {
  uv,
  pump,
}

enum ScheduleAction {
  turnOn,
  turnOff,
  toggle,
}

class Schedule extends Equatable {
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

  const Schedule({
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
