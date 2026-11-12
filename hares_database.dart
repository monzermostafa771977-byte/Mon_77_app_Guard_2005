import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

/// Local-first database. Schema changes must increment [schemaVersion]
/// and be implemented in onUpgrade without dropping user tables.
class HaresDatabase {
  HaresDatabase._();
  static final HaresDatabase instance = HaresDatabase._();
  static const int schemaVersion = 1;
  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    final root = await getDatabasesPath();
    final path = p.join(root, 'hares_local.db');
    _db = await openDatabase(
      path,
      version: schemaVersion,
      onConfigure: (db) async => db.execute('PRAGMA foreign_keys = ON'),
      onCreate: _createSchema,
      onUpgrade: _upgrade,
    );
    return _db!;
  }

  Future<void> _createSchema(Database db, int version) async {
    await db.execute('''CREATE TABLE app_settings (
      id INTEGER PRIMARY KEY CHECK (id = 1),
      strict_mode INTEGER NOT NULL DEFAULT 1,
      daily_grace_limit INTEGER NOT NULL DEFAULT 2,
      grace_minutes INTEGER NOT NULL DEFAULT 5,
      created_at TEXT NOT NULL,
      updated_at TEXT NOT NULL
    )''');
    await db.insert('app_settings', {
      'id': 1,
      'strict_mode': 1,
      'daily_grace_limit': 2,
      'grace_minutes': 5,
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    });
    await db.execute('''CREATE TABLE tracked_apps (
      package_name TEXT PRIMARY KEY,
      display_name TEXT NOT NULL,
      daily_limit_minutes INTEGER NOT NULL DEFAULT 60,
      is_enabled INTEGER NOT NULL DEFAULT 1,
      created_at TEXT NOT NULL,
      updated_at TEXT NOT NULL
    )''');
    await db.execute('''CREATE TABLE usage_daily (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      package_name TEXT NOT NULL,
      usage_date TEXT NOT NULL,
      duration_seconds INTEGER NOT NULL DEFAULT 0,
      source TEXT NOT NULL DEFAULT 'manual_or_imported',
      UNIQUE(package_name, usage_date)
    )''');
    await db.execute('''CREATE TABLE limit_events (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      package_name TEXT NOT NULL,
      event_at TEXT NOT NULL,
      limit_minutes INTEGER NOT NULL,
      observed_minutes INTEGER NOT NULL,
      action TEXT NOT NULL
    )''');
    await db.execute('''CREATE TABLE grace_requests (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      package_name TEXT NOT NULL,
      requested_at TEXT NOT NULL,
      reason TEXT NOT NULL,
      requested_minutes INTEGER NOT NULL,
      status TEXT NOT NULL DEFAULT 'pending',
      decision_at TEXT
    )''');
    await db.execute('''CREATE TABLE grace_grants (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      request_id INTEGER NOT NULL,
      package_name TEXT NOT NULL,
      started_at TEXT NOT NULL,
      expires_at TEXT NOT NULL,
      granted_minutes INTEGER NOT NULL,
      FOREIGN KEY(request_id) REFERENCES grace_requests(id)
    )''');
    await db.execute('''CREATE TABLE focus_sessions (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      started_at TEXT NOT NULL,
      ended_at TEXT,
      planned_minutes INTEGER NOT NULL,
      status TEXT NOT NULL DEFAULT 'running'
    )''');
    await db.execute('''CREATE TABLE habits (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      title TEXT NOT NULL,
      is_active INTEGER NOT NULL DEFAULT 1,
      created_at TEXT NOT NULL
    )''');
    await db.execute('''CREATE TABLE habit_logs (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      habit_id INTEGER NOT NULL,
      log_date TEXT NOT NULL,
      completed INTEGER NOT NULL DEFAULT 0,
      FOREIGN KEY(habit_id) REFERENCES habits(id),
      UNIQUE(habit_id, log_date)
    )''');
    await db.execute('CREATE INDEX idx_usage_date ON usage_daily(usage_date)');
    await db.execute('CREATE INDEX idx_limit_events_time ON limit_events(event_at)');
  }

  Future<void> _upgrade(Database db, int oldVersion, int newVersion) async {
    // Future migrations must be additive and transactional by SQLite.
    // Never drop or recreate existing user data during an upgrade.
  }

  Future<Map<String, Object?>> getSettings() async {
    final db = await database;
    final rows = await db.query('app_settings', where: 'id = 1', limit: 1);
    return rows.isEmpty ? <String, Object?>{} : rows.first;
  }

  Future<void> updateStrictMode(bool enabled) async {
    final db = await database;
    await db.update(
      'app_settings',
      {'strict_mode': enabled ? 1 : 0, 'updated_at': DateTime.now().toIso8601String()},
      where: 'id = 1',
    );
  }

  Future<void> addHabit(String title) async {
    final db = await database;
    await db.insert('habits', {
      'title': title.trim(),
      'created_at': DateTime.now().toIso8601String(),
    });
  }
}
