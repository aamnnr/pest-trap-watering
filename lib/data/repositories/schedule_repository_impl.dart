import '../../../domain/entities/schedule.dart';
import '../../../domain/repositories/schedule_repository.dart';
import '../datasources/local/schedule_local_datasource.dart';
import '../models/schedule/schedule_model.dart';
import '../../../core/utils/logger.dart';

class ScheduleRepositoryImpl implements ScheduleRepository {
  final ScheduleLocalDataSource localDataSource;

  ScheduleRepositoryImpl({required this.localDataSource});

  @override
  Future<List<Schedule>> getSchedules({String? deviceId}) async {
    try {
      final models = await localDataSource.getSchedules(deviceId: deviceId);
      return models.map((model) => model.toEntity()).toList();
    } catch (e) {
      Logger.e('ScheduleRepositoryImpl', 'Failed to get schedules', e);
      return [];
    }
  }

  @override
  Future<Schedule?> getSchedule(String id) async {
    try {
      final model = await localDataSource.getScheduleById(id);
      return model?.toEntity();
    } catch (e) {
      Logger.e('ScheduleRepositoryImpl', 'Failed to get schedule', e);
      return null;
    }
  }

  @override
  Future<void> createSchedule(Schedule schedule) async {
    try {
      final model = ScheduleModel.fromEntity(schedule);
      await localDataSource.saveSchedule(model);
      Logger.d('ScheduleRepositoryImpl', 'Schedule created: ${schedule.id}');
    } catch (e) {
      Logger.e('ScheduleRepositoryImpl', 'Failed to create schedule', e);
      throw Exception('Failed to create schedule: $e');
    }
  }

  @override
  Future<void> updateSchedule(Schedule schedule) async {
    try {
      final model = ScheduleModel.fromEntity(schedule);
      await localDataSource.updateSchedule(model);
      Logger.d('ScheduleRepositoryImpl', 'Schedule updated: ${schedule.id}');
    } catch (e) {
      Logger.e('ScheduleRepositoryImpl', 'Failed to update schedule', e);
      throw Exception('Failed to update schedule: $e');
    }
  }

  @override
  Future<void> deleteSchedule(String id) async {
    try {
      await localDataSource.deleteSchedule(id);
      Logger.d('ScheduleRepositoryImpl', 'Schedule deleted: $id');
    } catch (e) {
      Logger.e('ScheduleRepositoryImpl', 'Failed to delete schedule', e);
      throw Exception('Failed to delete schedule: $e');
    }
  }

  @override
  Future<void> toggleSchedule(String id, bool isEnabled) async {
    try {
      await localDataSource.toggleSchedule(id, isEnabled);
      Logger.d('ScheduleRepositoryImpl', 'Schedule toggled: $id -> $isEnabled');
    } catch (e) {
      Logger.e('ScheduleRepositoryImpl', 'Failed to toggle schedule', e);
      throw Exception('Failed to toggle schedule: $e');
    }
  }
}
