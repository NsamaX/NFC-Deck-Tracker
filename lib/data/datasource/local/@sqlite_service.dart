import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';

import 'package:nfc_deck_tracker/util/logger.dart';

import '@database_service.dart';

class SQLiteService {
  final DatabaseService _databaseService;

  SQLiteService(this._databaseService);

  Future<Database> getDatabase() async {
    try {
      return _databaseService.database;
    } catch (e) {
      debugPrint('❌ Failed to get database instance: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> queryTable({
    required String sql,
  }) async {
    try {
      final Database db = await getDatabase();
      final result = await db.rawQuery(sql);

      final sqlLines = sql
          .split('\n')
          .map((line) => line.trimLeft())
          .where((line) => line.isNotEmpty)
          .toList();

      final formattedSql = sqlLines.join('\n');
      final message = '🔎 Query\n'
          'SQL:\n'
          '$formattedSql\n'
          'Returned: ${result.length} rows';

      LoggerUtil.addMessage(message: message);
      LoggerUtil.flushMessages();

      return result;
    } catch (e) {
      debugPrint('❌ Failed to execute raw query: $e');
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
      final Database db = await getDatabase();

      await _ensureTableExists(
        db: db,
        table: table,
      );

      final result = await db.query(
        table,
        where: where,
        whereArgs: whereArgs,
        orderBy: orderBy,
      );

      LoggerUtil.addMessage(message: '🔎 Query\nTable: $table\nWHERE: $where\nARGS : $whereArgs\nReturned: ${result.length} rows');
      LoggerUtil.flushMessages();

      return result;
    } catch (e) {
      debugPrint('❌ Failed to query table "$table": $e');
      return [];
    }
  }

  Future<void> insert({
    required String table,
    required Map<String, dynamic> data,
  }) async {
    try {
      final Database db = await getDatabase();

      await _ensureTableExists(
        db: db,
        table: table,
      );

      await db.insert(
        table,
        data,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      debugPrint('📝 Inserted data into "$table" successfully');
    } catch (e) {
      debugPrint('❌ Failed to insert data into "$table": $e');
    }
  }

  Future<void> insertBatch({
    required String table,
    required List<Map<String, dynamic>> dataList,
  }) async {
    const int chunkSize = 500;

    try {
      final Database db = await getDatabase();

      await _ensureTableExists(
        db: db,
        table: table,
      );

      await db.transaction((txn) async {
        for (int i = 0; i < dataList.length; i += chunkSize) {
          final chunk = dataList.skip(i).take(chunkSize);
          final batch = txn.batch();

          for (final data in chunk) {
            batch.insert(
              table,
              data,
              conflictAlgorithm: ConflictAlgorithm.replace,
            );
          }

          await batch.commit(
            noResult: true,
            continueOnError: true,
          );
        }
      });

      debugPrint('📝 Inserted batch data into "$table" successfully');
    } catch (e) {
      debugPrint('❌ Failed to insert batch into "$table": $e');
    }
  }

  Future<void> update({
    required String table,
    required Map<String, dynamic> data,
    required String where,
    required List<dynamic> whereArgs,
  }) async {
    try {
      final Database db = await getDatabase();

      await _ensureTableExists(
        db: db,
        table: table,
      );

      await db.update(
        table,
        data,
        where: where,
        whereArgs: whereArgs,
      );

      debugPrint('🔔 Updated data in "$table" successfully');
    } catch (e) {
      debugPrint('❌ Failed to update data in "$table": $e');
    }
  }

  Future<bool> delete({
    required String table,
    String? where,
    List<dynamic>? whereArgs,
  }) async {
    try {
      final Database db = await getDatabase();

      await _ensureTableExists(
        db: db,
        table: table,
      );

      await db.delete(
        table,
        where: where,
        whereArgs: whereArgs,
      );

      debugPrint(
        where == null
            ? '🗑️ Deleted all data from "$table"'
            : '🗑️ Deleted data from "$table" with condition: $where');
      return true;
    } catch (e) {
      debugPrint('❌ Failed to delete data from "$table": $e');
      return false;
    }
  }

  Future<void> _ensureTableExists({
    required Database db,
    required String table,
  }) async {
    try {
      final int? count = Sqflite.firstIntValue(
        await db.rawQuery(
          "SELECT COUNT(*) FROM sqlite_master WHERE type='table' AND name=?",
          [table],
        ),
      );

      if (count == null || count == 0) {
        throw Exception('Table "$table" does not exist.');
      }
    } catch (e) {
      debugPrint('❌ Table check failed for "$table": $e');
      rethrow;
    }
  }
}
