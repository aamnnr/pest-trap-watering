import 'package:flutter_bloc/flutter_bloc.dart';
import 'monitoring_state.dart';
import '../../../domain/usecases/monitoring/get_device_status.dart';
import '../../../domain/usecases/monitoring/get_battery_history.dart';
import '../../../domain/usecases/monitoring/get_statistics.dart';
import '../../../core/utils/logger.dart';

class MonitoringCubit extends Cubit<MonitoringState> {
  final GetDeviceStatus getDeviceStatus;
  final GetBatteryHistory getBatteryHistory;
  final GetStatistics getStatistics;

  MonitoringCubit({
    required this.getDeviceStatus,
    required this.getBatteryHistory,
    required this.getStatistics,
  }) : super(const MonitoringState());

  Future<void> loadDeviceStatus(String deviceId) async {
    emit(state.copyWith(isLoading: true));
    try {
      final status = await getDeviceStatus.execute(deviceId);
      emit(state.copyWith(
        isLoading: false,
        deviceStatus: status,
        error: null,
      ));
      Logger.d('MonitoringCubit', 'Device status loaded for $deviceId');
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: 'Failed to load device status: $e',
      ));
      Logger.e('MonitoringCubit', 'Failed to load device status', e);
    }
  }

  Future<void> loadBatteryHistory({
    required String deviceId,
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
  }) async {
    emit(state.copyWith(isLoading: true));
    try {
      final history = await getBatteryHistory.execute(
        deviceId: deviceId,
        startDate: startDate,
        endDate: endDate,
        limit: limit ?? 30,
      );
      emit(state.copyWith(
        isLoading: false,
        batteryHistory: history,
        error: null,
      ));
      Logger.d('MonitoringCubit',
          'Battery history loaded: ${history.length} records');
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: 'Failed to load battery history: $e',
      ));
      Logger.e('MonitoringCubit', 'Failed to load battery history', e);
    }
  }

  Future<void> loadStatistics({
    required String deviceId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    emit(state.copyWith(isLoading: true));
    try {
      final stats = await getStatistics.execute(deviceId, startDate, endDate);
      emit(state.copyWith(
        isLoading: false,
        statistics: stats,
        error: null,
      ));
      Logger.d('MonitoringCubit', 'Statistics loaded for $deviceId');
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: 'Failed to load statistics: $e',
      ));
      Logger.e('MonitoringCubit', 'Failed to load statistics', e);
    }
  }

  void clearError() {
    emit(state.copyWith(error: null));
  }
}
