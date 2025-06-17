import '../../model/record.dart';

import '@sqlite_service.dart';

class CreateRecordLocalDatasource {
  final SQLiteService _sqliteService;

  CreateRecordLocalDatasource(this._sqliteService);

  Future<void> create({
    required RecordModel record,
  }) async {
    await _sqliteService.insert(
      table: 'records',
      data: record.toJson(),
    );
  }
}
