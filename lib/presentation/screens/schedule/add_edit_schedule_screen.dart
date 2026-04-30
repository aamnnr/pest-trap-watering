import 'package:flutter/material.dart';

class AddEditScheduleScreen extends StatelessWidget {
  final String? scheduleId;
  final String deviceId;

  const AddEditScheduleScreen({
    super.key,
    this.scheduleId,
    required this.deviceId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(scheduleId == null ? 'Add Schedule' : 'Edit Schedule'),
      ),
      body: Center(
        child: Text(
            '${scheduleId == null ? "Add" : "Edit"} Schedule for Device: $deviceId'),
      ),
    );
  }
}
