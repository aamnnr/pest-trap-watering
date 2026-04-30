import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../../core/utils/logger.dart';

class WifiConfigScreen extends StatefulWidget {
  const WifiConfigScreen({super.key});

  @override
  State<WifiConfigScreen> createState() => _WifiConfigScreenState();
}

class _WifiConfigScreenState extends State<WifiConfigScreen> {
  final _formKey = GlobalKey<FormState>();
  final _ssidController = TextEditingController();
  final _passwordController = TextEditingController();
  final _esp32IpController = TextEditingController(text: '192.168.4.1');

  bool _isConnecting = false;
  bool _isConnectedToEsp32 = false;
  String? _esp32ApName;

  @override
  void initState() {
    super.initState();
    _checkEsp32Connection();
  }

  @override
  void dispose() {
    _ssidController.dispose();
    _passwordController.dispose();
    _esp32IpController.dispose();
    super.dispose();
  }

  Future<void> _checkEsp32Connection() async {
    setState(() {
      _isConnecting = true;
    });

    try {
      final ip = _esp32IpController.text;
      final url = Uri.parse('http://$ip/');

      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 3);

      try {
        final request = await client.getUrl(url);
        final response = await request.close();

        if (response.statusCode == 200) {
          setState(() {
            _isConnectedToEsp32 = true;
            _esp32ApName = 'ESP32 Device';
          });

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Connected to ESP32 device!')),
            );
          }
        } else {
          _showConnectionError();
        }
      } catch (e) {
        _showConnectionError();
      } finally {
        client.close();
      }
    } catch (e) {
      _showConnectionError();
    } finally {
      if (mounted) {
        setState(() {
          _isConnecting = false;
        });
      }
    }
  }

  void _showConnectionError() {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Cannot connect to ESP32. Make sure you are connected to device WiFi (PestTrap-Watering_Setup_XX)'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 5),
        ),
      );
    }
  }

  Future<void> _saveConfiguration() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isConnecting = true;
    });

    try {
      final ip = _esp32IpController.text;
      final url = Uri.parse('http://$ip/save');

      final payload = jsonEncode({
        'ssid': _ssidController.text,
        'pass': _passwordController.text,
      });

      Logger.d('WifiConfig', 'Sending config to $url');
      Logger.d('WifiConfig', 'Payload: ${_ssidController.text} / [HIDDEN]');

      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: payload,
          )
          .timeout(const Duration(seconds: 15));

      Logger.d('WifiConfig', 'Response status: ${response.statusCode}');
      Logger.d('WifiConfig', 'Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'ok') {
          _showSuccessDialog();
        } else {
          _showErrorDialog('Failed: ${data['message']}');
        }
      } else {
        _showErrorDialog('HTTP Error: ${response.statusCode}');
      }
    } catch (e) {
      Logger.e('WifiConfig', 'Connection error', e);
      _showErrorDialog(
          'Connection failed: $e\n\nMake sure you are connected to ESP32 WiFi');
    } finally {
      setState(() {
        _isConnecting = false;
      });
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Text('Success!'),
          ],
        ),
        content: const Text(
          'WiFi configuration sent successfully!\n\n'
          'The ESP32 will restart and connect to your WiFi network.\n'
          'This may take 30-60 seconds.\n\n'
          'After that, the device will appear in your device list.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.error, color: Colors.red),
            SizedBox(width: 8),
            Text('Error'),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('WiFi Configuration'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildConnectionGuide(),
              const SizedBox(height: 24),
              _buildConnectionStatus(),
              const SizedBox(height: 24),
              _buildConfigForm(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConnectionGuide() {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue),
                SizedBox(width: 8),
                Text(
                  'How to Configure',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 12),
            Text(
              '1. Make sure ESP32 device is powered ON\n'
              '2. Device will create WiFi network: PestTrap-Watering_Setup_XX\n'
              '3. Go to phone WiFi settings and connect to that network\n'
              '4. Return to this app and enter your home WiFi credentials\n'
              '5. Tap "Send Configuration"',
              style: TextStyle(fontSize: 14, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConnectionStatus() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Connection Status',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  _isConnecting
                      ? Icons.hourglass_empty
                      : (_isConnectedToEsp32
                          ? Icons.check_circle
                          : Icons.error),
                  color: _isConnecting
                      ? Colors.orange
                      : (_isConnectedToEsp32 ? Colors.green : Colors.red),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _isConnecting
                        ? 'Checking connection...'
                        : (_isConnectedToEsp32
                            ? 'Connected to $_esp32ApName'
                            : 'Not connected to ESP32'),
                  ),
                ),
                if (!_isConnecting)
                  TextButton(
                    onPressed: _checkEsp32Connection,
                    child: const Text('Refresh'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfigForm() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'WiFi Credentials',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label: 'ESP32 IP Address',
              hint: '192.168.4.1',
              controller: _esp32IpController,
              prefixIcon: Icons.dns,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label: 'WiFi SSID',
              hint: 'Your home WiFi name',
              controller: _ssidController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter WiFi SSID';
                }
                return null;
              },
              prefixIcon: Icons.wifi,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label: 'WiFi Password',
              hint: 'Your WiFi password',
              controller: _passwordController,
              obscureText: true,
              prefixIcon: Icons.lock,
            ),
            const SizedBox(height: 24),
            CustomButton(
              text: 'Send Configuration to ESP32',
              onPressed: _saveConfiguration,
              isLoading: _isConnecting,
              icon: Icons.send,
            ),
          ],
        ),
      ),
    );
  }
}
