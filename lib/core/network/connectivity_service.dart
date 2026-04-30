import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../utils/logger.dart';

class ConnectivityService {
  static final ConnectivityService _instance = ConnectivityService._internal();
  factory ConnectivityService() => _instance;
  ConnectivityService._internal();

  final Connectivity _connectivity = Connectivity();
  final StreamController<ConnectivityResult> _controller =
      StreamController<ConnectivityResult>.broadcast();

  ConnectivityResult _currentStatus = ConnectivityResult.none;
  ConnectivityResult get currentStatus => _currentStatus;

  Stream<ConnectivityResult> get onConnectivityChanged => _controller.stream;

  void initialize() {
    _connectivity.onConnectivityChanged.listen((result) {
      _currentStatus = result;
      _controller.add(result);
      Logger.d('ConnectivityService', 'Status changed to: ${result.name}');
      _handleConnectivityChange(result);
    });

    _checkInitialStatus();
  }

  Future<void> _checkInitialStatus() async {
    try {
      final result = await _connectivity.checkConnectivity();
      _currentStatus = result;
      _controller.add(result);
      Logger.d('ConnectivityService', 'Initial status: ${result.name}');
    } catch (e) {
      Logger.e('ConnectivityService', 'Failed to check initial status', e);
    }
  }

  void _handleConnectivityChange(ConnectivityResult result) {
    if (result != ConnectivityResult.none) {
      // Connection restored
      Logger.d('ConnectivityService', 'Internet connection restored');
      // Trigger reconnection logic for MQTT
    } else {
      // Connection lost
      Logger.d('ConnectivityService', 'Internet connection lost');
    }
  }

  Future<bool> hasInternet() async {
    try {
      final result = await _connectivity.checkConnectivity();
      return result != ConnectivityResult.none;
    } catch (e) {
      return false;
    }
  }

  void dispose() {
    _controller.close();
  }
}
