import '_sqlite_service.dart';

class DeleteRecordLocalDatasource {
  final SQLiteService _sqliteService;

  DeleteRecordLocalDatasource(this._sqliteService);

  Future<bool> deleteRecord({
    required String recordId,
  }) async {
    return await _sqliteService.delete(
      table: 'records',
      where: 'recordId = ?',
      whereArgs: [recordId],
    );
  }
}
