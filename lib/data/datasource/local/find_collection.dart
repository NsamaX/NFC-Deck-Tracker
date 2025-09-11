import '../../model/collection.dart';

import '@sqlite_service.dart';

class FindCollectionLocalDatasource {
  final SQLiteService _sqliteService;

  FindCollectionLocalDatasource(this._sqliteService);

  Future<CollectionModel?> find({
    required String collectionId,
  }) async {
    final result = await _sqliteService.getTable(
      table: 'collections',
      where: 'collectionId = ?',
      whereArgs: [collectionId],
    );

    if (result.isEmpty) return null;

    return CollectionModel.fromJson(result.first);
  }
}
