import '@sqlite_service.dart';

class CheckDuplicateNameLocalDatasource {
  final SQLiteService _sqliteService;

  CheckDuplicateNameLocalDatasource(this._sqliteService);

  Future<int> check({
    required String collectionId,
    required String name,
  }) async {
    final result = await _sqliteService.getTable(
      table: 'cards',
      where: 'collectionId = ? AND name = ?',
      whereArgs: [collectionId, name],
    );

    return result.length;
  }
}
