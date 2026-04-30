import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import '../utils/logger.dart';

class DatabaseHelper {
  static Database? _database;
  static const String databaseName = 'pest_trap_watering.db';

  // Table names
  static const String tableDevices = 'devices';
  static const String tableTelemetry = 'telemetry';
  static const String tableSchedules = 'schedules';
  static const String tableActivityLogs = 'activity_logs';
  static const String tableNotifications = 'notifications';

  static Future<void> init() async {
    await _getDatabase();
  }

  static Future<Database> _getDatabase() async {
    if (_database != null) return _database!;

    try {
      final directory = await getApplicationDocumentsDirectory();
      final path = join(directory.path, databaseName);

      _database = await openDatabase(
        path,
        version: 1,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
      );

      Logger.d('DatabaseHelper', 'Database initialized at: $path');
      return _database!;
    } catch (e) {
      Logger.e('DatabaseHelper', 'Failed to initialize database', e);
      rethrow;
    }
  }

  static Future<void> _onCreate(Database db, int version) async {
    // Create devices table
    await db.execute('''
      CREATE TABLE $tableDevices (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        mac_address TEXT UNIQUE NOT NULL,
        device_id TEXT NOT NULL,
        mqtt_topic TEXT NOT NULL,
        location TEXT,
        is_active INTEGER DEFAULT 1,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // Create telemetry table
    await db.execute('''
      CREATE TABLE $tableTelemetry (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        device_id TEXT NOT NULL,
        battery_percentage INTEGER,
        uv_status INTEGER,
        pump_status INTEGER,
        is_night INTEGER,
        timestamp TEXT NOT NULL,
        FOREIGN KEY (device_id) REFERENCES $tableDevices (id)
      )
    ''');

    // Create schedules table
    await db.execute('''
      CREATE TABLE $tableSchedules (
        id TEXT PRIMARY KEY,
        device_id TEXT NOT NULL,
        type TEXT NOT NULL,
        action TEXT NOT NULL,
        start_time TEXT NOT NULL,
        end_time TEXT,
        repeat_days TEXT,
        is_enabled INTEGER DEFAULT 1,
        created_at TEXT NOT NULL,
        FOREIGN KEY (device_id) REFERENCES $tableDevices (id)
      )
    ''');

    // Create activity logs table
    await db.execute('''
      CREATE TABLE $tableActivityLogs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        device_id TEXT NOT NULL,
        action TEXT NOT NULL,
        source TEXT NOT NULL,
        details TEXT,
        status TEXT NOT NULL,
        timestamp TEXT NOT NULL,
        FOREIGN KEY (device_id) REFERENCES $tableDevices (id)
      )
    ''');

    // Create notifications table
    await db.execute('''
      CREATE TABLE $tableNotifications (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        body TEXT NOT NULL,
        type TEXT NOT NULL,
        device_id TEXT,
        is_read INTEGER DEFAULT 0,
        created_at TEXT NOT NULL
      )
    ''');

    // Create indexes for performance
    await db.execute(
        'CREATE INDEX idx_telemetry_device_time ON $tableTelemetry(device_id, timestamp)');
    await db.execute(
        'CREATE INDEX idx_logs_device_time ON $tableActivityLogs(device_id, timestamp)');
    await db.execute(
        'CREATE INDEX idx_notifications_read ON $tableNotifications(is_read)');

    Logger.d('DatabaseHelper', 'Database schema created successfully');
  }

  static Future<void> _onUpgrade(
      Database db, int oldVersion, int newVersion) async {
    Logger.d(
        'DatabaseHelper', 'Upgrading database from $oldVersion to $newVersion');
    // Handle migrations here when needed
  }

  // Public methods to access database
  static Future<Database> get database async => await _getDatabase();

  // Generic CRUD operations
  static Future<int> insert(String table, Map<String, dynamic> data) async {
    final db = await _getDatabase();
    return await db.insert(table, data);
  }

  static Future<List<Map<String, dynamic>>> query(
    String table, {
    String? where,
    List<dynamic>? whereArgs,
    String? orderBy,
    int? limit,
  }) async {
    final db = await _getDatabase();
    return await db.query(
      table,
      where: where,
      whereArgs: whereArgs,
      orderBy: orderBy,
      limit: limit,
    );
  }

  static Future<int> update(
    String table,
    Map<String, dynamic> data, {
    required String where,
    required List<dynamic> whereArgs,
  }) async {
    final db = await _getDatabase();
    return await db.update(table, data, where: where, whereArgs: whereArgs);
  }

  static Future<int> delete(
    String table, {
    required String where,
    required List<dynamic> whereArgs,
  }) async {
    final db = await _getDatabase();
    return await db.delete(table, where: where, whereArgs: whereArgs);
  }

  static Future<void> clearTable(String table) async {
    final db = await _getDatabase();
    await db.delete(table);
    Logger.d('DatabaseHelper', 'Cleared table: $table');
  }

  static Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}
