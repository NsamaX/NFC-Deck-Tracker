import '../../model/record.dart';

import '@sqlite_service.dart';

class RecordLocalDatasource {
  final SQLiteService _sqliteService;

  RecordLocalDatasource(this._sqliteService);

  Future<void> create({
    required RecordModel record,
  }) async {
    await _sqliteService.insert(
      table: 'records',
      data: record.toJsonForLocal(),
    );
  }

  Future<bool> delete({
    required String recordId,
  }) async {
    return await _sqliteService.delete(
      table: 'records',
      where: 'recordId = ?',
      whereArgs: [recordId],
    );
  }

  Future<List<RecordModel>> fetch({
    required String deckId,
  }) async {
    final result = await _sqliteService.getTable(
      table: 'records',
      where: 'deckId = ?',
      whereArgs: [deckId],
      orderBy: 'createdAt DESC',
    );
    return result.map((row) => RecordModel.fromJson(row)).toList();
  }

  Future<void> update({
    required RecordModel record,
  }) async {
    await _sqliteService.update(
      table: 'records',
      data: record.toJsonForLocal(),
      where: 'recordId = ?',
      whereArgs: [record.recordId],
    );
  }
}
