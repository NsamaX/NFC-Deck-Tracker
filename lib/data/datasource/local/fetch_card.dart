import '@sqlite_service.dart';

import '../../model/card.dart';

class FetchCardLocalDatasource {
  final SQLiteService _sqliteService;

  FetchCardLocalDatasource(this._sqliteService);

  Future<List<CardModel>> fetchCard({
    required String collectionId,
  }) async {
    final result = await _sqliteService.getTable(
      table: 'cards',
      where: 'collectionId = ?',
      whereArgs: [collectionId],
    );
    return result.map((row) => CardModel.fromJson(row)).toList();
  }
}
