import '../../model/deck.dart';

import '@sqlite_service.dart';

class CreateDeckLocalDatasource {
  final SQLiteService _sqliteService;

  CreateDeckLocalDatasource(this._sqliteService);

  Future<void> create({
    required DeckModel deck,
  }) async {
    await _sqliteService.insert(
      table: 'decks', 
      data: deck.toJsonForLocal(),
    );

    await _sqliteService.insertBatch(
      table: 'cardsInDeck',
      dataList: deck.toJsonForCardsInDeck(),
    );
  }
}
