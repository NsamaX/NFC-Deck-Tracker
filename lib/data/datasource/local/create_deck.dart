import 'package:sqflite/sqflite.dart';

import 'package:nfc_deck_tracker/.config/game.dart';

import '../../model/card_in_deck.dart';
import '../../model/collection.dart';
import '../../model/deck.dart';

import '@sqlite_service.dart';

class CreateDeckLocalDatasource {
  final SQLiteService _sqliteService;

  CreateDeckLocalDatasource(this._sqliteService);

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
}
