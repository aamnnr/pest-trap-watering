import '../entities/activity_log.dart';

abstract class LogRepository {
  Future<void> saveLog(ActivityLog log);
  Future<List<ActivityLog>> getLogs({
    String? deviceId,
    DateTime? startDate,
    DateTime? endDate,
    String? action,
    int? limit,
    int? offset,
  });
  Future<int> getLogsCount({
    String? deviceId,
    DateTime? startDate,
    DateTime? endDate,
    String? action,
  });
  Future<void> cleanOldLogs(int daysToKeep);
}
