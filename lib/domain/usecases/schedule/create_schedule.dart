import 'dart:math';
import '../../entities/schedule.dart';
import '../../repositories/schedule_repository.dart';
import '../../../core/utils/logger.dart';

class CreateSchedule {
  final ScheduleRepository repository;

  CreateSchedule(this.repository);

  Future<void> execute({
    required String deviceId,
    required ScheduleType type,
    required ScheduleAction action,
    required String startTime,
    String? endTime,
    List<int> repeatDays = const [],
  }) async {
    try {
      final id = _generateId();
      final schedule = Schedule(
        id: id,
        deviceId: deviceId,
        type: type,
        action: action,
        startTime: startTime,
        endTime: endTime,
        repeatDays: repeatDays,
        isEnabled: true,
        createdAt: DateTime.now(),
        updatedAt: null,
      );

      await repository.createSchedule(schedule);
      Logger.d('CreateSchedule', 'Schedule created: $id');
    } catch (e) {
      Logger.e('CreateSchedule', 'Failed to create schedule', e);
      throw Exception('Failed to create schedule: $e');
    }
  }

  String _generateId() {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final random = Random();
    return String.fromCharCodes(Iterable.generate(
        16, (_) => chars.codeUnitAt(random.nextInt(chars.length))));
  }
}
