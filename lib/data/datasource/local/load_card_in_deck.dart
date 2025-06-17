import '../../model/deck.dart';

import '@sqlite_service.dart';

class LoadCardInDeckLocalDatasource {
  final SQLiteService _sqliteService;

  LoadCardInDeckLocalDatasource(this._sqliteService);

  Future<void> create({
    required DeckModel deck,
  }) async {
    await _sqliteService.insertBatch(
      table: 'cardsInDeck',
      dataList: deck.toJsonForCardsInDeck(),
    );
  }
}
