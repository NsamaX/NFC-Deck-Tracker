import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '&database_constant.dart';

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

      debugPrint('📂 Database initialized successfully');
      return db;
    } catch (e) {
      debugPrint('❌ Failed to initialize the database: $e');
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

      debugPrint('🛠️ Tables created successfully');
    } catch (e) {
      debugPrint('❌ Failed to create tables: $e');
    }
  }

  Future<void> _migrate(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    try {
      if (oldVersion < _dbVersion) {
        debugPrint('🔄 Migrating database from v$oldVersion to v$newVersion...');

        final List<String> _migrations = DatabaseConstant.migrations;
        final Batch batch = db.batch();

        for (final query in _migrations) {
          batch.execute(query);
        }

        await batch.commit();

        debugPrint('🔔 Database migrated successfully');
      }
    } catch (e) {
      debugPrint('❌ Database migration failed: $e');
    }
  }

  Future<void> _configureDatabase(
    Database db,
  ) async {
    try {
      await db.rawQuery('PRAGMA foreign_keys = ON');
      await db.rawQuery('PRAGMA journal_mode = WAL');

      debugPrint('🔧 Database configured successfully');
    } catch (e) {
      debugPrint('❌ Failed to configure database: $e');
    }
  }

  Future<void> closeDatabase() async {
    try {
      final Database? db = await _database;

      await db?.close();
      _database = null;

      debugPrint('🔒 Database closed successfully.');
    } catch (e) {
      debugPrint('❌ Failed to close database: $e');
    }
  }

  Future<void> deleteDatabaseFile() async {
    try {
      final String dbPath = await getDatabasesPath();
      final String path = join(dbPath, _db);

      await closeDatabase();
      await deleteDatabase(path);

      debugPrint('🗑️ Database "$_db" deleted successfully.');
    } catch (e) {
      debugPrint('❌ Failed to delete database "$_db": $e');
    }
  }
}
