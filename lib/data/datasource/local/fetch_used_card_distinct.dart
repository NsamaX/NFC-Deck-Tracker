import '_sqlite_service.dart';

import '../../model/card.dart';

class FetchUsedCardDistinctLocalDatasource {
  final SQLiteService _sqliteService;

  FetchUsedCardDistinctLocalDatasource(this._sqliteService);

  Future<List<CardModel>> fetchUsedCardDistinct() async {
    final result = await _sqliteService.queryTable(
      sql: 
      """
        SELECT DISTINCT c.*
        FROM cards c
        JOIN cardsInDeck cd ON c.collectionId = cd.collectionId AND c.cardId = cd.cardId;
      """,
    );
    return result.map((row) => CardModel.fromJson(row)).toList();
  }
}
