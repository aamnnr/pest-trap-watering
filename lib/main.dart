import 'package:flutter/material.dart';
import 'app/app.dart';
import 'core/storage/database_helper.dart';
import 'services/background_service.dart';
import 'core/network/connectivity_service.dart';
import 'core/utils/logger.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Database
  await DatabaseHelper.init();
  Logger.d('Main', 'Database initialized');

  // Initialize Background Service
  await BackgroundService.init();
  Logger.d('Main', 'Background service initialized');

  // Initialize Connectivity Service
  ConnectivityService().initialize();
  Logger.d('Main', 'Connectivity service initialized');

  runApp(const PestTrapWateringApp());
}

// Test function - can be called during development
void testBackgroundService() async {
  Logger.d('Test', 'Testing background service...');
  await BackgroundService.init();
  await BackgroundService.triggerManualSync();
  await BackgroundService.showNotification(
      'Test', 'Background service is working!');
}
