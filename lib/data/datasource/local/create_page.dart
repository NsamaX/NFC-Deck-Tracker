import '../../model/page.dart';

import '@sqlite_service.dart';

class CreatePageLocalDatasource {
  final SQLiteService _sqliteService;

  CreatePageLocalDatasource(this._sqliteService);

  Future<void> createPage({
    required PageModel page,
  }) async {
    await _sqliteService.insert(
      table: 'pages',
      data: page.toJson(),
    );
  }
}
