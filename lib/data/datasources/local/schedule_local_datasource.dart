import 'package:sqflite/sqflite.dart';
import '../../../core/storage/database_helper.dart';
import '../../../core/utils/logger.dart';
import '../../models/schedule/schedule_model.dart';

class ScheduleLocalDataSource {
  Future<List<ScheduleModel>> getSchedules({String? deviceId}) async {
    try {
      final db = await DatabaseHelper.database;
      List<Map<String, dynamic>> result;

      if (deviceId != null) {
        result = await db.query(
          DatabaseHelper.tableSchedules,
          where: 'device_id = ?',
          whereArgs: [deviceId],
          orderBy: 'start_time ASC',
        );
      } else {
        result = await db.query(
          DatabaseHelper.tableSchedules,
          orderBy: 'created_at DESC',
        );
      }

      return result.map((json) => ScheduleModel.fromJson(json)).toList();
    } catch (e) {
      Logger.e('ScheduleLocalDataSource', 'Failed to get schedules', e);
      return [];
    }
  }

  Future<ScheduleModel?> getScheduleById(String id) async {
    try {
      final db = await DatabaseHelper.database;
      final result = await db.query(
        DatabaseHelper.tableSchedules,
        where: 'id = ?',
        whereArgs: [id],
      );

      if (result.isNotEmpty) {
        return ScheduleModel.fromJson(result.first);
      }
      return null;
    } catch (e) {
      Logger.e('ScheduleLocalDataSource', 'Failed to get schedule by id', e);
      return null;
    }
  }

  Future<void> saveSchedule(ScheduleModel schedule) async {
    try {
      final db = await DatabaseHelper.database;
      await db.insert(
        DatabaseHelper.tableSchedules,
        schedule.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      Logger.d('ScheduleLocalDataSource', 'Schedule saved: ${schedule.id}');
    } catch (e) {
      Logger.e('ScheduleLocalDataSource', 'Failed to save schedule', e);
      throw Exception('Failed to save schedule: $e');
    }
  }

  Future<void> updateSchedule(ScheduleModel schedule) async {
    try {
      final db = await DatabaseHelper.database;
      await db.update(
        DatabaseHelper.tableSchedules,
        schedule.toJson(),
        where: 'id = ?',
        whereArgs: [schedule.id],
      );
      Logger.d('ScheduleLocalDataSource', 'Schedule updated: ${schedule.id}');
    } catch (e) {
      Logger.e('ScheduleLocalDataSource', 'Failed to update schedule', e);
      throw Exception('Failed to update schedule: $e');
    }
  }

  Future<void> deleteSchedule(String id) async {
    try {
      final db = await DatabaseHelper.database;
      await db.delete(
        DatabaseHelper.tableSchedules,
        where: 'id = ?',
        whereArgs: [id],
      );
      Logger.d('ScheduleLocalDataSource', 'Schedule deleted: $id');
    } catch (e) {
      Logger.e('ScheduleLocalDataSource', 'Failed to delete schedule', e);
      throw Exception('Failed to delete schedule: $e');
    }
  }

  Future<void> toggleSchedule(String id, bool isEnabled) async {
    try {
      final db = await DatabaseHelper.database;
      await db.update(
        DatabaseHelper.tableSchedules,
        {'is_enabled': isEnabled ? 1 : 0},
        where: 'id = ?',
        whereArgs: [id],
      );
      Logger.d(
          'ScheduleLocalDataSource', 'Schedule toggled: $id -> $isEnabled');
    } catch (e) {
      Logger.e('ScheduleLocalDataSource', 'Failed to toggle schedule', e);
      throw Exception('Failed to toggle schedule: $e');
    }
  }
}
