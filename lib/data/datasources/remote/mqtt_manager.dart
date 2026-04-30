import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import '../../../core/utils/logger.dart';
import '../../../config/env/environment.dart';

class MQTTManager {
  MqttServerClient? _client;
  bool _isConnected = false;

  String get broker => mqttBroker;
  int get port => mqttPort;

  // Callbacks
  Function(String topic, String message)? onMessageReceived;
  Function()? onConnected;
  Function(dynamic error)? onDisconnected;

  bool get isConnected => _isConnected;

  Future<bool> connect(String clientId,
      {String? username, String? password}) async {
    try {
      _client = MqttServerClient(broker, clientId);
      _client!.port = port;
      _client!.keepAlivePeriod = 60;
      // connectTimeoutPeriod expects int (seconds), not Duration
      _client!.connectTimeoutPeriod =
          connectionTimeout.inSeconds; // Convert to seconds
      _client!.logging(on: false);

      // Setup callbacks
      _client!.onConnected = _handleConnected;
      _client!.onDisconnected = _handleDisconnected;
      _client!.onSubscribed = _handleSubscribed;
      _client!.onSubscribeFail = _handleSubscribeFail;
      _client!.pongCallback = _handlePong;

      // Setup connection message
      final connMessage = MqttConnectMessage()
          .withClientIdentifier(clientId)
          .startClean()
          .withWillQos(MqttQos.atLeastOnce);

      _client!.connectionMessage = connMessage;

      // Connect
      await _client!.connect();

      if (_client!.connectionStatus!.state == MqttConnectionState.connected) {
        _isConnected = true;
        Logger.d('MQTTManager', 'Connected to broker: $broker');

        // Setup message listener
        _client!.updates!.listen(_handleIncomingMessage);

        return true;
      } else {
        Logger.e(
            'MQTTManager', 'Failed to connect: ${_client!.connectionStatus}');
        return false;
      }
    } catch (e) {
      Logger.e('MQTTManager', 'Connection error', e);
      _isConnected = false;
      return false;
    }
  }

  void _handleConnected() {
    _isConnected = true;
    Logger.d('MQTTManager', 'Connected callback triggered');
    onConnected?.call();
  }

  void _handleDisconnected() {
    _isConnected = false;
    Logger.d('MQTTManager', 'Disconnected from broker');
    onDisconnected?.call('Disconnected');
  }

  void _handleSubscribed(String topic) {
    Logger.d('MQTTManager', 'Subscribed to: $topic');
  }

  void _handleSubscribeFail(String topic) {
    Logger.e('MQTTManager', 'Failed to subscribe: $topic');
  }

  bool _handlePong() {
    Logger.d('MQTTManager', 'Pong received');
    return true;
  }

  void _handleIncomingMessage(List<MqttReceivedMessage<MqttMessage>> messages) {
    for (final message in messages) {
      final topic = message.topic;
      final payload = message.payload as MqttPublishMessage;
      final messageData =
          MqttPublishPayload.bytesToStringAsString(payload.payload.message);

      Logger.d('MQTTManager',
          'Message received - Topic: $topic, Payload: $messageData');
      onMessageReceived?.call(topic, messageData);
    }
  }

  Future<bool> subscribe(String topic,
      {MqttQos qos = MqttQos.atLeastOnce}) async {
    if (!_isConnected) {
      Logger.w('MQTTManager', 'Cannot subscribe - not connected');
      return false;
    }

    try {
      _client!.subscribe(topic, qos);
      return true;
    } catch (e) {
      Logger.e('MQTTManager', 'Subscribe error', e);
      return false;
    }
  }

  Future<bool> publish(String topic, String message,
      {MqttQos qos = MqttQos.atLeastOnce}) async {
    if (!_isConnected) {
      Logger.w('MQTTManager', 'Cannot publish - not connected');
      return false;
    }

    try {
      final builder = MqttClientPayloadBuilder();
      builder.addString(message);
      _client!.publishMessage(topic, qos, builder.payload!);
      Logger.d('MQTTManager', 'Published to $topic: $message');
      return true;
    } catch (e) {
      Logger.e('MQTTManager', 'Publish error', e);
      return false;
    }
  }

  Future<void> disconnect() async {
    if (_client != null && _isConnected) {
      _client!.disconnect();
      _isConnected = false;
      Logger.d('MQTTManager', 'Disconnected');
    }
  }

  void dispose() {
    disconnect();
    _client = null;
  }
}
