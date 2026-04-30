import '../../../core/storage/database_helper.dart';
import '../../../core/utils/logger.dart';
import '../../models/log/activity_log_model.dart';

class LogLocalDataSource {
  Future<void> saveLog(ActivityLogModel log) async {
    try {
      final db = await DatabaseHelper.database;
      await db.insert(
        DatabaseHelper.tableActivityLogs,
        log.toJson(),
      );
      Logger.d('LogLocalDataSource', 'Log saved: ${log.action}');
    } catch (e) {
      Logger.e('LogLocalDataSource', 'Failed to save log', e);
    }
  }

  Future<List<ActivityLogModel>> getLogs({
    String? deviceId,
    DateTime? startDate,
    DateTime? endDate,
    String? action,
    int? limit,
    int? offset,
  }) async {
    try {
      final db = await DatabaseHelper.database;
      var query = 'SELECT * FROM ${DatabaseHelper.tableActivityLogs} WHERE 1=1';
      final args = <dynamic>[];

      if (deviceId != null) {
        query += ' AND device_id = ?';
        args.add(deviceId);
      }

      if (startDate != null) {
        query += ' AND timestamp >= ?';
        args.add(startDate.toIso8601String());
      }

      if (endDate != null) {
        query += ' AND timestamp <= ?';
        args.add(endDate.toIso8601String());
      }

      if (action != null) {
        query += ' AND action = ?';
        args.add(action);
      }

      query += ' ORDER BY timestamp DESC';

      if (limit != null) {
        query += ' LIMIT $limit';
      }

      if (offset != null) {
        query += ' OFFSET $offset';
      }

      final result = await db.rawQuery(query, args);
      return result.map((json) => ActivityLogModel.fromJson(json)).toList();
    } catch (e) {
      Logger.e('LogLocalDataSource', 'Failed to get logs', e);
      return [];
    }
  }

  Future<int> getLogsCount({
    String? deviceId,
    DateTime? startDate,
    DateTime? endDate,
    String? action,
  }) async {
    try {
      final db = await DatabaseHelper.database;
      var query =
          'SELECT COUNT(*) as count FROM ${DatabaseHelper.tableActivityLogs} WHERE 1=1';
      final args = <dynamic>[];

      if (deviceId != null) {
        query += ' AND device_id = ?';
        args.add(deviceId);
      }

      if (startDate != null) {
        query += ' AND timestamp >= ?';
        args.add(startDate.toIso8601String());
      }

      if (endDate != null) {
        query += ' AND timestamp <= ?';
        args.add(endDate.toIso8601String());
      }

      if (action != null) {
        query += ' AND action = ?';
        args.add(action);
      }

      final result = await db.rawQuery(query, args);
      return result.first['count'] as int;
    } catch (e) {
      Logger.e('LogLocalDataSource', 'Failed to get logs count', e);
      return 0;
    }
  }

  Future<void> cleanOldLogs(int daysToKeep) async {
    try {
      final db = await DatabaseHelper.database;
      final cutoffDate = DateTime.now().subtract(Duration(days: daysToKeep));

      await db.delete(
        DatabaseHelper.tableActivityLogs,
        where: 'timestamp < ?',
        whereArgs: [cutoffDate.toIso8601String()],
      );
      Logger.d(
          'LogLocalDataSource', 'Cleaned logs older than $daysToKeep days');
    } catch (e) {
      Logger.e('LogLocalDataSource', 'Failed to clean old logs', e);
    }
  }
}
