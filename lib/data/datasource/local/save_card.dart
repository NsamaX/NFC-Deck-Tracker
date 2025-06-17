import '../../model/card.dart';

import '@sqlite_service.dart';

class SaveCardLocalDatasource {
  final SQLiteService _sqliteService;

  SaveCardLocalDatasource(this._sqliteService);

  Future<void> save({
    required List<CardModel> cards,
  }) async {
    final cardsJson = cards.map((card) => card.toJson()).toList();
    await _sqliteService.insertBatch(
      table: 'cards',
      dataList: cardsJson,
    );
  }
}
