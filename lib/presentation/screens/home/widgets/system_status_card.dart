import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../cubit/device/device_cubit.dart';
import '../../../cubit/device/device_state.dart';

class SystemStatusCard extends StatelessWidget {
  const SystemStatusCard({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DeviceCubit, DeviceState>(
      builder: (context, state) {
        int onlineCount = 0;
        int offlineCount = 0;
        int warningCount = 0;

        if (state is DeviceLoaded) {
          for (final device in state.devices) {
            if (device.status.name == 'online') {
              onlineCount++;
              // Check for low battery warning
              if (device.telemetry != null &&
                  device.telemetry!.batteryPercentage < 20) {
                warningCount++;
              }
            } else {
              offlineCount++;
            }
          }
        }

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem(
                      context,
                      icon: Icons.check_circle,
                      value: onlineCount.toString(),
                      label: 'Online',
                      color: Colors.green,
                    ),
                    _buildStatItem(
                      context,
                      icon: Icons.offline_bolt,
                      value: offlineCount.toString(),
                      label: 'Offline',
                      color: Colors.grey,
                    ),
                    _buildStatItem(
                      context,
                      icon: Icons.warning,
                      value: warningCount.toString(),
                      label: 'Warning',
                      color: Colors.orange,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total Devices'),
                    Text(
                      (onlineCount + offlineCount).toString(),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatItem(
    BuildContext context, {
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}
