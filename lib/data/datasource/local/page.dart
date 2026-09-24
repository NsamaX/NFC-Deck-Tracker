import 'dart:convert';

import '../../model/page.dart';

import 'sqlite_service.dart';

class PageLocalDatasource {
  final SQLiteService _sqliteService;

  PageLocalDatasource(this._sqliteService);

  Future<Map<String, dynamic>> find({
    required String collectionId,
  }) async {
    final result = await _sqliteService.getTable(
      table: 'pages',
      where: 'collectionId = ?',
      whereArgs: [collectionId],
    );

    if (result.isEmpty) return {};

    return Map<String, dynamic>.from(json.decode(result.first['paging']));
  }

  Future<void> save({
    required PageModel page,
  }) async {
    await _sqliteService.transaction((txn) async {
      await txn.delete(
        table: 'pages',
        where: 'collectionId = ?',
        whereArgs: [page.collectionId],
      );
      await txn.insert(table: 'pages', data: page.toJson());
    });
  }
}
