import 'package:flutter/material.dart';
import '../utils/logger.dart';

class ErrorHandler {
  static void handleError(BuildContext context, dynamic error) {
    Logger.e('ErrorHandler', 'Error occurred', error);

    String message = _getUserFriendlyMessage(error);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  static String _getUserFriendlyMessage(dynamic error) {
    if (error.toString().contains('network')) {
      return 'No internet connection. Please check your network.';
    }
    if (error.toString().contains('timeout')) {
      return 'Connection timeout. Please try again.';
    }
    if (error.toString().contains('MQTT')) {
      return 'MQTT connection failed. Please check broker settings.';
    }
    return 'An error occurred. Please try again.';
  }

  static Widget errorWidget(String message, VoidCallback onRetry) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
