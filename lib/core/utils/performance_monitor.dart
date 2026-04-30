import 'package:flutter/foundation.dart';
import 'logger.dart';

class PerformanceMonitor {
  static final Map<String, Stopwatch> _stopwatches = {};

  static void startTracking(String operation) {
    if (kDebugMode) {
      _stopwatches[operation] = Stopwatch()..start();
    }
  }

  static void endTracking(String operation) {
    if (kDebugMode && _stopwatches.containsKey(operation)) {
      final sw = _stopwatches[operation]!;
      sw.stop();
      Logger.d('Performance', '$operation took ${sw.elapsedMilliseconds}ms');
      _stopwatches.remove(operation);
    }
  }

  static Future<T> trackPerformance<T>(
      String operation, Future<T> Function() callback) async {
    startTracking(operation);
    final result = await callback();
    endTracking(operation);
    return result;
  }
}
