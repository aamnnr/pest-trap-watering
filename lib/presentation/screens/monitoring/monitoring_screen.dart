import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../domain/entities/device.dart';
import '../../cubit/device/device_cubit.dart';
import '../../cubit/device/device_state.dart';
import '../../cubit/monitoring/monitoring_cubit.dart';
import '../../cubit/monitoring/monitoring_state.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/common/empty_state_widget.dart';

class MonitoringScreen extends StatefulWidget {
  const MonitoringScreen({super.key});

  @override
  State<MonitoringScreen> createState() => _MonitoringScreenState();
}

class _MonitoringScreenState extends State<MonitoringScreen> {
  String? _selectedDeviceId;
  DateTimeRange? _dateRange;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    await context.read<DeviceCubit>().loadDevices();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Monitoring'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: _selectDateRange,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshData,
          ),
        ],
      ),
      body: BlocBuilder<DeviceCubit, DeviceState>(
        builder: (context, deviceState) {
          if (deviceState is DeviceLoading) {
            return const LoadingIndicator(message: 'Loading devices...');
          }

          if (deviceState is DeviceLoaded) {
            final devices = deviceState.devices;

            if (devices.isEmpty) {
              return const EmptyStateWidget(
                title: 'No Devices',
                message: 'Add a device to start monitoring',
                icon: Icons.analytics,
              );
            }

            // Auto-select first device if none selected
            if (_selectedDeviceId == null && devices.isNotEmpty) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  setState(() {
                    _selectedDeviceId = devices.first.id;
                    _loadMonitoringData();
                  });
                }
              });
            }

            return Column(
              children: [
                _buildDeviceSelector(devices),
                Expanded(
                  child: BlocBuilder<MonitoringCubit, MonitoringState>(
                    builder: (context, monitoringState) {
                      if (monitoringState.isLoading) {
                        return const LoadingIndicator(
                            message: 'Loading data...');
                      }

                      if (monitoringState.error != null) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('Error: ${monitoringState.error}'),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () => _loadMonitoringData(),
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        );
                      }

                      return RefreshIndicator(
                        onRefresh: _loadMonitoringData,
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildCurrentStatusCard(monitoringState),
                              const SizedBox(height: 24),
                              _buildBatteryChart(monitoringState),
                              const SizedBox(height: 24),
                              _buildStatisticsCard(monitoringState),
                              const SizedBox(height: 24),
                              _buildActivitySummary(),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          }

          return const SizedBox();
        },
      ),
    );
  }

  Widget _buildDeviceSelector(List<Device> devices) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: 'Select Device',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
        initialValue: _selectedDeviceId,
        items: devices.map((device) {
          final isOnline = device.status.name == 'online';
          return DropdownMenuItem(
            value: device.id,
            child: Row(
              children: [
                Icon(
                  isOnline ? Icons.check_circle : Icons.offline_bolt,
                  size: 16,
                  color: isOnline ? Colors.green : Colors.grey,
                ),
                const SizedBox(width: 8),
                Expanded(child: Text(device.name)),
                if (device.telemetry != null)
                  Text(
                    '${device.telemetry!.batteryPercentage}%',
                    style: const TextStyle(fontSize: 12),
                  ),
              ],
            ),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            _selectedDeviceId = value;
          });
          _loadMonitoringData();
        },
      ),
    );
  }

  Widget _buildCurrentStatusCard(MonitoringState state) {
    final status = state.deviceStatus;

    if (status == null) return const SizedBox();

    final isOnline = status['isOnline'] as bool;
    final batteryPercentage = status['batteryPercentage'] as int? ?? 0;
    final uvStatus = status['uvStatus'] as bool? ?? false;
    final pumpStatus = status['pumpStatus'] as bool? ?? false;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Current Status',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatusItem(
                  icon: Icons.wifi,
                  label: 'Status',
                  value: isOnline ? 'Online' : 'Offline',
                  color: isOnline ? Colors.green : Colors.red,
                ),
                _buildStatusItem(
                  icon: Icons.battery_std,
                  label: 'Battery',
                  value: '$batteryPercentage%',
                  color: _getBatteryColor(batteryPercentage),
                ),
                _buildStatusItem(
                  icon: Icons.light_mode,
                  label: 'UV Light',
                  value: uvStatus ? 'ON' : 'OFF',
                  color: uvStatus ? Colors.orange : Colors.grey,
                ),
                _buildStatusItem(
                  icon: Icons.water_drop,
                  label: 'Water Pump',
                  value: pumpStatus ? 'ON' : 'OFF',
                  color: pumpStatus ? Colors.blue : Colors.grey,
                ),
              ],
            ),
            if (status['lastSeen'] != null) ...[
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.access_time, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    'Last seen: ${_formatLastSeen(status['lastSeen'] as DateTime)}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildBatteryChart(MonitoringState state) {
    final history = state.batteryHistory ?? [];

    if (history.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              Icon(Icons.show_chart, size: 48, color: Colors.grey.shade400),
              const SizedBox(height: 16),
              Text(
                'No data available',
                style: TextStyle(color: Colors.grey.shade600),
              ),
              const SizedBox(height: 8),
              Text(
                'Wait for telemetry data from device',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Battery History',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                if (_dateRange != null)
                  Text(
                    '${_formatDate(_dateRange!.start)} - ${_formatDate(_dateRange!.end)}',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 250,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: true),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text('${value.toInt()}%');
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index >= 0 && index < history.length) {
                            final timestamp =
                                history[index]['timestamp'] as DateTime;
                            return Text(
                              '${timestamp.day}/${timestamp.month}',
                              style: const TextStyle(fontSize: 10),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: history.asMap().entries.map((entry) {
                        return FlSpot(
                          entry.key.toDouble(),
                          (entry.value['batteryPercentage'] as int).toDouble(),
                        );
                      }).toList(),
                      isCurved: true,
                      color: Colors.green,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Colors.green.withValues(alpha: 0.1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsCard(MonitoringState state) {
    final stats = state.statistics;

    if (stats == null) return const SizedBox();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Statistics Summary',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    label: 'Avg Battery',
                    value: '${stats['averageBattery']}%',
                    icon: Icons.battery_std,
                    color: Colors.green,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    label: 'UV Usage',
                    value: '${stats['uvOnPercentage']}%',
                    icon: Icons.light_mode,
                    color: Colors.orange,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    label: 'Pump Usage',
                    value: '${stats['pumpOnPercentage']}%',
                    icon: Icons.water_drop,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    label: 'Total Commands',
                    value: '${stats['totalCommands']}',
                    icon: Icons.touch_app,
                    color: Colors.purple,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    label: 'Data Points',
                    value: '${stats['dataPoints']}',
                    icon: Icons.data_usage,
                    color: Colors.teal,
                  ),
                ),
                const Expanded(child: SizedBox()),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildActivitySummary() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Activity Summary',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text('View Full History'),
              subtitle: const Text('See all device activity logs'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.pushNamed(context, '/history');
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.file_download),
              title: const Text('Export Data'),
              subtitle: const Text('Download CSV report'),
              trailing: const Icon(Icons.chevron_right),
              onTap: _showExportOptions,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _loadMonitoringData() async {
    if (_selectedDeviceId == null) return;

    final endDate = _dateRange?.end ?? DateTime.now();
    final startDate =
        _dateRange?.start ?? DateTime.now().subtract(const Duration(days: 7));

    // Load device status
    if (mounted) {
      await context.read<MonitoringCubit>().loadDeviceStatus(_selectedDeviceId!);
    }

    // Load battery history
    if (mounted) {
      await context.read<MonitoringCubit>().loadBatteryHistory(
            deviceId: _selectedDeviceId!,
            startDate: startDate,
            endDate: endDate,
            limit: 30,
          );
    }

    // Load statistics
    if (mounted) {
      await context.read<MonitoringCubit>().loadStatistics(
            deviceId: _selectedDeviceId!,
            startDate: startDate,
            endDate: endDate,
          );
    }
  }

  Future<void> _refreshData() async {
    await _loadMonitoringData();
    if (mounted) {
      await context.read<DeviceCubit>().loadDevices();
    }
  }

  Future<void> _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      initialDateRange: _dateRange,
    );

    if (picked != null && mounted) {
      setState(() {
        _dateRange = picked;
      });
      _loadMonitoringData();
    }
  }

  void _showExportOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (bottomSheetContext) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Export Data',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.file_copy),
              title: const Text('CSV Format'),
              onTap: () async {
                Navigator.pop(bottomSheetContext);
                await _exportData('csv');
              },
            ),
            ListTile(
              leading: const Icon(Icons.picture_as_pdf),
              title: const Text('PDF Format'),
              onTap: () async {
                Navigator.pop(bottomSheetContext);
                await _exportData('pdf');
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _exportData(String format) async {
    if (_selectedDeviceId == null) return;

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Exporting data as $format...')),
    );

    // Simulate export process
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Export completed!')),
      );
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatLastSeen(DateTime lastSeen) {
    final now = DateTime.now();
    final diff = now.difference(lastSeen);

    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes} min ago';
    }
    if (diff.inHours < 24) {
      return '${diff.inHours} hour${diff.inHours > 1 ? 's' : ''} ago';
    }
    return '${diff.inDays} day${diff.inDays > 1 ? 's' : ''} ago';
  }

  Color _getBatteryColor(int percentage) {
    if (percentage >= 50) return Colors.green;
    if (percentage >= 20) return Colors.orange;
    return Colors.red;
  }
}