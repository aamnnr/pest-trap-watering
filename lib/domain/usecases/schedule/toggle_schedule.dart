import '../../repositories/schedule_repository.dart';
import '../../../core/utils/logger.dart';

class ToggleSchedule {
  final ScheduleRepository repository;

  ToggleSchedule(this.repository);

  Future<void> execute(String scheduleId, bool isEnabled) async {
    try {
      await repository.toggleSchedule(scheduleId, isEnabled);
      Logger.d('ToggleSchedule', 'Schedule toggled: $scheduleId -> $isEnabled');
    } catch (e) {
      Logger.e('ToggleSchedule', 'Failed to toggle schedule', e);
      throw Exception('Failed to toggle schedule: $e');
    }
  }
}
