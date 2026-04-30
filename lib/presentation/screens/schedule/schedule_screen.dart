import 'package:flutter/material.dart';

class ScheduleScreen extends StatelessWidget {
  final String? deviceId;

  const ScheduleScreen({super.key, this.deviceId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Schedules'),
      ),
      body: Center(
        child: Text(deviceId != null
            ? 'Schedules for device: $deviceId - Coming Soon'
            : 'All Schedules - Coming Soon'),
      ),
    );
  }
}
