import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../domain/entities/device.dart';
import '../../cubit/device/device_cubit.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/loading_overlay.dart';

class AddDeviceScreen extends StatefulWidget {
  const AddDeviceScreen({super.key});
  
  @override
  State<AddDeviceScreen> createState() => _AddDeviceScreenState();
}

class _AddDeviceScreenState extends State<AddDeviceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _macController = TextEditingController();
  final _locationController = TextEditingController();
  
  // WiFi config variables
  final _wifiSsidController = TextEditingController();
  final _wifiPasswordController = TextEditingController();
  final _esp32IpController = TextEditingController(text: '192.168.4.1');
  
  bool _isLoading = false;
  int _step = 0; // 0: device info, 1: wifi config
  
  // ESP32 AP connection
  String? _esp32ApName;
  bool _isConnectedToEsp32 = false;
  List<Map<String, dynamic>> _availableNetworks = [];
  bool _isScanningWifi = false;
  
  @override
  void dispose() {
    _nameController.dispose();
    _macController.dispose();
    _locationController.dispose();
    _wifiSsidController.dispose();
    _wifiPasswordController.dispose();
    _esp32IpController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_step == 0 ? 'Add Device' : 'Configure WiFi'),
        actions: [
          if (_step == 1)
            TextButton(
              onPressed: () {
                setState(() {
                  _step = 0;
                });
              },
              child: const Text('Back'),
            ),
        ],
      ),
      body: LoadingOverlay(
        isLoading: _isLoading,
        message: _step == 0 ? 'Adding device...' : 'Configuring WiFi...',
        child: _step == 0 ? _buildDeviceInfoForm() : _buildWifiConfigForm(),
      ),
    );
  }
  
  Widget _buildDeviceInfoForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    Icon(Icons.info_outline, size: 48, color: Colors.blue),
                    SizedBox(height: 12),
                    Text(
                      'How to pair your device:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '1. Power on your ESP32 device\n'
                      '2. Device will create WiFi: PestTrap-Watering_Setup_XX\n'
                      '3. Connect your phone to that WiFi\n'
                      '4. Enter device MAC address below\n'
                      '5. Or connect to device WiFi first, then we will auto-detect',
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label: 'Device Name',
              hint: 'e.g., Garden Pump',
              controller: _nameController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter device name';
                }
                return null;
              },
              prefixIcon: Icons.devices,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label: 'MAC Address',
              hint: 'XX:XX:XX:XX:XX:XX',
              controller: _macController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter MAC address';
                }
                if (!RegExp(r'^([0-9A-Fa-f]{2}[:]){5}([0-9A-Fa-f]{2})$').hasMatch(value.toUpperCase())) {
                  return 'Invalid MAC address format';
                }
                return null;
              },
              prefixIcon: Icons.settings_ethernet,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label: 'Location (Optional)',
              hint: 'e.g., Backyard',
              controller: _locationController,
              prefixIcon: Icons.location_on,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: 'Check Connection',
                    onPressed: _checkEsp32Connection,
                    type: ButtonType.secondary,
                    icon: Icons.wifi_find,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CustomButton(
                    text: 'Next: Configure WiFi',
                    onPressed: _validateAndProceed,
                    icon: Icons.arrow_forward,
                  ),
                ),
              ],
            ),
            if (_isConnectedToEsp32) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green.shade600),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Connected to ESP32: $_esp32ApName',
                        style: TextStyle(color: Colors.green.shade800),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
  
  Widget _buildWifiConfigForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  Icon(Icons.wifi, size: 48, color: Colors.blue),
                  SizedBox(height: 12),
                  Text(
                    'Configure Home WiFi',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Enter your home WiFi credentials to connect the ESP32 device.',
                    style: TextStyle(fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
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
            controller: _wifiSsidController,
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
            controller: _wifiPasswordController,
            obscureText: true,
            prefixIcon: Icons.lock,
          ),
          const SizedBox(height: 16),
          CustomButton(
            text: 'Scan Available Networks',
            onPressed: _scanWifiNetworks,
            type: ButtonType.secondary,
            isLoading: _isScanningWifi,
            icon: Icons.search,
          ),
          if (_availableNetworks.isNotEmpty) ...[
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Available Networks:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 150,
                      child: ListView.builder(
                        itemCount: _availableNetworks.length,
                        itemBuilder: (context, index) {
                          final network = _availableNetworks[index];
                          return ListTile(
                            leading: const Icon(Icons.wifi, color: Colors.blue),
                            title: Text(network['ssid'] as String),
                            trailing: Text('${network['signal']}%', style: const TextStyle(fontSize: 12)),
                            dense: true,
                            onTap: () {
                              _wifiSsidController.text = network['ssid'] as String;
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 24),
          CustomButton(
            text: 'Send WiFi Configuration',
            onPressed: _sendWifiConfig,
            icon: Icons.save,
          ),
        ],
      ),
    );
  }
  
  Future<void> _checkEsp32Connection() async {
    setState(() {
      _isLoading = true;
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
          _isLoading = false;
        });
      }
    }
  }
  
  void _showConnectionError() {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cannot connect to ESP32. Make sure you are connected to device WiFi'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  
  Future<void> _scanWifiNetworks() async {
    setState(() {
      _isScanningWifi = true;
    });
    
    // Simulate network scanning
    await Future.delayed(const Duration(seconds: 2));
    
    if (mounted) {
      setState(() {
        _availableNetworks = [
          {'ssid': 'Home WiFi 2.4GHz', 'signal': 85},
          {'ssid': 'Office Network', 'signal': 70},
          {'ssid': 'Guest WiFi', 'signal': 45},
        ];
        _isScanningWifi = false;
      });
    }
  }
  
  void _validateAndProceed() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _step = 1;
      });
    }
  }
  
  Future<void> _sendWifiConfig() async {
    if (_wifiSsidController.text.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter WiFi SSID')),
        );
      }
      return;
    }
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      final ip = _esp32IpController.text;
      final url = Uri.parse('http://$ip/save');
      
      final payload = jsonEncode({
        'ssid': _wifiSsidController.text,
        'pass': _wifiPasswordController.text,
      });
      
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: payload,
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'ok') {
          await _addDeviceToApp();
        } else if (mounted) {
          _showErrorDialog('Failed to configure WiFi: ${data['message']}');
        }
      } else if (mounted) {
        _showErrorDialog('Failed to configure WiFi. Status: ${response.statusCode}');
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog('Connection failed: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  
  Future<void> _addDeviceToApp() async {
    try {
      final deviceId = _macController.text.replaceAll(':', '').toLowerCase();
      final id = DateTime.now().millisecondsSinceEpoch.toString();
      
      final success = await context.read<DeviceCubit>().addNewDevice(
        id: id,
        name: _nameController.text,
        macAddress: _macController.text.toUpperCase(),
        deviceId: deviceId,
        mqttTopic: 'tanisolution/$deviceId/telemetry',
        location: _locationController.text.isEmpty ? null : _locationController.text,
        config: const DeviceConfig(uvStartHour: 18, uvEndHour: 23),
      );
      
      if (success && mounted) {
        if (!mounted) return;
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (dialogContext) => AlertDialog(
            title: const Icon(Icons.check_circle, color: Colors.green, size: 48),
            content: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Device Added Successfully!'),
                SizedBox(height: 8),
                Text('The ESP32 will restart and connect to your WiFi.'),
                SizedBox(height: 8),
                Text('You can now control it from the app.', style: TextStyle(fontSize: 12)),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
        
        if (mounted) {
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog('Failed to add device: $e');
      }
    }
  }
  
  void _showErrorDialog(String message) {
    if (mounted) {
      showDialog(
        context: context,
        builder: (dialogContext) => AlertDialog(
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
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }
}