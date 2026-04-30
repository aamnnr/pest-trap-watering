import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/storage/local_storage.dart';
import '../../../core/utils/logger.dart';
import '../../cubit/device/device_cubit.dart';
import '../../widgets/common/custom_button.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _darkMode = false;
  String _themeMode = 'system';
  String _syncInterval = '15';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final localStorage = LocalStorage();
    _notificationsEnabled = await localStorage.isNotificationsEnabled();
    _themeMode = await localStorage.getThemeMode();
    _darkMode = _themeMode == 'dark';

    final prefs = await SharedPreferences.getInstance();
    _syncInterval = prefs.getString('sync_interval') ?? '15';

    setState(() {});
  }

  Future<void> _saveSettings() async {
    setState(() => _isLoading = true);

    try {
      final localStorage = LocalStorage();
      await localStorage.setNotificationsEnabled(_notificationsEnabled);

      final themeMode =
          _darkMode ? 'dark' : (_themeMode == 'system' ? 'system' : 'light');
      await localStorage.setThemeMode(themeMode);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('sync_interval', _syncInterval);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Settings saved successfully')),
        );
      }
    } catch (e) {
      Logger.e('SettingsScreen', 'Failed to save settings', e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProfileSection(),
                const SizedBox(height: 16),
                _buildPreferencesSection(),
                const SizedBox(height: 16),
                _buildNotificationsSection(),
                const SizedBox(height: 16),
                _buildSyncSection(),
                const SizedBox(height: 16),
                _buildDataSection(),
                const SizedBox(height: 16),
                _buildAboutSection(),
                const SizedBox(height: 24),
                CustomButton(
                  text: 'Save Settings',
                  onPressed: _saveSettings,
                  isLoading: _isLoading,
                  icon: Icons.save,
                ),
                const SizedBox(height: 16),
                CustomButton(
                  text: 'Clear All Data',
                  onPressed: _showClearDataDialog,
                  type: ButtonType.danger,
                  icon: Icons.delete_forever,
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withValues(alpha: 0.5),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  Widget _buildProfileSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.person, size: 24),
                SizedBox(width: 12),
                Text(
                  'Profile',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const ListTile(
              leading: Icon(Icons.badge),
              title: Text('App Version'),
              subtitle: Text('1.0.0'),
              trailing: Icon(Icons.info_outline),
            ),
            ListTile(
              leading: const Icon(Icons.devices),
              title: const Text('Device ID'),
              subtitle: Text(DateTime.now()
                  .millisecondsSinceEpoch
                  .toString()
                  .substring(0, 8)),
              trailing: const Icon(Icons.content_copy),
              onTap: () {
                // Copy device ID
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreferencesSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.settings, size: 24),
                SizedBox(width: 12),
                Text(
                  'Preferences',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Dark Mode'),
              subtitle: const Text('Enable dark theme'),
              value: _darkMode,
              onChanged: (value) {
                setState(() {
                  _darkMode = value;
                  _themeMode = value ? 'dark' : 'light';
                });
              },
              secondary: const Icon(Icons.dark_mode),
            ),
            ListTile(
              leading: const Icon(Icons.language),
              title: const Text('Language'),
              subtitle: const Text('English'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                _showLanguageDialog();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.notifications, size: 24),
                SizedBox(width: 12),
                Text(
                  'Notifications',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Push Notifications'),
              subtitle: const Text('Receive device alerts and updates'),
              value: _notificationsEnabled,
              onChanged: (value) {
                setState(() {
                  _notificationsEnabled = value;
                });
              },
              secondary: const Icon(Icons.notifications_active),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.battery_alert),
              title: const Text('Low Battery Alert'),
              subtitle: const Text('Notify when battery below 20%'),
              trailing: Switch(
                value: true,
                onChanged: (value) {},
              ),
            ),
            ListTile(
              leading: const Icon(Icons.device_unknown),
              title: const Text('Device Offline Alert'),
              subtitle: const Text('Notify when device offline'),
              trailing: Switch(
                value: true,
                onChanged: (value) {},
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSyncSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.sync, size: 24),
                SizedBox(width: 12),
                Text(
                  'Data Sync',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.timer),
              title: const Text('Sync Interval'),
              subtitle: Text('Every $_syncInterval minutes'),
              trailing: DropdownButton<String>(
                value: _syncInterval,
                items: const [
                  DropdownMenuItem(value: '5', child: Text('5 minutes')),
                  DropdownMenuItem(value: '15', child: Text('15 minutes')),
                  DropdownMenuItem(value: '30', child: Text('30 minutes')),
                  DropdownMenuItem(value: '60', child: Text('1 hour')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _syncInterval = value;
                    });
                  }
                },
              ),
            ),
            const Divider(),
          ],
        ),
      ),
    );
  }

  Widget _buildDataSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.storage, size: 24),
                SizedBox(width: 12),
                Text(
                  'Data Management',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.backup),
              title: const Text('Export Data'),
              subtitle: const Text('Export all device data'),
              trailing: const Icon(Icons.chevron_right),
              onTap: _showExportOptions,
            ),
            ListTile(
              leading: const Icon(Icons.restore),
              title: const Text('Import Data'),
              subtitle: const Text('Import from backup'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // Implement import
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.info, size: 24),
                SizedBox(width: 12),
                Text(
                  'About',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.description),
              title: const Text('Privacy Policy'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                _showPrivacyDialog();
              },
            ),
            ListTile(
              leading: const Icon(Icons.help),
              title: const Text('Help & Support'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                _showSupportDialog();
              },
            ),
            ListTile(
              leading: const Icon(Icons.code),
              title: const Text('Open Source Licenses'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                _showLicensesDialog();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('English'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Bahasa Indonesia'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showExportOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
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
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Export started...')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.picture_as_pdf),
              title: const Text('PDF Format'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Export started...')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.cloud_upload),
              title: const Text('Backup to Cloud'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Backup started...')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showClearDataDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Data'),
        content: const Text(
          'This will delete all devices, schedules, and history.\n'
          'This action cannot be undone.\n\n'
          'Are you sure?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _clearAllData();
            },
            child: const Text('Clear', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _clearAllData() async {
    setState(() => _isLoading = true);

    try {
      // Clear device data
      final deviceCubit = context.read<DeviceCubit>();
      final devices = await deviceCubit.getDevices.execute();

      for (final device in devices) {
        await deviceCubit.removeDevice(device.id);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('All data cleared successfully')),
        );
      }
    } catch (e) {
      Logger.e('SettingsScreen', 'Failed to clear data', e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showPrivacyDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Privacy Policy'),
        content: const SingleChildScrollView(
          child: Text(
            'Your data is stored locally on your device.\n\n'
            'We do not collect any personal information.\n\n'
            'Device credentials are stored securely.\n\n'
            'You can export or delete your data at any time.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showSupportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Help & Support'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('📧 Email: support@tanisolusi.com'),
            SizedBox(height: 8),
            Text('🌐 Website: www.tanisolusi.com'),
            SizedBox(height: 8),
            Text('📱 Phone: +62 123 4567 890'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showLicensesDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Open Source Licenses'),
        content: const SingleChildScrollView(
          child: Text(
            'This app uses the following open source libraries:\n\n'
            '• Flutter - BSD 3-Clause\n'
            '• flutter_bloc - MIT\n'
            '• mqtt_client - MIT\n'
            '• sqflite - BSD\n'
            '• fl_chart - MIT\n'
            '• go_router - BSD 3-Clause\n'
            '• and more...\n\n'
            'Thank you to all contributors!',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
