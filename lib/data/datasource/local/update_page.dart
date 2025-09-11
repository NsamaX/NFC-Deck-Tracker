import '../../model/page.dart';

import '@sqlite_service.dart';

class UpdatePageLocalDatasource {
  final SQLiteService _sqliteService;

  UpdatePageLocalDatasource(this._sqliteService);

  Future<void> update({
    required PageModel page,
  }) async {
    await _sqliteService.update(
      table: 'pages',
      data: page.toJson(),
      where: 'collectionId = ?',
      whereArgs: [page.collectionId],
    );
  }
}
