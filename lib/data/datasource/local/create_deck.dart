import '_sqlite_service.dart';

import '../../model/deck.dart';

class CreateDeckLocalDatasource {
  final SQLiteService _sqliteService;

  CreateDeckLocalDatasource(this._sqliteService);

  Future<void> createDeck({
    required DeckModel deck,
  }) async {
    await _sqliteService.insert(
      table: 'decks', 
      data: deck.toJsonForDeck(),
    );

    await _sqliteService.insertBatch(
      table: 'cardsInDeck',
      dataList: deck.toJsonForCardsInDeck(),
    );
  }
}
