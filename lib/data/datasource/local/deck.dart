import 'package:nfc_deck_tracker/.config/game.dart';
import 'package:sqflite/sqflite.dart';

import '../../model/card.dart';
import '../../model/card_in_deck.dart';
import '../../model/collection.dart';
import '../../model/deck.dart';

import 'sqlite_service.dart';

class DeckLocalDatasource {
  final SQLiteService _sqliteService;

  DeckLocalDatasource(this._sqliteService);

  Future<void> create({
    required DeckModel deck,
  }) async {
    await _sqliteService.transaction((txn) async {
      await txn.insert(
        table: 'decks',
        data: deck.toJsonForLocal(),
      );

      final List<CardInDeckModel> cards = deck.cards;
      if (cards.isEmpty) return;

      final collectionId = cards.first.card.collectionId;
      final collection = CollectionModel(
        collectionId: collectionId,
        name: GameConfig.instance.isSupported(collectionId)
            ? collectionId
            : 'unknow',
        isSynced: true,
        updatedAt: DateTime.now(),
      );
      await txn.insert(
        table: 'collections',
        data: collection.toJsonForLocal(),
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );

      for (final card in cards) {
        await txn.insert(
          table: 'cards',
          data: card.card.toJsonForLocal(),
          conflictAlgorithm: ConflictAlgorithm.ignore,
        );
      }

      await txn.insertBatch(
        table: 'cardsInDeck',
        dataList: deck.toJsonForCardsInDeck(),
      );
    });
  }

  Future<bool> delete({
    required String deckId,
  }) async {
    return await _sqliteService.delete(
      table: 'decks',
      where: 'deckId = ?',
      whereArgs: [deckId],
    );
  }

  Future<List<DeckModel>> fetch() async {
    final result = await _sqliteService.getTable(
      table: 'decks',
    );
    return result.map((row) {
      final DeckModel deck = DeckModel.fromJsonForLocal(row);
      return DeckModel(
        deckId: deck.deckId,
        name: deck.name,
        cards: [],
        isSynced: deck.isSynced,
        updatedAt: deck.updatedAt,
      );
    }).toList();
  }

  Future<List<CardInDeckModel>> fetchCardsInDeck({
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

  Future<void> update({
    required DeckModel deck,
  }) async {
    await _sqliteService.transaction((txn) async {
      final List<CardInDeckModel> cards = deck.cards;

      if (cards.isEmpty) {
        await txn.delete(
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

      final List<dynamic> ids = cards
          .expand(
            (c) => [c.card.cardId, c.card.collectionId],
          )
          .toList();

      await txn.delete(
        table: 'cardsInDeck',
        where: 'deckId = ? AND NOT ($placeholders)',
        whereArgs: [deck.deckId, ...ids],
      );

      for (final cardInDeck in cards) {
        final String cardId = cardInDeck.card.cardId;
        final String collectionId = cardInDeck.card.collectionId;

        final List<Map<String, dynamic>> existing = await txn.getTable(
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
          await txn.insert(
            table: 'cardsInDeck',
            data: cardData,
          );
        } else {
          await txn.update(
            table: 'cardsInDeck',
            data: cardData,
            where: 'deckId = ? AND cardId = ? AND collectionId = ?',
            whereArgs: [deck.deckId, cardId, collectionId],
          );
        }
      }
    });
  }
}
