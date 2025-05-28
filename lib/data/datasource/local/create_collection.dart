import '_sqlite_service.dart';

import '../../model/collection.dart';

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
