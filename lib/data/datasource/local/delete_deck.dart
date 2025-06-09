import '@sqlite_service.dart';

class DeleteDeckLocalDatasource {
  final SQLiteService _sqliteService;

  DeleteDeckLocalDatasource(this._sqliteService);

  Future<bool> deleteDeck({
    required String deckId,
  }) async {
    return await _sqliteService.delete(
      table: 'decks',
      where: 'deckId = ?',
      whereArgs: [deckId],
    );
  }
}
