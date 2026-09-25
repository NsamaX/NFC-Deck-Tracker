import 'package:sqflite/sqflite.dart';

import 'sqlite_service.dart';

class PendingDeleteLocalDatasource {
  final SQLiteService _sqliteService;

  PendingDeleteLocalDatasource(this._sqliteService);

  Future<void> add({
    required String userId,
    required String kind,
    required String id,
  }) async {
    await _sqliteService.insert(
      table: 'pendingDeletes',
      data: {'userId': userId, 'kind': kind, 'id': id},
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  Future<Set<String>> ids({
    required String userId,
    required String kind,
  }) async {
    final rows = await _sqliteService.getTable(
      table: 'pendingDeletes',
      where: 'userId = ? AND kind = ?',
      whereArgs: [userId, kind],
    );
    return {for (final row in rows) row['id'] as String};
  }

  Future<void> remove({
    required String userId,
    required String kind,
    required String id,
  }) async {
    await _sqliteService.delete(
      table: 'pendingDeletes',
      where: 'userId = ? AND kind = ? AND id = ?',
      whereArgs: [userId, kind, id],
    );
  }
}
