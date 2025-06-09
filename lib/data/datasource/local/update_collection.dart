import '../../model/collection.dart';

import '@sqlite_service.dart';

class UpdateCollectionLocalDatasource {
  final SQLiteService _sqliteService;

  UpdateCollectionLocalDatasource(this._sqliteService);

  Future<void> updateCollection({
    required CollectionModel collection,
  }) async {
    await _sqliteService.update(
      table: 'collections',
      data: collection.toJson(),
      where: 'collectionId = ?',
      whereArgs: [collection.collectionId],
    );
  }
}
