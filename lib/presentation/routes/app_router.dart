import 'package:go_router/go_router.dart';
import '../screens/splash_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/device/device_list_screen.dart';
import '../screens/device/device_detail_screen.dart';
import '../screens/device/add_device_screen.dart';
import '../screens/schedule/schedule_screen.dart';
import '../screens/schedule/add_edit_schedule_screen.dart';
import '../screens/monitoring/monitoring_screen.dart';
import '../screens/monitoring/history_screen.dart';
import '../screens/wifi/wifi_config_screen.dart';
import '../screens/settings/settings_screen.dart';

class AppRouter {
  static const String splash = '/';
  static const String home = '/home';
  static const String devices = '/devices';
  static const String deviceDetail = '/devices/:id';
  static const String addDevice = '/devices/add';
  static const String schedules = '/schedules';
  static const String addSchedule = '/schedules/add';
  static const String editSchedule = '/schedules/edit/:id';
  static const String monitoring = '/monitoring';
  static const String history = '/history';
  static const String wifiConfig = '/wifi-config';
  static const String settings = '/settings';

  static final router = GoRouter(
    initialLocation: splash,
    routes: [
      GoRoute(
        path: splash,
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: home,
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: devices,
        name: 'devices',
        builder: (context, state) => const DeviceListScreen(),
      ),
      GoRoute(
        path: deviceDetail,
        name: 'deviceDetail',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return DeviceDetailScreen(deviceId: id);
        },
      ),
      GoRoute(
        path: addDevice,
        name: 'addDevice',
        builder: (context, state) => const AddDeviceScreen(),
      ),
      GoRoute(
        path: schedules,
        name: 'schedules',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return ScheduleScreen(deviceId: extra?['deviceId']);
        },
      ),
      GoRoute(
        path: addSchedule,
        name: 'addSchedule',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return AddEditScheduleScreen(
            deviceId: extra?['deviceId'] ?? '',
          );
        },
      ),
      GoRoute(
        path: editSchedule,
        name: 'editSchedule',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          final extra = state.extra as Map<String, dynamic>?;
          return AddEditScheduleScreen(
            scheduleId: id,
            deviceId: extra?['deviceId'] ?? '',
          );
        },
      ),
      GoRoute(
        path: monitoring,
        name: 'monitoring',
        builder: (context, state) => const MonitoringScreen(),
      ),
      GoRoute(
        path: history,
        name: 'history',
        builder: (context, state) => const HistoryScreen(),
      ),
      GoRoute(
        path: wifiConfig,
        name: 'wifiConfig',
        builder: (context, state) => const WifiConfigScreen(),
      ),
      GoRoute(
        path: settings,
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
  );
}
