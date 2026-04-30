import '../../../domain/entities/schedule.dart';

abstract class ScheduleState {
  const ScheduleState();
}

class ScheduleInitial extends ScheduleState {}

class ScheduleLoading extends ScheduleState {}

class ScheduleLoaded extends ScheduleState {
  final List<Schedule> schedules;

  const ScheduleLoaded(this.schedules);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ScheduleLoaded && other.schedules == schedules;
  }

  @override
  int get hashCode => schedules.hashCode;
}

class ScheduleError extends ScheduleState {
  final String message;

  const ScheduleError(this.message);
}
