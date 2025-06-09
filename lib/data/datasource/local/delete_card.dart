import '@sqlite_service.dart';

import '../../model/card.dart';

class DeleteCardLocalDatasource {
  final SQLiteService _sqliteService;

  DeleteCardLocalDatasource(this._sqliteService);

  Future<void> deleteCard({
    required CardModel card,
  }) async {
    await _sqliteService.delete(
      table: 'cards', 
      where: 'collectionId = ? AND cardId = ?', 
      whereArgs: [card.collectionId, card.cardId],
    );
  }
}
