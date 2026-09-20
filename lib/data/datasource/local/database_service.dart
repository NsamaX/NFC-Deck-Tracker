import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'package:nfc_deck_tracker/util/logger.dart';

import 'database_constant.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();

  factory DatabaseService() => _instance;

  DatabaseService._internal();

  Future<Database>? _database;

  static const String _db = DatabaseConstant.dbName;
  static const int _dbVersion = DatabaseConstant.dbVersion;

  Future<Database> get database async {
    _database ??= _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    try {
      final String dbPath = await getDatabasesPath();
      final String path = join(dbPath, _db);

      final Database db = await openDatabase(
        path,
        version: _dbVersion,
        onCreate: _createTables,
        onUpgrade: _migrate,
        onDowngrade: onDatabaseDowngradeDelete,
      );

      await _configureDatabase(db);

      LoggerUtil.buffer('Database initialized successfully');
      LoggerUtil.flush();
      return db;
    } catch (e) {
      LoggerUtil.e('Failed to initialize the database: $e');
      rethrow;
    }
  }

  Future<void> _createTables(
    Database db,
    int version,
  ) async {
    try {
      final List<String> _tables = DatabaseConstant.tables;
      final Batch batch = db.batch();

      for (final String query in _tables) {
        batch.execute(query);
      }

      await batch.commit();

      LoggerUtil.buffer('Tables created successfully');
    } catch (e) {
      LoggerUtil.e('Failed to create tables: $e');
      rethrow;
    }
  }

  Future<void> _migrate(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    try {
      if (oldVersion < _dbVersion) {
        LoggerUtil.buffer(
            'Migrating database from v$oldVersion to v$newVersion...');

        final List<String> _migrations = DatabaseConstant.migrations;
        final Batch batch = db.batch();

        for (final query in _migrations) {
          batch.execute(query);
        }

        await batch.commit();

        LoggerUtil.buffer('Database migrated successfully');
      }
    } catch (e) {
      LoggerUtil.e('Database migration failed: $e');
      rethrow;
    }
  }

  Future<void> _configureDatabase(
    Database db,
  ) async {
    try {
      await db.rawQuery('PRAGMA foreign_keys = ON');
      await db.rawQuery('PRAGMA journal_mode = WAL');

      LoggerUtil.buffer('Database configured successfully');
    } catch (e) {
      LoggerUtil.e('Failed to configure database: $e');
      rethrow;
    }
  }
}
