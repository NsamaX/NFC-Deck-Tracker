import '../../model/record.dart';

import '@sqlite_service.dart';

class FetchRecordLocalDatasource {
  final SQLiteService _sqliteService;

  FetchRecordLocalDatasource(this._sqliteService);

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
}
