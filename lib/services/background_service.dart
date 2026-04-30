import 'package:workmanager/workmanager.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../core/utils/logger.dart';
import '../core/network/connectivity_service.dart';
import '../core/storage/local_storage.dart';
import '../data/datasources/local/device_local_datasource.dart';
import '../data/datasources/local/schedule_local_datasource.dart';
import '../data/datasources/remote/mqtt_manager.dart';
import '../data/datasources/remote/mqtt_service.dart';
import '../domain/entities/schedule.dart'; // Import dari domain entity

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    Logger.d('BackgroundService', 'Executing task: $taskName');

    switch (taskName) {
      case 'syncTelemetry':
        await BackgroundService.syncTelemetry();
        break;
      case 'checkDevices':
        await BackgroundService.checkDeviceStatus();
        break;
      case 'cleanupOldData':
        await BackgroundService.cleanupOldData();
        break;
      case 'checkSchedules':
        await BackgroundService.checkSchedules();
        break;
      default:
        Logger.w('BackgroundService', 'Unknown task: $taskName');
    }

    return Future.value(true);
  });
}

class BackgroundService {
  static const String syncTelemetryTask = 'syncTelemetry';
  static const String checkDevicesTask = 'checkDevices';
  static const String cleanupOldDataTask = 'cleanupOldData';
  static const String checkSchedulesTask = 'checkSchedules';

  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static DeviceLocalDataSource? _deviceDataSource;
  static ScheduleLocalDataSource? _scheduleDataSource;
  static MQTTService? _mqttService;

  static Future<void> init() async {
    // Initialize dependencies
    _deviceDataSource = DeviceLocalDataSource();
    _scheduleDataSource = ScheduleLocalDataSource();

    final mqttManager = MQTTManager();
    _mqttService = MQTTService(mqttManager);

    // Initialize WorkManager
    await Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: false,
    );

    // Register periodic tasks
    await _registerPeriodicTasks();

    // Initialize notifications
    await _initNotifications();

