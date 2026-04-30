import 'package:get_it/get_it.dart';
import '../data/datasources/local/device_local_datasource.dart';
import '../data/datasources/local/schedule_local_datasource.dart';
import '../data/datasources/remote/mqtt_manager.dart';
import '../data/datasources/remote/mqtt_service.dart';
import '../data/repositories/device_repository_impl.dart';
import '../data/repositories/schedule_repository_impl.dart';
import '../domain/repositories/device_repository.dart';
import '../domain/repositories/schedule_repository.dart';
import '../domain/usecases/device/add_device.dart';
import '../domain/usecases/device/control_device.dart';
import '../domain/usecases/device/get_devices.dart';
import '../domain/usecases/device/update_device.dart';
import '../domain/usecases/device/delete_device.dart';
import '../domain/usecases/schedule/create_schedule.dart';
import '../domain/usecases/schedule/get_schedules.dart';
import '../domain/usecases/schedule/update_schedule.dart';
import '../domain/usecases/schedule/delete_schedule.dart';
import '../domain/usecases/schedule/toggle_schedule.dart';
import '../domain/usecases/monitoring/get_device_status.dart';
import '../domain/usecases/monitoring/get_battery_history.dart';
import '../presentation/cubit/device/device_cubit.dart';
import '../presentation/cubit/control/control_cubit.dart';
import '../presentation/cubit/schedule/schedule_cubit.dart';
import '../presentation/cubit/monitoring/monitoring_cubit.dart';

final GetIt getIt = GetIt.instance;

Future<void> setupDependencyInjection() async {
  // Core
  getIt.registerLazySingleton(() => MQTTManager());
  getIt.registerLazySingleton(() => MQTTService(getIt()));

  // Data Sources
  getIt.registerLazySingleton(() => DeviceLocalDataSource());
  getIt.registerLazySingleton(() => ScheduleLocalDataSource());

  // Repositories
  getIt.registerLazySingleton<DeviceRepository>(
    () => DeviceRepositoryImpl(
      localDataSource: getIt(),
      mqttService: getIt(),
    ),
  );

  getIt.registerLazySingleton<ScheduleRepository>(
    () => ScheduleRepositoryImpl(
      localDataSource: getIt(),
    ),
  );

  // Use Cases - Device
  getIt.registerLazySingleton(() => AddDevice(getIt<DeviceRepository>()));
  getIt.registerLazySingleton(() => GetDevices(getIt<DeviceRepository>()));
  getIt.registerLazySingleton(() => UpdateDevice(getIt<DeviceRepository>()));
  getIt.registerLazySingleton(() => DeleteDevice(getIt<DeviceRepository>()));
  getIt.registerLazySingleton(
    () => ControlDevice(
      mqttService: getIt(),
      deviceRepository: getIt(),
    ),
  );

  // Use Cases - Schedule
  getIt
      .registerLazySingleton(() => CreateSchedule(getIt<ScheduleRepository>()));
  getIt.registerLazySingleton(() => GetSchedules(getIt<ScheduleRepository>()));
  getIt
      .registerLazySingleton(() => UpdateSchedule(getIt<ScheduleRepository>()));
  getIt
      .registerLazySingleton(() => DeleteSchedule(getIt<ScheduleRepository>()));
  getIt
      .registerLazySingleton(() => ToggleSchedule(getIt<ScheduleRepository>()));

  // Use Cases - Monitoring
  getIt.registerLazySingleton(() => GetDeviceStatus(getIt<DeviceRepository>()));
  getIt.registerLazySingleton(
      () => GetBatteryHistory(getIt<DeviceRepository>()));

  // Cubits
  getIt.registerFactory(
    () => DeviceCubit(
      getDevices: getIt(),
      addDevice: getIt(),
      updateDevice: getIt(),
      deleteDevice: getIt(),
      controlDevice: getIt(),
    ),
  );

  getIt.registerFactory(
    () => ControlCubit(controlDevice: getIt()),
  );

  getIt.registerFactory(
    () => ScheduleCubit(
      createSchedule: getIt(),
      getSchedules: getIt(),
      updateSchedule: getIt(),
      deleteSchedule: getIt(),
      toggleSchedule: getIt(),
    ),
  );

  getIt.registerFactory(
    () => MonitoringCubit(
      getDeviceStatus: getIt(),
      getBatteryHistory: getIt(),
      getStatistics: getIt(), // Will be added later
    ),
  );
}
