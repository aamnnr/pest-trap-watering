import '../entities/schedule.dart';

abstract class ScheduleRepository {
  Future<List<Schedule>> getSchedules({String? deviceId});
  Future<Schedule?> getSchedule(String id);
  Future<void> createSchedule(Schedule schedule);
  Future<void> updateSchedule(Schedule schedule);
  Future<void> deleteSchedule(String id);
  Future<void> toggleSchedule(String id, bool isEnabled);
}
