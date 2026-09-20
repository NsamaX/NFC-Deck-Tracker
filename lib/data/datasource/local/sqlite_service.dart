import 'package:sqflite/sqflite.dart';

import 'package:nfc_deck_tracker/util/logger.dart';

import 'database_service.dart';

class SQLiteService {
  final DatabaseService _databaseService;
  final DatabaseExecutor? _transaction;

  SQLiteService({
    required DatabaseService databaseService,
  })  : _databaseService = databaseService,
        _transaction = null;

  SQLiteService._inTransaction(this._databaseService, this._transaction);

  bool get inTransaction => _transaction != null;

  Future<DatabaseExecutor> getDatabase() async {
    if (_transaction != null) return _transaction;
    try {
      return _databaseService.database;
    } catch (e) {
      LoggerUtil.e('Failed to get database instance: $e');
      rethrow;
    }
  }

  Future<T> transaction<T>(
    Future<T> Function(SQLiteService txn) action,
  ) async {
    if (_transaction != null) return action(this);
    final Database db = await _databaseService.database;
    return db.transaction(
      (txn) => action(SQLiteService._inTransaction(_databaseService, txn)),
    );
  }

  Future<List<Map<String, dynamic>>> queryTable({
    required String sql,
  }) async {
    try {
      final DatabaseExecutor db = await getDatabase();
      final result = await db.rawQuery(sql);

      final sqlLines = sql
          .split('\n')
          .map((line) => line.trimLeft())
          .where((line) => line.isNotEmpty)
          .toList();

      final formattedSql = sqlLines.join('\n');
      final message = 'Query\n'
          'SQL:\n'
          '$formattedSql\n'
          'Returned: ${result.length} rows';

      LoggerUtil.i(message);

      return result;
    } catch (e) {
      LoggerUtil.e('Failed to execute raw query: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getTable({
    required String table,
    String? where,
    List<dynamic>? whereArgs,
    String? orderBy,
  }) async {
    try {
      final DatabaseExecutor db = await getDatabase();

      final result = await db.query(
        table,
        where: where,
        whereArgs: whereArgs,
        orderBy: orderBy,
      );

      LoggerUtil.i(
          'Query\nTable: $table\nWHERE: $where\nARGS : $whereArgs\nReturned: ${result.length} rows');

      return result;
    } catch (e) {
      LoggerUtil.e('Failed to query table "$table": $e');
      return [];
    }
  }

  Future<void> insert({
    required String table,
    required Map<String, dynamic> data,
    ConflictAlgorithm conflictAlgorithm = ConflictAlgorithm.replace,
  }) async {
    try {
      final DatabaseExecutor db = await getDatabase();

      await db.insert(
        table,
        data,
        conflictAlgorithm: conflictAlgorithm,
      );

      LoggerUtil.i('Inserted data into "$table" successfully');
    } catch (e) {
      LoggerUtil.e('Failed to insert data into "$table": $e');
      if (inTransaction) rethrow;
    }
  }

  Future<void> insertBatch({
    required String table,
    required List<Map<String, dynamic>> dataList,
    ConflictAlgorithm conflictAlgorithm = ConflictAlgorithm.abort,
  }) async {
    const int chunkSize = 500;

    try {
      await transaction((txn) async {
        final DatabaseExecutor executor = await txn.getDatabase();
        for (int i = 0; i < dataList.length; i += chunkSize) {
          final chunk = dataList.skip(i).take(chunkSize);
          final batch = executor.batch();

          for (final data in chunk) {
            batch.insert(
              table,
              data,
              conflictAlgorithm: conflictAlgorithm,
            );
          }

          await batch.commit(
            noResult: true,
            continueOnError: false,
          );
        }
      });

      LoggerUtil.i('Inserted batch data into "$table" successfully');
    } catch (e) {
      LoggerUtil.e('Failed to insert batch into "$table": $e');
      if (inTransaction) rethrow;
    }
  }

  Future<void> update({
    required String table,
    required Map<String, dynamic> data,
    required String where,
    required List<dynamic> whereArgs,
  }) async {
    try {
      final DatabaseExecutor db = await getDatabase();

      await db.update(
        table,
        data,
        where: where,
        whereArgs: whereArgs,
      );

      LoggerUtil.i('Updated data in "$table" successfully');
    } catch (e) {
      LoggerUtil.e('Failed to update data in "$table": $e');
      if (inTransaction) rethrow;
    }
  }

  Future<bool> delete({
    required String table,
    String? where,
    List<dynamic>? whereArgs,
  }) async {
    try {
      final DatabaseExecutor db = await getDatabase();

      await db.delete(
        table,
        where: where,
        whereArgs: whereArgs,
      );

      LoggerUtil.i(where == null
          ? 'Deleted all data from "$table"'
          : 'Deleted data from "$table" with condition: $where');
      return true;
    } catch (e) {
      LoggerUtil.e('Failed to delete data from "$table": $e');
      if (inTransaction) rethrow;
      return false;
    }
  }
}
