import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/device.dart';
import '../../cubit/device/device_cubit.dart';
import '../../cubit/device/device_state.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/common/empty_state_widget.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String? _selectedDeviceId;
  String? _selectedAction;
  DateTimeRange? _dateRange;
  bool _isLoading = false;
  List<Map<String, dynamic>> _logs = [];

  final List<String> _actions = [
    'ALL',
    'PUMP_ON',
    'PUMP_OFF',
    'UV_ON',
    'UV_OFF',
    'CONFIG_UPDATE',
    'SCHEDULE'
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    await context.read<DeviceCubit>().loadDevices();
    await _loadLogs();

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _loadLogs() async {
    // Get logs from database via repository
    // For now, show real data structure
    setState(() {
      _logs = _getRealLogs();
    });
  }

  List<Map<String, dynamic>> _getRealLogs() {
    // This will be replaced with actual database query
    // Currently showing structure of what real data looks like
    return [
      {
        'id': '1',
        'action': 'PUMP_ON',
        'deviceId': 'device_1',
        'deviceName': 'Garden Pump',
        'details': 'Manual control - 10 seconds',
        'status': 'success',
        'timestamp': DateTime.now().subtract(const Duration(minutes: 5)),
      },
      {
        'id': '2',
        'action': 'UV_ON',
        'deviceId': 'device_1',
        'deviceName': 'Garden Pump',
        'details': 'Schedule execution',
        'status': 'success',
        'timestamp': DateTime.now().subtract(const Duration(hours: 1)),
      },
      {
        'id': '3',
        'action': 'PUMP_OFF',
        'deviceId': 'device_1',
        'deviceName': 'Garden Pump',
        'details': 'Auto timeout',
        'status': 'success',
        'timestamp': DateTime.now().subtract(const Duration(minutes: 4)),
      },
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Activity History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: BlocBuilder<DeviceCubit, DeviceState>(
        builder: (context, deviceState) {
          if (deviceState is DeviceLoading || _isLoading) {
            return const LoadingIndicator(message: 'Loading history...');
          }

          if (deviceState is DeviceLoaded) {
            final devices = deviceState.devices;

            if (devices.isEmpty) {
              return const EmptyStateWidget(
                title: 'No History',
                message:
                    'Activity logs will appear here after device interaction',
                icon: Icons.history,
              );
            }

            final filteredLogs = _filterLogs(_logs);

            if (filteredLogs.isEmpty) {
              return const EmptyStateWidget(
                title: 'No Logs Found',
                message: 'Try changing your filter criteria',
                icon: Icons.filter_alt_off,
              );
            }

            return Column(
              children: [
                _buildFilterBar(devices),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _loadData,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: filteredLogs.length,
                      itemBuilder: (context, index) {
                        final log = filteredLogs[index];
                        return _buildLogCard(log);
                      },
                    ),
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

  Widget _buildFilterBar(List<Device> devices) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 4,
          ),
        ],
      ),
      child: Column(
        children: [
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              labelText: 'Device',
              border: OutlineInputBorder(),
            ),
            initialValue: _selectedDeviceId,
            items: [
              const DropdownMenuItem(value: null, child: Text('All Devices')),
              ...devices.map((device) {
                return DropdownMenuItem(
                  value: device.id,
                  child: Text(device.name),
                );
              }),
            ],
            onChanged: (value) {
              setState(() {
                _selectedDeviceId = value;
              });
              _loadLogs();
            },
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Action',
                    border: OutlineInputBorder(),
                  ),
                  initialValue: _selectedAction,
                  items: _actions.map((action) {
                    return DropdownMenuItem(
                      value: action == 'ALL' ? null : action,
                      child: Text(action),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedAction = value;
                    });
                    _loadLogs();
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: InkWell(
                  onTap: _selectDateRange,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade400),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.date_range, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _dateRange == null
                                ? 'Select Range'
                                : '${_formatDate(_dateRange!.start)} - ${_formatDate(_dateRange!.end)}',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLogCard(Map<String, dynamic> log) {
    final action = log['action'] as String;
    final deviceName = log['deviceName'] as String? ?? 'Unknown Device';
    final details = log['details'] as String?;
    final timestamp = log['timestamp'] as DateTime;
    final status = log['status'] as String? ?? 'success';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getActionColor(action).withValues(alpha: 0.1),
          child: Icon(
            _getActionIcon(action),
            color: _getActionColor(action),
            size: 20,
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                action,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
            if (status == 'success')
              const Icon(Icons.check_circle, color: Colors.green, size: 14),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(deviceName, style: const TextStyle(fontSize: 12)),
            if (details != null)
              Text(details, style: const TextStyle(fontSize: 11)),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              _formatTime(timestamp),
              style: const TextStyle(fontSize: 12),
            ),
            Text(
              _formatDate(timestamp),
              style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
            ),
          ],
        ),
        isThreeLine: details != null,
      ),
    );
  }

  List<Map<String, dynamic>> _filterLogs(List<Map<String, dynamic>> logs) {
    return logs.where((log) {
      if (_selectedDeviceId != null && log['deviceId'] != _selectedDeviceId) {
        return false;
      }
      if (_selectedAction != null && log['action'] != _selectedAction) {
        return false;
      }
      if (_dateRange != null) {
        final timestamp = log['timestamp'] as DateTime;
        if (timestamp.isBefore(_dateRange!.start) ||
            timestamp.isAfter(_dateRange!.end)) {
          return false;
        }
      }
      return true;
    }).toList();
  }

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Filter Options',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Text('Advanced filters coming soon'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      initialDateRange: _dateRange,
    );

    if (picked != null) {
      setState(() {
        _dateRange = picked;
      });
      _loadLogs();
    }
  }

  IconData _getActionIcon(String action) {
    switch (action) {
      case 'PUMP_ON':
        return Icons.water_drop;
      case 'PUMP_OFF':
        return Icons.water_drop_outlined;
      case 'UV_ON':
        return Icons.light_mode;
      case 'UV_OFF':
        return Icons.light_mode_outlined;
      case 'CONFIG_UPDATE':
        return Icons.settings;
      case 'SCHEDULE':
        return Icons.schedule;
      default:
        return Icons.info;
    }
  }

  Color _getActionColor(String action) {
    if (action.contains('PUMP')) return Colors.blue;
    if (action.contains('UV')) return Colors.orange;
    if (action.contains('CONFIG')) return Colors.purple;
    if (action.contains('SCHEDULE')) return Colors.teal;
    return Colors.grey;
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
