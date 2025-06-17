import '../../model/deck.dart';

import '@sqlite_service.dart';

class CreateCardInDeckLocalDatasource {
  final SQLiteService _sqliteService;

  CreateCardInDeckLocalDatasource(this._sqliteService);

  Future<void> create({
    required DeckModel deck,
  }) async {
    await _sqliteService.insertBatch(
      table: 'cardsInDeck',
      dataList: deck.toJsonForCardsInDeck(),
    );
  }
}
