import '../../entities/schedule.dart';
import '../../repositories/schedule_repository.dart';
import '../../../core/utils/logger.dart';

class GetSchedules {
  final ScheduleRepository repository;

  GetSchedules(this.repository);

  Future<List<Schedule>> execute({String? deviceId}) async {
    try {
      final schedules = await repository.getSchedules(deviceId: deviceId);
      Logger.d('GetSchedules', 'Retrieved ${schedules.length} schedules');
      return schedules;
    } catch (e) {
      Logger.e('GetSchedules', 'Failed to get schedules', e);
      return [];
    }
  }
}
