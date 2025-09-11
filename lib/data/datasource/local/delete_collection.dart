import '@sqlite_service.dart';

class DeleteCollectionLocalDatasource {
  final SQLiteService _sqliteService;

  DeleteCollectionLocalDatasource(this._sqliteService);

  Future<bool> delete({
    required String collectionId,
  }) async {
    return await _sqliteService.delete(
      table: 'collections',
      where: 'collectionId = ?', 
      whereArgs: [collectionId],
    );
  }
}
