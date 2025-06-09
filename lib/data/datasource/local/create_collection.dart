import '../../model/collection.dart';

import '@sqlite_service.dart';

class CreateCollectionLocalDatasource {
  final SQLiteService _sqliteService;

  CreateCollectionLocalDatasource(this._sqliteService);

  Future<void> createCollection({
    required CollectionModel collection,
  }) async {
    await _sqliteService.insert(
      table: 'collections',
      data: collection.toJson(),
    );
  }
}
