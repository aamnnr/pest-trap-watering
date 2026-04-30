import 'package:flutter_bloc/flutter_bloc.dart';
import 'schedule_state.dart';
import '../../../domain/usecases/schedule/create_schedule.dart';
import '../../../domain/usecases/schedule/get_schedules.dart';
import '../../../domain/usecases/schedule/update_schedule.dart';
import '../../../domain/usecases/schedule/delete_schedule.dart';
import '../../../domain/usecases/schedule/toggle_schedule.dart';
import '../../../domain/entities/schedule.dart';
import '../../../core/utils/logger.dart';

class ScheduleCubit extends Cubit<ScheduleState> {
  final CreateSchedule createSchedule;
  final GetSchedules getSchedules;
  final UpdateSchedule updateSchedule;
  final DeleteSchedule deleteSchedule;
  final ToggleSchedule toggleSchedule;

  ScheduleCubit({
    required this.createSchedule,
    required this.getSchedules,
    required this.updateSchedule,
    required this.deleteSchedule,
    required this.toggleSchedule,
  }) : super(ScheduleInitial());

  Future<void> loadSchedules({String? deviceId}) async {
    emit(ScheduleLoading());
    try {
      final schedules = await getSchedules.execute(deviceId: deviceId);
      emit(ScheduleLoaded(schedules));
      Logger.d('ScheduleCubit', 'Loaded ${schedules.length} schedules');
    } catch (e) {
      emit(ScheduleError('Failed to load schedules: $e'));
      Logger.e('ScheduleCubit', 'Failed to load schedules', e);
    }
  }

  Future<bool> addSchedule({
    required String deviceId,
    required ScheduleType type,
    required ScheduleAction action,
    required String startTime,
    String? endTime,
    List<int> repeatDays = const [],
  }) async {
    try {
      await createSchedule.execute(
        deviceId: deviceId,
        type: type,
        action: action,
        startTime: startTime,
        endTime: endTime,
        repeatDays: repeatDays,
      );
      await loadSchedules(deviceId: deviceId);
      Logger.d('ScheduleCubit', 'Schedule added successfully');
      return true;
    } catch (e) {
      Logger.e('ScheduleCubit', 'Failed to add schedule', e);
      return false;
    }
  }

  Future<bool> editSchedule(Schedule schedule) async {
    try {
      await updateSchedule.execute(schedule);
      await loadSchedules(deviceId: schedule.deviceId);
      Logger.d('ScheduleCubit', 'Schedule updated successfully');
      return true;
    } catch (e) {
      Logger.e('ScheduleCubit', 'Failed to update schedule', e);
      return false;
    }
  }

  Future<bool> removeSchedule(String scheduleId, {String? deviceId}) async {
    try {
      await deleteSchedule.execute(scheduleId);
      await loadSchedules(deviceId: deviceId);
      Logger.d('ScheduleCubit', 'Schedule deleted successfully');
      return true;
    } catch (e) {
      Logger.e('ScheduleCubit', 'Failed to delete schedule', e);
      return false;
    }
  }

  Future<bool> toggleScheduleStatus(String scheduleId, bool isEnabled,
      {String? deviceId}) async {
    try {
      await toggleSchedule.execute(scheduleId, isEnabled);
      await loadSchedules(deviceId: deviceId);
      Logger.d('ScheduleCubit', 'Schedule toggled successfully');
      return true;
    } catch (e) {
      Logger.e('ScheduleCubit', 'Failed to toggle schedule', e);
      return false;
    }
  }
}
