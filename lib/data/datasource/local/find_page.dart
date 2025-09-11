import 'dart:convert';

import '@sqlite_service.dart';

class FindPageLocalDatasource {
  final SQLiteService _sqliteService;

  FindPageLocalDatasource(this._sqliteService);

  Future<Map<String, dynamic>> find({
    required String collectionId,
  }) async {
    final result = await _sqliteService.getTable(
      table: 'pages',
      where: 'collectionId = ?',
      whereArgs: [collectionId],
    );

    if (result.isEmpty) return {};

    final pagingJson = result.first['paging'];
    return json.decode(pagingJson);
  }
}
