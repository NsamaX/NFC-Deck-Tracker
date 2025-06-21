import '@sqlite_service.dart';

class UpdateCollectionDateLocalDatasource {
  final SQLiteService _sqliteService;

  UpdateCollectionDateLocalDatasource(this._sqliteService);

  Future<void> update({
    required String collectionId,
  }) async {
    await _sqliteService.update(
      table: 'collections',
      data: {'updatedAt': DateTime.now().toIso8601String()},
      where: 'collectionId = ?',
      whereArgs: [collectionId],
    );
  }
}
