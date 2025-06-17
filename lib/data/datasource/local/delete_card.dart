import '@sqlite_service.dart';

class DeleteCardLocalDatasource {
  final SQLiteService _sqliteService;

  DeleteCardLocalDatasource(this._sqliteService);

  Future<void> delete({
    required String collectionId,
    required String cardId,
  }) async {
    await _sqliteService.delete(
      table: 'cards',
      where: 'collectionId = ? AND cardId = ?',
      whereArgs: [collectionId, cardId],
    );
  }
}
