import 'package:nfc_deck_tracker/.config/game.dart';
import 'package:sqflite/sqflite.dart';

import '../../../domain/entity/collection.dart';
import '../../model/card.dart';
import '../../model/card_in_deck.dart';
import '../../model/collection.dart';
import '../../model/deck.dart';

import 'sqlite_service.dart';

class DeckLocalDatasource {
  static const String _cardsInDeckSql = '''
    SELECT cd.deckId, cd.count, c.*
    FROM cardsInDeck cd
    JOIN cards c ON c.collectionId = cd.collectionId AND c.cardId = cd.cardId
  ''';

  final SQLiteService _sqliteService;
  final bool Function(String collectionId) _isBuiltIn;

  DeckLocalDatasource(
    this._sqliteService, {
    bool Function(String collectionId)? isBuiltIn,
  }) : _isBuiltIn = isBuiltIn ?? GameConfig.instance.isSupported;

  Future<void> create({
    required DeckModel deck,
  }) async {
    await _sqliteService.transaction((txn) async {
      await txn.insert(table: 'decks', data: deck.toJsonForLocal());
      await _writeCards(txn, deck);
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
    final decks = await _sqliteService.getTable(table: 'decks');
    final rows = await _sqliteService.queryTable(sql: _cardsInDeckSql);

    final cardsByDeck = <String, List<CardInDeckModel>>{};
    for (final row in rows) {
      cardsByDeck.putIfAbsent(row['deckId'] as String, () => []).add(
          CardInDeckModel(card: CardModel.fromJson(row), count: row['count']));
    }

    return decks.map((row) {
      final deck = DeckModel.fromJsonForLocal(row);
      return DeckModel(
        deckId: deck.deckId,
        name: deck.name,
        cards: cardsByDeck[deck.deckId] ?? [],
        isSynced: deck.isSynced,
        updatedAt: deck.updatedAt,
      );
    }).toList();
  }

  Future<List<CardInDeckModel>> fetchCardsInDeck({
    required String deckId,
  }) async {
    final rows = await _sqliteService.queryTable(
      sql: '$_cardsInDeckSql WHERE cd.deckId = ?',
      arguments: [deckId],
    );
    return rows
        .map((row) =>
            CardInDeckModel(card: CardModel.fromJson(row), count: row['count']))
        .toList();
  }

  Future<void> update({
    required DeckModel deck,
  }) async {
    await _sqliteService.transaction((txn) async {
      await txn.update(
        table: 'decks',
        data: deck.toJsonForLocal(),
        where: 'deckId = ?',
        whereArgs: [deck.deckId],
      );
      await txn.delete(
        table: 'cardsInDeck',
        where: 'deckId = ?',
        whereArgs: [deck.deckId],
      );
      await _writeCards(txn, deck);
    });
  }

  Future<void> _writeCards(SQLiteService txn, DeckModel deck) async {
    if (deck.cards.isEmpty) return;

    final collectionIds = {for (final c in deck.cards) c.card.collectionId};
    for (final collectionId in collectionIds) {
      final isBuiltIn = _isBuiltIn(collectionId);
      await txn.insert(
        table: 'collections',
        data: CollectionModel(
          collectionId: collectionId,
          name: isBuiltIn ? collectionId : CollectionEntity.unknownName,
          isSynced: true,
          updatedAt: DateTime.now(),
        ).toJsonForLocal(),
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }

    for (final cardInDeck in deck.cards) {
      await txn.insert(
        table: 'cards',
        data: cardInDeck.card.toJsonForLocal(),
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }

    await txn.insertBatch(
      table: 'cardsInDeck',
      dataList: deck.toJsonForCardsInDeck(),
    );
  }
}
