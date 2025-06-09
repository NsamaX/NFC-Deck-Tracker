import '../../model/collection.dart';

import '@sqlite_service.dart';

class FetchCollectionLocalDatasource {
  final SQLiteService _sqliteService;

  FetchCollectionLocalDatasource(this._sqliteService);

  Future<List<CollectionModel>> fetchCollection() async {
    final result = await _sqliteService.getTable(
      table: 'collections',
    );
    return result.map((row) => CollectionModel.fromJson(row)).toList();
  }
}
