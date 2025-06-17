import '../../model/deck.dart';

import '@sqlite_service.dart';

class FetchDeckLocalDatasource {
  final SQLiteService _sqliteService;

  FetchDeckLocalDatasource(this._sqliteService);

  Future<List<DeckModel>> fetch() async {
    final result = await _sqliteService.getTable(
      table: 'decks',
    );

    return result.map((row) {
      final DeckModel deck = DeckModel.fromJson(row);
      return DeckModel(
        deckId: deck.deckId,
        name: deck.name,
        cards: [],
        isSynced: deck.isSynced,
        updatedAt: deck.updatedAt,
      );
    }).toList();
  }
}
