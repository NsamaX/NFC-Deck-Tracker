import '_sqlite_service.dart';

import '../../model/page.dart';

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
