import '../../entities/schedule.dart';
import '../../repositories/schedule_repository.dart';
import '../../../core/utils/logger.dart';

class UpdateSchedule {
  final ScheduleRepository repository;

  UpdateSchedule(this.repository);

  Future<void> execute(Schedule schedule) async {
    try {
      await repository.updateSchedule(schedule);
      Logger.d('UpdateSchedule', 'Schedule updated: ${schedule.id}');
    } catch (e) {
      Logger.e('UpdateSchedule', 'Failed to update schedule', e);
      throw Exception('Failed to update schedule: $e');
    }
  }
}
