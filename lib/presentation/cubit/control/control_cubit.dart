import 'package:flutter_bloc/flutter_bloc.dart';
import 'control_state.dart';
import '../../../domain/usecases/device/control_device.dart';
import '../../../core/utils/logger.dart';

class ControlCubit extends Cubit<ControlState> {
  final ControlDevice controlDevice;

  ControlCubit({required this.controlDevice}) : super(ControlInitial());

  Future<void> controlPump({
    required String deviceId,
    required ControlAction action,
    int? durationSeconds,
  }) async {
    emit(ControlLoading());
    try {
      final success = await controlDevice.execute(
        deviceId: deviceId,
        type: ControlType.pump,
        action: action,
        durationSeconds: durationSeconds,
      );

      if (success) {
        final actionText = _getActionText(action);
        emit(ControlSuccess('Pump $actionText successfully'));
        Logger.d('ControlCubit', 'Pump control success');
      } else {
        emit(const ControlError('Failed to control pump'));
      }
    } catch (e) {
      emit(ControlError('Error: $e'));
      Logger.e('ControlCubit', 'Pump control error', e);
    }
  }

  Future<void> controlUV({
    required String deviceId,
    required ControlAction action,
  }) async {
    emit(ControlLoading());
    try {
      final success = await controlDevice.execute(
        deviceId: deviceId,
        type: ControlType.uv,
        action: action,
      );

      if (success) {
        final actionText = _getActionText(action);
        emit(ControlSuccess('UV $actionText successfully'));
        Logger.d('ControlCubit', 'UV control success');
      } else {
        emit(const ControlError('Failed to control UV'));
      }
    } catch (e) {
      emit(ControlError('Error: $e'));
      Logger.e('ControlCubit', 'UV control error', e);
    }
  }

  String _getActionText(ControlAction action) {
    switch (action) {
      case ControlAction.turnOn:
        return 'turned ON';
      case ControlAction.turnOff:
        return 'turned OFF';
      case ControlAction.toggle:
        return 'toggled';
    }
  }

  void reset() {
    emit(ControlInitial());
  }
}
