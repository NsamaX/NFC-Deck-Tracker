import 'package:nfc_deck_tracker/.config/game.dart';

import '../../model/card.dart';

import 'sqlite_service.dart';

class CardLocalDatasource {
  final SQLiteService _sqliteService;
  final bool Function(String collectionId) _isBuiltIn;

  CardLocalDatasource(
    this._sqliteService, {
    bool Function(String collectionId)? isBuiltIn,
  }) : _isBuiltIn = isBuiltIn ?? GameConfig.instance.isSupported;

  Future<int> countByName({
    required String collectionId,
    required String name,
  }) async {
    final result = await _sqliteService.getTable(
      table: 'cards',
      where: 'collectionId = ? AND name = ?',
      whereArgs: [collectionId, name],
    );
    return result.length;
  }

  Future<void> create({
    required CardModel card,
  }) async {
    await _sqliteService.insert(
      table: 'cards',
      data: card.toJsonForLocal(),
    );
  }

  Future<void> delete({
    required String collectionId,
    required String cardId,
  }) async {
    await _sqliteService.delete(
      table: 'cards',
      where: 'collectionId = ? AND cardId = ?',
      whereArgs: [collectionId, cardId],
    );
  }

  Future<List<CardModel>> fetch({
    required String collectionId,
  }) async {
    final result = await _sqliteService.getTable(
      table: 'cards',
      where: 'collectionId = ?',
      whereArgs: [collectionId],
    );
    return result.map((row) => CardModel.fromJson(row)).toList();
  }

  Future<List<CardModel>> fetchUsedDistinct() async {
    final result = await _sqliteService.queryTable(
      sql: """
        SELECT DISTINCT c.*
        FROM cards c
        JOIN cardsInDeck cd ON c.collectionId = cd.collectionId AND c.cardId = cd.cardId;
      """,
    );
    return result.map((row) => CardModel.fromJson(row)).toList();
  }

  Future<List<CardModel>> fetchUserCards() async {
    final result = await _sqliteService.getTable(table: 'cards');
    return result
        .map(CardModel.fromJson)
        .where((c) => !_isBuiltIn(c.collectionId))
        .toList();
  }

  Future<CardModel?> find({
    required String collectionId,
    required String cardId,
  }) async {
    final result = await _sqliteService.getTable(
      table: 'cards',
      where: 'collectionId = ? AND cardId = ?',
      whereArgs: [collectionId, cardId],
    );

    if (result.isEmpty) return null;

    return CardModel.fromJson(result.first);
  }

  Future<void> save({
    required List<CardModel> cards,
  }) async {
    final cardsJson = cards.map((card) => card.toJsonForLocal()).toList();
    await _sqliteService.upsertBatch(
      table: 'cards',
      dataList: cardsJson,
      keyColumns: const ['collectionId', 'cardId'],
    );
  }

  Future<void> update({
    required CardModel card,
  }) async {
    await _sqliteService.update(
      table: 'cards',
      data: card.toJsonForLocal(),
      where: 'collectionId = ? AND cardId = ?',
      whereArgs: [card.collectionId, card.cardId],
    );
  }
}
