import '@sqlite_service.dart';

import '../../model/page.dart';

class UpdatePageLocalDatasource {
  final SQLiteService _sqliteService;

  UpdatePageLocalDatasource(this._sqliteService);

  Future<void> updatePage({
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
