import '@sqlite_service.dart';

import '../../model/card.dart';

class FindCardLocalDatasource {
  final SQLiteService _sqliteService;

  FindCardLocalDatasource(this._sqliteService);

  Future<CardModel?> findCard({
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