    Logger.d('BackgroundService', 'Background service initialized');
  }

  static Future<void> _registerPeriodicTasks() async {
    // Sync telemetry every 15 minutes
    await Workmanager().registerPeriodicTask(
      syncTelemetryTask,
      syncTelemetryTask,
      frequency: const Duration(minutes: 15),
      constraints: Constraints(
        networkType: NetworkType.connected,
        requiresBatteryNotLow: true,
      ),
    );

    // Check devices status every hour
    await Workmanager().registerPeriodicTask(
      checkDevicesTask,
      checkDevicesTask,
      frequency: const Duration(hours: 1),
    );

    // Cleanup old data every day
    await Workmanager().registerPeriodicTask(
      cleanupOldDataTask,
      cleanupOldDataTask,
      frequency: const Duration(days: 1),
      existingWorkPolicy: ExistingWorkPolicy.replace,
    );

    // Check schedules every 5 minutes
    await Workmanager().registerPeriodicTask(
      checkSchedulesTask,
      checkSchedulesTask,
      frequency: const Duration(minutes: 5),
    );

    Logger.d('BackgroundService', 'Periodic tasks registered');
  }

  static Future<void> _initNotifications() async {
    // Android notification channel
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS notification settings
    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(settings);

    // Create notification channel for Android
    final androidPlugin = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin != null) {
      const androidChannel = AndroidNotificationChannel(
        'pest_trap_channel',
        'PestTrap Notifications',
        description: 'Notifications from PestTrap System',
        importance: Importance.high,
      );
      await androidPlugin.createNotificationChannel(androidChannel);
    }
  }

  static Future<void> syncTelemetry() async {
    Logger.d('BackgroundService', 'Syncing telemetry data...');

    final connectivity = ConnectivityService();
    final hasInternet = await connectivity.hasInternet();

    if (!hasInternet) {
      Logger.d('BackgroundService', 'No internet connection, skipping sync');
      return;
    }

    try {
      // Connect to MQTT if not connected
      if (_mqttService != null) {
        final clientId = 'bg_sync_${DateTime.now().millisecondsSinceEpoch}';
        await _mqttService!.connect(clientId);
      }

      // Get all devices
      final devices = await _deviceDataSource?.getDevices() ?? [];

      for (final device in devices) {
        // Request telemetry from device
        await _mqttService?.sendCommand(
          device.deviceId,
          'get_status',
          {},
        );

        // Small delay to avoid flooding
        await Future.delayed(const Duration(milliseconds: 500));
      }

      // Update last sync time
      await LocalStorage().setLastSyncTime(DateTime.now());

      Logger.d('BackgroundService',
          'Telemetry sync completed for ${devices.length} devices');
    } catch (e) {
      Logger.e('BackgroundService', 'Failed to sync telemetry', e);
    }
  }

  static Future<void> checkDeviceStatus() async {
    Logger.d('BackgroundService', 'Checking device status...');

    try {
      final devices = await _deviceDataSource?.getDevices() ?? [];
      final now = DateTime.now();

      for (final device in devices) {
        final lastSeen = device.updatedAt;
        final minutesSinceLastSeen = now.difference(lastSeen).inMinutes;

        // Check if device is offline for more than 10 minutes
        if (minutesSinceLastSeen > 10) {
          // Send notification for offline device
          await showNotification(
            'Device Offline',
            '${device.name} has been offline for $minutesSinceLastSeen minutes',
          );
          Logger.d('BackgroundService', 'Device ${device.name} is offline');
        }

        // Check for low battery from last telemetry
        final telemetryList = await _deviceDataSource?.getTelemetryHistory(
          device.id,
          limit: 1,
        );

        if (telemetryList != null && telemetryList.isNotEmpty) {
          final lastTelemetry = telemetryList.first;
          if (lastTelemetry.batteryPercentage < 20) {
            await showNotification(
              'Low Battery Warning',
              '${device.name} battery is at ${lastTelemetry.batteryPercentage}%',
            );
          }
        }
      }

      Logger.d('BackgroundService', 'Device status check completed');
    } catch (e) {
      Logger.e('BackgroundService', 'Failed to check device status', e);
    }
  }

  static Future<void> cleanupOldData() async {
    Logger.d('BackgroundService', 'Cleaning up old data...');

    try {
      // Delete telemetry older than 30 days
      await _deviceDataSource?.cleanOldTelemetry(30);

      Logger.d('BackgroundService', 'Data cleanup completed');
    } catch (e) {
      Logger.e('BackgroundService', 'Failed to cleanup old data', e);
    }
  }

  static Future<void> checkSchedules() async {
    Logger.d('BackgroundService', 'Checking schedules...');

    try {
      final schedules = await _scheduleDataSource?.getSchedules() ?? [];
      final now = DateTime.now();
      final currentTime =
          '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

      for (final schedule in schedules) {
        if (!schedule.isEnabled) continue;

        // Check if schedule matches current time
        if (schedule.startTime == currentTime) {
          // Check repeat days
          if (schedule.repeatDays.isEmpty ||
              schedule.repeatDays.contains(now.weekday)) {
            Logger.d('BackgroundService', 'Executing schedule: ${schedule.id}');

            // Execute schedule action via MQTT
            String command;

            // Build command based on schedule type and action
            if (schedule.type == ScheduleType.uv) {
              switch (schedule.action) {
                case ScheduleAction.turnOn:
                  command = 'uv_on';
                  break;
                case ScheduleAction.turnOff:
                  command = 'uv_off';
                  break;
                case ScheduleAction.toggle:
                  command = 'uv_toggle';
                  break;
              }
            } else {
              // ScheduleType.pump
              switch (schedule.action) {
                case ScheduleAction.turnOn:
                  command = 'pump_on';
                  break;
                case ScheduleAction.turnOff:
                  command = 'pump_off';
                  break;
                case ScheduleAction.toggle:
                  command = 'pump_toggle';
                  break;
              }
            }

            await _mqttService?.sendCommand(
              schedule.deviceId,
              command,
              {},
            );

            await showNotification(
              'Schedule Executed',
              '${schedule.type.name.toUpperCase()} ${_getActionName(schedule.action)} at $currentTime',
            );
          }
        }
      }

      Logger.d('BackgroundService', 'Schedule check completed at $currentTime');
    } catch (e) {
      Logger.e('BackgroundService', 'Failed to check schedules', e);
    }
  }

  static String _getActionName(ScheduleAction action) {
    switch (action) {
      case ScheduleAction.turnOn:
        return 'ON';
      case ScheduleAction.turnOff:
        return 'OFF';
      case ScheduleAction.toggle:
        return 'TOGGLED';
    }
  }

  static Future<void> showNotification(String title, String body) async {
    try {
      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        'pest_trap_channel',
        'PestTrap Notifications',
        channelDescription: 'Notifications from PestTrap System',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      );

      const NotificationDetails details = NotificationDetails(
        android: androidDetails,
        iOS: DarwinNotificationDetails(),
      );

      await _notifications.show(
        DateTime.now().millisecondsSinceEpoch.remainder(100000),
        title,
        body,
        details,
      );

      Logger.d('BackgroundService', 'Notification shown: $title');
    } catch (e) {
      Logger.e('BackgroundService', 'Failed to show notification', e);
    }
  }

  static Future<void> stopAllTasks() async {
    await Workmanager().cancelAll();
    Logger.d('BackgroundService', 'All background tasks stopped');
  }

  static Future<void> triggerManualSync() async {
    Logger.d('BackgroundService', 'Manual sync triggered');
    await syncTelemetry();
    await checkDeviceStatus();
    await checkSchedules();
  }
}
