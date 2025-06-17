import '../../model/card.dart';

import '@sqlite_service.dart';

class UpdateCardLocalDatasource {
  final SQLiteService _sqliteService;

  UpdateCardLocalDatasource(this._sqliteService);

  Future<void> update({
    required CardModel card,
  }) async {
    await _sqliteService.update(
      table: 'cards',
      data: card.toJsonForLocal(),
      where: 'collectionId = ? AND cardId = ?',
      whereArgs: [card.collectionId, card.cardId],
    );
  }
}
