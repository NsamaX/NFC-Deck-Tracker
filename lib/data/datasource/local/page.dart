import '../../model/page.dart';
import 'dart:convert';

import '@sqlite_service.dart';

class PageLocalDatasource {
  final SQLiteService _sqliteService;

  PageLocalDatasource(this._sqliteService);

  Future<void> create({
    required PageModel page,
  }) async {
    await _sqliteService.insert(
      table: 'pages',
      data: page.toJson(),
    );
  }

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
