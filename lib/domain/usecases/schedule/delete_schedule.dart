import '../../repositories/schedule_repository.dart';
import '../../../core/utils/logger.dart';

class DeleteSchedule {
  final ScheduleRepository repository;

  DeleteSchedule(this.repository);

  Future<void> execute(String scheduleId) async {
    try {
      await repository.deleteSchedule(scheduleId);
      Logger.d('DeleteSchedule', 'Schedule deleted: $scheduleId');
    } catch (e) {
      Logger.e('DeleteSchedule', 'Failed to delete schedule', e);
      throw Exception('Failed to delete schedule: $e');
    }
  }
}
