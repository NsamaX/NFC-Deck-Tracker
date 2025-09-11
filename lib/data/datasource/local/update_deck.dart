import '../../model/card_in_deck.dart';
import '../../model/deck.dart';

import '@sqlite_service.dart';

class UpdateDeckLocalDatasource {
  final SQLiteService _sqliteService;

  UpdateDeckLocalDatasource(this._sqliteService);

  Future<void> update({
    required DeckModel deck,
  }) async {
    final List<CardInDeckModel> cards = deck.cards;

    if (cards.isEmpty) {
      await _sqliteService.delete(
        table: 'cardsInDeck',
        where: 'deckId = ?',
        whereArgs: [deck.deckId],
      );
      return;
    }

    final String placeholders = List.generate(
      cards.length,
      (_) => '(cardId = ? AND collectionId = ?)',
    ).join(' OR ');

    final List<dynamic> ids = cards.expand(
      (c) => [c.card.cardId, c.card.collectionId],
    ).toList();

    await _sqliteService.delete(
      table: 'cardsInDeck',
      where: 'deckId = ? AND NOT ($placeholders)',
      whereArgs: [deck.deckId, ...ids],
    );

    for (final cardInDeck in cards) {
      final String cardId = cardInDeck.card.cardId;
      final String collectionId = cardInDeck.card.collectionId;

      final List<Map<String, dynamic>> existing = await _sqliteService.getTable(
        table: 'cardsInDeck',
        where: 'deckId = ? AND cardId = ? AND collectionId = ?',
        whereArgs: [deck.deckId, cardId, collectionId],
      );

      final Map<String, dynamic> cardData = {
        'deckId': deck.deckId,
        'collectionId': collectionId,
        'cardId': cardId,
        'count': cardInDeck.count,
      };

      if (existing.isEmpty) {
        await _sqliteService.insert(
          table: 'cardsInDeck',
          data: cardData,
        );
      } else {
        await _sqliteService.update(
          table: 'cardsInDeck',
          data: cardData,
          where: 'deckId = ? AND cardId = ? AND collectionId = ?',
          whereArgs: [deck.deckId, cardId, collectionId],
        );
      }
    }
  }
}
