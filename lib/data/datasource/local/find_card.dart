import '../../model/card.dart';

import '@sqlite_service.dart';

class FindCardLocalDatasource {
  final SQLiteService _sqliteService;

  FindCardLocalDatasource(this._sqliteService);

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
}
