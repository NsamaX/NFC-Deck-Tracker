import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'package:nfc_deck_tracker/util/logger.dart';

import 'database_constant.dart';

class DatabaseService {
  final DatabaseFactory? _factory;
  final String? _path;
  final int _version;
  final List<String> _tables;
  final Map<int, List<String>> _migrations;

  DatabaseService({
    DatabaseFactory? factory,
    String? path,
    int version = DatabaseConstant.dbVersion,
    List<String> tables = DatabaseConstant.tables,
    Map<int, List<String>> migrations = DatabaseConstant.migrations,
  })  : _factory = factory,
        _path = path,
        _version = version,
        _tables = tables,
        _migrations = migrations {
    final invalid = migrations.keys.where((v) => v < 2 || v > version);
    if (invalid.isNotEmpty) {
      throw StateError('Migrations $invalid are outside 2..$version');
    }
  }

  Future<Database>? _database;

  static const String _db = DatabaseConstant.dbName;

  Future<Database> get database => _database ??= _initDatabase();

  Future<Database> _initDatabase() async {
    try {
      final factory = _factory ?? databaseFactory;
      final String path = _path ?? join(await factory.getDatabasesPath(), _db);

      final Database db = await factory.openDatabase(
        path,
        options: OpenDatabaseOptions(
          version: _version,
          onConfigure: (db) => db.execute('PRAGMA foreign_keys = ON'),
          onCreate: _createTables,
          onUpgrade: _migrate,
          onDowngrade: onDatabaseDowngradeDelete,
        ),
      );

      await _configureDatabase(db);

      LoggerUtil.buffer('Database initialized successfully');
      LoggerUtil.flush();
      return db;
    } catch (e) {
      _database = null;
      LoggerUtil.e('Failed to initialize the database: $e');
      rethrow;
    }
  }

  Future<void> _createTables(
    Database db,
    int version,
  ) async {
    try {
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
    for (var version = oldVersion + 1; version <= newVersion; version++) {
      final statements = _migrations[version] ?? const [];
      try {
        for (final statement in statements) {
          await db.execute(statement);
        }
        LoggerUtil.buffer('Database migrated to v$version');
      } catch (e) {
        LoggerUtil.e('Database migration to v$version failed: $e');
        rethrow;
      }
    }
  }

  Future<void> _configureDatabase(
    Database db,
  ) async {
    try {
      await db.rawQuery('PRAGMA journal_mode = WAL');

      LoggerUtil.buffer('Database configured successfully');
    } catch (e) {
      LoggerUtil.e('Failed to configure database: $e');
      rethrow;
    }
  }
}
