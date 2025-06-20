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
    await _sqliteService.insert(
      table: 'decks', 
      data: deck.toJsonForLocal(),
    );

    final collectionId = deck.cards.first.card.collectionId;
    final collection = CollectionModel(
      collectionId: collectionId,
      name: GameConfig.isSupported(deck.cards.first.card.collectionId) ? collectionId : 'unknow',
      isSynced: true,
      updatedAt: DateTime.now(),
    );
    await _sqliteService.insert(
      table: 'collections',
      data: collection.toJsonForLocal(),
    );

    final List<CardInDeckModel> cards = deck.cards;
    for (final card in cards) {
      await _sqliteService.insert(
        table: 'cards',
        data: card.card.toJsonForLocal(),
      );
    }

    await _sqliteService.insertBatch(
      table: 'cardsInDeck',
      dataList: deck.toJsonForCardsInDeck(),
    );
  }
}
