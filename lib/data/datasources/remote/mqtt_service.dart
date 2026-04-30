import 'dart:convert';
import '../../../core/utils/logger.dart';
import 'mqtt_manager.dart';

class MQTTService {
  final MQTTManager _mqttManager;

  // Queue for offline commands
  final List<Map<String, dynamic>> _offlineCommandQueue = [];

  MQTTService(this._mqttManager);

  Future<bool> connect(String clientId) async {
    final success = await _mqttManager.connect(clientId);
    if (success) {
      // Process offline queue after reconnection
      await _processOfflineQueue();
    }
    return success;
  }

  Future<bool> subscribeToDevice(String deviceId) async {
    final topic = 'tanisolution/$deviceId/command';
    return await _mqttManager.subscribe(topic);
  }

  Future<bool> sendCommand(
      String deviceId, String command, Map<String, dynamic> params) async {
    final topic = 'tanisolution/$deviceId/telemetry';

    final message = jsonEncode({
      'command': command,
      'params': params,
      'timestamp': DateTime.now().toIso8601String(),
    });

    if (_mqttManager.isConnected) {
      return await _mqttManager.publish(topic, message);
    } else {
      // Store command for later
      _offlineCommandQueue.add({
        'topic': topic,
        'message': message,
        'timestamp': DateTime.now(),
      });
      Logger.d('MQTTService', 'Command queued for offline delivery');
      return false;
    }
  }

  Future<bool> sendTelemetry(String deviceId, Map<String, dynamic> data) async {
    final topic = 'tanisolution/$deviceId/telemetry';
    final message = jsonEncode(data);

    if (_mqttManager.isConnected) {
      return await _mqttManager.publish(topic, message);
    }
    return false;
  }

  Future<void> _processOfflineQueue() async {
    if (_offlineCommandQueue.isEmpty) return;

    Logger.d('MQTTService',
        'Processing ${_offlineCommandQueue.length} queued commands');

    final commands = List<Map<String, dynamic>>.from(_offlineCommandQueue);

    for (final command in commands) {
      final bool success =
          await _mqttManager.publish(command['topic'], command['message']);
      if (success) {
        _offlineCommandQueue.remove(command);
      } else {
        break; // Stop if failed, will retry next time
      }
    }
  }

  void setMessageCallback(
      Function(String deviceId, String command, Map<String, dynamic> params)
          onCommand) {
    _mqttManager.onMessageReceived = (topic, message) {
      try {
        // Extract deviceId from topic: tanisolution/{deviceId}/command
        final parts = topic.split('/');
        if (parts.length >= 2) {
          final deviceId = parts[1];
          final data = jsonDecode(message);

          if (data['command'] != null) {
            onCommand(deviceId, data['command'], data['params'] ?? {});
          }
        }
      } catch (e) {
        Logger.e('MQTTService', 'Failed to parse message', e);
      }
    };
  }

  void dispose() {
    _mqttManager.dispose();
  }
}
