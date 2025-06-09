import '@sqlite_service.dart';

import '../../model/record.dart';

class UpdateRecordLocalDatasource {
  final SQLiteService _sqliteService;

  UpdateRecordLocalDatasource(this._sqliteService);

  Future<void> updateRecord({
    required RecordModel record,
  }) async {
    await _sqliteService.update(
      table: 'records',
      data: record.toJson(),
      where: 'recordId = ?',
      whereArgs: [record.recordId],
    );
  }
}
