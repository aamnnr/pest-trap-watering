import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/device.dart';
import '../../../domain/usecases/device/control_device.dart';
import '../../cubit/device/device_cubit.dart';
import '../../cubit/control/control_cubit.dart';
import '../../cubit/control/control_state.dart';
import '../../widgets/common/custom_button.dart';

class DeviceDetailScreen extends StatefulWidget {
  final String deviceId;

  const DeviceDetailScreen({super.key, required this.deviceId});

  @override
  State<DeviceDetailScreen> createState() => _DeviceDetailScreenState();
}

class _DeviceDetailScreenState extends State<DeviceDetailScreen> {
  late DeviceCubit _deviceCubit;
  late ControlCubit _controlCubit;

  @override
  void initState() {
    super.initState();
    _deviceCubit = context.read<DeviceCubit>();
    _controlCubit = context.read<ControlCubit>();
    _deviceCubit.loadDevices();
  }

  @override
  void dispose() {
    _controlCubit.reset();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final device = _deviceCubit.getDeviceById(widget.deviceId);

    if (device == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Device Details')),
        body: const Center(child: Text('Device not found')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(device.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // Navigate to edit device
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _confirmDelete(device.id),
          ),
        ],
      ),
      body: BlocListener<ControlCubit, ControlState>(
        listener: (context, state) {
          if (state is ControlSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
            _deviceCubit.loadDevices();
          } else if (state is ControlError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(state.message), backgroundColor: Colors.red),
            );
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStatusCard(device),
              const SizedBox(height: 16),
              _buildTelemetryCard(device),
              const SizedBox(height: 16),
              _buildControlCard(device),
              const SizedBox(height: 16),
              _buildConfigCard(device),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusCard(Device device) {
    final isOnline = device.status.name == 'online';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color:
                        isOnline ? Colors.green.shade50 : Colors.grey.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.devices,
                    color: isOnline ? Colors.green : Colors.grey,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        device.name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        device.deviceId,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color:
                        isOnline ? Colors.green.shade100 : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    isOnline ? 'ONLINE' : 'OFFLINE',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isOnline
                          ? Colors.green.shade800
                          : Colors.grey.shade700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.location_on, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Text(
                  device.location ?? 'No location set',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.access_time, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Text(
                  'Last seen: ${_formatDateTime(device.lastSeen)}',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTelemetryCard(Device device) {
    final telemetry = device.telemetry;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Telemetry Data',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildMetricItem(
                    icon: Icons.battery_std,
                    value: '${telemetry?.batteryPercentage ?? 0}%',
                    label: 'Battery',
                    color: _getBatteryColor(telemetry?.batteryPercentage ?? 0),
                  ),
                ),
                Expanded(
                  child: _buildMetricItem(
                    icon: Icons.light_mode,
                    value: telemetry?.uvStatus == true ? 'ON' : 'OFF',
                    label: 'UV Light',
                    color: telemetry?.uvStatus == true
                        ? Colors.orange
                        : Colors.grey,
                  ),
                ),
                Expanded(
                  child: _buildMetricItem(
                    icon: Icons.water_drop,
                    value: telemetry?.pumpStatus == true ? 'ON' : 'OFF',
                    label: 'Water Pump',
                    color: telemetry?.pumpStatus == true
                        ? Colors.blue
                        : Colors.grey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildMetricItem(
                    icon: Icons.nightlight_round,
                    value: telemetry?.isNight == true ? 'Yes' : 'No',
                    label: 'Night Time',
                    color: Colors.indigo,
                  ),
                ),
                const Expanded(child: SizedBox()),
                const Expanded(child: SizedBox()),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricItem({
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
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildControlCard(Device device) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Manual Control',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: device.telemetry?.uvStatus == true
                        ? 'Turn UV OFF'
                        : 'Turn UV ON',
                    onPressed: () => _controlUV(
                        device.id, device.telemetry?.uvStatus ?? false),
                    type: device.telemetry?.uvStatus == true
                        ? ButtonType.danger
                        : ButtonType.primary,
                    icon: Icons.light_mode,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CustomButton(
                    text: device.telemetry?.pumpStatus == true
                        ? 'Turn Pump OFF'
                        : 'Turn Pump ON',
                    onPressed: () => _controlPump(
                        device.id, device.telemetry?.pumpStatus ?? false),
                    type: device.telemetry?.pumpStatus == true
                        ? ButtonType.danger
                        : ButtonType.primary,
                    icon: Icons.water_drop,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: 'Pump for 10s',
                    onPressed: () => _controlPumpTimed(device.id, 10),
                    type: ButtonType.secondary,
                    icon: Icons.timer,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CustomButton(
                    text: 'Pump for 30s',
                    onPressed: () => _controlPumpTimed(device.id, 30),
                    type: ButtonType.secondary,
                    icon: Icons.timer,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfigCard(Device device) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Schedule Configuration',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ListTile(
              leading: const Icon(Icons.schedule),
              title: const Text('UV Schedule'),
              subtitle: Text(
                  'Active from ${device.config.uvStartHour}:00 to ${device.config.uvEndHour}:00'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.pushNamed(
                  context,
                  '/schedules',
                  arguments: {'deviceId': device.id},
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Auto Mode'),
              subtitle: const Text('Automatic UV based on schedule'),
              trailing: Switch(
                value: device.config.autoMode,
                onChanged: (value) {
                  // Update auto mode
                },
              ),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.wifi),
              title: const Text('WiFi Configuration'),
              subtitle: const Text('Setup device WiFi connection'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.pushNamed(context, '/wifi-config');
              },
            ),
          ],
        ),
      ),
    );
  }

  void _controlUV(String deviceId, bool currentStatus) {
    _controlCubit.controlUV(
      deviceId: deviceId,
      action: currentStatus ? ControlAction.turnOff : ControlAction.turnOn,
    );
  }

  void _controlPump(String deviceId, bool currentStatus) {
    _controlCubit.controlPump(
      deviceId: deviceId,
      action: currentStatus ? ControlAction.turnOff : ControlAction.turnOn,
    );
  }

  void _controlPumpTimed(String deviceId, int duration) {
    _controlCubit.controlPump(
      deviceId: deviceId,
      action: ControlAction.turnOn,
      durationSeconds: duration,
    );
  }

  // PERBAIKAN: Method _confirmDelete dengan penanganan mounted yang benar
  void _confirmDelete(String deviceId) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Device'),
        content: const Text('Are you sure you want to delete this device?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              // Tutup dialog terlebih dahulu
              if (dialogContext.mounted) {
                Navigator.pop(dialogContext);
              }

              // Eksekusi delete
              final success = await _deviceCubit.removeDevice(deviceId);

              // Cek apakah widget masih mounted setelah async operation
              if (mounted) {
                if (success) {
                  Navigator.pop(context); // Kembali ke halaman sebelumnya
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Failed to delete device'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Color _getBatteryColor(int percentage) {
    if (percentage >= 50) return Colors.green;
    if (percentage >= 20) return Colors.orange;
    return Colors.red;
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes} min ago';
    if (diff.inDays < 1) return '${diff.inHours} hours ago';
    return '${diff.inDays} days ago';
  }
}
