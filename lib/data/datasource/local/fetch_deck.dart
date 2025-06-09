import '../../model/card.dart';
import '../../model/deck.dart';

import '@sqlite_service.dart';

class FetchDeckLocalDatasource {
  final SQLiteService _sqliteService;

  FetchDeckLocalDatasource(this._sqliteService);

  Future<List<DeckModel>> fetchDeck() async {
    final result = await _sqliteService.getTable(
      table: 'decks',
    );

    final List<DeckModel> decks = [];

    for (final row in result) {
      final DeckModel deck = DeckModel.fromJson(row);
      final List<CardInDeckModel> cardsInDeck = await _fetchCardsInDeck(
        deckId: deck.deckId,
      );

      decks.add(
        DeckModel(
          deckId: deck.deckId,
          name: deck.name,
          cards: cardsInDeck,
          isSynced: deck.isSynced,
          updatedAt: deck.updatedAt,
        ),
      );
    }

    return decks;
  }

  Future<List<CardInDeckModel>> _fetchCardsInDeck({
    required String deckId,
  }) async {
    final List<Map<String, dynamic>> cardLinks = await _sqliteService.getTable(
      table: 'cardsInDeck',
      where: 'deckId = ?',
      whereArgs: [deckId],
    );

    final List<CardInDeckModel> cards = [];

    for (final row in cardLinks) {
      final String collectionId = row['collectionId'];
      final String cardId = row['cardId'];
      final int count = row['count'];

      final List<Map<String, dynamic>> result = await _sqliteService.getTable(
        table: 'cards',
        where: 'collectionId = ? AND cardId = ?',
        whereArgs: [collectionId, cardId],
      );

      if (result.isNotEmpty) {
        final CardModel card = CardModel.fromJson(result.first);

        cards.add(
          CardInDeckModel(
            card: card,
            count: count,
          ),
        );
      }
    }

    return cards;
  }
}
