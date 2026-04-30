import 'package:sqflite/sqflite.dart';
import '../../../core/storage/database_helper.dart';
import '../../../core/utils/logger.dart';
import '../../models/device/device_model.dart';

class DeviceLocalDataSource {
  Future<List<DeviceModel>> getDevices() async {
    try {
      final db = await DatabaseHelper.database;
      final result = await db.query(
        DatabaseHelper.tableDevices,
        orderBy: 'created_at DESC',
      );

      return result.map((json) => DeviceModel.fromJson(json)).toList();
    } catch (e) {
      Logger.e('DeviceLocalDataSource', 'Failed to get devices', e);
      throw Exception('Failed to get devices: $e');
    }
  }

  Future<DeviceModel?> getDeviceById(String id) async {
    try {
      final db = await DatabaseHelper.database;
      final result = await db.query(
        DatabaseHelper.tableDevices,
        where: 'id = ?',
        whereArgs: [id],
      );

      if (result.isNotEmpty) {
        return DeviceModel.fromJson(result.first);
      }
      return null;
    } catch (e) {
      Logger.e('DeviceLocalDataSource', 'Failed to get device by id', e);
      throw Exception('Failed to get device: $e');
    }
  }

  Future<DeviceModel?> getDeviceByMacAddress(String macAddress) async {
    try {
      final db = await DatabaseHelper.database;
      final result = await db.query(
        DatabaseHelper.tableDevices,
        where: 'mac_address = ?',
        whereArgs: [macAddress],
      );

      if (result.isNotEmpty) {
        return DeviceModel.fromJson(result.first);
      }
      return null;
    } catch (e) {
      Logger.e('DeviceLocalDataSource', 'Failed to get device by mac', e);
      throw Exception('Failed to get device: $e');
    }
  }

  Future<void> saveDevice(DeviceModel device) async {
    try {
      final db = await DatabaseHelper.database;
      await db.insert(
        DatabaseHelper.tableDevices,
        device.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      Logger.d('DeviceLocalDataSource', 'Device saved: ${device.name}');
    } catch (e) {
      Logger.e('DeviceLocalDataSource', 'Failed to save device', e);
      throw Exception('Failed to save device: $e');
    }
  }

  Future<void> updateDevice(DeviceModel device) async {
    try {
      final db = await DatabaseHelper.database;
      await db.update(
        DatabaseHelper.tableDevices,
        device.toJson(),
        where: 'id = ?',
        whereArgs: [device.id],
      );
      Logger.d('DeviceLocalDataSource', 'Device updated: ${device.name}');
    } catch (e) {
      Logger.e('DeviceLocalDataSource', 'Failed to update device', e);
      throw Exception('Failed to update device: $e');
    }
  }

  Future<void> deleteDevice(String id) async {
    try {
      final db = await DatabaseHelper.database;
      await db.delete(
        DatabaseHelper.tableDevices,
        where: 'id = ?',
        whereArgs: [id],
      );
      Logger.d('DeviceLocalDataSource', 'Device deleted: $id');
    } catch (e) {
      Logger.e('DeviceLocalDataSource', 'Failed to delete device', e);
      throw Exception('Failed to delete device: $e');
    }
  }

  Future<void> saveTelemetry(DeviceTelemetryModel telemetry) async {
    try {
      final db = await DatabaseHelper.database;
      await db.insert(
        DatabaseHelper.tableTelemetry,
        telemetry.toJson(),
      );
      Logger.d('DeviceLocalDataSource',
          'Telemetry saved for device: ${telemetry.deviceId}');
    } catch (e) {
      Logger.e('DeviceLocalDataSource', 'Failed to save telemetry', e);
    }
  }

  Future<List<DeviceTelemetryModel>> getTelemetryHistory(
    String deviceId, {
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
  }) async {
    try {
      final db = await DatabaseHelper.database;
      var whereClause = 'device_id = ?';
      final whereArgs = [deviceId];

      if (startDate != null) {
        whereClause += ' AND timestamp >= ?';
        whereArgs.add(startDate.toIso8601String());
      }

      if (endDate != null) {
        whereClause += ' AND timestamp <= ?';
        whereArgs.add(endDate.toIso8601String());
      }

      final result = await db.query(
        DatabaseHelper.tableTelemetry,
        where: whereClause,
        whereArgs: whereArgs,
        orderBy: 'timestamp DESC',
        limit: limit,
      );

      return result.map((json) => DeviceTelemetryModel.fromJson(json)).toList();
    } catch (e) {
      Logger.e('DeviceLocalDataSource', 'Failed to get telemetry history', e);
      return [];
    }
  }

  Future<void> cleanOldTelemetry(int daysToKeep) async {
    try {
      final db = await DatabaseHelper.database;
      final cutoffDate = DateTime.now().subtract(Duration(days: daysToKeep));

      await db.delete(
        DatabaseHelper.tableTelemetry,
        where: 'timestamp < ?',
        whereArgs: [cutoffDate.toIso8601String()],
      );
      Logger.d('DeviceLocalDataSource',
          'Cleaned telemetry older than $daysToKeep days');
    } catch (e) {
      Logger.e('DeviceLocalDataSource', 'Failed to clean old telemetry', e);
    }
  }

  // Add to DeviceLocalDataSource class
  Future<void> cacheDevices(List<DeviceModel> devices) async {
    try {
      final db = await DatabaseHelper.database;
      await db.delete(DatabaseHelper.tableDevices);
      for (final device in devices) {
        await db.insert(DatabaseHelper.tableDevices, device.toJson());
      }
      Logger.d('DeviceLocalDataSource', 'Cached ${devices.length} devices');
    } catch (e) {
      Logger.e('DeviceLocalDataSource', 'Failed to cache devices', e);
    }
  }

  Future<List<DeviceModel>> getCachedDevices() async {
    return await getDevices();
  }

  Future<bool> hasCachedDevices() async {
    final devices = await getDevices();
    return devices.isNotEmpty;
  }
}
