import '_sqlite_service.dart';

class DeleteCollectionLocalDatasource {
  final SQLiteService _sqliteService;

  DeleteCollectionLocalDatasource(this._sqliteService);

  Future<bool> deleteCollection({
    required String collectionId,
  }) async {
    return await _sqliteService.delete(
      table: 'collections',
      where: 'collectionId = ?', 
      whereArgs: [collectionId],
    );
  }
}
