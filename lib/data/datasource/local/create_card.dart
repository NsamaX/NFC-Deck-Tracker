import '../../model/card.dart';

import '@sqlite_service.dart';

class CreateCardLocalDatasource {
  final SQLiteService _sqliteService;

  CreateCardLocalDatasource(this._sqliteService);

  Future<void> create({
    required CardModel card,
  }) async {
    await _sqliteService.insert(
      table: 'cards',
      data: card.toJsonForLocal(),
    );
  }
}
