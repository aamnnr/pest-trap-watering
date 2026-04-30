import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/themes/light_theme.dart';
import '../config/themes/dark_theme.dart';
import '../presentation/routes/app_router.dart';
import '../presentation/cubit/device/device_cubit.dart';
import '../presentation/cubit/schedule/schedule_cubit.dart';
import '../presentation/cubit/monitoring/monitoring_cubit.dart';
import 'dependency_injection.dart';

class PestTrapWateringApp extends StatefulWidget {
  const PestTrapWateringApp({super.key});

  @override
  State<PestTrapWateringApp> createState() => _PestTrapWateringAppState();
}

class _PestTrapWateringAppState extends State<PestTrapWateringApp> {
  ThemeMode _themeMode = ThemeMode.system;

  @override
  void initState() {
    super.initState();
    _loadThemeMode();
  }

  Future<void> _loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final themeModeStr = prefs.getString('theme_mode') ?? 'system';

    setState(() {
      _themeMode = themeModeStr == 'dark'
          ? ThemeMode.dark
          : (themeModeStr == 'light' ? ThemeMode.light : ThemeMode.system);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<DeviceCubit>(
          create: (_) => getIt<DeviceCubit>()..loadDevices(),
        ),
        BlocProvider<ScheduleCubit>(
          create: (_) => getIt<ScheduleCubit>(),
        ),
        BlocProvider<MonitoringCubit>(
          create: (_) => getIt<MonitoringCubit>(),
        ),
      ],
      child: MaterialApp.router(
        title: 'PestTrap-Watering System',
        theme: LightTheme.theme,
        darkTheme: DarkTheme.theme,
        themeMode: _themeMode,
        routerConfig: AppRouter.router,
        debugShowCheckedModeBanner: false,
        builder: (context, child) {
          return child!;
        },
      ),
    );
  }
}
