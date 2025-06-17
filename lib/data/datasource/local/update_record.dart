import '../../model/record.dart';

import '@sqlite_service.dart';

class UpdateRecordLocalDatasource {
  final SQLiteService _sqliteService;

  UpdateRecordLocalDatasource(this._sqliteService);

  Future<void> update({
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
