import '../../model/card.dart';
import '../../model/deck.dart';

import '@sqlite_service.dart';

class FetchCardInDeckLocalDatasource {
  final SQLiteService _sqliteService;

  FetchCardInDeckLocalDatasource(this._sqliteService);

  Future<List<CardInDeckModel>> fetchCardInDeck({
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

      final result = await _sqliteService.getTable(
        table: 'cards',
        where: 'collectionId = ? AND cardId = ?',
        whereArgs: [collectionId, cardId],
      );

      if (result.isNotEmpty) {
        final CardModel card = CardModel.fromJson(result.first);

        cards.add(CardInDeckModel(
          card: card,
          count: count,
        ));
      }
    }

    return cards;
  }
}
