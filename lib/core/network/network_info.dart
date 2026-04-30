import 'package:connectivity_plus/connectivity_plus.dart';
import '../utils/logger.dart';

abstract class NetworkInfo {
  Future<bool> get isConnected;
  Stream<ConnectivityResult> get connectivityStream;
}

class NetworkInfoImpl implements NetworkInfo {
  final Connectivity connectivity;

  NetworkInfoImpl({required this.connectivity});

  @override
  Future<bool> get isConnected async {
    try {
      final result = await connectivity.checkConnectivity();
      final isConnected = result != ConnectivityResult.none;
      Logger.d(
          'NetworkInfo', 'Connection status: $isConnected (${result.name})');
      return isConnected;
    } catch (e) {
      Logger.e('NetworkInfo', 'Failed to check connectivity', e);
      return false;
    }
  }

  @override
  Stream<ConnectivityResult> get connectivityStream =>
      connectivity.onConnectivityChanged;
}
